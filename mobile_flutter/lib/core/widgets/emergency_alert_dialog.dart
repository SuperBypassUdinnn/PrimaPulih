// Emergency Alert Widget — PrimaPulih
// Referensi mockup: IMG_00011.jpeg (Peringatan Darurat)
// Ditampilkan sebagai OverlayEntry / showDialog ketika skor PHQ/GAD sangat tinggi

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmergencyAlertDialog extends StatelessWidget {
  const EmergencyAlertDialog({
    super.key,
    required this.onContact,
    required this.onDismiss,
  });

  final VoidCallback onContact;
  final VoidCallback onDismiss;

  /// Show the emergency alert overlay
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContact,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => EmergencyAlertDialog(
        onContact: onContact,
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo + Title
            Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/logo_primapulih.svg',
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Peringatan Darurat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Alert icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE65100),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),

            // Message
            const Text(
              'Kondisi Pasien Terdeteksi Kritis. Harap Lakukan Konsultasi.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Color(0xFF333333),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // CTA button — merah persis mockup
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Hubungi Dokter Sekarang',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dismiss
            TextButton(
              onPressed: onDismiss,
              child: const Text(
                'Tutup',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
