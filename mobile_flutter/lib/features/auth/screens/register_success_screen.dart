// Register Success Screen — PrimaPulih
// Referensi mockup: IMG_00003.jpeg
// Layout: background biru muda, ilustrasi SVG besar, teks konfirmasi, tombol Ok

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.login),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF1A1A2E),
                    size: 32,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Illustration SVG
            ScaleTransition(
              scale: _scaleAnim,
              child: SvgPicture.asset(
                'assets/svg/illus_success.svg',
                width: MediaQuery.of(context).size.width * 0.75,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            FadeTransition(
              opacity: _fadeAnim,
              child: const Text(
                'Pendaftaran akun berhasil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: const Text(
                  'Pendaftaranmu berhasil. Kami telah mengirimkan tautan verifikasi ke emailmu untuk memastikan akunmu aman. Silakan cek kotak masuk (atau folder spam) untuk melanjutkan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF333333),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const Spacer(),

            // Ok Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Resend
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
                children: [
                  const TextSpan(text: 'Pesan belum terkirim? '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'resend verification',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
