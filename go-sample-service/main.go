package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

type Message struct {
	Data string `json:"data,omitempty"`
}

func setupRouter(router *mux.Router) {
	router.
		Methods("GET").
		Path("/").
		HandlerFunc(getFunction)
}

func getFunction(w http.ResponseWriter, r *http.Request) {
	log.Printf("Handling GET / request")
	msg := Message{Data: "Hello world!"}
	json.NewEncoder(w).Encode(msg)
}

func main() {
	listenAddr := ":8080"
	router := mux.NewRouter().StrictSlash(true)
	setupRouter(router)
	log.Printf("Starting HTTP server on %s", listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, router))
}
