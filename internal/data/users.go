package data

import (
	"database/sql"
	"errors"
	"time"
)

type User struct {
	ID            int64     `json:"id"`
	Fname         string    `json:"first_name"`
	Lname         string    `json:"last_name"`
	Password_hash string    `json:"-"`
	Phone_number  string    `json:"phone_number"`
	Email         string    `json:"email"`
	Created_at    time.Time `json:"-"`
	Updated_at    time.Time `json:"-"`
}

type UserModel struct {
	DB *sql.DB
}

func (m UserModel) GetUserById(id int64) (*User, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}
	query := `
				SELECT fname, lname, phone_number, email
				FROM users
				where id = $1
			`

	var usr User
	err := m.DB.QueryRow(query, id).Scan(
		&usr.Fname,
		&usr.Lname,
		&usr.Phone_number,
		&usr.Email,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &usr, nil
}

func (m UserModel) GetAllUsers(page int) ([]*User, error) {
	if page < 1 {
		page = 1
	}

	limit := 5
	offset := (page - 1) * limit

	query := `
		SELECT id, fname, lname, phone_number, email
		FROM users
		ORDER BY id
		LIMIT $1 OFFSET $2
	`

	rows, err := m.DB.Query(query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*User

	for rows.Next() {
		var usr User
		err := rows.Scan(
			&usr.ID,
			&usr.Fname,
			&usr.Lname,
			&usr.Phone_number,
			&usr.Email,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, &usr)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}
