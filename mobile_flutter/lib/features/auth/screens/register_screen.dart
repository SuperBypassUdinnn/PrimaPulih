// Register Screen — PrimaPulih
// Referensi mockup: IMG_00002.jpeg
// Layout: background biru muda penuh, form dengan label bold, toggle Pasien/Dokter

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isPatient = true;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;

  late AnimationController _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _toggleAnim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _setRole(bool isPatient) {
    setState(() {
      _isPatient = isPatient;
      if (isPatient) {
        _toggleAnim.reverse();
      } else {
        _toggleAnim.forward();
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui syarat dan ketentuan terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      fullName: _nameCtrl.text.trim(),
      role: _isPatient ? UserRole.patient : UserRole.healthWorker,
    );
    if (!mounted) return;
    if (ok) {
      context.pushReplacement(AppRoutes.registerSuccess);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Pendaftaran gagal. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1A1A2E),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Daftar Akun',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Text(
                  'Membuat akun untuk memulai',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 28),

                // Nama Pasien
                _FieldLabel(label: _isPatient ? 'Nama Pasien' : 'Nama Dokter/Perawat'),
                const SizedBox(height: 6),
                _RegTextField(
                  controller: _nameCtrl,
                  hint: _isPatient ? 'Dhini' : 'Dr. Sarah',
                  isFirst: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Email
                const _FieldLabel(label: 'Alamat Email'),
                const SizedBox(height: 6),
                _RegTextField(
                  controller: _emailCtrl,
                  hint: 'nama@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kata Sandi
                const _FieldLabel(label: 'Kata Sandi'),
                const SizedBox(height: 6),
                _RegTextField(
                  controller: _passwordCtrl,
                  hint: 'Buat kata sandi',
                  isPassword: true,
                  obscure: _obscurePass,
                  onToggleObscure: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                    if (v.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Konfirmasi Kata Sandi
                _RegTextField(
                  controller: _confirmCtrl,
                  hint: 'konfirmasi kata sandi',
                  isPassword: true,
                  obscure: _obscureConfirm,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Kata sandi tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Role Toggle — Pasien | Dokter atau Perawat
                _RoleToggle(
                  isPatient: _isPatient,
                  onSelectPatient: () => _setRole(true),
                  onSelectDoctor: () => _setRole(false),
                ),
                const SizedBox(height: 20),

                // Terms & Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (v) =>
                            setState(() => _agreeToTerms = v ?? false),
                        activeColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF555555),
                          ),
                          children: [
                            TextSpan(text: 'Saya telah membaca dan menyetujui '),
                            TextSpan(
                              text: 'Syarat dan Ketentuan',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' serta '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Daftar Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Already have account
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
                      children: [
                        const TextSpan(text: 'Sudah punya akun? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: const Text(
                              'Masuk sekarang',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Field Label
// ─────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Register TextField — outlined, persis mockup
// ─────────────────────────────────────────────

class _RegTextField extends StatelessWidget {
  const _RegTextField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.validator,
    this.isFirst = false,
  });
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscure,
      keyboardType: keyboardType,
      validator: validator,
      autofocus: isFirst,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFFAAAAAA),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFFAAAAAA),
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Role Toggle — persis mockup (biru kiri untuk pasien)
// ─────────────────────────────────────────────

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
    required this.isPatient,
    required this.onSelectPatient,
    required this.onSelectDoctor,
  });
  final bool isPatient;
  final VoidCallback onSelectPatient;
  final VoidCallback onSelectDoctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
      ),
      child: Row(
        children: [
          // Pasien
          Expanded(
            child: GestureDetector(
              onTap: onSelectPatient,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isPatient
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Pasien',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isPatient
                          ? Colors.white
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Dokter atau Perawat
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onSelectDoctor,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isPatient
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Dokter atau Perawat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !isPatient
                          ? Colors.white
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
