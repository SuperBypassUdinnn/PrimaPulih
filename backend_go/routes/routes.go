package routes

import (
	"backend_go/handlers"
	"backend_go/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	api := app.Group("/api")

	// Public routes
	auth := api.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	// Protected routes
	protected := api.Group("/", middleware.AuthMiddleware)

	// Assessments (P0)
	assessments := protected.Group("/assessments")
	// Only patients can submit
	assessments.Post("/", middleware.RequireRole("patient"), handlers.SubmitAssessment)
	// Health workers can view all, or specify ?patient_id=xxx
	assessments.Get("/", middleware.RequireRole("health_worker"), handlers.GetAssessments)

	// Daily Logs (P1)
	dailyLogs := protected.Group("/daily-logs")
	dailyLogs.Post("/", middleware.RequireRole("patient"), handlers.SubmitDailyLog)
	dailyLogs.Get("/", handlers.GetDailyLogs) // Both can view

	// Medications (P1)
	medications := protected.Group("/medications")
	medications.Post("/", handlers.AddMedication)
	medications.Get("/", handlers.GetMedications)
	
	medicationLogs := protected.Group("/medication-logs")
	medicationLogs.Post("/", middleware.RequireRole("patient"), handlers.CheckMedication)
}
