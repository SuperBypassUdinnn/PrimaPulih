// Assessment Question Widget — Reusable component
// Referensi mockup: IMG_00009.jpeg (toggle button 0-1-2-3)

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';

class AssessmentQuestionWidget extends StatelessWidget {
  const AssessmentQuestionWidget({
    super.key,
    required this.question,
    required this.selectedScore,
    required this.onScoreSelected,
  });

  final AssessmentQuestion question;
  final int? selectedScore;
  final void Function(int score) onScoreSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${question.number}. ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: question.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Score Selector (0-1-2-3)
          Container(
            decoration: BoxDecoration(
              color: selectedScore != null
                  ? AppColors.bgLight
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(4, (i) {
                final isSelected = selectedScore == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onScoreSelected(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '$i',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
