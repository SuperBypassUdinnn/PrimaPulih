package handlers

import (
	"backend_go/config"
	"backend_go/models"
	"context"

	"github.com/gofiber/fiber/v2"
)

func SubmitDailyLog(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)

	var req models.DailyLogRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}

	var patientID string
	err := config.DB.QueryRow(context.Background(), "SELECT id FROM patients WHERE user_id = $1", userID).Scan(&patientID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Patient profile not found"})
	}

	var logID string
	// DB has UNIQUE(patient_id, logged_at) constraint
	err = config.DB.QueryRow(context.Background(), 
		"INSERT INTO daily_logs (patient_id, mood_emoji) VALUES ($1, $2) RETURNING id",
		patientID, req.MoodEmoji).Scan(&logID)
		
	if err != nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": "Daily log already submitted for today or DB error"})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Daily log submitted successfully",
		"id":      logID,
	})
}

func GetDailyLogs(c *fiber.Ctx) error {
	patientID := c.Query("patient_id")
	if patientID == "" {
		// If no query param, try to get from logged in patient
		userID := c.Locals("user_id").(string)
		err := config.DB.QueryRow(context.Background(), "SELECT id FROM patients WHERE user_id = $1", userID).Scan(&patientID)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "patient_id required"})
		}
	}

	rows, err := config.DB.Query(context.Background(), 
		"SELECT id, mood_emoji, logged_at FROM daily_logs WHERE patient_id = $1 ORDER BY logged_at DESC", 
		patientID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch daily logs"})
	}
	defer rows.Close()

	var results []fiber.Map
	for rows.Next() {
		var l models.DailyLog
		err := rows.Scan(&l.ID, &l.MoodEmoji, &l.LoggedAt)
		if err == nil {
			results = append(results, fiber.Map{
				"id":         l.ID,
				"mood_emoji": l.MoodEmoji,
				"logged_at":  l.LoggedAt.Format("2006-01-02"),
			})
		}
	}

	return c.JSON(results)
}
