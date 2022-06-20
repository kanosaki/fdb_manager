package main

import (
	"net/http"

	"github.com/apple/foundationdb/bindings/go/src/fdb"
	"github.com/gin-gonic/gin"
	log "github.com/sirupsen/logrus"
)

func main() {
	fdb.MustAPIVersion(630)
	db, err := fdb.OpenDefault()
	if err != nil {
		log.Fatalf("failed to open FoundationDB: %+v", err)
	}
	r := gin.Default()

	// readiness probe
	r.GET("/ready", func(c *gin.Context) {
		c.String(http.StatusOK, "ok")
	})

	// liveness probe
	r.GET("/healthz", func(c *gin.Context) {
		c.String(http.StatusOK, "ok")
	})

	r.GET("/v1/status/now", func(c *gin.Context) {
		statusJsonIface, err := db.ReadTransact(func(tx fdb.ReadTransaction) (interface{}, error) {
			v, err := tx.Get(fdb.Key("\xff\xff/status/json")).Get()
			if err != nil {
				return nil, err
			}
			return v, nil
		})
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, map[string]any{
				"error": err.Error(),
			})
			return
		}
		statusJson, ok := statusJsonIface.([]byte)
		if !ok {
			panic("never here")
		}
		c.Data(http.StatusOK, "application/json", statusJson)
	})
	if err := r.Run(); err != nil {
		log.Fatal(err)
	}
}
