// AssessmentProvider — State Management untuk PHQ-9 & GAD-7

import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data_source.dart';

class AssessmentProvider extends ChangeNotifier {
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
    _currentQuestionCount =
        type == AssessmentType.phq9 ? 9 : 7;
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

    await Future.delayed(const Duration(milliseconds: 600));

    final result = AssessmentModel(
      id: 'asmnt-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      type: type,
      totalScore: totalScore,
      submittedAt: DateTime.now(),
    );

    MockDataSource.assessments.add(result);
    _lastResult = result;
    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  void reset() {
    _answers.clear();
    _lastResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
