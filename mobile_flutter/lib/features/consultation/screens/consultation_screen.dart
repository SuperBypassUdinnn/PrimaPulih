// Consultation Screen — PrimaPulih
// Referensi mockup: IMG_00005.jpeg
// Layout: header sama, gradient strip "Jadwal Konsultasi", card dokter dengan icon SVG

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/mock/mock_data_source.dart';
import '../../../data/models/models.dart';


class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final consultations = MockDataSource.consultations;
    final now = DateTime.now();
    final upcoming = consultations
        .where((c) => c.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final past = consultations
        .where((c) => c.scheduledAt.isBefore(now))
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            _ConsultHeader(),

            // ── Gradient Strip ────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF80DEEA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Jadwal Konsultasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MENDATANG
                    if (upcoming.isNotEmpty) ...[
                      const Text(
                        'MENDATANG',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...upcoming.map((c) => _ConsultCard(
                            consultation: c,
                            isUpcoming: true,
                          )),
                      const SizedBox(height: 20),
                    ],

                    // RIWAYAT (jika ada)
                    if (past.isNotEmpty) ...[
                      const Text(
                        'RIWAYAT',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...past.map((c) => _ConsultCard(
                            consultation: c,
                            isUpcoming: false,
                          )),
                    ],

                    // Jika tidak ada
                    if (upcoming.isEmpty && past.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Text(
                            'Belum ada jadwal konsultasi',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ),
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
// Header
// ─────────────────────────────────────────────

class _ConsultHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.menu_rounded,
                size: 28, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 10),
          SvgPicture.asset('assets/svg/logo_primapulih.svg',
              width: 40, height: 40),
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
              border:
                  Border.all(color: const Color(0xFF2563EB), width: 1.5),
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
// Consultation Card — persis mockup
// ─────────────────────────────────────────────

class _ConsultCard extends StatelessWidget {
  const _ConsultCard({
    required this.consultation,
    required this.isUpcoming,
  });
  final ConsultationModel consultation;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("EEEE, d MMM yyyy", "id_ID")
        .format(consultation.scheduledAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar — persis mockup (lingkaran dengan ikon dokter)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB0D4F0),
                    width: 2.5,
                  ),
                  color: const Color(0xFFE8F4FC),
                ),
                child: ClipOval(
                  child: Center(
                    child: SvgPicture.string(
                      _doctorAvatarSvg,
                      width: 44,
                      height: 44,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & specialization
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.doctorName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      consultation.specialization,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),

          // Date row
          _InfoRow(
            svgContent: _calendarSvg,
            label: dateStr,
          ),
          const SizedBox(height: 10),

          // Time row
          _InfoRow(
            svgContent: _clockSvg,
            label: consultation.timeRange,
          ),

          // Link row (if available)
          if (consultation.meetingLink != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              svgContent: _linkSvg,
              label: consultation.meetingLink!,
              isLink: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.svgContent,
    required this.label,
    this.isLink = false,
  });
  final String svgContent;
  final String label;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.string(
          svgContent,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
            isLink ? const Color(0xFF2563EB) : const Color(0xFF5B8DB8),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isLink ? const Color(0xFF2563EB) : const Color(0xFF333333),
              fontWeight: isLink ? FontWeight.w600 : FontWeight.w400,
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Inline SVG strings
// ─────────────────────────────────────────────

const String _doctorAvatarSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60">
  <circle cx="30" cy="30" r="30" fill="#E0F0F8"/>
  <circle cx="30" cy="22" r="11" fill="#7AACCC"/>
  <ellipse cx="30" cy="50" rx="18" ry="14" fill="#7AACCC"/>
  <!-- hijab -->
  <ellipse cx="30" cy="19" rx="13" ry="8" fill="#4A8A9A"/>
  <path d="M18 22 Q14 36 20 46 Q30 50 40 46 Q46 36 42 22" fill="#4A8A9A"/>
  <!-- face -->
  <circle cx="30" cy="23" r="8" fill="#FBBF7A"/>
  <!-- eyes -->
  <circle cx="27" cy="23" r="1.5" fill="#333"/>
  <circle cx="33" cy="23" r="1.5" fill="#333"/>
  <!-- smile -->
  <path d="M27 27 Q30 30 33 27" stroke="#E05050" stroke-width="1.5" fill="none" stroke-linecap="round"/>
</svg>
''';

const String _calendarSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="4" width="18" height="18" rx="3"/>
  <line x1="16" y1="2" x2="16" y2="6"/>
  <line x1="8" y1="2" x2="8" y2="6"/>
  <line x1="3" y1="10" x2="21" y2="10"/>
</svg>
''';

const String _clockSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <polyline points="12 7 12 12 16 14"/>
</svg>
''';

const String _linkSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>
  <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>
</svg>
''';
