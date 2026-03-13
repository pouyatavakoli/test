package main

import (
	"errors"
	"net/http"

	"github.com/pouyatavakoli/ZarafeMarket/internal/data"
)

func (app application) listSupportsHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.readPageParameter(r)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	supports, err := app.models.Support.GetAllSupports(int(page))
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	if len(supports) == 0 {
		app.notFoundResponse(w, r)
		return
	}

	data := map[string]interface{}{
		"page":     page,
		"supports": supports,
	}

	err = app.writeJSON(w, http.StatusOK, data, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}

}

func (app application) getSupportHandler(w http.ResponseWriter, r *http.Request) {

	id, err := app.readIDParam(r)
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}
	sprt, err := app.models.Support.GetSupportBy(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"support": sprt}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
