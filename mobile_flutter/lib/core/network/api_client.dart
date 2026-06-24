import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    // Determine base URL based on platform
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8080/api';
    } else {
      baseUrl = 'http://localhost:8080/api';
    }
  }

  late final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  String? _cachedToken;

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _cachedToken = token;
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    _cachedToken = null;
  }

  Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers(token));
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _headers(token),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: _headers(token),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _headers(token));
  }
}
