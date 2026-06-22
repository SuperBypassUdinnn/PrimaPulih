// Assessment Result Screen — PrimaPulih

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../assessment_provider.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key});

  Color _getScoreColor(int score, AssessmentType type) {
    if (type == AssessmentType.phq9) {
      if (score <= 4) return AppColors.success;
      if (score <= 9) return const Color(0xFF8BC34A);
      if (score <= 14) return AppColors.warning;
      if (score <= 19) return const Color(0xFFFF7043);
      return AppColors.error;
    } else {
      if (score <= 4) return AppColors.success;
      if (score <= 9) return const Color(0xFF8BC34A);
      if (score <= 14) return AppColors.warning;
      return AppColors.error;
    }
  }

  IconData _getScoreIcon(int score, AssessmentType type) {
    final maxScore = type == AssessmentType.phq9 ? 27 : 21;
    final ratio = score / maxScore;
    if (ratio < 0.2) return Icons.sentiment_very_satisfied_rounded;
    if (ratio < 0.4) return Icons.sentiment_satisfied_rounded;
    if (ratio < 0.6) return Icons.sentiment_neutral_rounded;
    if (ratio < 0.8) return Icons.sentiment_dissatisfied_rounded;
    return Icons.sentiment_very_dissatisfied_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssessmentProvider>();
    final result = prov.lastResult;

    if (result == null) {
      return GradientScaffold(
        appBar: const AppHeader(title: 'Hasil Tes', showBackButton: true),
        body: const Center(child: Text('Tidak ada hasil.')),
      );
    }

    final maxScore = result.type == AssessmentType.phq9 ? 27 : 21;
    final scoreRatio = result.totalScore / maxScore;
    final scoreColor = _getScoreColor(result.totalScore, result.type);
    final typeName = result.type == AssessmentType.phq9 ? 'PHQ-9' : 'GAD-7';

    return GradientScaffold(
      appBar: AppHeader(
        title: 'Hasil $typeName',
        showLogo: false,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Score Circle
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: scoreRatio),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        backgroundColor: AppColors.border,
                        color: scoreColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          _getScoreIcon(result.totalScore, result.type),
                          size: 40,
                          color: scoreColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.totalScore}',
                          style: AppTextStyles.scoreLarge.copyWith(
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          'dari $maxScore',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Interpretation Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: scoreColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Interpretasi Skor $typeName',
                        style: AppTextStyles.headingSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: scoreColor.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Text(
                      result.interpretation,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: scoreColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.type == AssessmentType.phq9
                        ? '• Skor 0-4: Minimal\n• Skor 5-9: Ringan\n• Skor 10-14: Sedang\n• Skor 15-19: Cukup Berat\n• Skor 20-27: Berat'
                        : '• Skor 0-4: Minimal\n• Skor 5-9: Ringan\n• Skor 10-14: Sedang\n• Skor 15-21: Berat',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Recommendation Card
            if (result.totalScore >= 10)
              AppCard(
                color: AppColors.errorLight,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Disarankan untuk berkonsultasi dengan tenaga kesehatan profesional.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            AppButton(
              label: 'Kembali ke Beranda',
              onPressed: () => context.go(AppRoutes.patientHome),
              icon: Icons.home_rounded,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Tes Lainnya',
              onPressed: () {
                prov.reset();
                final otherType = result.type == AssessmentType.phq9
                    ? 'gad7'
                    : 'phq9';
                context.pushReplacement(
                    '${AppRoutes.assessment}?type=$otherType');
              },
              outlined: true,
              color: AppColors.primary,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
