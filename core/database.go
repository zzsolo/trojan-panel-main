package core

import (
	"fmt"
	"trojan-panel-backend/core"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// InitDatabase initializes the database connection
func InitDatabase(config *core.Config) *gorm.DB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=%s&parseTime=%t&loc=Local",
		config.Database.User,
		config.Database.Password,
		config.Database.Host,
		config.Database.Port,
		config.Database.Name,
		config.Database.Charset,
		config.Database.ParseTime,
	)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		panic("failed to connect database: " + err.Error())
	}

	// Configure connection pool
	sqlDB, err := db.DB()
	if err != nil {
		panic("failed to get database instance: " + err.Error())
	}

	sqlDB.SetMaxIdleConns(config.Database.MaxIdle)
	sqlDB.SetMaxOpenConns(config.Database.MaxOpen)

	// Auto migrate tables
	// AutoMigrate(db)

	return db
}

// CloseDatabase closes the database connection
func CloseDatabase(db *gorm.DB) {
	sqlDB, err := db.DB()
	if err != nil {
		return
	}
	sqlDB.Close()
}

// AutoMigrate automatically migrates database tables
// func AutoMigrate(db *gorm.DB) {
// 	// Import models here and run migrations
// 	// db.AutoMigrate(
// 	// 	&model.User{},
// 	// 	&model.Node{},
// 	// 	&model.Account{},
// 	// )
// }