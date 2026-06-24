// AssessmentProvider — State Management untuk PHQ-9 & GAD-7
// Terhubung ke Backend Golang

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../data/models/models.dart';

class AssessmentProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  // Jawaban saat ini: index pertanyaan → skor (0-3)
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;
  AssessmentModel? _lastResult;
  String? _errorMessage;

  Map<int, int> get answers => Map.unmodifiable(_answers);
  bool get isSubmitting => _isSubmitting;
  AssessmentModel? get lastResult => _lastResult;
  String? get errorMessage => _errorMessage;

  int get totalScore => _answers.values.fold(0, (sum, v) => sum + v);
  bool get isComplete => _answers.length == _currentQuestionCount;

  int _currentQuestionCount = 9; // default PHQ-9

  void startAssessment(AssessmentType type) {
    _answers.clear();
    _lastResult = null;
    _errorMessage = null;
    _currentQuestionCount = type == AssessmentType.phq9 ? 9 : 7;
    notifyListeners();
  }

  void setAnswer(int questionIndex, int score) {
    _answers[questionIndex] = score;
    notifyListeners();
  }

  int? getAnswer(int questionIndex) => _answers[questionIndex];

  Future<AssessmentModel?> submitAssessment({
    required String patientId,
    required AssessmentType type,
  }) async {
    if (!isComplete) {
      _errorMessage = 'Harap jawab semua pertanyaan terlebih dahulu.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final typeString = type == AssessmentType.phq9 ? 'PHQ-9' : 'GAD-7';
      final response = await _api.post('/assessments', body: {
        'type': typeString,
        'total_score': totalScore,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final result = AssessmentModel(
          id: data['id'],
          patientId: patientId,
          type: type,
          totalScore: totalScore,
          submittedAt: DateTime.now(),
        );

        _lastResult = result;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Gagal mengirim hasil tes.';
      }
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server.';
    }

    _isSubmitting = false;
    notifyListeners();
    return _lastResult;
  }

  void reset() {
    _answers.clear();
    _lastResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
