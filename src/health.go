package main

import (
	"github.com/etherlabsio/healthcheck"
	"github.com/etherlabsio/healthcheck/checkers"
	"net/http"
	"time"
)

func health() http.Handler {
	return healthcheck.Handler(

		// WithTimeout allows you to set a max overall timeout.
		healthcheck.WithTimeout(5*time.Second),

		// Check heartbeat on root path and check used diskspace on /var/log with threshold 1%
		healthcheck.WithChecker("heartbeat", checkers.Heartbeat("/")),
		healthcheck.WithObserver(
			"diskspace", checkers.DiskSpace("/var/log", 1),
		),
	)
}
