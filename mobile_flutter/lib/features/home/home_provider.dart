// MoodProvider & MedicationProvider — State Management Fase P1
// Terhubung ke Backend Golang

import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';

// ─────────────────────────────────────────────
// MOOD TRACKER PROVIDER
// ─────────────────────────────────────────────

class MoodProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  MoodType? _selectedMood;
  bool _isSubmitting = false;
  List<DailyLogModel> _logs = [];

  MoodType? get selectedMood => _selectedMood;
  bool get isSubmitting => _isSubmitting;
  List<DailyLogModel> get logs => List.unmodifiable(_logs);

  Future<void> loadLogs() async {
    try {
      final response = await _api.get('/daily-logs');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _logs = data.map((json) {
          return DailyLogModel(
            id: json['id'],
            patientId: '', // Set by backend relation
            mood: MoodType.values.firstWhere(
              (e) => e.name == json['mood_emoji'],
              orElse: () => MoodType.senang,
            ),
            loggedAt: DateTime.parse(json['logged_at']),
          );
        }).toList();
        notifyListeners();
      }
    } catch (_) {
      // Handle error quietly or add error state
    }
  }

  void selectMood(MoodType mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  Future<bool> submitMood(String patientId) async {
    if (_selectedMood == null) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await _api.post('/daily-logs', body: {
        'mood_emoji': _selectedMood!.name,
      });

      if (response.statusCode == 201) {
        // Reload logs to get the new entry with correct ID and date
        await loadLogs();
        _selectedMood = null;
        _isSubmitting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  DailyLogModel? get todayLog {
    final today = DateTime.now();
    try {
      return _logs.firstWhere(
        (l) =>
            l.loggedAt.year == today.year &&
            l.loggedAt.month == today.month &&
            l.loggedAt.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }

  void reset() {
    _selectedMood = null;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// MEDICATION PROVIDER
// ─────────────────────────────────────────────

class MedicationProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<MedicationModel> _medications = [];
  // Key: medicationId → status hari ini
  final Map<String, bool> _todayStatus = {};
  bool _isLoading = false;

  List<MedicationModel> get medications => List.unmodifiable(_medications);
  bool get isLoading => _isLoading;

  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/medications');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _medications = data.map((json) {
          return MedicationModel(
            id: json['id'],
            patientId: '',
            medicineName: json['medicine_name'],
            timeOfDay: MedTime.values.firstWhere(
              (e) => e.name == json['time_of_day'],
              orElse: () => MedTime.pagi,
            ),
            dosage: 'Sesuai anjuran',
          );
        }).toList();

        // Note: Ideally backend should return today's status in GetMedications.
        // For now, we assume false initially if we can't fetch logs specifically.
        // We could fetch medication logs here if an endpoint exists.
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMedication(String name, MedTime time) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post('/medications', body: {
        'medicine_name': name,
        'time_of_day': time.name,
      });

      if (response.statusCode == 201) {
        await loadMedications();
        return true;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return false;
  }

  bool isChecked(String medicationId) => _todayStatus[medicationId] ?? false;

  Future<void> toggleMedication(String medicationId) async {
    final current = _todayStatus[medicationId] ?? false;
    final newValue = !current;
    
    // Optimistic UI update
    _todayStatus[medicationId] = newValue;
    notifyListeners();

    try {
      final response = await _api.post('/medication-logs', body: {
        'medication_id': medicationId,
        'status': newValue,
      });

      if (response.statusCode != 201) {
        // Revert on failure
        _todayStatus[medicationId] = current;
        notifyListeners();
      }
    } catch (_) {
      // Revert on exception
      _todayStatus[medicationId] = current;
      notifyListeners();
    }
  }

  List<MedicationModel> getMedicationsByTime(MedTime time) {
    return _medications.where((m) => m.timeOfDay == time).toList();
  }

  int get totalChecked =>
      _todayStatus.values.where((v) => v).length;
  int get totalMedications => _medications.length;
}
