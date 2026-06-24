// Assessment Question Widget — PrimaPulih
// Referensi: mockup IMG_00009
// Layout: nomor + teks bold, lalu selector row abu-biru dengan 0/1/2/3

import 'package:flutter/material.dart';
import '../../../data/models/models.dart';

class AssessmentQuestionWidget extends StatelessWidget {
  const AssessmentQuestionWidget({
    super.key,
    required this.question,
    required this.selectedScore,
    required this.onScoreSelected,
  });

  final AssessmentQuestion question;
  final int? selectedScore;
  final void Function(int score) onScoreSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text — bold, persis mockup
          Text(
            '${question.number}. ${question.text}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Score Row — satu strip abu-biru dengan 4 pilihan
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFD6E8F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(4, (i) {
                final isSelected = selectedScore == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onScoreSelected(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$i',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFF888888),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
