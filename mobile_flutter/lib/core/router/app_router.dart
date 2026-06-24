// App Router — GoRouter configuration untuk PrimaPulih

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/register_success_screen.dart';
import '../../features/home/screens/patient_home_screen.dart';
import '../../features/home/screens/doctor_home_screen.dart';
import '../../features/assessment/screens/assessment_screen.dart';
import '../../features/assessment/screens/assessment_result_screen.dart';
import '../../features/mood_tracker/screens/mood_tracker_screen.dart';
import '../../features/medication/screens/medication_screen.dart';
import '../../features/medication/screens/add_medication_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/consultation/screens/consultation_screen.dart';
import '../../data/models/models.dart';

/// Nama-nama route sebagai konstanta
class AppRoutes {
  AppRoutes._();

  static const String login             = '/login';
  static const String register          = '/register';
  static const String registerSuccess   = '/register-success';
  static const String patientHome       = '/home';
  static const String doctorHome        = '/doctor-home';
  static const String assessment        = '/assessment';
  static const String assessmentResult  = '/assessment/result';
  static const String moodTracker       = '/mood-tracker';
  static const String medication        = '/medication';
  static const String addMedication     = '/add-medication';
  static const String profile           = '/profile';
  static const String consultation      = '/consultation';
}

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.registerSuccess;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return authProvider.isPatient ? AppRoutes.patientHome : AppRoutes.doctorHome;
      }
      return null;
    },
    routes: [
      // ── AUTH ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registerSuccess,
        name: 'registerSuccess',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const RegisterSuccessScreen(),
        ),
      ),

      // ── HOME ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.patientHome,
        name: 'patientHome',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const PatientHomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.doctorHome,
        name: 'doctorHome',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const DoctorHomeScreen(),
        ),
      ),

      // ── ASSESSMENT ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.assessment,
        name: 'assessment',
        pageBuilder: (context, state) {
          final type = state.uri.queryParameters['type'] == 'gad7'
              ? AssessmentType.gad7
              : AssessmentType.phq9;
          return _buildPage(
            state: state,
            child: AssessmentScreen(type: type),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.assessmentResult,
        name: 'assessmentResult',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const AssessmentResultScreen(),
        ),
      ),

      // ── MOOD TRACKER ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.moodTracker,
        name: 'moodTracker',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const MoodTrackerScreen(),
        ),
      ),

      // ── MEDICATION ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.medication,
        name: 'medication',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const MedicationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.addMedication,
        name: 'addMedication',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const AddMedicationScreen(),
        ),
      ),

      // ── PROFILE ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),

      // ── CONSULTATION ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.consultation,
        name: 'consultation',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const ConsultationScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.error}'),
      ),
    ),
  );
}

CustomTransitionPage _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}
