# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive Trojan Panel management system with three main components:
- **trojan-panel-backend**: REST API backend with admin panel (Go/Gin)
- **trojan-panel-core**: Proxy node management service with gRPC API (Go/Gin)  
- **trojan-panel-ui**: Pre-built Vue.js frontend served as static files

The system manages multiple proxy protocols: Trojan, Trojan-Go, Xray-core, Hysteria1/2, and NaiveProxy across distributed proxy nodes.

## Quick Start Commands

### Development Environment Setup
```bash
# Install garble for obfuscation (required for both components)
go install mvdan.cc/garble@v0.10.1

# Backend development
cd trojan-panel-backend
go mod tidy
go run main.go

# Core development  
cd trojan-panel-core
go mod tidy
go run main.go
```

### Production Build Commands

#### Backend (trojan-panel-backend)
```bash
# Full automated build pipeline
./auto-build.sh                    # Linux/macOS
auto-build.bat                     # Windows

# Manual build for specific platforms
SET CGO_ENABLED=0
SET GOOS=linux
SET GOARCH=amd64
garble -literals -tiny build -o build/trojan-panel-linux-amd64 -trimpath -ldflags "-s -w -buildid="
```

#### Core (trojan-panel-core)
```bash
# Multi-arch Docker build
./build.sh                         # Linux/macOS
compile.bat                        # Windows

# Individual protocol compilation
./compile-trojan-go.bat           # Trojan-Go
./compile-xray.bat               # Xray-core
./compile-hysteria.bat           # Hysteria1
./compile-hysteria2.bat          # Hysteria2  
./compile-naiveproxy.bat         # NaiveProxy
```

### Testing Commands
```bash
# Backend tests
go test ./testing/...
go test ./testing/service/node_test.go

# Core tests
go test ./testing/...
go test ./testing/api/node_api_server_test.go

# Run specific test suites
go test -v ./testing/util/encrypt_test.go
```

### Docker Operations
```bash
# Multi-architecture backend build
docker buildx build -t jonssonyan/trojan-panel:latest --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x --push .

# Core service build
docker build -t trojan-panel-core:latest .

# Docker Compose deployment
cd install-script
docker-compose up -d
```

## Architecture Overview

### System Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   trojan-panel  │    │ trojan-panel-ui  │    │   trojan-panel  │
│    -backend     │◄───┤  (Static Files)  │    │     -core       │
│   (Port 8080)   │    │   Vue.js SPA     │    │   (Port 8081)   │
└─────────────────┘    └──────────────────┘    └──────────────────┘
         │                                                │
         └──────────────────┬─────────────────────────────┘
                           │
         ┌──────────────────┴─────────────────────────────┐
         │              MySQL + Redis                     │
         │         (Persistent Storage)                   │
         └──────────────────┬─────────────────────────────┘
                           │
         ┌──────────────────┴─────────────────────────────┐
         │           Proxy Nodes                        │
         │  (Trojan/Trojan-Go/Xray/Hysteria/NaiveProxy) │
         └────────────────────────────────────────────────┘
```

### Backend Architecture (trojan-panel-backend)
- **main.go**: Entry point with Gin HTTP server initialization
- **core/**: Configuration management, gRPC client, API definitions
- **dao/**: MySQL/Redis data access layer with connection pooling
- **service/**: Business logic for accounts, nodes, subscriptions, email
- **api/**: REST API handlers with request validation (validator/v10)
- **router/**: HTTP routing with middleware chain
- **middleware/**: JWT auth, rate limiting, logging, Casbin RBAC
- **model/**: Domain models (BOs/DTOs/VOs) and constants

### Core Architecture (trojan-panel-core)
- **main.go**: Entry point with gRPC server and Gin HTTP API
- **app/**: Protocol-specific implementations (Xray, Trojan-Go, Hysteria, NaiveProxy)
- **core/**: Configuration management and process control
- **api/**: gRPC API handlers for node management
- **dao/**: Multi-database support (MySQL, SQLite, Redis)
- **service/**: Node configuration and account management
- **router/**: REST API endpoints for node status/metrics

## Key Features

### Multi-Protocol Support
- **Trojan**: Traditional Trojan protocol
- **Trojan-Go**: Enhanced Trojan with WebSocket/gRPC support
- **Xray-core**: Comprehensive proxy platform with VLESS/VMess
- **Hysteria**: UDP-based protocol with QUIC transport
- **Hysteria2**: Next-gen Hysteria with improved performance
- **NaiveProxy**: Chrome-based proxy with HTTP/2 support

### User Management
- **RBAC System**: sysadmin/admin/user roles with Casbin
- **Quota System**: Traffic limits, expiration dates, IP restrictions
- **Subscription Service**: Auto-generated client configs for all protocols
- **Email Integration**: Notifications, password recovery, account alerts

### Node Management
- **Dynamic Configuration**: Real-time node provisioning and updates
- **Health Monitoring**: Node status, traffic statistics, performance metrics
- **Multi-Server Support**: Load balancing across multiple physical servers
- **Protocol Templates**: Pre-configured templates for each proxy type

## Database Schema

### Primary Tables
- **accounts**: User credentials, quotas, expiration, IP restrictions
- **node_types**: Protocol definitions and configuration templates
- **nodes**: Individual proxy server instances with runtime config
- **node_servers**: Physical servers hosting multiple nodes
- **roles**: RBAC role definitions and permission mappings
- **system_settings**: Global configuration parameters
- **blacklists**: IP/domain blocking rules

### Migration Strategy
```bash
# Manual SQL migrations in resource/sql/
trojan_panel_db_v1.3.0.sql → trojan_panel_db_v2.3.0.sql
```

## Configuration Management

### Backend Configuration
- **config/config.ini**: Auto-generated on first run
- **config/rbac_model.conf**: Casbin RBAC policy definitions
- **config/template/**: Proxy configuration templates
- Environment variables override file settings

### Core Configuration  
- **core/config.go**: Runtime configuration structure
- **app/**: Protocol-specific configuration templates
- SQLite for local node data, MySQL for centralized management

## Security Features
- **JWT Authentication**: Access tokens with refresh mechanism
- **Casbin RBAC**: Fine-grained permission control
- **Rate Limiting**: API endpoint protection via Redis
- **Request Validation**: Input sanitization with validator/v10
- **Encrypted Storage**: Password hashing, sensitive data encryption
- **gRPC Security**: Token-based authentication for node communication

## Build Targets

### Supported Platforms
- **Linux**: 386, amd64, arm/v6, arm/v7, arm64, ppc64le, s390x
- **Windows**: amd64 (via compile.bat)
- **macOS**: amd64 (via compile.bat)

### Build Artifacts
- **Backend**: `trojan-panel-linux-amd64`, `trojan-panel-windows-amd64.exe`
- **Core**: `trojan-panel-core-linux-amd64`, protocol-specific binaries

## Development Workflow

### Local Development
1. **Backend**: `cd trojan-panel-backend && go run main.go`
2. **Core**: `cd trojan-panel-core && go run main.go`
3. **Database**: Requires MySQL + Redis (see install-script/docker-compose.yml)

### Testing Strategy
- **Unit Tests**: Service layer and utility functions
- **Integration Tests**: API endpoints and database operations
- **Protocol Tests**: Individual proxy implementations
- **Load Tests**: Performance testing with concurrent users

### Debugging
- **Logs**: Structured logging with logrus (rotating file logs)
- **Metrics**: Real-time dashboard with system statistics
- **Health Checks**: Node status monitoring and alerting
- **Debug Mode**: Verbose logging configuration available