package main

import (
	"net/http"

	"github.com/apple/foundationdb/bindings/go/src/fdb"
	"github.com/labstack/echo/v4"
)

func initStatus(eg *echo.Group, app *app) {
	eg.GET("/now", func(c echo.Context) error {
		statusJsonIface, err := app.FDB.ReadTransact(func(tx fdb.ReadTransaction) (interface{}, error) {
			return tx.Get(fdb.Key("\xff\xff/status/json")).Get()
		})
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]any{
				"error": err.Error(),
			})
		}
		statusJson, ok := statusJsonIface.([]byte)
		if !ok {
			panic("never here")
		}
		return c.JSONBlob(http.StatusOK, statusJson)
	})
}
