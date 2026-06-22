// Login Screen — PrimaPulih
// Referensi mockup: IMG_00001.jpeg

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/router/app_router.dart';
import '../auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    // Router redirect otomatis mengarahkan ke home jika sukses
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Logo Section ──────────────────────────────
                _LogoSection(fadeAnim: _fadeAnim),

                // ── Form Section ──────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang di\nPrimaPulih!',
                              style: AppTextStyles.displayMedium,
                            ),
                            const SizedBox(height: 28),

                            // Email
                            AppTextField(
                              hint: 'Alamat Email',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!v.contains('@')) return 'Email tidak valid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password
                            AppTextField(
                              hint: 'Kata Sandi',
                              controller: _passwordCtrl,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline_rounded,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Kata sandi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Lupa password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Lupa kata sandi?',
                                  style: AppTextStyles.link,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Login Button
                            AppButton(
                              label: 'Login',
                              isLoading: auth.isLoading,
                              onPressed: _handleLogin,
                            ),
                            const SizedBox(height: 20),

                            // Daftar sekarang
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Belum ada akun? ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.register),
                                  child: Text(
                                    'Daftar sekarang',
                                    style: AppTextStyles.link,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Atau lanjutkan dengan',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Social Login Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  color: const Color(0xFFDB4437),
                                  onTap: () {},
                                ),
                                const SizedBox(width: 16),
                                _SocialButton(
                                  icon: Icons.apple_rounded,
                                  color: const Color(0xFF1A1A1A),
                                  onTap: () {},
                                ),
                                const SizedBox(width: 16),
                                _SocialButton(
                                  icon: Icons.facebook_rounded,
                                  color: const Color(0xFF1877F2),
                                  onTap: () {},
                                ),
                              ],
                            ),

                            // Demo hint
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bgLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💡 Demo Login',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pasien: dhini@email.com\nDokter: dr.sarah@primapulih.id\n(password: apapun)',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.fadeAnim});
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PRIMAPULIH',
              style: AppTextStyles.headingLarge.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Telemedicine Rehabilitasi Mental',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
