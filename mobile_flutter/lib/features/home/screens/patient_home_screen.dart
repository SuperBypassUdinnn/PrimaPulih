// Patient Home Screen — PrimaPulih
// Referensi mockup: IMG_00004.jpeg & IMG_00008.jpeg (Drawer)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../data/mock/mock_data_source.dart';
import '../../auth/auth_provider.dart';
import '../home_provider.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final patientId = auth.currentPatient?.id ?? '';
      if (patientId.isNotEmpty) {
        context.read<MoodProvider>().loadLogs(patientId);
        context.read<MedicationProvider>().loadMedications(patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final patient = auth.currentPatient;
    final firstName = patient?.fullName.split(' ').first ?? 'Pengguna';

    return GradientScaffold(
      drawer: _AppDrawer(patientName: patient?.fullName ?? ''),
      appBar: AppHeader(
        roleBadge: 'Pasien',
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onAvatarTap: () => context.push(AppRoutes.profile),
      ),
      body: Builder(
        builder: (context) => Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: _AppDrawer(patientName: patient?.fullName ?? ''),
          appBar: AppHeader(
            roleBadge: 'Pasien',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            onAvatarTap: () => context.push(AppRoutes.profile),
          ),
          body: Column(
            children: [
              // ── Gradient Header Strip ─────────────────────
              _QuickActionStrip(),

              // ── Scrollable Content ─────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar
                      AppCard(
                        padding: const EdgeInsets.all(12),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2027, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selected, focused) {
                            setState(() {
                              _selectedDay = selected;
                              _focusedDay = focused;
                            });
                          },
                          calendarStyle: CalendarStyle(
                            selectedDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            selectedTextStyle: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            defaultTextStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textPrimary),
                            weekendTextStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                            outsideTextStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textHint),
                            markerDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: false,
                            titleTextStyle: AppTextStyles.headingSmall,
                            leftChevronIcon: const Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.textSecondary),
                            rightChevronIcon: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600),
                            weekendStyle: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          eventLoader: (day) {
                            // Tandai hari yang ada mood log
                            final patientId = auth.currentPatient?.id ?? '';
                            return MockDataSource.dailyLogs
                                .where((l) =>
                                    l.patientId == patientId &&
                                    isSameDay(l.loggedAt, day))
                                .toList();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick Action Cards
                      _QuickActionCard(
                        icon: Icons.medication_outlined,
                        label: 'Jadwal konsumsi obat hari ini',
                        onTap: () => context.push(AppRoutes.medication),
                      ),
                      _QuickActionCard(
                        icon: Icons.calendar_month_outlined,
                        label: 'Jadwal konsultasi',
                        onTap: () => context.push(AppRoutes.consultation),
                      ),
                      _QuickActionCard(
                        icon: Icons.assignment_outlined,
                        label: 'Tes PHQ-9 dan GAD-7',
                        onTap: () => context.push(
                            '${AppRoutes.assessment}?type=phq9'),
                      ),

                      // Mood Card
                      const SizedBox(height: 8),
                      _MoodCard(patientName: firstName),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Action Strip (scrollable chips)
// ─────────────────────────────────────────────

class _QuickActionStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StripChip(label: 'Lengkapi data', isActive: true,
                onTap: () => context.push(AppRoutes.profile)),
            const SizedBox(width: 8),
            _StripChip(label: 'Isi riwayat klinis', isActive: false,
                onTap: () {}),
            const SizedBox(width: 8),
            _StripChip(label: 'Tes PHQ-9 dan GAD-7', isActive: false,
                onTap: () => context.push('${AppRoutes.assessment}?type=phq9')),
          ],
        ),
      ),
    );
  }
}

class _StripChip extends StatelessWidget {
  const _StripChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? Colors.white : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Action Card (list tiles)
// ─────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mood Banner Card
// ─────────────────────────────────────────────

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.patientName});
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.moodTracker),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bagaimana\nPerasaanmu\nHari ini ?',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Catat Sekarang',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('😊', style: const TextStyle(fontSize: 64)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// App Drawer (Side Menu)
// ─────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.patientName});
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textPrimary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.monitor_heart_outlined,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('PrimaPulih', style: AppTextStyles.headingSmall),
                  ],
                ),
              ),

              const Divider(),

              // Menu Items
              _DrawerItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil Saya',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.profile);
                },
              ),
              _DrawerItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi',
                color: AppColors.primary,
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                color: AppColors.primary,
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Edukasi & Tips',
                color: AppColors.primary,
                onTap: () => Navigator.pop(context),
              ),

              const Spacer(),
              const Divider(),

              // Keluar
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'Keluar',
                color: AppColors.error,
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().logout();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
