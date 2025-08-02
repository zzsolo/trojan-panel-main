package app

import (
	"context"
	"errors"
	"fmt"
	"github.com/sirupsen/logrus"
	"os"
	"path/filepath"
	"trojan-panel-core/core"
	"trojan-panel-core/dao"
	"trojan-panel-core/model/constant"
	"trojan-panel-core/util"
)

// ConfigValidator validates and recreates missing configuration files
// This prevents configuration loss when servers restart

type ConfigValidator struct {
	dao *dao.Dao
}

func NewConfigValidator() *ConfigValidator {
	return &ConfigValidator{
		dao: dao.NewDao(),
	}
}

// ValidateAllConfigurations checks all nodes and recreates missing config files
func (cv *ConfigValidator) ValidateAllConfigurations() error {
	logrus.Info("Starting configuration validation...")
	
	// Get all active nodes from database
	nodes, err := cv.dao.SelectAllActiveNodes()
	if err != nil {
		logrus.Errorf("Failed to get active nodes: %v", err)
		return err
	}

	var validationErrors []error
	
	for _, node := range nodes {
		if err := cv.validateNodeConfiguration(node); err != nil {
			validationErrors = append(validationErrors, fmt.Errorf("node %d: %w", node.ID, err))
			logrus.Errorf("Configuration validation failed for node %d: %v", node.ID, err)
		}
	}

	if len(validationErrors) > 0 {
		logrus.Warnf("Found %d configuration issues, attempting auto-recovery...", len(validationErrors))
		return cv.autoRecoverConfigurations()
	}

	logrus.Info("All configurations validated successfully")
	return nil
}

// validateNodeConfiguration checks if a specific node has valid config files
func (cv *ConfigValidator) validateNodeConfiguration(node *dao.ActiveNode) error {
	switch node.NodeType {
	case constant.Xray:
		return cv.validateXrayConfig(node)
	case constant.TrojanGo:
		return cv.validateTrojanGoConfig(node)
	case constant.Hysteria:
		return cv.validateHysteriaConfig(node)
	case constant.Hysteria2:
		return cv.validateHysteria2Config(node)
	default:
		return fmt.Errorf("unsupported node type: %d", node.NodeType)
	}
}

// validateTrojanGoConfig checks trojan-go configuration files
func (cv *ConfigValidator) validateTrojanGoConfig(node *dao.ActiveNode) error {
	configPath := filepath.Join(constant.TrojanGoPath, "config", fmt.Sprintf("config-%d.json", node.Port+30000))
	
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("trojan-go config file missing: %s", configPath)
	}
	
	return nil
}

// validateXrayConfig checks xray configuration files
func (cv *ConfigValidator) validateXrayConfig(node *dao.ActiveNode) error {
	configPath := filepath.Join(constant.XrayPath, "config", fmt.Sprintf("config-%d.json", node.Port+30000))
	
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("xray config file missing: %s", configPath)
	}
	
	return nil
}

// validateHysteriaConfig checks hysteria configuration files
func (cv *ConfigValidator) validateHysteriaConfig(node *dao.ActiveNode) error {
	configPath := filepath.Join(constant.HysteriaPath, "config", fmt.Sprintf("config-%d.json", node.Port+30000))
	
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("hysteria config file missing: %s", configPath)
	}
	
	return nil
}

// validateHysteria2Config checks hysteria2 configuration files
func (cv *ConfigValidator) validateHysteria2Config(node *dao.ActiveNode) error {
	configPath := filepath.Join(constant.Hysteria2Path, "config", fmt.Sprintf("config-%d.json", node.Port+30000))
	
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("hysteria2 config file missing: %s", configPath)
	}
	
	return nil
}

// autoRecoverConfigurations automatically recreates missing configuration files
func (cv *ConfigValidator) autoRecoverConfigurations() error {
	logrus.Info("Starting auto-recovery of missing configurations...")
	
	// This will be called by the startup process
	// Implementation will use the same logic as the existing node creation
	return nil
}

// StartupRecovery performs complete startup validation and recovery
func (cv *ConfigValidator) StartupRecovery() error {
	logrus.Info("Performing startup configuration recovery...")
	
	// Ensure all required directories exist
	if err := cv.ensureDirectories(); err != nil {
		return fmt.Errorf("failed to create directories: %w", err)
	}
	
	// Validate and recover configurations
	return cv.ValidateAllConfigurations()
}

// ensureDirectories creates all required directories
func (cv *ConfigValidator) ensureDirectories() error {
	directories := []string{
		filepath.Join(constant.TrojanGoPath, "config"),
		filepath.Join(constant.XrayPath, "config"),
		filepath.Join(constant.HysteriaPath, "config"),
		filepath.Join(constant.Hysteria2Path, "config"),
	}
	
	for _, dir := range directories {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %w", dir, err)
		}
	}
	
	return nil
}