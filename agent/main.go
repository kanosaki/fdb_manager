package main

import (
	"flag"
	"net/http"
	"os/exec"
	"path"
	"time"

	"github.com/apple/foundationdb/bindings/go/src/fdb"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	log "github.com/sirupsen/logrus"
)

var (
	routePrefix     = flag.String("routePrefix", "", "mount http routes on this path")
	corsAllowOrigin = flag.String("corsAllowOrigin", "", "support CORS")
)

func main() {
	flag.Parse()
	fdb.MustAPIVersion(710)
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

	var v1 gin.IRoutes = r.Group(path.Join(*routePrefix, "/v1"))

	if *corsAllowOrigin != "" {
		v1 = v1.Use(cors.New(cors.Config{
			AllowOrigins:     []string{*corsAllowOrigin},
			AllowMethods:     cors.DefaultConfig().AllowMethods,
			AllowHeaders:     cors.DefaultConfig().AllowHeaders,
			AllowCredentials: true,
			MaxAge:           24 * time.Hour,
		}))
	}

	v1.GET("/status/now", func(c *gin.Context) {
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
	v1.GET("/policy", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"actions": gin.H{
				"kill":         true,
				"maintenance":  true,
				"exclude":      true, // exclude + include
				"lock":         true, // lock + unlock
				"suspend":      true,
				"configure":    true,
				"coordinators": true,
				"setclass":     true,
			},
			"throttle": gin.H{},
			"option":   gin.H{},
			"reads": gin.H{
				"get":          true,
				"getrange":     true,
				"getrangekeys": true,
			},
			"writes": gin.H{
				"set":        true,
				"clear":      true,
				"clearrange": true,
			},
		})
	})
	v1.POST("/action/kill", func(c *gin.Context) {
		targets := c.QueryArray("address")
		if len(targets) == 0 || len(targets) == 1 && targets[0] == "list" {
			cmd := exec.Command("fdbcli", "-c", "kill")
			if err := cmd.Run(); err != nil {
				c.JSON(http.StatusOK, gin.H{})
			}
		}
	})
	if err := r.Run(); err != nil {
		log.Fatal(err)
	}
}
