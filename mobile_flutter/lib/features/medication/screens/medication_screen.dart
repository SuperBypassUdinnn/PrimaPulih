// Medication Checklist Screen — PrimaPulih
// Referensi mockup: IMG_00006.jpeg


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../auth/auth_provider.dart';
import '../../home/home_provider.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medProv = context.watch<MedicationProvider>();
    final auth = context.watch<AuthProvider>();
    final patientName = auth.currentPatient?.fullName.split(' ').first ?? 'Kamu';
    final today = DateTime.now();
    final dateStr = DateFormat('d MMM yyyy', 'id').format(today);

    // Date strip (scrollable tanggal minggu ini)
    final weekDays = List.generate(7, (i) {
      return today.subtract(Duration(days: today.weekday - 1 - i));
    });

    return GradientScaffold(
      appBar: AppHeader(
        title: 'PrimaPulih',
        roleBadge: 'Pasien',
        onAvatarTap: () => context.push(AppRoutes.profile),
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ── Week Date Strip ─────────────────────────────
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weekDays.map((day) {
                  final isToday = isSameDay(day, today);
                  return GestureDetector(
                    onTap: () {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${day.day}',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: isToday ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Halo $patientName, Waktunya menjaga\ndirimu hari ini',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Progress Card
                  AppCard(
                    color: AppColors.bgLight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress Hari Ini',
                                style: AppTextStyles.labelMedium,
                              ),
                              Text(
                                '${medProv.totalChecked} / ${medProv.totalMedications} obat diminum',
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                value: medProv.totalMedications > 0
                                    ? medProv.totalChecked /
                                        medProv.totalMedications
                                    : 0,
                                strokeWidth: 6,
                                backgroundColor: AppColors.border,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              '${medProv.totalMedications > 0 ? ((medProv.totalChecked / medProv.totalMedications) * 100).round() : 0}%',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Medication Groups by Time
                  ...MedTime.values.map((time) {
                    final meds = medProv.getMedicationsByTime(time);
                    return _MedicationGroup(
                      time: time,
                      medications: meds,
                      medProvider: medProv,
                    );
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MedicationGroup extends StatelessWidget {
  const _MedicationGroup({
    required this.time,
    required this.medications,
    required this.medProvider,
  });
  final MedTime time;
  final List<MedicationModel> medications;
  final MedicationProvider medProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Text(time.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(time.label, style: AppTextStyles.headingSmall),
              ],
            ),
          ),

          // Medication Items
          if (medications.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Tidak ada jadwal obat untuk ${time.label.toLowerCase()}.',
                style: AppTextStyles.bodySmall,
              ),
            )
          else
            ...medications.map((med) {
              final isChecked = medProvider.isChecked(med.id);
              return _MedicationItem(
                medication: med,
                isChecked: isChecked,
                onToggle: () => medProvider.toggleMedication(med.id),
              );
            }),
        ],
      ),
    );
  }
}

class _MedicationItem extends StatelessWidget {
  const _MedicationItem({
    required this.medication,
    required this.isChecked,
    required this.onToggle,
  });
  final MedicationModel medication;
  final bool isChecked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isChecked
            ? AppColors.successLight
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.medicineName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isChecked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medication.dosage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isChecked
                        ? AppColors.textHint
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.success : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChecked ? AppColors.success : AppColors.border,
                  width: 2,
                ),
                boxShadow: isChecked
                    ? [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: isChecked
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
