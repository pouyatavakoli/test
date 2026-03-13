package data

import (
	"database/sql"
	"errors"
)

type Support struct {
	ID            int64  `json:"id"`
	Fname         string `json:"first_name"`
	Lname         string `json:"last_name"`
	Password_hash string `json:"-"`
	Image_url     string `json:"image_url"`
}

type SupportModel struct {
	DB *sql.DB
}

func (m SupportModel) GetSupportBy(id int64) (*Support, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}
	query := `
				SELECT id, fname, lname, image_url
				FROM support
				where id = $1
			`

	var sprt Support
	err := m.DB.QueryRow(query, id).Scan(
		&sprt.ID,
		&sprt.Fname,
		&sprt.Lname,
		&sprt.Image_url,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &sprt, nil
}

func (m SupportModel) GetAllSupports(page int) ([]*Support, error) {
	if page < 1 {
		page = 1
	}

	limit := 5
	offset := (page - 1) * limit

	query := `
				SELECT id, fname, lname, image_url
				FROM support
				ORDER BY id
				LIMIT $1 OFFSET $2
			`

	rows, err := m.DB.Query(query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	supports := []*Support{}
	for rows.Next() {
		var sprt Support
		err := rows.Scan(
			&sprt.ID,
			&sprt.Fname,
			&sprt.Lname,
			&sprt.Image_url,
		)
		if err != nil {
			return nil, err
		}
		supports = append(supports, &sprt)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return supports, nil
}
