// Mood Tracker Screen — PrimaPulih
// Referensi mockup: IMG_00007.jpeg

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../auth/auth_provider.dart';
import '../../home/home_provider.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  static const List<MoodType> _moods = MoodType.values;

  @override
  Widget build(BuildContext context) {
    final moodProv = context.watch<MoodProvider>();
    final auth = context.watch<AuthProvider>();
    final patientId = auth.currentPatient?.id ?? 'pat-001';
    final todayLog = moodProv.todayLog;

    return GradientScaffold(
      appBar: AppHeader(
        title: 'PrimaPulih',
        roleBadge: 'Pasien',
        onAvatarTap: () => context.push(AppRoutes.profile),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Already logged today banner
            if (todayLog != null)
              AppCard(
                color: AppColors.successLight,
                child: Row(
                  children: [
                    Text(todayLog.mood.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suasana hati hari ini: ${todayLog.mood.label}',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Sudah tercatat. Kamu bisa memperbarui pilihan di bawah.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Mood Grid Card
            AppCard(
              child: Column(
                children: [
                  Text(
                    'Bagaimana perasaanmu hari ini?',
                    style: AppTextStyles.headingSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih salah satu yang paling menggambarkan kondisimu',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Mood Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: _moods.map((mood) {
                      final isSelected = moodProv.selectedMood == mood;
                      return _MoodTile(
                        mood: mood,
                        isSelected: isSelected,
                        onTap: () => moodProv.selectMood(mood),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  AppButton(
                    label: moodProv.isSubmitting ? 'Menyimpan...' : 'Catat',
                    isLoading: moodProv.isSubmitting,
                    onPressed: moodProv.selectedMood == null
                        ? null
                        : () async {
                            final ok = await moodProv.submitMood(patientId);
                            if (!context.mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Suasana hati "${moodProv.logs.first.mood.label}" berhasil dicatat! ✨',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.pop();
                            }
                          },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // History Section
            if (moodProv.logs.isNotEmpty) ...[
              SectionHeader(
                title: 'Riwayat Suasana Hati',
                subtitle: '${moodProv.logs.length} catatan',
              ),
              ...moodProv.logs.take(7).map((log) {
                return AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(log.mood.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.mood.label,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                            Text(
                              '${log.loggedAt.day}/${log.loggedAt.month}/${log.loggedAt.year}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mood.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
