// AuthProvider — State Management untuk Autentikasi
// Terhubung ke Backend Golang

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  
  UserModel? _currentUser;
  PatientModel? _currentPatient;
  // TODO: Add HealthWorkerModel if needed later
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  PatientModel? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isPatient => _currentUser?.role == UserRole.patient;

  /// Login dengan email & password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['user_id'];
        final roleStr = data['role'];
        final profileId = data['profile_id'];

        await _api.saveToken(token);

        final role = roleStr == 'patient' ? UserRole.patient : UserRole.healthWorker;

        _currentUser = UserModel(id: userId, email: email, role: role);

        if (role == UserRole.patient) {
          _currentPatient = PatientModel(
            id: profileId ?? '',
            userId: userId,
            fullName: 'Pasien', // We can fetch detailed profile later if needed
            icuDischargeDate: DateTime.now(),
          );
        }

        // Simpan sesi lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', role.name);
        await prefs.setString('profile_id', profileId ?? '');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Login gagal';
      }
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Register pasien atau nakes
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role == UserRole.patient ? 'patient' : 'health_worker',
      };

      if (role == UserRole.patient) {
        final now = DateTime.now();
        final year = now.year.toString();
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        body['icu_discharge_date'] = '$year-$month-$day';
      } else {
        body['specialization'] = 'Umum'; // Default
      }

      final response = await _api.post('/auth/register', body: body);

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Registrasi gagal';
      }
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Restore sesi dari SharedPreferences & Token Storage
  Future<void> restoreSession() async {
    final token = await _api.getToken();
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final email = prefs.getString('user_email');
    final roleStr = prefs.getString('user_role');
    final profileId = prefs.getString('profile_id');

    if (userId == null || email == null || roleStr == null) return;

    try {
      final role = UserRole.values.firstWhere((e) => e.name == roleStr);
      _currentUser = UserModel(id: userId, email: email, role: role);
      if (role == UserRole.patient) {
        _currentPatient = PatientModel(
          id: profileId ?? '',
          userId: userId,
          fullName: 'Pasien',
          icuDischargeDate: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (_) {
      // Sesi tidak valid, abaikan
    }
  }

  /// Logout
  Future<void> logout() async {
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _currentPatient = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
