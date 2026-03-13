package main

import (
	"errors"
	"net/http"

	"github.com/pouyatavakoli/ZarafeMarket/internal/data"
)

func (app *application) listUsersHandler(w http.ResponseWriter, r *http.Request) {

	page, err := app.readPageParameter(r)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	users, err := app.models.Users.GetAllUsers(int(page))
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	if len(users) == 0 {
		app.notFoundResponse(w, r)
		return
	}

	data := map[string]interface{}{
		"page":  page,
		"users": users,
	}

	err = app.writeJSON(w, http.StatusOK, data, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app application) getUserHandler(w http.ResponseWriter, r *http.Request) {

	id, err := app.readIDParam(r)
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}
	usr, err := app.models.Users.GetUserById(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"user": usr}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}

}
