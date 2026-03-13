package main

import (
	"errors"
	"net/http"

	"github.com/pouyatavakoli/ZarafeMarket/internal/data"
)

func (app *application) getSupportPageHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	supportPageData, err := app.models.SupportPage.GetSupportPageData(id)
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
		"support_info": supportPageData.SupportInfo,
		"performance":  supportPageData.Performance,
	}

	err = app.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
