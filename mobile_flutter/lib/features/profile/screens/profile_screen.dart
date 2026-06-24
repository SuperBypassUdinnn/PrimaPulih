// Profile Screen — PrimaPulih
// Referensi mockup: IMG_00010.jpeg
// Layout: header SVG, "Profil Saya", avatar berhijab, badge Aktif, menu list putih+SVG icon

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final patient = auth.currentPatient;
    final firstName = patient?.fullName.split(' ').first ?? 'Pasien';
    final patientId = patient?.id ?? '#0001';

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            _ProfileHeader(),

            // ── Content ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Avatar + info ────────────────────
                    Row(
                      children: [
                        // Avatar circle dengan border biru
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF5B8DB8),
                              width: 3,
                            ),
                            color: const Color(0xFFE8F4FC),
                          ),
                          child: ClipOval(
                            child: SvgPicture.string(
                              _avatarSvg,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID Pasien: #${patientId.replaceAll('pat-', '00')}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Aktif badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7AACCC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Aktif dalam perawatan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Menu Items ───────────────────────
                    _MenuItem(
                      svgContent: _personSvg,
                      label: 'Data Pribadi',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _MenuItem(
                      svgContent: _documentSvg,
                      label: 'Riwayat Klinis',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _MenuItem(
                      svgContent: _badgeSvg,
                      label: 'Perawat',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _MenuItem(
                      svgContent: _settingsSvg,
                      label: 'Pengaturan Akun',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),

                    // Logout — merah
                    _MenuItem(
                      svgContent: _logoutSvg,
                      label: 'Keluar / Log Out',
                      onTap: () => _showLogoutDialog(context, auth),
                      isDestructive: true,
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

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Kamu akan keluar dari sesi saat ini.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(
                  fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
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
// Menu Item Card — persis mockup
// ─────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.svgContent,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
  final String svgContent;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFE05050) : const Color(0xFF5B8DB8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.string(
              svgContent,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? const Color(0xFFE05050)
                      : const Color(0xFF1A1A2E),
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
// SVG strings
// ─────────────────────────────────────────────

const String _avatarSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80">
  <circle cx="40" cy="40" r="40" fill="#E0F0F8"/>
  <!-- Body -->
  <ellipse cx="40" cy="72" rx="26" ry="18" fill="#4A8A9A"/>
  <!-- Head -->
  <circle cx="40" cy="34" r="16" fill="#FBBF7A"/>
  <!-- Hijab -->
  <ellipse cx="40" cy="28" rx="18" ry="11" fill="#3A7A8A"/>
  <path d="M23 32 Q18 50 26 64 Q40 70 54 64 Q62 50 57 32" fill="#3A7A8A"/>
  <!-- Glasses -->
  <rect x="28" y="34" width="10" height="7" rx="3.5" fill="none" stroke="#555" stroke-width="1.5"/>
  <rect x="42" y="34" width="10" height="7" rx="3.5" fill="none" stroke="#555" stroke-width="1.5"/>
  <line x1="38" y1="37" x2="42" y2="37" stroke="#555" stroke-width="1.5"/>
  <!-- Eyes -->
  <circle cx="33" cy="37" r="2" fill="#333"/>
  <circle cx="47" cy="37" r="2" fill="#333"/>
  <!-- Smile -->
  <path d="M35 44 Q40 49 45 44" stroke="#E05050" stroke-width="2" fill="none" stroke-linecap="round"/>
</svg>
''';

const String _personSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>
''';

const String _documentSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
  <polyline points="14 2 14 8 20 8"/>
  <line x1="16" y1="13" x2="8" y2="13"/>
  <line x1="16" y1="17" x2="8" y2="17"/>
  <polyline points="10 9 9 9 8 9"/>
</svg>
''';

const String _badgeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="2" y="7" width="20" height="14" rx="2"/>
  <path d="M16 3H8l-2 4h12z"/>
  <circle cx="12" cy="14" r="2"/>
</svg>
''';

const String _settingsSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="3"/>
  <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
</svg>
''';

const String _logoutSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
  <polyline points="16 17 21 12 16 7"/>
  <line x1="21" y1="12" x2="9" y2="12"/>
</svg>
''';
