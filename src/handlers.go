package main

import (
	"github.com/gorilla/mux"
)

// Function to create http handler
func Router(projectName, buildTime, commit, release string) *mux.Router {
	r := mux.NewRouter()
	// Handle root path
	r.HandleFunc("/", home).Methods("GET")
	// Handle metadata path
	r.HandleFunc("/metadata", metadata(projectName, buildTime, commit, release)).Methods("GET")
	// Handle health path
	r.Handle("/health", health())

	return r
}
