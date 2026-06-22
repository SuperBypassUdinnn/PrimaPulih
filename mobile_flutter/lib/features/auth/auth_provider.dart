// AuthProvider — State Management untuk Autentikasi
// Menyimulasikan login/register dengan mock data lokal

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data_source.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  PatientModel? _currentPatient;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  PatientModel? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isPatient => _currentUser?.role == UserRole.patient;

  /// Login dengan email & password (mock: cek hanya email)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final user = MockDataSource.getUserByEmail(email);
    if (user == null) {
      _errorMessage = 'Email tidak ditemukan.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock: password apapun diterima jika email valid
    _currentUser = user;
    _currentPatient = MockDataSource.getPatientByUserId(user.id);

    // Simpan sesi lokal
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role.name);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Register pasien baru (mock: tambah ke list in-memory)
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Cek duplikat email
    final existing = MockDataSource.getUserByEmail(email);
    if (existing != null) {
      _errorMessage = 'Email sudah terdaftar.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Buat user & patient baru (in-memory)
    final newUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      role: role,
    );
    MockDataSource.users.add(newUser);

    if (role == UserRole.patient) {
      final newPatient = PatientModel(
        id: 'pat-${DateTime.now().millisecondsSinceEpoch}',
        userId: newUser.id,
        fullName: fullName,
        icuDischargeDate: DateTime.now(),
      );
      MockDataSource.patients.add(newPatient);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Restore sesi dari SharedPreferences
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) return;

    try {
      _currentUser = MockDataSource.users.firstWhere((u) => u.id == userId);
      _currentPatient = MockDataSource.getPatientByUserId(userId);
      notifyListeners();
    } catch (_) {
      // Sesi tidak valid, abaikan
    }
  }

  /// Logout
  Future<void> logout() async {
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
