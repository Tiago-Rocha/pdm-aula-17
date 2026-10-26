import '../models/user.dart';
import 'api_client.dart';

/// User accounts in the course API. The app identifies itself with its
/// clientId and clientSecret; the person with email and password.
class AuthRepository {
  AuthRepository(this._api); // injected, not created here

  final ApiClient _api;

  Future<Session> login(String email, String password) async {
    final json = await _api.post('/v1/auth/login', {
      'clientId': _api.clientId,
      'clientSecret': _api.clientSecret,
      'email': email,
      'password': password,
    });
    return _keep(json);
  }

  Future<Session> register(String name, String email, String password) async {
    final json = await _api.post('/v1/auth/register', {
      'clientId': _api.clientId,
      'clientSecret': _api.clientSecret,
      'name': name,
      'email': email,
      'password': password,
    });
    return _keep(json);
  }

  /// A new access token. The refresh token stays the same.
  Future<Session> refresh(String refreshToken) async {
    final json = await _api.post('/v1/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return _keep(json);
  }

  /// The refresh token stops working. Repeating it does no harm.
  Future<void> logout(String refreshToken) async {
    _api.userToken = null; // from now on, requests go as the app
    await _api.post('/v1/auth/logout', {'refreshToken': refreshToken});
  }

  /// Classroom tool: breaks the user's access token, to get a 401
  /// without waiting 15 minutes.
  void spoilToken() => _api.userToken = 'spoiled';

  /// The session from the API. Its access token goes into the ApiClient.
  Session _keep(dynamic json) {
    final session = Session.fromJson(json as Map<String, dynamic>);
    _api.userToken = session.accessToken;
    return session;
  }
}
