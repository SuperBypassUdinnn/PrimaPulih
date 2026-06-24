// Mood Tracker Screen — PrimaPulih
// Referensi mockup: IMG_00007.jpeg
// Layout: header sama seperti home, kartu putih besar dengan grid 3x3 mood + tombol Catat

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../auth/auth_provider.dart';
import '../../home/home_provider.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final moodProv = context.watch<MoodProvider>();
    final auth = context.watch<AuthProvider>();
    final patientId = auth.currentPatient?.id ?? 'pat-001';

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (sama persis dengan home) ──────────
            _MoodHeader(),

            // ── Content ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    children: [
                      // ── Mood Grid ────────────────────────
                      // Baris 1: Senang, Marah, Sedih
                      _MoodRow(
                        moods: [MoodType.senang, MoodType.marah, MoodType.sedih],
                        selected: moodProv.selectedMood,
                        onSelect: moodProv.selectMood,
                      ),
                      const SizedBox(height: 8),
                      // Baris 2: Bingung, Stress, Ngantuk
                      _MoodRow(
                        moods: [MoodType.bingung, MoodType.stress, MoodType.ngantuk],
                        selected: moodProv.selectedMood,
                        onSelect: moodProv.selectMood,
                      ),
                      const SizedBox(height: 8),
                      // Baris 3: Capek, Semangat (centered)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MoodTile(
                            mood: MoodType.capek,
                            isSelected: moodProv.selectedMood == MoodType.capek,
                            onTap: () => moodProv.selectMood(MoodType.capek),
                          ),
                          const SizedBox(width: 8),
                          _MoodTile(
                            mood: MoodType.semangat,
                            isSelected: moodProv.selectedMood == MoodType.semangat,
                            onTap: () => moodProv.selectMood(MoodType.semangat),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Catat Button ─────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: moodProv.selectedMood == null || moodProv.isSubmitting
                              ? null
                              : () async {
                                  final ok = await moodProv.submitMood(patientId);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Suasana hati berhasil dicatat! ✨'),
                                        backgroundColor: Color(0xFF2ECC71),
                                      ),
                                    );
                                    context.pop();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            disabledBackgroundColor: const Color(0xFF93B4D8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: moodProv.isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Catat',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
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
// Header widget (identik dengan home screen)
// ─────────────────────────────────────────────

class _MoodHeader extends StatelessWidget {
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
          // Logo SVG
          SvgPicture.asset(
            'assets/svg/logo_primapulih.svg',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          Text(
            'PrimaPulih',
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Pasien',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD6E8F7),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF7AACCC),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Baris 3 mood tiles
// ─────────────────────────────────────────────

class _MoodRow extends StatelessWidget {
  const _MoodRow({
    required this.moods,
    required this.selected,
    required this.onSelect,
  });
  final List<MoodType> moods;
  final MoodType? selected;
  final void Function(MoodType) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: moods.map((m) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _MoodTile(
              mood: m,
              isSelected: selected == m,
              onTap: () => onSelect(m),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Single Mood Tile dengan SVG
// ─────────────────────────────────────────────

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
        width: (MediaQuery.of(context).size.width - 72) / 3,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFDCEEFC)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF2563EB), width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG character
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                mood.svgPath,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF444444),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
