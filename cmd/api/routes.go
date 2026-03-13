package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
)

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodGet, "/v1/", app.dashBoard)

	router.HandlerFunc(http.MethodGet, "/v1/users", app.listUsersHandler)
	router.HandlerFunc(http.MethodGet, "/v1/users/:id", app.getUserHandler) //maybe remove later
	router.HandlerFunc(http.MethodGet, "/v1/users/:id/page", app.getUserPageHandler)

	router.HandlerFunc(http.MethodGet, "/v1/supports", app.listSupportsHandler)
	router.HandlerFunc(http.MethodGet, "/v1/supports/:id", app.getSupportHandler) //maybe remove later
	router.HandlerFunc(http.MethodGet, "/v1/supports/:id/page", app.getSupportPageHandler)

	return app.recoverPanic(router)
}
