// MoodProvider & MedicationProvider — State Management Fase P1

import 'package:flutter/foundation.dart';



import '../../data/models/models.dart';
import '../../data/mock/mock_data_source.dart';

// ─────────────────────────────────────────────
// MOOD TRACKER PROVIDER
// ─────────────────────────────────────────────

class MoodProvider extends ChangeNotifier {
  MoodType? _selectedMood;
  bool _isSubmitting = false;
  List<DailyLogModel> _logs = [];

  MoodType? get selectedMood => _selectedMood;
  bool get isSubmitting => _isSubmitting;
  List<DailyLogModel> get logs => List.unmodifiable(_logs);

  void loadLogs(String patientId) {
    _logs = MockDataSource.dailyLogs
        .where((l) => l.patientId == patientId)
        .toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    notifyListeners();
  }

  void selectMood(MoodType mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  Future<bool> submitMood(String patientId) async {
    if (_selectedMood == null) return false;

    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final newLog = DailyLogModel(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      mood: _selectedMood!,
      loggedAt: DateTime.now(),
    );

    MockDataSource.dailyLogs.add(newLog);
    _logs.insert(0, newLog);
    _selectedMood = null;
    _isSubmitting = false;
    notifyListeners();
    return true;
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
  List<MedicationModel> _medications = [];
  // Key: medicationId → status hari ini
  final Map<String, bool> _todayStatus = {};
  bool _isLoading = false;

  List<MedicationModel> get medications => List.unmodifiable(_medications);
  bool get isLoading => _isLoading;

  void loadMedications(String patientId) {
    _isLoading = true;
    notifyListeners();

    _medications = MockDataSource.getMedicationsForPatient(patientId);

    // Inisialisasi status dari mock logs hari ini
    final today = DateTime.now();
    for (final med in _medications) {
      try {
        final log = MockDataSource.medicationLogs.firstWhere(
          (l) =>
              l.medicationId == med.id &&
              l.loggedAt.year == today.year &&
              l.loggedAt.month == today.month &&
              l.loggedAt.day == today.day,
        );
        _todayStatus[med.id] = log.status;
      } catch (_) {
        _todayStatus[med.id] = false;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isChecked(String medicationId) => _todayStatus[medicationId] ?? false;

  void toggleMedication(String medicationId) {
    final current = _todayStatus[medicationId] ?? false;
    _todayStatus[medicationId] = !current;

    // Update atau tambah log
    final today = DateTime.now();
    final existingIndex = MockDataSource.medicationLogs.indexWhere(
      (l) =>
          l.medicationId == medicationId &&
          l.loggedAt.year == today.year &&
          l.loggedAt.month == today.month &&
          l.loggedAt.day == today.day,
    );

    if (existingIndex >= 0) {
      MockDataSource.medicationLogs[existingIndex] =
          MockDataSource.medicationLogs[existingIndex]
              .copyWith(status: !current);
    } else {
      MockDataSource.medicationLogs.add(
        MedicationLogModel(
          id: 'mlog-${DateTime.now().millisecondsSinceEpoch}',
          medicationId: medicationId,
          status: !current,
          loggedAt: today,
        ),
      );
    }

    notifyListeners();
  }

  List<MedicationModel> getMedicationsByTime(MedTime time) {
    return _medications.where((m) => m.timeOfDay == time).toList();
  }

  int get totalChecked =>
      _todayStatus.values.where((v) => v).length;
  int get totalMedications => _medications.length;
}
