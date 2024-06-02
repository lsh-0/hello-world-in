package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
)

func main() {
	port := flag.Int("port", 1234, "port to listen on")
	flag.Parse()

	address := fmt.Sprintf(":%d", *port)

	fmt.Printf("listening on port %d, ctrl-c to quit ...\n", *port)
	err := http.ListenAndServe(address, http.FileServer(http.Dir("../html")))
	if err != nil {
		fmt.Printf("error: %v\n", err)
		os.Exit(1)
	}
}
