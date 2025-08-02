# Trojan Panel Backend

## Overview
This is the REST API backend for the Trojan Panel management system, built with Go and Gin framework.

## Architecture
- **Framework**: Gin web framework
- **Database**: MySQL with GORM ORM
- **Cache**: Redis
- **Authentication**: JWT tokens
- **Authorization**: Casbin RBAC
- **Communication**: gRPC client for node communication

## Directory Structure
```
trojan-panel-backend/
├── api/                    # REST API handlers
├── config/                 # Configuration files
│   ├── config.ini         # Main configuration
│   └── rbac_model.conf    # Casbin RBAC model
├── core/                   # Core initialization
│   ├── config.go          # Configuration management
│   ├── database.go        # Database initialization
│   ├── redis.go           # Redis client
│   ├── grpc.go            # gRPC client
│   └── casbin.go          # RBAC initialization
├── dao/                    # Data access layer
├── middleware/             # HTTP middleware
│   ├── auth.go            # JWT authentication
│   ├── cors.go            # CORS handling
│   ├── logger.go          # Request logging
│   ├── recovery.go        # Panic recovery
│   └── rate_limiter.go    # Rate limiting
├── model/                  # Data models
│   ├── user.go            # User model
│   ├── node.go            # Node model
│   └── account.go         # Account model
├── router/                 # Route definitions
├── service/                # Business logic
├── testing/                # Test files
├── Dockerfile              # Docker configuration
├── go.mod                  # Go module definition
├── main.go                 # Application entry point
└── .github/workflows/      # CI/CD workflows
    └── docker-build-push.yml
```

## Quick Start

### Development
```bash
cd trojan-panel-backend
go mod tidy
go run main.go
```

### Production
```bash
# Build Docker image
docker build -t trojan-panel-backend .

# Run with Docker
docker run -p 8080:8080 trojan-panel-backend
```

## Configuration
Configure the application by editing `config/config.ini` or setting environment variables:

- `DB_HOST`: MySQL host
- `DB_USER`: MySQL username
- `DB_PASSWORD`: MySQL password
- `DB_NAME`: Database name
- `REDIS_HOST`: Redis host
- `REDIS_PORT`: Redis port
- `JWT_SECRET`: JWT signing secret
- `GRPC_HOST`: gRPC server host
- `GRPC_PORT`: gRPC server port

## Features
- User management with RBAC
- Node management for multiple proxy protocols
- Account management with traffic limits
- Subscription service
- Email notifications
- Health monitoring
- Rate limiting
- JWT authentication

## API Endpoints
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `GET /api/v1/users/profile` - Get user profile
- `GET /api/v1/nodes` - List nodes
- `POST /api/v1/nodes` - Create node
- `GET /api/v1/accounts` - List accounts
- `POST /api/v1/accounts` - Create account
- `GET /api/v1/subscription/:token` - Get subscription config

## License
Apache 2.0