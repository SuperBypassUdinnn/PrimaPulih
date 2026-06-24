package handlers

import (
	"backend_go/config"
	"backend_go/models"
	"context"

	"github.com/gofiber/fiber/v2"
)

func AddMedication(c *fiber.Ctx) error {
	// Usually prescribed by health worker, but for simplicity, allow patient to add their own or let it be flexible
	var req models.MedicationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}
	
	patientID := c.Query("patient_id")
	if patientID == "" {
		userID := c.Locals("user_id").(string)
		_ = config.DB.QueryRow(context.Background(), "SELECT id FROM patients WHERE user_id = $1", userID).Scan(&patientID)
	}

	var medID string
	err := config.DB.QueryRow(context.Background(), 
		"INSERT INTO medications (patient_id, medicine_name, time_of_day) VALUES ($1, $2, $3) RETURNING id",
		patientID, req.MedicineName, req.TimeOfDay).Scan(&medID)
		
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to add medication"})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Medication added successfully",
		"id":      medID,
	})
}

func GetMedications(c *fiber.Ctx) error {
	patientID := c.Query("patient_id")
	if patientID == "" {
		userID := c.Locals("user_id").(string)
		err := config.DB.QueryRow(context.Background(), "SELECT id FROM patients WHERE user_id = $1", userID).Scan(&patientID)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "patient_id required"})
		}
	}

	rows, err := config.DB.Query(context.Background(), 
		"SELECT id, medicine_name, time_of_day FROM medications WHERE patient_id = $1", 
		patientID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch medications"})
	}
	defer rows.Close()

	var results []fiber.Map
	for rows.Next() {
		var m models.Medication
		err := rows.Scan(&m.ID, &m.MedicineName, &m.TimeOfDay)
		if err == nil {
			results = append(results, fiber.Map{
				"id":            m.ID,
				"medicine_name": m.MedicineName,
				"time_of_day":   m.TimeOfDay,
			})
		}
	}

	return c.JSON(results)
}

func CheckMedication(c *fiber.Ctx) error {
	var req models.MedicationLogRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}

	var logID string
	err := config.DB.QueryRow(context.Background(), 
		"INSERT INTO medication_logs (medication_id, status) VALUES ($1, $2) RETURNING id",
		req.MedicationID, req.Status).Scan(&logID)
		
	if err != nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": "Medication already checked for today or DB error"})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Medication log recorded successfully",
		"id":      logID,
	})
}
