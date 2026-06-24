// Assessment Result Screen — PrimaPulih
// Layout: header SVG konsisten, score circle animasi, interpretasi, emergency alert jika kritis

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/emergency_alert_dialog.dart';
import '../../../data/models/models.dart';
import '../assessment_provider.dart';

class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({super.key});

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  @override
  void initState() {
    super.initState();
    // Tampilkan emergency alert jika skor sangat tinggi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<AssessmentProvider>();
      final result = prov.lastResult;
      if (result == null) return;
      final isCritical = (result.type == AssessmentType.phq9 &&
              result.totalScore >= 15) ||
          (result.type == AssessmentType.gad7 && result.totalScore >= 10);
      if (isCritical && mounted) {
        EmergencyAlertDialog.show(
          context,
          onContact: () {
            Navigator.pop(context); // dismiss dialog
            context.push(AppRoutes.consultation);
          },
        );
      }
    });
  }

  Color _scoreColor(int score, AssessmentType type) {
    if (type == AssessmentType.phq9) {
      if (score <= 4) return const Color(0xFF2ECC71);
      if (score <= 9) return const Color(0xFF8BC34A);
      if (score <= 14) return const Color(0xFFF39C12);
      if (score <= 19) return const Color(0xFFFF7043);
      return const Color(0xFFE53935);
    } else {
      if (score <= 4) return const Color(0xFF2ECC71);
      if (score <= 9) return const Color(0xFF8BC34A);
      if (score <= 14) return const Color(0xFFF39C12);
      return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssessmentProvider>();
    final result = prov.lastResult;

    if (result == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFD6E8F7),
        body: SafeArea(
          child: Column(
            children: [
              _ResultHeader(),
              const Expanded(
                child: Center(
                  child: Text(
                    'Tidak ada hasil.',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxScore = result.type == AssessmentType.phq9 ? 27 : 21;
    final scoreRatio = result.totalScore / maxScore;
    final color = _scoreColor(result.totalScore, result.type);
    final typeName = result.type == AssessmentType.phq9 ? 'PHQ-9' : 'GAD-7';
    final isCritical = (result.type == AssessmentType.phq9 &&
            result.totalScore >= 15) ||
        (result.type == AssessmentType.gad7 && result.totalScore >= 10);

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────
            _ResultHeader(),

            // ── Content ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // Animated Score Circle
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: scoreRatio),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 14,
                                backgroundColor: const Color(0xFFDDDDDD),
                                color: color,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              children: [
                                Icon(
                                  _getScoreIcon(result.totalScore, result.type),
                                  size: 40,
                                  color: color,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${result.totalScore}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  'dari $maxScore',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Interpretation Card
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Interpretasi Skor $typeName',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1.5),
                            ),
                            child: Text(
                              result.interpretation,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.type == AssessmentType.phq9
                                ? '• Skor 0-4: Minimal\n• Skor 5-9: Ringan\n• Skor 10-14: Sedang\n• Skor 15-19: Cukup Berat\n• Skor 20-27: Berat'
                                : '• Skor 0-4: Minimal\n• Skor 5-9: Ringan\n• Skor 10-14: Sedang\n• Skor 15-21: Berat',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFF666666),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Warning card if score high
                    if (isCritical)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFEF9A9A), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFE53935), size: 26),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Disarankan untuk segera berkonsultasi dengan tenaga kesehatan profesional.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: Color(0xFFE53935),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Back to Home
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.patientHome),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tes Lainnya
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          prov.reset();
                          final otherType = result.type == AssessmentType.phq9
                              ? 'gad7'
                              : 'phq9';
                          context.pushReplacement(
                              '${AppRoutes.assessment}?type=$otherType');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF2563EB), width: 1.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Tes Lainnya',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getScoreIcon(int score, AssessmentType type) {
    final maxScore = type == AssessmentType.phq9 ? 27 : 21;
    final ratio = score / maxScore;
    if (ratio < 0.2) return Icons.sentiment_very_satisfied_rounded;
    if (ratio < 0.4) return Icons.sentiment_satisfied_rounded;
    if (ratio < 0.6) return Icons.sentiment_neutral_rounded;
    if (ratio < 0.8) return Icons.sentiment_dissatisfied_rounded;
    return Icons.sentiment_very_dissatisfied_rounded;
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.patientHome),
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
