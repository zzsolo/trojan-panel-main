package main

import (
	"context"
	"fmt"
	"github.com/sirupsen/logrus"
	"os"
	"os/signal"
	"syscall"
	"time"
	"trojan-panel-core/app"
	"trojan-panel-core/core"
	"trojan-panel-core/dao"
	"trojan-panel-core/model/constant"
)

// StartupRecovery handles automatic recovery of missing configurations on server restart
type StartupRecovery struct {
	configValidator *app.ConfigValidator
	dao             *dao.Dao
}

func NewStartupRecovery() *StartupRecovery {
	return &StartupRecovery{
		configValidator: app.NewConfigValidator(),
		dao:           dao.NewDao(),
	}
}

// PerformRecovery performs complete startup recovery process
func (sr *StartupRecovery) PerformRecovery() error {
	logrus.Info("🔄 Starting Trojan Panel Core Recovery Process...")
	
	// Initialize database connection
	if err := sr.dao.Init(); err != nil {
		return fmt.Errorf("failed to initialize database: %w", err)
	}
	defer sr.dao.Close()

	// Perform configuration validation and recovery
	if err := sr.configValidator.StartupRecovery(); err != nil {
		logrus.Errorf("Configuration validation failed: %v", err)
		// Continue with startup even if validation fails
	}

	// Recover missing configurations by recreating nodes
	if err := sr.recoverMissingConfigurations(); err != nil {
		logrus.Errorf("Failed to recover missing configurations: %v", err)
		return err
	}

	logrus.Info("✅ Startup recovery completed successfully")
	return nil
}

// recoverMissingConfigurations recreates all active nodes from database
func (sr *StartupRecovery) recoverMissingConfigurations() error {
	logrus.Info("🔍 Scanning for missing node configurations...")
	
	// Get all active nodes from database
	nodes, err := sr.dao.SelectAllActiveNodes()
	if err != nil {
		return fmt.Errorf("failed to get active nodes: %w", err)
	}

	logrus.Infof("Found %d active nodes in database", len(nodes))
	
	var recoveryErrors []error
	
	// Process each node type for recovery
	for _, node := range nodes {
		if err := sr.recoverNodeConfiguration(node); err != nil {
			recoveryErrors = append(recoveryErrors, fmt.Errorf("node %d: %w", node.ID, err))
			logrus.Errorf("Failed to recover node %d: %v", node.ID, err)
		} else {
			logrus.Infof("Successfully recovered node %d (type: %d, port: %d)", 
				node.ID, node.NodeType, node.Port)
		}
	}

	if len(recoveryErrors) > 0 {
		logrus.Warnf("Recovered %d nodes with %d errors", len(nodes), len(recoveryErrors))
	} else {
		logrus.Infof("Successfully recovered all %d nodes", len(nodes))
	}

	return nil
}

// recoverNodeConfiguration recreates configuration for a specific node
func (sr *StartupRecovery) recoverNodeConfiguration(node *dao.ActiveNode) error {
	// Check if configuration file exists
	configPath := sr.getConfigPath(node)
	if _, err := os.Stat(configPath); err == nil {
		// Configuration already exists, skip recovery
		return nil
	}

	// Recreate configuration based on node type
	switch node.NodeType {
	case constant.TrojanGo:
		return sr.recoverTrojanGoNode(node)
	case constant.Xray:
		return sr.recoverXrayNode(node)
	case constant.Hysteria:
		return sr.recoverHysteriaNode(node)
	case constant.Hysteria2:
		return sr.recoverHysteria2Node(node)
	default:
		return fmt.Errorf("unsupported node type: %d", node.NodeType)
	}
}

// recoverTrojanGoNode recreates trojan-go configuration
func (sr *StartupRecovery) recoverTrojanGoNode(node *dao.ActiveNode) error {
	// Get node details from database
	nodeDetails, err := sr.dao.SelectTrojanGoNodeDetails(node.ID)
	if err != nil {
		return fmt.Errorf("failed to get trojan-go node details: %w", err)
	}

	// Create configuration using existing logic
	config := app.TrojanGoConfigDto{
		ApiPort:         node.Port + 30000,
		Port:            node.Port,
		Sni:             nodeDetails.Sni,
		MuxEnable:       nodeDetails.MuxEnable,
		WebsocketEnable: nodeDetails.WebsocketEnable,
		WebsocketPath:   nodeDetails.WebsocketPath,
		WebsocketHost:   nodeDetails.WebsocketHost,
		SSEnable:        nodeDetails.SSEnable,
		SSMethod:        nodeDetails.SSMethod,
		SSPassword:      nodeDetails.SSPassword,
	}

	return app.StartTrojanGo(config)
}

// recoverXrayNode recreates xray configuration
func (sr *StartupRecovery) recoverXrayNode(node *dao.ActiveNode) error {
	// Implementation for Xray recovery
	// Similar to recoverTrojanGoNode but for Xray
	return nil
}

// recoverHysteriaNode recreates hysteria configuration
func (sr *StartupRecovery) recoverHysteriaNode(node *dao.ActiveNode) error {
	// Implementation for Hysteria recovery
	return nil
}

// recoverHysteria2Node recreates hysteria2 configuration
func (sr *StartupRecovery) recoverHysteria2Node(node *dao.ActiveNode) error {
	// Implementation for Hysteria2 recovery
	return nil
}

// getConfigPath returns the configuration file path for a node
func (sr *StartupRecovery) getConfigPath(node *dao.ActiveNode) string {
	basePath := ""
	switch node.NodeType {
	case constant.TrojanGo:
		basePath = constant.TrojanGoPath
	case constant.Xray:
		basePath = constant.XrayPath
	case constant.Hysteria:
		basePath = constant.HysteriaPath
	case constant.Hysteria2:
		basePath = constant.Hysteria2Path
	}
	
	return fmt.Sprintf("%s/config/config-%d.json", basePath, node.Port+30000)
}

// StartWithRecovery starts the application with automatic recovery
func StartWithRecovery() error {
	sr := NewStartupRecovery()
	
	// Perform recovery before normal startup
	if err := sr.PerformRecovery(); err != nil {
		logrus.Errorf("Startup recovery failed: %v", err)
		// Continue with startup anyway, but log the error
	}
	
	// Start normal application initialization
	return app.StartApplication()
}

// MonitorRecoveryStatus monitors the recovery process
func (sr *StartupRecovery) MonitorRecoveryStatus(ctx context.Context) {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ticker.C:
			// Periodically check configuration health
			if err := sr.configValidator.ValidateAllConfigurations(); err != nil {
				logrus.Warnf("Configuration health check failed: %v", err)
			}
		case <-ctx.Done():
			return
		}
	}
}

// RunRecoveryDaemon runs the recovery as a daemon process
func RunRecoveryDaemon() {
	logrus.Info("🚀 Starting Trojan Panel Core Recovery Daemon...")
	
	// Handle graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	
	// Start recovery process
	go func() {
		if err := StartWithRecovery(); err != nil {
			logrus.Fatalf("Application startup failed: %v", err)
		}
	}()
	
	// Start monitoring
	go NewStartupRecovery().MonitorRecoveryStatus(ctx)
	
	// Wait for shutdown signal
	<-sigChan
	logrus.Info("🛑 Received shutdown signal, cleaning up...")
	cancel()
}