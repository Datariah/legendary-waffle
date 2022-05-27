package internal

import (
	"encoding/json"
	"io/ioutil"
	"net/http"

	log "github.com/sirupsen/logrus"
)

type Quote struct {
	Id           string   `json:"_id"`
	Tags         []string `json:"tags"`
	Content      string   `json:"content"`
	Author       string   `json:"author"`
	AuthorSlug   string   `json:"authorSlug"`
	Length       int      `json:"length"`
	DateAdded    string   `json:"dateAdded"`
	DateModified string   `json:"dateModified"`
}

func GetQuote() (*Quote, error) {
	resp, err := http.Get("https://api.quotable.io/random")
	if err != nil {
		log.Fatal(err)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)
	}

	quote := Quote{}

	err = json.Unmarshal(body, &quote)

	if err != nil {
		log.Error("error unmarshaling response into Quote: %v", err)
		return &Quote{}, err
	}

	return &quote, nil
}
