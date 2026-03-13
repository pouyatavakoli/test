package data

import (
	"database/sql"
	"errors"
	"time"
)

type UserPageData struct {
	User               *User           `json:"user"`
	RecentRequests     []*Request      `json:"recent_requests"`
	RecentProductViews []*ProductView  `json:"recent_product_views"`
	MostSoldProducts   []*ProductSales `json:"most_sold_products"`
	SuggestedProducts  []*Product      `json:"suggested_products"`
	DiscountCodes      []*DiscountCode `json:"discount_code"`
}

type Request struct {
	Title string
	//TODO:
}
type DiscountCode struct{
	code string
	//TODO:
}

type ProductView struct {
	ShopID       int64     `json:"shop_id"`
	ShopName     string    `json:"shop_name"`
	ProductID    int64     `json:"product_id"`
	ProductTitle string    `json:"product_title"`
	ViewedAt     time.Time `json:"viewed_at"`
}

type ProductSales struct {
	ShopID       int64   `json:"shop_id"`
	ShopName     string  `json:"shop_name"`
	ProductID    int64   `json:"product_id"`
	ProductTitle string  `json:"product_title"`
	TotalSold    int     `json:"total_sold"`
	Price        float64 `json:"price"`
}

type Product struct {
	ShopID      int64   `json:"shop_id"`
	ShopName    string  `json:"shop_name"`
	ProductID   int64   `json:"product_id"`
	Title       string  `json:"title"`
	Description string  `json:"description"`
	ProductType string  `json:"product_type"`
	Price       float64 `json:"price,omitempty"`
}

type UserPageModel struct {
	DB *sql.DB
}

func (m UserPageModel) GetUserPageData(userID int64) (*UserPageData, error) {
	user, err := m.GetUserInfo(userID)
	if err != nil {
		return nil, err
	}

	recentRequests, err := m.GetRecentRequests(userID, 10)
	if err != nil {
		return nil, err
	}

	recentProductViews, err := m.GetRecentProductViews(userID, 10)
	if err != nil {
		return nil, err
	}

	mostSoldProducts, err := m.GetMostSoldProducts(10)
	if err != nil {
		return nil, err
	}

	suggestedProducts, err := m.GetSuggestedProducts(userID, 10)
	if err != nil {
		return nil, err
	}

	return &UserPageData{
		User:               user,
		RecentRequests:     recentRequests,
		RecentProductViews: recentProductViews,
		MostSoldProducts:   mostSoldProducts,
		SuggestedProducts:  suggestedProducts,
	}, nil
}

func (m UserPageModel) GetUserInfo(userID int64) (*User, error) {
	query := `
		SELECT id, fname, lname, phone_number, email, created_at
		FROM users
		WHERE id = $1
	`

	var user User
	err := m.DB.QueryRow(query, userID).Scan(
		&user.ID,
		&user.Fname,
		&user.Lname,
		&user.Phone_number,
		&user.Email,
		&user.Created_at,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &user, nil
}

func (m UserPageModel) GetRecentRequests(userID int64, limit int) ([]*Request, error) {
	query := ``
	//TODO:

	rows, err := m.DB.Query(query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []*Request
	for rows.Next() {
		var o Request
		err := rows.Scan(
		//TODO:
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, &o)
	}
	return orders, nil
}

func (m UserPageModel) GetRecentProductViews(userID int64, limit int) ([]*ProductView, error) {
	query := ``
	// TODO:

	rows, err := m.DB.Query(query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var views []*ProductView
	for rows.Next() {
		var v ProductView
		err := rows.Scan(
			&v.ShopID,
			&v.ShopName,
			&v.ProductID,
			&v.ProductTitle,
			&v.ViewedAt,
		)
		if err != nil {
			return nil, err
		}
		views = append(views, &v)
	}
	return views, nil
}

func (m UserPageModel) GetMostSoldProducts(limit int) ([]*ProductSales, error) {
	query := ``
	//TODO:

	rows, err := m.DB.Query(query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []*ProductSales
	for rows.Next() {
		var p ProductSales
		err := rows.Scan(
			&p.ShopID,
			&p.ShopName,
			&p.ProductID,
			&p.ProductTitle,
			&p.TotalSold,
			&p.Price,
		)
		if err != nil {
			return nil, err
		}
		products = append(products, &p)
	}
	return products, nil
}

func (m UserPageModel) GetSuggestedProducts(userID int64, limit int) ([]*Product, error) {
	query := ``
	//TODO:

	rows, err := m.DB.Query(query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []*Product
	for rows.Next() {
		var p Product
		err := rows.Scan(
			&p.ShopID,
			&p.ShopName,
			&p.ProductID,
			&p.Title,
			&p.Description,
			&p.ProductType,
			&p.Price,
		)
		if err != nil {
			return nil, err
		}
		products = append(products, &p)
	}
	return products, nil
}

func (m UserPageModel) GetDiscountCode(limit int) ([]*DiscountCode, error) {
	query := ``
	//TODO:

	rows, err := m.DB.Query(query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var discountCodes []*DiscountCode

	for rows.Next() {
		var dc DiscountCode
		err := rows.Scan(
			&dc.code,
			//TODO:
		)
		if err != nil {
			return nil, err
		}
		discountCodes = append(discountCodes, &dc)
	}
	return discountCodes, nil
}
