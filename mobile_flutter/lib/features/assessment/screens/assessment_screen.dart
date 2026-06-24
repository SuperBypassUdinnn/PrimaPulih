// Assessment Screen — PHQ-9 & GAD-7
// Referensi mockup: IMG_00009.jpeg

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/mock/mock_data_source.dart';
import '../../auth/auth_provider.dart';
import '../assessment_provider.dart';
import '../widgets/assessment_question_widget.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, required this.type});
  final AssessmentType type;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  List<AssessmentQuestion> get _questions => widget.type == AssessmentType.phq9
      ? MockDataSource.phq9Questions
      : MockDataSource.gad7Questions;

  String get _title =>
      widget.type == AssessmentType.phq9 ? 'PHQ-9' : 'GAD-7';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().startAssessment(widget.type);
    });
  }

  Future<void> _handleSubmit() async {
    final prov = context.read<AssessmentProvider>();
    if (!prov.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua pertanyaan terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    await prov.submitAssessment(
      patientId: auth.currentPatient?.id ?? 'pat-001',
      type: widget.type,
    );
    if (!mounted) return;
    context.push(AppRoutes.assessmentResult);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssessmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            _AssessmentHeader(),

            // ── Gradient Title Strip ─────────────────────
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
                'Tes PHQ-9 dan GAD-10',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),

            // ── Question List ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Instructions
                    Text(
                      _title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.type == AssessmentType.phq9
                          ? 'Petunjuk: Dalam 2 minggu terakhir, seberapa sering Anda mengalami hal-hal berikut?'
                          : 'Petunjuk: Selama 2 minggu terakhir, seberapa sering Anda terganggu oleh hal-hal berikut?',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Skor: 0 = tidak sama sekali, 1 = beberapa hari, 2 = lebih dari setengah hari, 3 = hampir setiap hari',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF777777),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Questions
                    ...List.generate(_questions.length, (i) {
                      return AssessmentQuestionWidget(
                        question: _questions[i],
                        selectedScore: prov.getAnswer(i),
                        onScoreSelected: (score) => prov.setAnswer(i, score),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: prov.isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: prov.isComplete
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFB0C4D8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: prov.isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Kirim Hasil',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _AssessmentHeader extends StatelessWidget {
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
