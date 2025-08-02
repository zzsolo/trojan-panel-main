package core

import (
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	Redis    RedisConfig
	GRPC     GRPCConfig
	JWT      JWTConfig
	Email    EmailConfig
	Log      LogConfig
}

type ServerConfig struct {
	Port    int
	RunMode string
	Timeout time.Duration
}

type DatabaseConfig struct {
	Type        string
	User        string
	Password    string
	Host        string
	Port        int
	Name        string
	TablePrefix string
	Charset     string
	ParseTime   bool
	MaxIdle     int
	MaxOpen     int
}

type RedisConfig struct {
	Host        string
	Port        int
	Password    string
	Database    int
	MaxIdle     int
	MaxActive   int
	IdleTimeout time.Duration
}

type GRPCConfig struct {
	Host string
	Port int
}

type JWTConfig struct {
	Secret     string
	ExpireTime time.Duration
	Issuer     string
}

type EmailConfig struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
	SSL      bool
}

type LogConfig struct {
	Level      string
	Path       string
	MaxSize    int
	MaxBackups int
	MaxAge     int
	Compress   bool
}

func InitConfig() *Config {
	return &Config{
		Server: ServerConfig{
			Port:    getEnvAsInt("SERVER_PORT", 8080),
			RunMode: getEnv("GIN_MODE", "debug"),
			Timeout: getEnvAsDuration("SERVER_TIMEOUT", 60*time.Second),
		},
		Database: DatabaseConfig{
			Type:        "mysql",
			User:        getEnv("DB_USER", "trojan_panel"),
			Password:    getEnv("DB_PASSWORD", "your_password"),
			Host:        getEnv("DB_HOST", "localhost"),
			Port:        getEnvAsInt("DB_PORT", 3306),
			Name:        getEnv("DB_NAME", "trojan_panel_db"),
			TablePrefix: getEnv("DB_TABLE_PREFIX", "trojan_panel_"),
			Charset:     "utf8mb4",
			ParseTime:   true,
			MaxIdle:     getEnvAsInt("DB_MAX_IDLE", 10),
			MaxOpen:     getEnvAsInt("DB_MAX_OPEN", 100),
		},
		Redis: RedisConfig{
			Host:        getEnv("REDIS_HOST", "localhost"),
			Port:        getEnvAsInt("REDIS_PORT", 6379),
			Password:    getEnv("REDIS_PASSWORD", ""),
			Database:    getEnvAsInt("REDIS_DB", 0),
			MaxIdle:     getEnvAsInt("REDIS_MAX_IDLE", 10),
			MaxActive:   getEnvAsInt("REDIS_MAX_ACTIVE", 100),
			IdleTimeout: getEnvAsDuration("REDIS_IDLE_TIMEOUT", 300*time.Second),
		},
		GRPC: GRPCConfig{
			Host: getEnv("GRPC_HOST", "localhost"),
			Port: getEnvAsInt("GRPC_PORT", 8081),
		},
		JWT: JWTConfig{
			Secret:     getEnv("JWT_SECRET", "your-secret-key-change-me-in-production"),
			ExpireTime: getEnvAsDuration("JWT_EXPIRE", 24*time.Hour),
			Issuer:     getEnv("JWT_ISSUER", "trojan-panel-backend"),
		},
		Email: EmailConfig{
			Host:     getEnv("EMAIL_HOST", "smtp.gmail.com"),
			Port:     getEnvAsInt("EMAIL_PORT", 587),
			Username: getEnv("EMAIL_USERNAME", ""),
			Password: getEnv("EMAIL_PASSWORD", ""),
			From:     getEnv("EMAIL_FROM", "admin@trojanpanel.com"),
			SSL:      getEnvAsBool("EMAIL_SSL", false),
		},
		Log: LogConfig{
			Level:      getEnv("LOG_LEVEL", "info"),
			Path:       getEnv("LOG_PATH", "./logs"),
			MaxSize:    getEnvAsInt("LOG_MAX_SIZE", 100),
			MaxBackups: getEnvAsInt("LOG_MAX_BACKUPS", 10),
			MaxAge:     getEnvAsInt("LOG_MAX_AGE", 30),
			Compress:   getEnvAsBool("LOG_COMPRESS", true),
		},
	}
}

// Helper functions for environment variables
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	strValue := getEnv(key, "")
	if value, err := strconv.Atoi(strValue); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
	strValue := getEnv(key, "")
	if value, err := strconv.ParseBool(strValue); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
	strValue := getEnv(key, "")
	if value, err := time.ParseDuration(strValue); err == nil {
		return value
	}
	return defaultValue
}