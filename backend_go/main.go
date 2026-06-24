package main

import (
	"backend_go/config"
	"backend_go/routes"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main() {
	// Connect to Database
	config.ConnectDB()

	// Initialize Fiber app
	app := fiber.New()

	// Middleware
	app.Use(logger.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
	}))

	// Setup Routes
	routes.SetupRoutes(app)

	// Health check
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("PrimaPulih API is running!")
	})

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server listening on port %s", port)
	log.Fatal(app.Listen(":" + port))
}
