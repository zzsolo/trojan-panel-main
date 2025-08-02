package core

import (
	"trojan-panel-backend/core"

	"github.com/casbin/casbin/v2"
	gormadapter "github.com/casbin/gorm-adapter/v3"
	"gorm.io/gorm"
)

// InitCasbin initializes the Casbin enforcer
func InitCasbin(db *gorm.DB) *casbin.Enforcer {
	// Initialize Gorm adapter
	adapter, err := gormadapter.NewAdapterByDB(db)
	if err != nil {
		panic("failed to initialize casbin adapter: " + err.Error())
	}
	
	// Initialize enforcer with model and policy
	enforcer, err := casbin.NewEnforcer("config/rbac_model.conf", adapter)
	if err != nil {
		panic("failed to initialize casbin enforcer: " + err.Error())
	}
	
	// Load policies
	enforcer.EnableLog(true)
	if err := enforcer.LoadPolicy(); err != nil {
		panic("failed to load casbin policies: " + err.Error())
	}
	
	return enforcer
}