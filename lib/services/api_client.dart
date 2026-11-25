import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Semua panggilan HTTP ke backend Django lewat kelas ini.
/// Header ditulis sebagai string biasa (bukan `HttpHeaders` dari `dart:io`)
/// supaya tetap bisa di-build untuk Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers({String? token}) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Token $token',
  };

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: {'Accept': 'application/json'},
    );
    _ensureSuccess(response);
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: _headers(token: token),
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);
    return Project.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: _headers(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['token'] as String;
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: _headers(token: token),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Body mentah tidak diteruskan: saat DEBUG=True isinya bisa berupa
      // halaman error HTML atau stack trace.
      throw ApiException(
        response.statusCode,
        'Permintaan gagal (HTTP ${response.statusCode}).',
      );
    }
  }
}
