package main

import (
	"fmt"
	"log"
	"net/http"
)

func srv(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK!"))
	w.Write([]byte("\nUpload feito pela branch tag"))
}

func main() {

	http.HandleFunc("/", srv)
	fmt.Println("Ouvindo na porta 5000!")
	log.Fatal(http.ListenAndServe(":5000", nil))
}
