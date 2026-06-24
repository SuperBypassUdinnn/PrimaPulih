package handlers

import (
	"backend_go/config"
	"backend_go/models"
	"context"
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

func Register(c *fiber.Ctx) error {
	var req models.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}

	if req.Role != "patient" && req.Role != "health_worker" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid role"})
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to hash password"})
	}

	ctx := context.Background()
	tx, err := config.DB.Begin(ctx)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Database error"})
	}
	defer func() {
		_ = tx.Rollback(ctx)
	}()

	var userID string
	err = tx.QueryRow(ctx, "INSERT INTO users (email, password_hash, role) VALUES ($1, $2, $3) RETURNING id",
		req.Email, string(hashedPassword), req.Role).Scan(&userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create user. Email might exist."})
	}

	switch req.Role {
	case "patient":
		_, err = tx.Exec(ctx, "INSERT INTO patients (user_id, full_name, icu_discharge_date) VALUES ($1, $2, $3)",
			userID, req.FullName, req.ICUDischargeDate)
	case "health_worker":
		_, err = tx.Exec(ctx, "INSERT INTO health_workers (user_id, full_name, specialization) VALUES ($1, $2, $3)",
			userID, req.FullName, req.Specialization)
	}

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create profile"})
	}

	if err := tx.Commit(ctx); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to commit transaction"})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "User registered successfully", "user_id": userID})
}

func Login(c *fiber.Ctx) error {
	var req models.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid payload"})
	}

	var user models.User
	err := config.DB.QueryRow(context.Background(), "SELECT id, email, password_hash, role FROM users WHERE email = $1", req.Email).
		Scan(&user.ID, &user.Email, &user.PasswordHash, &user.Role)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid email or password"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid email or password"})
	}

	// Create JWT token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	})

	secret := os.Getenv("JWT_SECRET")
	t, err := token.SignedString([]byte(secret))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Could not login"})
	}

	// Also fetch specific profile ID for frontend convenience
	var profileID string
	switch user.Role {
	case "patient":
		_ = config.DB.QueryRow(context.Background(), "SELECT id FROM patients WHERE user_id = $1", user.ID).Scan(&profileID)
	case "health_worker":
		_ = config.DB.QueryRow(context.Background(), "SELECT id FROM health_workers WHERE user_id = $1", user.ID).Scan(&profileID)
	}

	return c.JSON(fiber.Map{
		"token":      t,
		"user_id":    user.ID,
		"role":       user.Role,
		"profile_id": profileID,
	})
}
