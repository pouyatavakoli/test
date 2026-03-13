package main

import (
	"errors"
	"net/http"

	"github.com/pouyatavakoli/ZarafeMarket/internal/data"
)

func (app *application) getUserPageHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	userPageData, err := app.models.UserPage.GetUserPageData(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"user":                 userPageData.User,
		"recent_requests":      userPageData.RecentRequests,
		"recent_product_views": userPageData.RecentProductViews,
		"most_sold_products":   userPageData.MostSoldProducts,
		"suggested_products":   userPageData.SuggestedProducts,
		"discount_codes":       userPageData.DiscountCodes,
	}

	err = app.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
