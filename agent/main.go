package main

import (
	"flag"

	"github.com/apple/foundationdb/bindings/go/src/fdb"
	log "github.com/sirupsen/logrus"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	"github.com/kanosaki/fdb_manager/agent/ops"
)

var (
	routePrefix     = flag.String("routePrefix", "", "mount http routes on this path")
	corsAllowOrigin = flag.String("corsAllowOrigin", "", "support CORS")
	doMigrate       = flag.Bool("migrate", false, "perform migrate")
)

func main() {
	flag.Parse()
	fdb.MustAPIVersion(710)
	fd, err := fdb.OpenDefault()
	if err != nil {
		log.Fatalf("failed to open FoundationDB: %+v", err)
	}
	gd, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to open Database: %+v", err)
	}
	if *doMigrate {
		if err := ops.Migrate(gd); err != nil {
			log.Fatalf("failed to migrate: %+v", err)
		}
	}
	o := ops.New()
	a := &app{
		FDB: fd,
		Ops: o,
	}
	runEcho(a)
}
