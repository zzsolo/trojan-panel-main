# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive Trojan Panel management system consisting of three main components:

1. **trojan-panel-backend**: Main backend application with REST API and admin panel
2. **trojan-panel-core**: Core proxy node management service with gRPC API
3. **trojan-panel-ui**: Frontend web interface (pre-built static files)

The system manages multiple proxy protocols including Trojan, Trojan-Go, Xray-core, Hysteria, Hysteria2, and NaiveProxy.

## Build and Development Commands

### Backend (trojan-panel-backend)
```bash
# Install garble for obfuscation
go install mvdan.cc/garble@v0.10.1

# Build using provided scripts
./auto-build.sh          # Linux
./auto-build.bat         # Windows

# Manual build for Linux amd64
SET CGO_ENABLED=0
SET GOOS=linux
SET GOARCH=amd64
garble -literals -tiny build -o build/trojan-panel-linux-amd64 -trimpath -ldflags "-s -w -buildid="

# Run tests
go test ./testing/...
```

### Core (trojan-panel-core)
```bash
# Build using provided scripts
./build.sh               # Linux
./compile.bat            # Windows

# Individual component compilation
./compile-trojan-go.bat
./compile-xray.bat
./compile-hysteria.bat
./compile-hysteria2.bat
./compile-naiveproxy.bat

# Run tests
go test ./testing/...
```

### Docker Commands
```bash
# Multi-architecture build for backend
docker buildx build -t jonssonyan/trojan-panel:latest --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x --push .

# Build core service
docker build -t trojan-panel-core:latest .
```

## Architecture

### System Overview
The system operates as a distributed proxy management platform:
- **Backend**: Admin panel and user management API (Port configurable, default 8080)
- **Core**: Proxy node management service (Port configurable, default 8081)
- **UI**: Static web interface served by the backend
- **Database**: MySQL for persistent storage, Redis for caching and session management
- **Proxy Nodes**: Individual proxy servers managed by the core service

### Backend Architecture (trojan-panel-backend)
- **main.go**: Entry point, initializes configurations and starts HTTP server
- **core/**: Configuration management and gRPC API definitions
- **dao/**: Data access layer with MySQL and Redis support
- **service/**: Business logic for accounts, nodes, subscriptions, emails
- **api/**: HTTP API handlers with request validation
- **router/**: HTTP routing with authentication and authorization middleware
- **middleware/**: JWT, rate limiting, logging, RBAC (Casbin)
- **model/**: Domain models with BOs, DTOs, VOs, and constants

### Core Architecture (trojan-panel-core)
- **main.go**: Entry point, initializes gRPC server and proxy applications
- **app/**: Protocol-specific implementations (Xray, Trojan-Go, Hysteria, NaiveProxy)
- **core/**: Configuration and process management
- **api/**: gRPC API handlers for node management
- **dao/**: Data access with MySQL, SQLite, and Redis
- **service/**: Account and node configuration management

### Key Features
- **Multi-Protocol Support**: Trojan, Trojan-Go, Xray-core, Hysteria1/2, NaiveProxy
- **User Management**: Role-based access (sysadmin, admin, user) with quotas
- **Node Management**: Dynamic proxy node configuration and monitoring
- **Subscription Service**: Auto-generate client configurations
- **Dashboard**: Real-time system statistics and monitoring
- **Email Integration**: Account notifications and password recovery
- **gRPC Communication**: Secure node-backend communication

### Database Schema
Main entities in MySQL:
- **Accounts**: User credentials, quotas, traffic limits, IP restrictions
- **Node Types**: Supported proxy protocols and configurations
- **Nodes**: Individual proxy server instances
- **Node Servers**: Physical servers hosting multiple nodes
- **Roles**: RBAC role definitions and permissions
- **System Settings**: Global configuration parameters
- **Blacklists**: IP and domain blocking rules

### Communication Flow
1. User requests → Backend API → Authentication/Authorization
2. Backend → Core service (gRPC) → Proxy node configuration
3. Proxy nodes → Core service → Traffic statistics
4. Core → Backend → Database updates and caching

## Configuration

### Backend Configuration
- **config/config.ini**: Main configuration (auto-generated on first run)
- **config/rbac_model.conf**: Casbin RBAC model
- **config/template/**: Proxy configuration templates
- Environment variables override config file settings

### Core Configuration
- **core/config.go**: Configuration structure and defaults
- **app/**: Protocol-specific configuration templates
- SQLite for local node data, MySQL for centralized management

### Security Features
- JWT-based authentication with refresh tokens
- Role-based access control using Casbin
- Rate limiting on API endpoints
- Request validation and sanitization
- Encrypted password storage
- gRPC token authentication for node communication
- Redis-based session management

## Development Notes

### Code Structure Patterns
- **Layered Architecture**: router → api → middleware → service → dao → model
- **Dependency Injection**: Through initialization functions
- **Validation**: Using validator/v10 for request validation
- **Logging**: Structured logging with logrus
- **Error Handling**: Consistent error response format

### Database Migrations
- SQL migration files in `resource/sql/`
- Version-based migrations (v1.3.0 through v2.3.0)
- Manual execution required for updates

### Testing
- Unit tests in `testing/` directories
- Focus on service layer and utility functions
- Integration tests for API endpoints

### Build Process
- Uses garble for code obfuscation
- Cross-platform compilation support
- Multi-architecture Docker builds
- Automated build scripts for CI/CD

## Important Notes

- The backend creates necessary configuration files on first run
- Database connections are pooled and properly closed on shutdown
- All proxy node communications use gRPC with token authentication
- The system supports both centralized and distributed deployment models
- Redis is used for caching, rate limiting, and session management
- Email service requires proper SMTP configuration
- The UI is pre-built and served as static files from the backend