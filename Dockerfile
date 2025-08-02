# Build stage
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o trojan-panel-backend .

# Final stage
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S trojan && \
    adduser -u 1001 -S trojan -G trojan

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/trojan-panel-backend .
COPY --from=builder /app/config ./config

# Change ownership to trojan user
RUN chown -R trojan:trojan /app && \
    chmod +x ./trojan-panel-backend

# Switch to non-root user
USER trojan

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the binary
CMD ["./trojan-panel-backend"]