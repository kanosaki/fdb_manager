package main

import (
	"github.com/labstack/echo/v4"
	"net/http"
)

func initCommands(eg *echo.Group, app *app) {
	eg.GET("/policy", func(c echo.Context) error {
		return c.JSON(http.StatusOK, echo.Map{
			"actions": echo.Map{
				"kill":         true,
				"maintenance":  true,
				"exclude":      true, // exclude
				"include":      true, // include
				"lock":         true, // lock + unlock
				"suspend":      true,
				"configure":    true,
				"coordinators": true,
				"setclass":     true,
			},
			"throttle": echo.Map{},
			"option":   echo.Map{},
			"reads": echo.Map{
				"get":          true,
				"getrange":     true,
				"getrangekeys": true,
			},
			"writes": echo.Map{
				"set":        true,
				"clear":      true,
				"clearrange": true,
			},
		})
	})
	eg.POST("/kill", func(c echo.Context) error {
		panic("not supported")
	})
}
