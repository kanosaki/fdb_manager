package main

import (
	"net/http"

	"github.com/labstack/echo/v4"

	"github.com/kanosaki/fdb_manager/agent/ops"
)

func initOps(eg *echo.Group, app *app) {
	eg.GET("/process/query", func(c echo.Context) error {
		ctx := c.Request().Context()
		var params ops.QueryProcessParam

		if err := c.Bind(&params); err != nil {
			return err
		}
		procs, err := ops.QueryProcess(ctx, &params)
		if err != nil {
			return err
		}
		return c.JSON(http.StatusOK, procs)
	})
}
