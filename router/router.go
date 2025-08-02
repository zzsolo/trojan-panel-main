package router

import (
	"time"
	"trojan-panel-backend/core"
	"trojan-panel-backend/middleware"

	"github.com/gin-gonic/gin"
)

type Dependencies struct {
	Config      *core.Config
	DB          interface{}
	Redis       interface{}
	GRPCClient  *core.GRPCClient
	Enforcer    interface{}
}

// SetupRouter configures the HTTP routes
func SetupRouter(router *gin.Engine, deps *Dependencies) {
	// Global middleware
	router.Use(middleware.CORS())
	router.Use(middleware.Logger())
	router.Use(middleware.Recovery())
	router.Use(middleware.RateLimiter(deps.Redis))

	// API routes
	api := router.Group("/api/v1")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/login")
			auth.POST("/register")
			auth.POST("/logout")
			auth.POST("/refresh")
		}

		// User routes
		users := api.Group("/users")
		users.Use(middleware.Auth())
		{
			users.GET("/profile")
			users.PUT("/profile")
			users.PUT("/password")
		}

		// Node routes
		nodes := api.Group("/nodes")
		nodes.Use(middleware.Auth())
		{
			nodes.GET("")
			nodes.POST("")
			nodes.GET("/:id")
			nodes.PUT("/:id")
			nodes.DELETE("/:id")
			nodes.GET("/:id/status")
		}

		// Account routes
		accounts := api.Group("/accounts")
		accounts.Use(middleware.Auth())
		{
			accounts.GET("")
			accounts.POST("")
			accounts.GET("/:id")
			accounts.PUT("/:id")
			accounts.DELETE("/:id")
			accounts.GET("/:id/traffic")
		}

		// Subscription routes
		subscription := api.Group("/subscription")
		subscription.Use(middleware.Auth())
		{
			subscription.GET("/:token")
			subscription.POST("/refresh/:id")
		}

		// System routes
		system := api.Group("/system")
		system.Use(middleware.Auth())
		{
			system.GET("/settings")
			system.PUT("/settings")
			system.GET("/stats")
		}
	}

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
			"time":   time.Now().Format(time.RFC3339),
		})
	})

	// Swagger documentation
	// router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
}