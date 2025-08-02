package core

import (
	"context"
	"fmt"
	"trojan-panel-backend/core"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// GRPCClient represents the gRPC client connection
type GRPCClient struct {
	conn   *grpc.ClientConn
	client interface{}
}

// InitGRPCClient initializes the gRPC client connection
func InitGRPCClient(config *core.Config) *GRPCClient {
	address := fmt.Sprintf("%s:%d", config.GRPC.Host, config.GRPC.Port)
	
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	conn, err := grpc.DialContext(ctx, address, 
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithBlock(),
	)
	if err != nil {
		panic("failed to connect to gRPC server: " + err.Error())
	}
	
	return &GRPCClient{
		conn: conn,
	}
}

// Close closes the gRPC connection
func (c *GRPCClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

// GetConnection returns the underlying gRPC connection
func (c *GRPCClient) GetConnection() *grpc.ClientConn {
	return c.conn
}