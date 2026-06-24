// Doctor Home Screen — PrimaPulih
// Tampilan Dashboard Premium untuk Tenaga Kesehatan

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../auth/auth_provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final ApiClient _api = ApiClient();
  bool _isLoading = true;
  List<dynamic> _assessments = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await _api.get('/assessments');
      if (response.statusCode == 200) {
        setState(() {
          _assessments = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUser?.email.split('@').first ?? 'Dokter';

    // Hitung statistik
    final int totalAssessments = _assessments.length;
    final int criticalCount = _assessments.where((a) {
      final score = a['total_score'] as int;
      final type = a['type'] as String;
      return (type == 'PHQ-9' && score >= 15) || (type == 'GAD-7' && score >= 10);
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Dr. $userName',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pantau kondisi pasien Anda hari ini',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFD6E8F7),
                    child: SvgPicture.asset(
                      'assets/svg/logo_primapulih.svg',
                      width: 28,
                    ),
                  ),
                ],
              ),
            ),

            // ── Statistik Cards ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Asesmen',
                      value: '$totalAssessments',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Pasien Kritis',
                      value: '$criticalCount',
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFE53935),
                      isAlert: criticalCount > 0,
                    ),
                  ),
                ],
              ),
            ),

            // ── Recent Assessments List ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: const Text(
                'Asesmen Terbaru',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _assessments.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada data asesmen pasien.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF888888),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchDashboardData,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                            itemCount: _assessments.length,
                            itemBuilder: (context, index) {
                              final data = _assessments[index];
                              return _AssessmentCard(data: data);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addMedication),
        backgroundColor: const Color(0xFF2563EB),
        tooltip: 'Tambah Resep Obat',
        child: const Icon(Icons.medication_rounded, color: Colors.white),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFFEBEE) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isAlert ? const Color(0xFFEF9A9A) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String;
    final score = data['total_score'] as int;
    final patientName = data['patient_name'] as String;
    // Format date simple
    final dateStr = data['submitted_at'].toString().split('T').first;

    // Determine severity
    bool isCritical = false;
    Color severityColor = const Color(0xFF8BC34A);
    String severityText = 'Aman';

    if (type == 'PHQ-9') {
      if (score >= 15) {
        isCritical = true;
        severityColor = const Color(0xFFE53935);
        severityText = 'Kritis';
      } else if (score >= 10) {
        severityColor = const Color(0xFFF39C12);
        severityText = 'Sedang';
      }
    } else {
      if (score >= 10) {
        isCritical = true;
        severityColor = const Color(0xFFE53935);
        severityText = 'Kritis';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCritical
            ? Border.all(color: const Color(0xFFEF9A9A), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Score Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: severityColor, width: 2),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: severityColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              severityText,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
