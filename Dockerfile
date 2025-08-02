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

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/trojan-panel-backend .

# Copy configuration files
COPY --from=builder /app/config ./config

# Make the binary executable
RUN chmod +x ./trojan-panel-backend

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./trojan-panel-backend"]