// Profile Screen — PrimaPulih
// Referensi mockup: IMG_00010.jpeg

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/mock/mock_data_source.dart';
import '../../../data/models/models.dart';
import '../../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final patient = auth.currentPatient;
    final user = auth.currentUser;
    final assessments = MockDataSource.getAssessmentsForPatient(patient?.id ?? '');
    final latestPHQ9 = assessments.where((a) => a.type == AssessmentType.phq9).firstOrNull;
    final latestGAD7 = assessments.where((a) => a.type == AssessmentType.gad7).firstOrNull;

    return GradientScaffold(
      appBar: const AppHeader(
        title: 'PrimaPulih',
        showBackButton: true,
        roleBadge: 'Pasien',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile Header ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profil Saya', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient?.fullName ?? 'Pengguna',
                            style: AppTextStyles.headingMedium,
                          ),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Aktif dalam perawatan',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Assessment Summary ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ScoreSummaryCard(
                      label: 'PHQ-9',
                      subtitle: 'Depresi',
                      score: latestPHQ9?.totalScore,
                      maxScore: 27,
                      interpretation: latestPHQ9?.phq9Interpretation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreSummaryCard(
                      label: 'GAD-7',
                      subtitle: 'Kecemasan',
                      score: latestGAD7?.totalScore,
                      maxScore: 21,
                      interpretation: latestGAD7?.gad7Interpretation,
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu List ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Data Pribadi',
                    subtitle: patient?.fullName ?? '-',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    label: 'Riwayat Klinis',
                    subtitle: patient?.icuDischargeDate != null
                        ? 'Keluar ICU: ${DateFormat('d MMM yyyy', 'id').format(patient!.icuDischargeDate)}'
                        : '-',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.badge_outlined,
                    label: 'Perawat',
                    subtitle: 'Dr. Sarah Azizah, Sp.Kj',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.assignment_outlined,
                    label: 'Riwayat Asesmen',
                    subtitle: '${assessments.length} asesmen tersimpan',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Pengaturan Akun',
                    subtitle: user?.email ?? '',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    onTap: () async {
                      final confirm = await _showLogoutDialog(context);
                      if (confirm == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Keluar / Log Out',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar', style: AppTextStyles.headingSmall),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun ini?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({
    required this.label,
    required this.subtitle,
    this.score,
    required this.maxScore,
    this.interpretation,
  });
  final String label;
  final String subtitle;
  final int? score;
  final int maxScore;
  final String? interpretation;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.primary,
              )),
          Text(subtitle, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(
            score != null ? '$score/$maxScore' : 'Belum diisi',
            style: AppTextStyles.headingMedium,
          ),
          if (interpretation != null)
            Text(
              interpretation!,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
