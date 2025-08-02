package core

import (
	"context"
	"fmt"
	"trojan-panel-backend/core"

	"github.com/redis/go-redis/v9"
)

// InitRedis initializes the Redis client
func InitRedis(config *core.Config) *redis.Client {
	rdb := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%d", config.Redis.Host, config.Redis.Port),
		Password: config.Redis.Password,
		DB:       config.Redis.Database,
		PoolSize: config.Redis.MaxActive,
	})

	// Test connection
	ctx := context.Background()
	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		panic("failed to connect redis: " + err.Error())
	}

	return rdb
}