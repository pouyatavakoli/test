package main

import (
	"fmt"
	"net/http"
)

func (app *application) dashBoard(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `
		<html>
		<body>
			<h2>Dashboard</h2>
			<ul>
				<li><a href="/v1/healthcheck">healthcheck</a></li>
				<li><a href="/v1/users">users</a></li>
				<li><a href="/v1/supports">supports</a></li>
			</ul>
		</body>
		</html>
	`)
}
