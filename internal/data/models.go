package data

import (
	"database/sql"
	"errors"
)

var (
	ErrRecordNotFound = errors.New("record not found")
)

type Models struct {
	Users       UserModel
	Support     SupportModel
	UserPage    UserPageModel
	SupportPage SupportPageModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		Users:       UserModel{DB: db},
		Support:     SupportModel{DB: db},
		UserPage:    UserPageModel{DB: db},
		SupportPage: SupportPageModel{DB: db},
	}
}
