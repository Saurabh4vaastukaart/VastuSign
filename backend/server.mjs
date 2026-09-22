import { createServer } from 'node:http';
import { DatabaseSync } from 'node:sqlite';
import { createHmac, pbkdf2Sync, randomBytes, randomUUID, timingSafeEqual } from 'node:crypto';
import { mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(fileURLToPath(import.meta.url));
const databasePath = resolve(process.env.DATABASE_PATH || `${root}/data/vastusign.sqlite`);
mkdirSync(dirname(databasePath), { recursive: true });
const db = new DatabaseSync(databasePath);
const port = Number(process.env.PORT || 8787);
const secret = process.env.AUTH_SECRET || 'local-development-change-me';

db.exec(`
  PRAGMA journal_mode = WAL;
  PRAGMA foreign_keys = ON;
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    created_at TEXT NOT NULL
  );
  CREATE TABLE IF NOT EXISTS properties (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    address TEXT,
    facing TEXT,
    created_at TEXT NOT NULL
  );
  CREATE TABLE IF NOT EXISTS measurements (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    category_id TEXT NOT NULL,
    angle REAL NOT NULL,
    direction TEXT NOT NULL,
    broad_direction TEXT NOT NULL,
    accuracy REAL NOT NULL,
    is_true_north INTEGER NOT NULL DEFAULT 0,
    boundary_uncertain INTEGER NOT NULL DEFAULT 0,
    photo_url TEXT,
    captured_at TEXT NOT NULL
  );
  CREATE TABLE IF NOT EXISTS reports (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    overall_score INTEGER NOT NULL,
    rule_version TEXT NOT NULL,
    payload TEXT NOT NULL,
    generated_at TEXT NOT NULL
  );
`);

const json = (response, status, body) => {
  response.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'access-control-allow-origin': '*',
    'access-control-allow-headers': 'authorization, content-type',
    'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
  });
  response.end(JSON.stringify(body));
};

async function readBody(request) {
  let raw = '';
  for await (const chunk of request) {
    raw += chunk;
    if (raw.length > 1_000_000) throw new Error('Request body is too large.');
  }
  if (!raw) return {};
  return JSON.parse(raw);
}

function hashPassword(password, salt) {
  return pbkdf2Sync(password, salt, 120_000, 32, 'sha256').toString('hex');
}

function tokenFor(userId) {
  const payload = Buffer.from(JSON.stringify({ userId, exp: Date.now() + 30 * 86_400_000 })).toString('base64url');
  const signature = createHmac('sha256', secret).update(payload).digest('base64url');
  return `${payload}.${signature}`;
}

function authenticate(request) {
  const token = request.headers.authorization?.replace(/^Bearer\s+/i, '');
  if (!token) return null;
  const [payload, signature] = token.split('.');
  if (!payload || !signature) return null;
  const expected = createHmac('sha256', secret).update(payload).digest();
  const supplied = Buffer.from(signature, 'base64url');
  if (expected.length !== supplied.length || !timingSafeEqual(expected, supplied)) return null;
  const value = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));
  return value.exp > Date.now() ? value.userId : null;
}

function propertyForUser(propertyId, userId) {
  return db.prepare('SELECT * FROM properties WHERE id = ? AND user_id = ?').get(propertyId, userId);
}

const preferences = {
  main_entrance: { good: ['N', 'NE', 'E'], balanced: ['NW'], attention: ['SE', 'W'] },
  kitchen: { good: ['SE'], balanced: ['NW', 'E'], attention: ['S', 'W'] },
  master_bedroom: { good: ['SW'], balanced: ['S', 'W'], attention: ['NW'] },
  bedroom: { good: ['SW', 'S', 'W'], balanced: ['NW', 'E'], attention: ['N'] },
  toilet: { good: ['NW', 'W'], balanced: ['S', 'SE'], attention: ['N', 'E'] },
  pooja_room: { good: ['NE', 'N', 'E'], balanced: ['NW'], attention: ['SE', 'W'] },
  drawing_room: { good: ['N', 'NE', 'E'], balanced: ['NW'], attention: ['SE', 'S'] },
  dining_room: { good: ['W', 'NW'], balanced: ['E', 'N'], attention: ['S'] },
  study_room: { good: ['NE', 'E', 'N'], balanced: ['NW'], attention: ['W', 'S'] },
  guest_room: { good: ['NW'], balanced: ['N', 'W'], attention: ['SE'] },
  staircase: { good: ['S', 'SW', 'W'], balanced: ['SE'], attention: ['N', 'E'] },
  electrical: { good: ['SE'], balanced: ['S'], attention: ['N', 'NE'] },
};

function scoreFor(categoryId, direction) {
  const rule = preferences[categoryId] || { good: ['N', 'NE', 'E'], balanced: ['NW', 'SE'], attention: ['W', 'S'] };
  if (rule.good.includes(direction)) return 86;
  if (rule.balanced.includes(direction)) return 68;
  if (rule.attention.includes(direction)) return 48;
  return 28;
}

const server = createServer(async (request, response) => {
  try {
    if (request.method === 'OPTIONS') return json(response, 204, {});
    const url = new URL(request.url, `http://${request.headers.host || 'localhost'}`);
    const path = url.pathname;

    if (request.method === 'GET' && path === '/health') {
      return json(response, 200, { status: 'ok', service: 'vastusign-api', ruleVersion: 'starter-rules-2026.09' });
    }

    if (request.method === 'POST' && path === '/v1/auth/register') {
      const body = await readBody(request);
      if (!body.name || !body.email || typeof body.password !== 'string' || body.password.length < 8) {
        return json(response, 400, { error: 'Name, email and a password of at least 8 characters are required.' });
      }
      const id = randomUUID();
      const salt = randomBytes(16).toString('hex');
      try {
        db.prepare('INSERT INTO users VALUES (?, ?, ?, ?, ?, ?)').run(
          id, String(body.name).trim(), String(body.email).trim().toLowerCase(),
          hashPassword(body.password, salt), salt, new Date().toISOString(),
        );
      } catch (error) {
        if (String(error).includes('UNIQUE')) return json(response, 409, { error: 'An account already exists for this email.' });
        throw error;
      }
      return json(response, 201, { token: tokenFor(id), user: { id, name: body.name, email: body.email } });
    }

    if (request.method === 'POST' && path === '/v1/auth/login') {
      const body = await readBody(request);
      const user = db.prepare('SELECT * FROM users WHERE email = ?').get(String(body.email || '').trim().toLowerCase());
      if (!user || hashPassword(String(body.password || ''), user.salt) !== user.password_hash) {
        return json(response, 401, { error: 'Invalid email or password.' });
      }
      return json(response, 200, { token: tokenFor(user.id), user: { id: user.id, name: user.name, email: user.email } });
    }

    const userId = authenticate(request);
    if (!userId) return json(response, 401, { error: 'Authentication required.' });

    if (request.method === 'GET' && path === '/v1/properties') {
      const properties = db.prepare('SELECT * FROM properties WHERE user_id = ? ORDER BY created_at DESC').all(userId);
      return json(response, 200, { properties });
    }

    if (request.method === 'POST' && path === '/v1/properties') {
      const body = await readBody(request);
      if (!body.name || !body.type) return json(response, 400, { error: 'Property name and type are required.' });
      const property = {
        id: randomUUID(), user_id: userId, name: String(body.name), type: String(body.type),
        address: body.address ? String(body.address) : null,
        facing: body.facing ? String(body.facing) : null,
        created_at: new Date().toISOString(),
      };
      db.prepare('INSERT INTO properties VALUES (?, ?, ?, ?, ?, ?, ?)').run(...Object.values(property));
      return json(response, 201, { property });
    }

    const measurementMatch = path.match(/^\/v1\/properties\/([^/]+)\/measurements$/);
    if (measurementMatch && request.method === 'GET') {
      if (!propertyForUser(measurementMatch[1], userId)) return json(response, 404, { error: 'Property not found.' });
      const measurements = db.prepare('SELECT * FROM measurements WHERE property_id = ? ORDER BY captured_at').all(measurementMatch[1]);
      return json(response, 200, { measurements });
    }
    if (measurementMatch && request.method === 'POST') {
      const propertyId = measurementMatch[1];
      if (!propertyForUser(propertyId, userId)) return json(response, 404, { error: 'Property not found.' });
      const body = await readBody(request);
      const required = ['categoryId', 'angle', 'direction', 'broadDirection', 'accuracy'];
      if (required.some((key) => body[key] === undefined)) return json(response, 400, { error: `Required: ${required.join(', ')}` });
      const item = {
        id: body.id || randomUUID(), property_id: propertyId, category_id: String(body.categoryId),
        angle: Number(body.angle), direction: String(body.direction), broad_direction: String(body.broadDirection),
        accuracy: Number(body.accuracy), is_true_north: body.isTrueNorth ? 1 : 0,
        boundary_uncertain: body.boundaryUncertain ? 1 : 0,
        photo_url: body.photoUrl ? String(body.photoUrl) : null,
        captured_at: body.capturedAt || new Date().toISOString(),
      };
      db.prepare('INSERT OR REPLACE INTO measurements VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').run(...Object.values(item));
      return json(response, 201, { measurement: item });
    }

    const reportMatch = path.match(/^\/v1\/properties\/([^/]+)\/reports$/);
    if (reportMatch && request.method === 'POST') {
      const propertyId = reportMatch[1];
      if (!propertyForUser(propertyId, userId)) return json(response, 404, { error: 'Property not found.' });
      const rows = db.prepare('SELECT * FROM measurements WHERE property_id = ? ORDER BY captured_at').all(propertyId);
      if (!rows.length) return json(response, 422, { error: 'At least one measurement is required.' });
      const observations = rows.map((item, index) => {
        const score = scoreFor(item.category_id, item.broad_direction);
        return {
          priority: index + 1, categoryId: item.category_id, direction: item.direction,
          broadDirection: item.broad_direction, angle: item.angle, score,
          rating: score >= 75 ? 'good' : score >= 60 ? 'balanced' : score >= 40 ? 'attention' : 'critical',
        };
      }).sort((a, b) => a.score - b.score).map((item, index) => ({ ...item, priority: index + 1 }));
      const overallScore = Math.round(observations.reduce((sum, item) => sum + item.score, 0) / observations.length);
      const report = { id: `VS-${Date.now()}`, propertyId, overallScore, ruleVersion: 'starter-rules-2026.09', observations, generatedAt: new Date().toISOString() };
      db.prepare('INSERT INTO reports VALUES (?, ?, ?, ?, ?, ?)').run(report.id, propertyId, overallScore, report.ruleVersion, JSON.stringify(report), report.generatedAt);
      return json(response, 201, { report });
    }
    if (reportMatch && request.method === 'GET') {
      if (!propertyForUser(reportMatch[1], userId)) return json(response, 404, { error: 'Property not found.' });
      const reports = db.prepare('SELECT * FROM reports WHERE property_id = ? ORDER BY generated_at DESC').all(reportMatch[1]).map((row) => JSON.parse(row.payload));
      return json(response, 200, { reports });
    }

    return json(response, 404, { error: 'Route not found.' });
  } catch (error) {
    console.error(error);
    return json(response, 500, { error: 'Unexpected server error.' });
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`VastuSign API listening on http://0.0.0.0:${port}`);
});

export { server };
