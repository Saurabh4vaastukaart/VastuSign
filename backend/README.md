# VastuSign API

Zero-dependency Node.js API using the built-in SQLite driver. It provides:

- email/password registration and login;
- signed bearer sessions;
- user-owned properties;
- property measurements;
- server-generated, versioned reports;
- SQLite persistence with foreign keys and WAL mode.

Run with Node 24 or newer:

```bash
AUTH_SECRET="replace-with-a-long-random-value" npm start
```

The default port is `8787`. Set `PORT` and `DATABASE_PATH` as needed. Check
`GET /health` before configuring the mobile application's production API URL.

## Docker deployment

```bash
docker build -t vastusign-api .
docker run --rm -p 8787:8787 \
  -e AUTH_SECRET="replace-with-at-least-32-random-characters" \
  -v vastusign-data:/data vastusign-api
```

Terminate TLS at the hosting platform or reverse proxy. Use a persistent volume
for `/data`, a unique production `AUTH_SECRET`, and restrict CORS to the app's
actual web origins if a browser client is added. The native Android client does
not rely on browser CORS.

## Routes

- `GET /health`
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `GET|POST /v1/properties`
- `GET|POST /v1/properties/:id/measurements`
- `GET|POST /v1/properties/:id/reports`
