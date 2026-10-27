import 'dart:convert';

import 'package:http/http.dart' as http;

const baseUrl = 'https://api-pdm.sublimecipher.com';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => '$statusCode: $message';
}

/// Talks HTTP to the course API: tokens, headers, status codes and JSON.
/// It knows nothing about islands, forecasts or users.
class ApiClient {
  ApiClient({required this.clientId, required this.clientSecret});

  final String clientId;
  final String clientSecret;
  String? _token; // the app's token, from clientId and clientSecret
  String? userToken; // the logged-in user's token, set by AuthRepository

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> put(String path) => _send('PUT', path);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  /// POST with a JSON body and no token: login, register, refresh, logout.
  /// Returns null when the API answers 204 No Content.
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    _check(response);
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  /// GET, PUT and DELETE come through here, always with a token.
  Future<dynamic> _send(String method, String path) async {
    final response = await _request(method, path);
    // TODO 2: on a 401, renew the session and repeat the request once
    _check(response);
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  /// A new request each time: an http.Request can only be sent once.
  Future<http.Response> _request(String method, String path) async {
    // the user's token when someone is logged in; otherwise, the app's
    final token = userToken ?? (_token ??= await _fetchToken());
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['Authorization'] = 'Bearer $token';
    final streamed = await request.send().timeout(const Duration(seconds: 10));
    return http.Response.fromStream(streamed);
  }

  Future<String> _fetchToken() async {
    final json = await post('/v1/auth/token', {
      'clientId': clientId,
      'clientSecret': clientSecret,
    }) as Map<String, dynamic>;
    return json['accessToken'] as String;
  }

  void _check(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode == 401) {
      _token = null; // expired or wrong: ask for a new one next time
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final error = body['error'] as Map<String, dynamic>;
    throw ApiException(response.statusCode, error['message'] as String);
  }
}
