// Consultation Screen — PrimaPulih
// Referensi mockup: IMG_00005.jpeg

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../data/mock/mock_data_source.dart';
import '../../../data/models/models.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upcoming = MockDataSource.consultations;

    return GradientScaffold(
      appBar: AppHeader(
        title: 'PrimaPulih',
        roleBadge: 'Pasien',
        showBackButton: true,
        onAvatarTap: () => context.push(AppRoutes.profile),
      ),
      body: Column(
        children: [
          // ── Header Strip ─────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'Jadwal Konsultasi',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Content ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MENDATANG
                  Text('MENDATANG',
                      style: AppTextStyles.headingLarge.copyWith(
                        letterSpacing: 1,
                      )),
                  const SizedBox(height: 12),

                  if (upcoming.isEmpty)
                    AppCard(
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: AppColors.textHint, size: 40),
                            const SizedBox(height: 8),
                            Text('Tidak ada jadwal konsultasi mendatang.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...upcoming.map(
                      (c) => _ConsultationCard(consultation: c),
                    ),

                  // RIWAYAT
                  const SizedBox(height: 24),
                  Text('RIWAYAT',
                      style: AppTextStyles.headingLarge.copyWith(
                        letterSpacing: 1,
                      )),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.history_rounded,
                              color: AppColors.textHint, size: 40),
                          const SizedBox(height: 8),
                          Text('Belum ada riwayat konsultasi.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
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

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.consultation});
  final ConsultationModel consultation;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMM yyyy', 'id')
        .format(consultation.scheduledAt);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.doctorName,
                      style: AppTextStyles.headingSmall,
                    ),
                    Text(
                      consultation.specialization,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Schedule info
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            text: _capitalize(dateStr),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: consultation.timeRange,
          ),
          if (consultation.meetingLink != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.link_rounded,
              text: 'link-shared',
              textColor: AppColors.primary,
              isLink: true,
            ),
          ],
          const SizedBox(height: 16),

          // Join button
          AppButton(
            label: 'Bergabung ke Konsultasi',
            icon: Icons.video_call_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link konsultasi akan dibuka di browser.'),
                ),
              );
            },
            height: 46,
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.textColor,
    this.isLink = false,
  });
  final IconData icon;
  final String text;
  final Color? textColor;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor ?? AppColors.textPrimary,
            decoration: isLink ? TextDecoration.underline : null,
          ),
        ),
      ],
    );
  }
}
