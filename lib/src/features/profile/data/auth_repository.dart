import '../../../core/data/local_database.dart';
import '../../../core/network/api_client.dart';
import '../../analysis/domain/vastu_measurement.dart';

class CloudSession {
  const CloudSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  final String token;
  final String userId;
  final String name;
  final String email;
}

class AuthRepository {
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<CloudSession?> currentSession() async {
    final row = await LocalDatabase.instance.loadCloudSession();
    if (row == null) return null;
    return CloudSession(
      token: row['token'] as String,
      userId: row['user_id'] as String,
      name: row['name'] as String,
      email: row['email'] as String,
    );
  }

  Future<CloudSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate('/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<CloudSession> login({
    required String email,
    required String password,
  }) {
    return _authenticate('/v1/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<CloudSession> _authenticate(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client.post(path, body);
    final user = response['user'] as Map<String, dynamic>;
    final session = CloudSession(
      token: response['token'] as String,
      userId: user['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
    );
    await LocalDatabase.instance.saveCloudSession(
      token: session.token,
      userId: session.userId,
      name: session.name,
      email: session.email,
    );
    return session;
  }

  Future<int> syncMeasurements(
    CloudSession session,
    List<VastuMeasurement> measurements,
  ) async {
    final propertiesResponse = await _client.get(
      '/v1/properties',
      token: session.token,
    );
    final properties = propertiesResponse['properties'] as List<dynamic>;
    Map<String, dynamic> property;
    if (properties.isEmpty) {
      final created = await _client.post(
        '/v1/properties',
        {'name': 'My Property', 'type': 'residential'},
        token: session.token,
      );
      property = created['property'] as Map<String, dynamic>;
    } else {
      property = properties.first as Map<String, dynamic>;
    }

    final propertyId = property['id'] as String;
    for (final item in measurements) {
      await _client.post(
        '/v1/properties/$propertyId/measurements',
        {
          'id': item.id,
          'categoryId': item.category.id,
          'angle': item.angle,
          'direction': item.direction,
          'broadDirection': item.broadDirection,
          'accuracy': item.accuracy,
          'boundaryUncertain': item.isBoundaryUncertain,
          'capturedAt': item.capturedAt.toIso8601String(),
        },
        token: session.token,
      );
    }
    return measurements.length;
  }

  Future<void> signOut() => LocalDatabase.instance.clearCloudSession();
}
