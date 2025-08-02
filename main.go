package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"trojan-panel-backend/core"
	"trojan-panel-backend/router"

	"github.com/gin-gonic/gin"
)

// @title Trojan Panel Backend API
// @version 2.3.0
// @description REST API backend for Trojan Panel management system
// @termsOfService https://github.com/trojanpanel/trojan-panel-backend

// @contact.name Trojan Panel Team
// @contact.url https://github.com/trojanpanel/trojan-panel-backend
// @contact.email admin@trojanpanel.com

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /api/v1
// @schemes http https
func main() {
	// Initialize configuration
	config := core.InitConfig()
	
	// Initialize database connections
	db := core.InitDatabase(config)
	defer core.CloseDatabase(db)
	
	// Initialize Redis
	redisClient := core.InitRedis(config)
	defer redisClient.Close()
	
	// Initialize gRPC client
	grpcClient := core.InitGRPCClient(config)
	defer grpcClient.Close()
	
	// Initialize Casbin
	enforcer := core.InitCasbin(db)
	
	// Initialize Gin router
	gin.SetMode(config.Server.RunMode)
	r := gin.New()
	
	// Setup router
	router.SetupRouter(r, &router.Dependencies{
		Config:      config,
		DB:          db,
		Redis:       redisClient,
		GRPCClient:  grpcClient,
		Enforcer:    enforcer,
	})
	
	// Create HTTP server
	srv := &http.Server{
		Addr:    fmt.Sprintf(":%d", config.Server.Port),
		Handler: r,
	}
	
	// Start server in goroutine
	go func() {
		log.Printf("Starting Trojan Panel Backend server on port %d", config.Server.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()
	
	// Wait for interrupt signal to gracefully shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")
	
	// Graceful shutdown with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	
	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("Server forced to shutdown: %v", err)
	}
	
	log.Println("Server exited")
}

// Version information
var (
	Version   = "2.3.0"
	BuildTime = "2025-08-02"
	GitCommit = "HEAD"
)

func printVersion() {
	fmt.Printf("Trojan Panel Backend v%s\n", Version)
	fmt.Printf("Build Time: %s\n", BuildTime)
	fmt.Printf("Git Commit: %s\n", GitCommit)
}