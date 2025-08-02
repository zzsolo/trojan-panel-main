package model

import (
	"time"
)

// Account represents a user's proxy account
type Account struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	UserID      uint      `gorm:"column:user_id;not null" json:"user_id"`
	Username    string    `gorm:"unique;not null" json:"username"`
	Password    string    `gorm:"not null" json:"password"`
	TrafficUsed int64     `gorm:"column:traffic_used" json:"traffic_used"`
	TrafficLimit int64    `gorm:"column:traffic_limit" json:"traffic_limit"`
	ExpireDate  time.Time `gorm:"column:expire_date" json:"expire_date"`
	IPLimit     int       `gorm:"column:ip_limit" json:"ip_limit"`
	Status      int       `gorm:"type:tinyint;default:1" json:"status"`
	CreatedAt   time.Time `gorm:"column:created_at" json:"created_at"`
	UpdatedAt   time.Time `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt   *time.Time `gorm:"index;column:deleted_at" json:"-"`
}

// TableName sets the table name for Account model
func (Account) TableName() string {
	return "trojan_panel_account"
}

// AccountStatus constants
const (
	AccountStatusActive   = 1
	AccountStatusInactive = 0
	AccountStatusExpired  = -1
)