// Data Models — PrimaPulih
// Struktur menyerupai skema PostgreSQL di PrimaPulih V2.md

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// 1. MANAJEMEN PENGGUNA
// ─────────────────────────────────────────────

enum UserRole { patient, healthWorker }

class UserModel {
  final String id;
  final String email;
  final String passwordHash; // disimpan sebagai string kosong di mock
  final UserRole role;

  const UserModel({
    required this.id,
    required this.email,
    this.passwordHash = '',
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        passwordHash: json['password_hash'] as String? ?? '',
        role: (json['role'] as String) == 'patient'
            ? UserRole.patient
            : UserRole.healthWorker,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password_hash': passwordHash,
        'role': role == UserRole.patient ? 'patient' : 'health_worker',
      };
}

class PatientModel {
  final String id;
  final String userId;
  final String fullName;
  final DateTime icuDischargeDate;

  const PatientModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.icuDischargeDate,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fullName: json['full_name'] as String,
        icuDischargeDate: DateTime.parse(json['icu_discharge_date'] as String),
      );
}

class HealthWorkerModel {
  final String id;
  final String userId;
  final String fullName;
  final String specialization;

  const HealthWorkerModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.specialization,
  });
}

// ─────────────────────────────────────────────
// 2. ENGINE ASESMEN KLINIS
// ─────────────────────────────────────────────

enum AssessmentType { phq9, gad7 }

class AssessmentModel {
  final String id;
  final String patientId;
  final AssessmentType type;
  final int totalScore;
  final DateTime submittedAt;

  const AssessmentModel({
    required this.id,
    required this.patientId,
    required this.type,
    required this.totalScore,
    required this.submittedAt,
  });

  /// Interpretasi skor PHQ-9
  String get phq9Interpretation {
    if (totalScore <= 4) return 'Minimal / Tidak Ada Depresi';
    if (totalScore <= 9) return 'Depresi Ringan';
    if (totalScore <= 14) return 'Depresi Sedang';
    if (totalScore <= 19) return 'Depresi Cukup Berat';
    return 'Depresi Berat';
  }

  /// Interpretasi skor GAD-7
  String get gad7Interpretation {
    if (totalScore <= 4) return 'Minimal / Tidak Ada Kecemasan';
    if (totalScore <= 9) return 'Kecemasan Ringan';
    if (totalScore <= 14) return 'Kecemasan Sedang';
    return 'Kecemasan Berat';
  }

  String get interpretation =>
      type == AssessmentType.phq9 ? phq9Interpretation : gad7Interpretation;

  factory AssessmentModel.fromJson(Map<String, dynamic> json) => AssessmentModel(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        type: (json['type'] as String) == 'PHQ-9'
            ? AssessmentType.phq9
            : AssessmentType.gad7,
        totalScore: json['total_score'] as int,
        submittedAt: DateTime.parse(json['submitted_at'] as String),
      );
}

// ─────────────────────────────────────────────
// 3. TRACKER KEPATUHAN HARIAN
// ─────────────────────────────────────────────

enum MoodType {
  senang,
  marah,
  sedih,
  bingung,
  stress,
  ngantuk,
  capek,
  semangat,
}

extension MoodTypeExtension on MoodType {
  String get label {
    switch (this) {
      case MoodType.senang:   return 'Senang';
      case MoodType.marah:    return 'Marah';
      case MoodType.sedih:    return 'Sedih';
      case MoodType.bingung:  return 'Bingung';
      case MoodType.stress:   return 'Stress';
      case MoodType.ngantuk:  return 'Ngantuk';
      case MoodType.capek:    return 'Capek';
      case MoodType.semangat: return 'Semangat';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.senang:   return '😊';
      case MoodType.marah:    return '😠';
      case MoodType.sedih:    return '😢';
      case MoodType.bingung:  return '😕';
      case MoodType.stress:   return '😩';
      case MoodType.ngantuk:  return '😴';
      case MoodType.capek:    return '😓';
      case MoodType.semangat: return '💪';
    }
  }
}

class DailyLogModel {
  final String id;
  final String patientId;
  final MoodType mood;
  final DateTime loggedAt;

  const DailyLogModel({
    required this.id,
    required this.patientId,
    required this.mood,
    required this.loggedAt,
  });
}

enum MedTime { pagi, siang, malam }

extension MedTimeExtension on MedTime {
  String get label {
    switch (this) {
      case MedTime.pagi:  return 'Pagi';
      case MedTime.siang: return 'Siang';
      case MedTime.malam: return 'Malam';
    }
  }

  String get icon {
    switch (this) {
      case MedTime.pagi:  return '🌅';
      case MedTime.siang: return '☀️';
      case MedTime.malam: return '🌙';
    }
  }
}

class MedicationModel {
  final String id;
  final String patientId;
  final String medicineName;
  final MedTime timeOfDay;
  final String dosage; // contoh: "1 Tablet - Sesudah makan"

  const MedicationModel({
    required this.id,
    required this.patientId,
    required this.medicineName,
    required this.timeOfDay,
    required this.dosage,
  });
}

class MedicationLogModel {
  final String id;
  final String medicationId;
  final bool status;
  final DateTime loggedAt;

  const MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.status,
    required this.loggedAt,
  });

  MedicationLogModel copyWith({bool? status}) => MedicationLogModel(
        id: id,
        medicationId: medicationId,
        status: status ?? this.status,
        loggedAt: loggedAt,
      );
}

// ─────────────────────────────────────────────
// 4. KONSULTASI (Mock saja, tidak ada di DB spec)
// ─────────────────────────────────────────────

class ConsultationModel {
  final String id;
  final String doctorName;
  final String specialization;
  final DateTime scheduledAt;
  final String timeRange; // "14.00 - 15.00 WIB"
  final String? meetingLink;

  const ConsultationModel({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.scheduledAt,
    required this.timeRange,
    this.meetingLink,
  });
}

// ─────────────────────────────────────────────
// 5. PERTANYAAN ASESMEN
// ─────────────────────────────────────────────

@immutable
class AssessmentQuestion {
  final int number;
  final String text;

  const AssessmentQuestion({required this.number, required this.text});
}
