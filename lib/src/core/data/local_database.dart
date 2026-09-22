import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/analysis/data/demo_categories.dart';
import '../../features/analysis/domain/vastu_measurement.dart';
import '../../features/reports/domain/vastu_report.dart';

class LocalDatabase {
  LocalDatabase._();

  static final instance = LocalDatabase._();
  Database? _database;

  Future<void> initialize() async {
    if (_database != null) return;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      p.join(root, 'vastusign.db'),
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE profiles(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE properties(
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            address TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE measurements(
            id TEXT PRIMARY KEY,
            property_id TEXT NOT NULL,
            category_id TEXT NOT NULL,
            angle REAL NOT NULL,
            direction TEXT NOT NULL,
            broad_direction TEXT NOT NULL,
            score INTEGER NOT NULL,
            rating TEXT NOT NULL,
            accuracy REAL NOT NULL,
            captured_at TEXT NOT NULL,
            boundary_uncertain INTEGER NOT NULL DEFAULT 0,
            photo_path TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE reports(
            id TEXT PRIMARY KEY,
            property_id TEXT NOT NULL,
            overall_score INTEGER NOT NULL,
            rule_version TEXT NOT NULL,
            report_json TEXT NOT NULL,
            generated_at TEXT NOT NULL,
            pdf_path TEXT
          )
        ''');
        await _createCloudSessionTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createCloudSessionTable(database);
      },
    );
    await _ensureDefaults();
  }

  Database get _db {
    final database = _database;
    if (database == null) {
      throw StateError('LocalDatabase.initialize() must run before use.');
    }
    return database;
  }

  Future<void> _ensureDefaults() async {
    final now = DateTime.now().toIso8601String();
    await _db.insert(
      'profiles',
      {'id': 'local-user', 'name': 'Guest', 'email': null, 'created_at': now},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await _db.insert(
      'properties',
      {
        'id': 'my-property',
        'profile_id': 'local-user',
        'name': 'My Property',
        'type': 'residential',
        'address': null,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> upsertMeasurement(VastuMeasurement item) async {
    await _db.insert(
      'measurements',
      {
        'id': item.id,
        'property_id': 'my-property',
        'category_id': item.category.id,
        'angle': item.angle,
        'direction': item.direction,
        'broad_direction': item.broadDirection,
        'score': item.score,
        'rating': item.rating.name,
        'accuracy': item.accuracy,
        'captured_at': item.capturedAt.toIso8601String(),
        'boundary_uncertain': item.isBoundaryUncertain ? 1 : 0,
        'photo_path': item.photoPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VastuMeasurement>> loadMeasurements() async {
    final rows = await _db.query(
      'measurements',
      where: 'property_id = ?',
      whereArgs: ['my-property'],
      orderBy: 'captured_at ASC',
    );
    final categories = {for (final item in demoCategories) item.id: item};
    return rows.map((row) {
      final category = categories[row['category_id']];
      if (category == null) return null;
      final ratingName = row['rating'] as String;
      return VastuMeasurement(
        id: row['id'] as String,
        category: category,
        angle: (row['angle'] as num).toDouble(),
        direction: row['direction'] as String,
        broadDirection: row['broad_direction'] as String,
        score: row['score'] as int,
        rating: VastuRating.values.firstWhere(
          (item) => item.name == ratingName,
          orElse: () => VastuRating.attention,
        ),
        accuracy: (row['accuracy'] as num).toDouble(),
        capturedAt: DateTime.parse(row['captured_at'] as String),
        isBoundaryUncertain: row['boundary_uncertain'] == 1,
        photoPath: row['photo_path'] as String?,
      );
    }).whereType<VastuMeasurement>().toList(growable: false);
  }

  Future<void> deleteMeasurement(String id) async {
    await _db.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearMeasurements() async {
    await _db.delete(
      'measurements',
      where: 'property_id = ?',
      whereArgs: ['my-property'],
    );
  }

  Future<void> saveReport(VastuReport report, {String? pdfPath}) async {
    final payload = {
      'id': report.id,
      'title': report.title,
      'propertyLabel': report.propertyLabel,
      'overallScore': report.overallScore,
      'ruleSetVersion': report.ruleSetVersion,
      'templateVersion': report.templateVersion,
      'observations': report.observations.map((item) => {
        'category': item.measurement.category.name,
        'categoryId': item.measurement.category.id,
        'direction': item.measurement.direction,
        'angle': item.measurement.angle,
        'score': item.measurement.score,
        'rating': item.measurement.rating.name,
        'effects': item.effects,
        'remedies': item.remedies,
        'priority': item.priority,
      }).toList(),
    };
    await _db.insert(
      'reports',
      {
        'id': report.id,
        'property_id': 'my-property',
        'overall_score': report.overallScore,
        'rule_version': report.ruleSetVersion,
        'report_json': jsonEncode(payload),
        'generated_at': report.generatedAt.toIso8601String(),
        'pdf_path': pdfPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> listReports() {
    return _db.query('reports', orderBy: 'generated_at DESC');
  }

  Future<void> saveCloudSession({
    required String token,
    required String userId,
    required String name,
    required String email,
  }) async {
    await _db.insert(
      'cloud_session',
      {
        'id': 1,
        'token': token,
        'user_id': userId,
        'name': name,
        'email': email,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Object?>?> loadCloudSession() async {
    final rows = await _db.query('cloud_session', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> clearCloudSession() => _db.delete('cloud_session');

  Future<void> deleteAllUserData() async {
    await _db.transaction((transaction) async {
      await transaction.delete('reports');
      await transaction.delete('measurements');
      await transaction.delete('cloud_session');
    });
  }

  static Future<void> _createCloudSessionTable(Database database) {
    return database.execute('''
      CREATE TABLE IF NOT EXISTS cloud_session(
        id INTEGER PRIMARY KEY CHECK(id = 1),
        token TEXT NOT NULL,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }
}
