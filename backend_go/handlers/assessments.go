package handlers

import (
	"backend_go/config"
	"backend_go/models"
	"context"

	"github.com/gofiber/fiber/v2"
)

func SubmitAssessment(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)

	var req models.AssessmentRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}

	if req.Type != "PHQ-9" && req.Type != "GAD-7" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid assessment type"})
	}

	var patientID string
	err := config.DB.QueryRow(context.Background(), "SELECT id FROM patients WHERE user_id = $1", userID).Scan(&patientID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Patient profile not found"})
	}

	var assessmentID string
	err = config.DB.QueryRow(context.Background(), 
		"INSERT INTO assessments (patient_id, type, total_score) VALUES ($1, $2, $3) RETURNING id",
		patientID, req.Type, req.TotalScore).Scan(&assessmentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to submit assessment"})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Assessment submitted successfully",
		"id":      assessmentID,
	})
}

func GetAssessments(c *fiber.Ctx) error {
	patientID := c.Query("patient_id")
	
	query := `
		SELECT a.id, a.patient_id, a.type, a.total_score, a.submitted_at, p.full_name
		FROM assessments a
		JOIN patients p ON a.patient_id = p.id
		ORDER BY a.submitted_at DESC
	`
	var args []interface{}
	
	if patientID != "" {
		query = `
			SELECT a.id, a.patient_id, a.type, a.total_score, a.submitted_at, p.full_name
			FROM assessments a
			JOIN patients p ON a.patient_id = p.id
			WHERE a.patient_id = $1
			ORDER BY a.submitted_at DESC
		`
		args = append(args, patientID)
	}

	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch assessments"})
	}
	defer rows.Close()

	var results []fiber.Map
	for rows.Next() {
		var a models.Assessment
		var patientName string
		err := rows.Scan(&a.ID, &a.PatientID, &a.Type, &a.TotalScore, &a.SubmittedAt, &patientName)
		if err == nil {
			results = append(results, fiber.Map{
				"id":           a.ID,
				"patient_id":   a.PatientID,
				"patient_name": patientName,
				"type":         a.Type,
				"total_score":  a.TotalScore,
				"submitted_at": a.SubmittedAt,
			})
		}
	}

	return c.JSON(results)
}
