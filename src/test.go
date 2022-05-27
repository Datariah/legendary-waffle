package main

import (
	"github.com/Datariah/legendary-waffle/internal"
	log "github.com/sirupsen/logrus"
)

func main() {
	quote, err := internal.GetQuote()
	if err != nil {
		log.Fatal("error retrieving quote: %v", err)
	}
	log.WithFields(log.Fields{"quote": quote}).Info("Quote retrieved successfully")
}
