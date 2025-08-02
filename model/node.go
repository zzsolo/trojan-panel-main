package model

import (
	"time"
)

// Node represents a proxy node
type Node struct {
	ID           uint      `gorm:"primaryKey" json:"id"`
	Name         string    `gorm:"not null" json:"name"`
	Type         string    `gorm:"type:varchar(50);not null" json:"type"`
	Address      string    `gorm:"not null" json:"address"`
	Port         int       `gorm:"not null" json:"port"`
	Status       int       `gorm:"type:tinyint;default:1" json:"status"`
	TrafficUsed  int64     `gorm:"column:traffic_used" json:"traffic_used"`
	TrafficLimit int64     `gorm:"column:traffic_limit" json:"traffic_limit"`
	Config       string    `gorm:"type:text" json:"config"`
	Secret       string    `gorm:"type:varchar(255)" json:"secret"`
	CreatedAt    time.Time `gorm:"column:created_at" json:"created_at"`
	UpdatedAt    time.Time `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt    *time.Time `gorm:"index;column:deleted_at" json:"-"`
}

// TableName sets the table name for Node model
func (Node) TableName() string {
	return "trojan_panel_node"
}

// NodeType constants
const (
	NodeTypeTrojan     = "trojan"
	NodeTypeTrojanGo   = "trojan-go"
	NodeTypeXray       = "xray"
	NodeTypeHysteria   = "hysteria"
	NodeTypeHysteria2  = "hysteria2"
	NodeTypeNaiveProxy = "naiveproxy"
)

// NodeStatus constants
const (
	NodeStatusActive   = 1
	NodeStatusInactive = 0
	NodeStatusError    = -1
)