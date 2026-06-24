// Medication Checklist Screen — PrimaPulih
// Referensi mockup: IMG_00006.jpeg

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../auth/auth_provider.dart';
import '../../home/home_provider.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medProv = context.watch<MedicationProvider>();
    final auth = context.watch<AuthProvider>();
    final firstName = auth.currentPatient?.fullName.split(' ').first ?? 'Kamu';
    final today = DateTime.now();

    // Buat 7 hari mulai dari Senin minggu ini
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            _MedHeader(),

            // ── Date Strip ────────────────────────────────
            Container(
              color: Colors.white,
              child: _DateStrip(weekDays: weekDays, today: today),
            ),

            // ── Scrollable Content ─────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting — bold besar, tanpa card
                    Text(
                      'Halo $firstName, Waktunya menjaga\ndirimu hari ini',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Groups by time
                    ...MedTime.values.map((time) {
                      final meds = medProv.getMedicationsByTime(time);
                      return _MedGroup(
                        time: time,
                        medications: meds,
                        medProv: medProv,
                      );
                    }),
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
// Header — identik dengan home
// ─────────────────────────────────────────────

class _MedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.menu_rounded, size: 28, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 10),
          SvgPicture.asset('assets/svg/logo_primapulih.svg', width: 40, height: 40),
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
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD6E8F7),
            child: const Icon(Icons.person_rounded, color: Color(0xFF7AACCC), size: 24),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date Strip — angka saja, kolom vertikal
// ─────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.weekDays, required this.today});
  final List<DateTime> weekDays;
  final DateTime today;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, i) {
          final day = weekDays[i];
          final isToday = _isSameDay(day, today);
          return Container(
            width: MediaQuery.of(context).size.width / 7,
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF2563EB) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isToday ? Colors.white : const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Medication Time Group
// ─────────────────────────────────────────────

class _MedGroup extends StatelessWidget {
  const _MedGroup({
    required this.time,
    required this.medications,
    required this.medProv,
  });
  final MedTime time;
  final List<MedicationModel> medications;
  final MedicationProvider medProv;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                SvgPicture.asset(
                  time.svgPath,
                  width: 26,
                  height: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  time.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),

          // Medication items
          if (medications.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Tidak ada jadwal obat.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            )
          else
            ...medications.map((med) {
              return _MedItem(
                medication: med,
                isChecked: medProv.isChecked(med.id),
                onToggle: () => medProv.toggleMedication(med.id),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Single Medication Item — circle checkbox
// ─────────────────────────────────────────────

class _MedItem extends StatelessWidget {
  const _MedItem({
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
            ? const Color(0xFFEBF5FB)
            : const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.medicineName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    decoration: isChecked ? TextDecoration.none : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medication.dosage,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          // Circle checkbox — persis mockup
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? const Color(0xFF2ECC71) : Colors.white,
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
                boxShadow: isChecked
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isChecked
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
