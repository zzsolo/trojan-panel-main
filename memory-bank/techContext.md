# Technology Context

## Backend (trojan-panel-backend)
- **Language**: Go 1.19
- **Web Framework**: Gin 1.8.2
- **Database**: MySQL 8.0+ (driver: go-sql-driver/mysql 1.7.0)
- **Cache**: Redis (gomodule/redigo 1.8.9)
- **Authentication**: JWT (golang-jwt/jwt v3.2.2)
- **Authorization**: Casbin RBAC (v2.60.0)
- **Validation**: validator/v10 10.11.1
- **Rate Limiting**: tollbooth v4.0.2
- **Logging**: logrus 1.9.0
- **Configuration**: ini.v1 1.67.0
- **gRPC**: v1.54.0
- **Build**: garble for obfuscation

## Core (trojan-panel-core)
- **Language**: Go 1.20
- **Web Framework**: Gin 1.8.2
- **Database**: MySQL 8.0+, SQLite (modernc.org/sqlite v1.23.1)
- **Cache**: Redis (gomodule/redigo 1.8.9)
- **Proxy Protocols**:
  - Xray-core: v1.8.0
  - Trojan-Go: v0.10.6
  - Hysteria: Integrated support
  - Hysteria2: Integrated support
  - NaiveProxy: Integrated support
- **Process Management**: Custom process management for proxy services
- **gRPC**: v1.53.0

## Frontend (trojan-panel-ui)
- **Framework**: Vue.js (inferred from build structure)
- **UI Library**: Element UI (inferred from component structure)
- **Build**: Pre-built static assets

## Infrastructure
- **Containerization**: Docker
- **Build System**: Cross-platform compilation scripts
- **Architecture**: Microservices (Backend + Core)
- **Communication**: gRPC for internal services, REST for external API