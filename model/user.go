package model

import "time"

// User represents a system user
type User struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Username    string    `gorm:"unique;not null" json:"username"`
	Email       string    `gorm:"unique;not null" json:"email"`
	Password    string    `gorm:"not null" json:"-"`
	Role        string    `gorm:"type:varchar(50);default:'user'" json:"role"`
	Status      int       `gorm:"type:tinyint;default:1" json:"status"`
	LastLogin   time.Time `gorm:"column:last_login" json:"last_login"`
	CreatedAt   time.Time `gorm:"column:created_at" json:"created_at"`
	UpdatedAt   time.Time `gorm:"column:updated_at" json:"updated_at"`
	DeletedAt   *time.Time `gorm:"index;column:deleted_at" json:"-"`
}

// TableName sets the table name for User model
func (User) TableName() string {
	return "trojan_panel_user"
}

// UserRole constants
const (
	RoleSysAdmin = "sysadmin"
	RoleAdmin    = "admin"
	RoleUser     = "user"
)

// UserStatus constants
const (
	UserStatusActive   = 1
	UserStatusInactive = 0
	UserStatusBanned   = -1
)