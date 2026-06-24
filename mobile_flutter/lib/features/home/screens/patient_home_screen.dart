// Patient Home Screen — PrimaPulih
// Referensi mockup: IMG_00004.jpeg

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFD6E8F7),
      drawer: _AppDrawer(patientName: patient?.fullName ?? ''),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Header ────────────────────────────────
            _HomeHeader(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onAvatarTap: () => context.push(AppRoutes.profile),
            ),

            // ── Quick Action Chip Strip ───────────────────
            _ChipStrip(),

            // ── Body Content ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    // Calendar Card — persis mockup (putih, rounded)
                    _CalendarCard(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      onDaySelected: (sel, foc) => setState(() {
                        _selectedDay = sel;
                        _focusedDay = foc;
                      }),
                      patientId: auth.currentPatient?.id ?? '',
                    ),
                    const SizedBox(height: 14),

                    // Quick Action List Items (mockup: teks + chevron saja)
                    _QuickCard(
                      label: 'Jadwal konsumsi obat hari ini',
                      onTap: () => context.push(AppRoutes.medication),
                    ),
                    const SizedBox(height: 10),
                    _QuickCard(
                      label: 'Jadwal konsultasi',
                      onTap: () => context.push(AppRoutes.consultation),
                    ),
                    const SizedBox(height: 10),
                    _QuickCard(
                      label: 'Tes PHQ-9 dan GAD-10',
                      onTap: () => context.push('${AppRoutes.assessment}?type=phq9'),
                    ),
                    const SizedBox(height: 10),

                    // Mood Banner — persis mockup
                    _MoodBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header App Bar
// ─────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onMenuTap, required this.onAvatarTap});
  final VoidCallback onMenuTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu_rounded, size: 28, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/svg/logo_primapulih.svg',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          const Text(
            'PrimaPulih',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Pasien',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFD6E8F7),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF7AACCC),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Chip Strip (gradient biru-hijau persis mockup)
// ─────────────────────────────────────────────

class _ChipStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF80DEEA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(label: 'Lengkapi data', filled: true),
            const SizedBox(width: 8),
            _Chip(label: 'Isi riwayat klinis', filled: false),
            const SizedBox(width: 8),
            _Chip(label: 'Tes PHQ-9 dan GAD-7', filled: false),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.filled});
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Calendar Card — persis mockup putih rounded
// ─────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.patientId,
  });
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2027, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFFD6E8F7),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2563EB),
          ),
          selectedTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          defaultTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF333333),
          ),
          weekendTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF888888),
          ),
          outsideTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFFCCCCCC),
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          markerSize: 5,
          cellMargin: const EdgeInsets.all(4),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
          leftChevronIcon: Icon(Icons.chevron_left_rounded,
              color: Color(0xFF888888), size: 24),
          rightChevronIcon: Icon(Icons.chevron_right_rounded,
              color: Color(0xFF888888), size: 24),
          headerPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
          ),
          weekendStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
          ),
        ),
        eventLoader: (day) {
          return MockDataSource.dailyLogs
              .where((l) => l.patientId == patientId && isSameDay(l.loggedAt, day))
              .toList();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Card — persis mockup (teks + chevron)
// ─────────────────────────────────────────────

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF888888),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mood Banner — putih dengan 3D karakter SVG
// ─────────────────────────────────────────────

class _MoodBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.moodTracker),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
        child: Row(
          children: [
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bagaimana\nPerasaanmu\nHari ini ?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // SVG karakter semangat (persis mockup — gambar 3D orang)
            SvgPicture.asset(
              'assets/svg/mood_semangat.svg',
              width: 100,
              height: 110,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// App Drawer
// ─────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.patientName});
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD6E8F7),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF1A1A2E), size: 24),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/svg/logo_primapulih.svg',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PrimaPulih',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              _DrawerItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil Saya',
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.profile);
                },
              ),
              _DrawerItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Edukasi & Tips',
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              const Divider(),
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'Keluar',
                color: Colors.red,
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
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF2563EB);
    return ListTile(
      leading: Icon(icon, color: c, size: 24),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
