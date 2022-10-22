package main

import (
	"fmt"
	"net/http"
	"os"
	"sync"
	"time"
)

func main() {
	start := time.Now().UTC()

	var healthyMux sync.Mutex
	healthy := true

	// a health function that uses the shutdown flag to
	http.HandleFunc("/_/health", func(w http.ResponseWriter, r *http.Request) {
		healthyMux.Lock()
		defer healthyMux.Unlock()
		if healthy {
			w.Header().Add("content-type", "json")
			w.Write(([]byte)(fmt.Sprintf("{\"alive\": %f}", time.Since(start).Seconds())))
		} else {
			w.WriteHeader(http.StatusInternalServerError)
		}
	})

	// any request to the kill internal endpint will mark the server as unhealty
	http.HandleFunc("/_/kill", func(w http.ResponseWriter, r *http.Request) {
		healthyMux.Lock()
		healthy = false
		healthyMux.Unlock()
		w.WriteHeader(http.StatusOK)
	})

	// and now a handler to serve files contained in a directory
	appFiles := os.Getenv("APPFILES")
	if len(appFiles) == 0 {
		appFiles = "/app"
	}
	fmt.Printf("appFiles: %s\n", appFiles)
	http.Handle("/", http.FileServer(http.Dir(appFiles)))

	http.ListenAndServe(":8000", nil)
}
