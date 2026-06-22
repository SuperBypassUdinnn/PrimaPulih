// Assessment Screen — PHQ-9 & GAD-7
// Referensi mockup: IMG_00009.jpeg

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/mock/mock_data_source.dart';
import '../../auth/auth_provider.dart';
import '../assessment_provider.dart';
import '../widgets/assessment_question_widget.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, required this.type});
  final AssessmentType type;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final ScrollController _scrollController = ScrollController();

  List<AssessmentQuestion> get _questions => widget.type == AssessmentType.phq9
      ? MockDataSource.phq9Questions
      : MockDataSource.gad7Questions;

  String get _title =>
      widget.type == AssessmentType.phq9 ? 'PHQ-9' : 'GAD-7';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().startAssessment(widget.type);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final assessmentProv = context.read<AssessmentProvider>();
    if (!assessmentProv.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua pertanyaan terlebih dahulu.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final patientId = auth.currentPatient?.id ?? 'pat-001';

    await assessmentProv.submitAssessment(
      patientId: patientId,
      type: widget.type,
    );

    if (!mounted) return;
    context.push(AppRoutes.assessmentResult);
  }

  @override
  Widget build(BuildContext context) {
    final assessmentProv = context.watch<AssessmentProvider>();

    return GradientScaffold(
      appBar: AppHeader(
        title: _title,
        showLogo: false,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ── Gradient Header Strip ─────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'Tes PHQ-9 dan GAD-7',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Progress indicator ────────────────────────────
          _ProgressBar(
            answered: assessmentProv.answers.length,
            total: _questions.length,
          ),

          // ── Questions List ────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  AppCard(
                    color: AppColors.bgLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title,
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.primary,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          widget.type == AssessmentType.phq9
                              ? 'Petunjuk: Dalam 2 minggu terakhir, seberapa sering Anda mengalami hal-hal berikut?'
                              : 'Petunjuk: Selama 2 minggu terakhir, seberapa sering Anda terganggu oleh hal-hal berikut?',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor: 0 = tidak sama sekali, 1 = beberapa hari, '
                          '2 = lebih dari setengah hari, 3 = hampir setiap hari',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Question Items
                  ...List.generate(_questions.length, (index) {
                    final q = _questions[index];
                    return AssessmentQuestionWidget(
                      question: q,
                      selectedScore: assessmentProv.getAnswer(index),
                      onScoreSelected: (score) =>
                          assessmentProv.setAnswer(index, score),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Submit button
                  AppButton(
                    label: assessmentProv.isSubmitting
                        ? 'Menyimpan...'
                        : 'Kirim Hasil',
                    isLoading: assessmentProv.isSubmitting,
                    onPressed: _handleSubmit,
                    icon: Icons.send_rounded,
                    color: assessmentProv.isComplete
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Progress Bar Widget
// ─────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.answered, required this.total});
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? answered / total : 0.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres: $answered / $total pertanyaan',
                style: AppTextStyles.labelSmall,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
