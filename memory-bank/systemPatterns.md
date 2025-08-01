# System Patterns

## Architecture Patterns

### 1. Layered Architecture
```
Router → API → Middleware → Service → DAO → Model
```
- **Router Layer**: HTTP routing and middleware composition
- **API Layer**: Request handlers and validation
- **Middleware Layer**: Cross-cutting concerns (auth, logging, rate limiting)
- **Service Layer**: Business logic implementation
- **DAO Layer**: Data access operations
- **Model Layer**: Domain entities and data structures

### 2. Microservices Architecture
- **Backend Service**: Admin panel and user management
- **Core Service**: Proxy node management and communication
- **Communication**: gRPC with token authentication

### 3. CQRS Pattern (Partial)
- Separate read/write operations for performance
- Caching layer for read optimization
- Event-driven updates between services

## Design Patterns

### 1. Repository Pattern
- Data access abstraction through DAO layer
- Unified interface for database operations
- Support for multiple databases (MySQL, Redis, SQLite)

### 2. Strategy Pattern
- Protocol-specific implementations in core service
- Pluggable proxy node types
- Template-based configuration generation

### 3. Factory Pattern
- Node creation and configuration
- Template generation for different protocols
- Account management operations

### 4. Observer Pattern
- Real-time traffic monitoring
- System statistics updates
- Node health checking

### 5. Middleware Pattern
- Authentication and authorization
- Rate limiting and logging
- Request/response processing

## Security Patterns

### 1. JWT Authentication
- Token-based authentication
- Refresh token mechanism
- Role-based access control

### 2. RBAC with Casbin
- Role-based permissions
- Policy-based access control
- Dynamic permission management

### 3. Rate Limiting
- Token bucket algorithm
- IP-based and user-based limiting
- Configurable thresholds

## Data Patterns

### 1. Domain-Driven Design
- Rich domain models
- Business logic encapsulation
- Aggregate root patterns

### 2. Cache-Aside Pattern
- Redis caching for frequently accessed data
- Cache invalidation strategies
- Performance optimization

### 3. Unit of Work Pattern
- Database transaction management
- Connection pooling
- Resource cleanup

## Communication Patterns

### 1. gRPC Communication
- Service-to-service communication
- Protocol buffer definitions
- Secure token authentication

### 2. RESTful API
- External client communication
- Resource-oriented design
- Standard HTTP methods

### 3. Event-Driven Architecture
- Asynchronous processing
- Cron job scheduling
- Background task processing

## Configuration Patterns

### 1. Configuration Management
- Centralized configuration
- Environment variable overrides
- Template-based configuration generation

### 2. Builder Pattern
- Complex object construction
- Fluent interface design
- Validation and defaults

## Error Handling Patterns

### 1. Centralized Error Handling
- Consistent error response format
- Error logging and monitoring
- Graceful degradation

### 2. Retry Pattern
- Resilient database operations
- Exponential backoff
- Circuit breaker pattern