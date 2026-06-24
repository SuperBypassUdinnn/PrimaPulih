// Mock Data Source — PrimaPulih
// Menggantikan REST API Golang yang belum siap.
// Struktur data menyerupai respons JSON dari backend.

import '../models/models.dart';

class MockDataSource {
  MockDataSource._();

  // ─── USERS ────────────────────────────────────────────────
  static final List<UserModel> users = [
    const UserModel(
      id: 'usr-001',
      email: 'dhini@email.com',
      role: UserRole.patient,
    ),
    const UserModel(
      id: 'usr-002',
      email: 'dr.sarah@primapulih.id',
      role: UserRole.healthWorker,
    ),
    const UserModel(
      id: 'usr-003',
      email: 'budi@email.com',
      role: UserRole.patient,
    ),
  ];

  // ─── PATIENTS ─────────────────────────────────────────────
  static final List<PatientModel> patients = [
    PatientModel(
      id: 'pat-001',
      userId: 'usr-001',
      fullName: 'Dhini Rahmawati',
      icuDischargeDate: DateTime(2025, 10, 15),
    ),
    PatientModel(
      id: 'pat-002',
      userId: 'usr-003',
      fullName: 'Budi Santoso',
      icuDischargeDate: DateTime(2025, 11, 3),
    ),
  ];

  // ─── HEALTH WORKERS ───────────────────────────────────────
  static final List<HealthWorkerModel> healthWorkers = [
    const HealthWorkerModel(
      id: 'hw-001',
      userId: 'usr-002',
      fullName: 'Dr. Sarah Azizah, Sp.Kj',
      specialization: 'Psikiater Klinis',
    ),
  ];

  // ─── ASSESSMENTS ──────────────────────────────────────────
  static final List<AssessmentModel> assessments = [
    AssessmentModel(
      id: 'asmnt-001',
      patientId: 'pat-001',
      type: AssessmentType.phq9,
      totalScore: 7,
      submittedAt: DateTime(2025, 12, 10),
    ),
    AssessmentModel(
      id: 'asmnt-002',
      patientId: 'pat-001',
      type: AssessmentType.gad7,
      totalScore: 5,
      submittedAt: DateTime(2025, 12, 10),
    ),
    AssessmentModel(
      id: 'asmnt-003',
      patientId: 'pat-001',
      type: AssessmentType.phq9,
      totalScore: 4,
      submittedAt: DateTime(2025, 12, 18),
    ),
    AssessmentModel(
      id: 'asmnt-004',
      patientId: 'pat-002',
      type: AssessmentType.gad7,
      totalScore: 11,
      submittedAt: DateTime(2025, 12, 15),
    ),
  ];

  // ─── DAILY LOGS ───────────────────────────────────────────
  static final List<DailyLogModel> dailyLogs = [
    DailyLogModel(
      id: 'log-001',
      patientId: 'pat-001',
      mood: MoodType.senang,
      loggedAt: DateTime(2025, 12, 23),
    ),
    DailyLogModel(
      id: 'log-002',
      patientId: 'pat-001',
      mood: MoodType.stress,
      loggedAt: DateTime(2025, 12, 22),
    ),
    DailyLogModel(
      id: 'log-003',
      patientId: 'pat-001',
      mood: MoodType.semangat,
      loggedAt: DateTime(2025, 12, 21),
    ),
    DailyLogModel(
      id: 'log-004',
      patientId: 'pat-001',
      mood: MoodType.ngantuk,
      loggedAt: DateTime(2025, 12, 20),
    ),
  ];

  // ─── MEDICATIONS ──────────────────────────────────────────
  static final List<MedicationModel> medications = [
    const MedicationModel(
      id: 'med-001',
      patientId: 'pat-001',
      medicineName: 'Sertraline - 50mg',
      timeOfDay: MedTime.pagi,
      dosage: '1 Tablet  •  Sesudah makan',
    ),
    const MedicationModel(
      id: 'med-002',
      patientId: 'pat-001',
      medicineName: 'Melatonin - 5mg',
      timeOfDay: MedTime.malam,
      dosage: '1 Tablet  •  Sesudah makan',
    ),
    const MedicationModel(
      id: 'med-003',
      patientId: 'pat-002',
      medicineName: 'Alprazolam - 0.5mg',
      timeOfDay: MedTime.siang,
      dosage: '1 Tablet  •  Sesudah makan',
    ),
  ];

  // ─── MEDICATION LOGS ──────────────────────────────────────
  static List<MedicationLogModel> medicationLogs = [
    MedicationLogModel(
      id: 'mlog-001',
      medicationId: 'med-001',
      status: true,
      loggedAt: DateTime(2025, 12, 25),
    ),
    MedicationLogModel(
      id: 'mlog-002',
      medicationId: 'med-002',
      status: false,
      loggedAt: DateTime(2025, 12, 25),
    ),
  ];

  // ─── CONSULTATIONS ────────────────────────────────────────
  static final List<ConsultationModel> consultations = [
    ConsultationModel(
      id: 'con-001',
      doctorName: 'Dr. Sarah Azizah, Sp.Kj',
      specialization: 'Psikiater Klinis',
      scheduledAt: DateTime(2025, 12, 22),
      timeRange: '14.00 - 15.00 WIB',
      meetingLink: 'https://meet.primapulih.id/room/con-001',
    ),
  ];

  // ─── PHQ-9 QUESTIONS ──────────────────────────────────────
  static const List<AssessmentQuestion> phq9Questions = [
    AssessmentQuestion(
      number: 1,
      text: 'Kurang tertarik atau bergairah dalam melakukan apapun',
    ),
    AssessmentQuestion(
      number: 2,
      text: 'Merasa murung, sedih, atau putus asa',
    ),
    AssessmentQuestion(
      number: 3,
      text: 'Sulit tidur atau terlalu banyak tidur',
    ),
    AssessmentQuestion(
      number: 4,
      text: 'Merasa lelah atau tidak bertenaga',
    ),
    AssessmentQuestion(
      number: 5,
      text: 'Kurang nafsu makan atau makan berlebihan',
    ),
    AssessmentQuestion(
      number: 6,
      text: 'Merasa buruk tentang diri sendiri atau merasa gagal',
    ),
    AssessmentQuestion(
      number: 7,
      text: 'Sulit berkonsentrasi pada sesuatu',
    ),
    AssessmentQuestion(
      number: 8,
      text: 'Bergerak atau berbicara sangat lambat, atau gelisah dan tidak bisa diam',
    ),
    AssessmentQuestion(
      number: 9,
      text: 'Memiliki pikiran untuk menyakiti diri sendiri atau lebih baik mati',
    ),
  ];

  // ─── GAD-7 QUESTIONS ──────────────────────────────────────
  static const List<AssessmentQuestion> gad7Questions = [
    AssessmentQuestion(
      number: 1,
      text: 'Merasa gugup, cemas, atau tegang',
    ),
    AssessmentQuestion(
      number: 2,
      text: 'Tidak mampu menghentikan atau mengendalikan rasa khawatir',
    ),
    AssessmentQuestion(
      number: 3,
      text: 'Terlalu banyak mengkhawatirkan berbagai hal',
    ),
    AssessmentQuestion(
      number: 4,
      text: 'Kesulitan untuk rileks',
    ),
    AssessmentQuestion(
      number: 5,
      text: 'Merasa gelisah sehingga sulit untuk diam',
    ),
    AssessmentQuestion(
      number: 6,
      text: 'Mudah tersinggung atau marah',
    ),
    AssessmentQuestion(
      number: 7,
      text: 'Merasa takut seolah sesuatu yang buruk akan terjadi',
    ),
  ];

  // ─── HELPERS ──────────────────────────────────────────────

  static PatientModel? getPatientByUserId(String userId) {
    try {
      return patients.firstWhere((p) => p.userId == userId);
    } catch (_) {
      return null;
    }
  }

  static UserModel? getUserByEmail(String email) {
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<AssessmentModel> getAssessmentsForPatient(String patientId) {
    return assessments.where((a) => a.patientId == patientId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  static List<MedicationModel> getMedicationsForPatient(String patientId) {
    return medications.where((m) => m.patientId == patientId).toList();
  }

  static DailyLogModel? getTodayLog(String patientId) {
    final today = DateTime.now();
    try {
      return dailyLogs.firstWhere(
        (l) =>
            l.patientId == patientId &&
            l.loggedAt.year == today.year &&
            l.loggedAt.month == today.month &&
            l.loggedAt.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }
}
