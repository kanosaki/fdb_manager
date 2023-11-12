package ops

import (
	"gorm.io/gorm"
)

func New() *Service {
	return &Service{}
}

func Migrate(db *gorm.DB) error {
	if err := db.AutoMigrate(&Note{}); err != nil {
		return err
	}
	return nil
}

type Service struct {
}
