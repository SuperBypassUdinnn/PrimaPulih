package models

import "time"

type User struct {
	ID           string    `json:"id"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"` // Don't expose password
	Role         string    `json:"role"`
	CreatedAt    time.Time `json:"created_at"`
}

type Patient struct {
	ID               string    `json:"id"`
	UserID           string    `json:"user_id"`
	FullName         string    `json:"full_name"`
	ICUDischargeDate time.Time `json:"icu_discharge_date"` // YYYY-MM-DD
}

type HealthWorker struct {
	ID             string `json:"id"`
	UserID         string `json:"user_id"`
	FullName       string `json:"full_name"`
	Specialization string `json:"specialization"`
}

type Assessment struct {
	ID          string    `json:"id"`
	PatientID   string    `json:"patient_id"`
	Type        string    `json:"type"` // PHQ-9 or GAD-7
	TotalScore  int       `json:"total_score"`
	SubmittedAt time.Time `json:"submitted_at"`
}

type DailyLog struct {
	ID        string    `json:"id"`
	PatientID string    `json:"patient_id"`
	MoodEmoji string    `json:"mood_emoji"`
	LoggedAt  time.Time `json:"logged_at"`
}

type Medication struct {
	ID           string `json:"id"`
	PatientID    string `json:"patient_id"`
	MedicineName string `json:"medicine_name"`
	TimeOfDay    string `json:"time_of_day"` // morning, afternoon, night
}

type MedicationLog struct {
	ID           string    `json:"id"`
	MedicationID string    `json:"medication_id"`
	Status       bool      `json:"status"`
	LoggedAt     time.Time `json:"logged_at"`
}

// Request & Response Structs
type RegisterRequest struct {
	Email            string `json:"email"`
	Password         string `json:"password"`
	Role             string `json:"role"` // patient or health_worker
	FullName         string `json:"full_name"`
	ICUDischargeDate string `json:"icu_discharge_date,omitempty"` // For patient
	Specialization   string `json:"specialization,omitempty"`     // For health_worker
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AssessmentRequest struct {
	Type       string `json:"type"` // PHQ-9 or GAD-7
	TotalScore int    `json:"total_score"`
}

type DailyLogRequest struct {
	MoodEmoji string `json:"mood_emoji"`
}

type MedicationRequest struct {
	MedicineName string `json:"medicine_name"`
	TimeOfDay    string `json:"time_of_day"`
}

type MedicationLogRequest struct {
	MedicationID string `json:"medication_id"`
	Status       bool   `json:"status"`
}
