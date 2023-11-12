package main

import (
	"github.com/apple/foundationdb/bindings/go/src/fdb"

	"github.com/kanosaki/fdb_manager/agent/ops"
)

type app struct {
	FDB fdb.Database
	Ops *ops.Service
}
