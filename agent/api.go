package main

import (
	"net/http"
	"os"
	"path"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/rs/zerolog"
	log "github.com/sirupsen/logrus"
)

func runEcho(app *app) {
	e := echo.New()
	cw := zerolog.ConsoleWriter{
		Out:        e.Logger.Output(),
		TimeFormat: time.TimeOnly,
	}
	zerolog.DurationFieldInteger = true
	logger := zerolog.New(cw).With().Timestamp().Logger()
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error {
			if v.Error != nil {
				logger.Error().
					Dur("latency", v.Latency).
					Str("uri", v.URI).
					Int("status", v.Status).
					Str("error", v.Error.Error()).
					Msg(v.Method)
			} else {
				logger.Info().
					Dur("latency", v.Latency).
					Str("uri", v.URI).
					Int("status", v.Status).
					Msg(v.Method)
			}
			return nil
		},
		LogLatency:  true,
		LogRemoteIP: true,
		LogMethod:   true,
		LogURI:      true,
		LogStatus:   true,
		LogError:    true,
	}))

	// readiness probe
	e.GET("/ready", func(c echo.Context) error {
		if err := c.String(http.StatusOK, "ok"); err != nil {
			return err
		}
		return nil
	})

	// liveness probe
	e.GET("/healthz", func(c echo.Context) error {
		if err := c.String(http.StatusOK, "ok"); err != nil {
			return err
		}
		return nil
	})

	var middlewares []echo.MiddlewareFunc
	if len(*corsAllowOrigin) != 0 {
		config := middleware.CORSConfig{
			Skipper:          nil,
			AllowOrigins:     []string{*corsAllowOrigin},
			AllowMethods:     middleware.DefaultCORSConfig.AllowMethods,
			AllowHeaders:     middleware.DefaultCORSConfig.AllowHeaders,
			AllowCredentials: middleware.DefaultCORSConfig.AllowCredentials,
			MaxAge:           int((24 * time.Hour).Seconds()),
		}
		middlewares = append(middlewares, middleware.CORSWithConfig(config))
	}
	v1 := e.Group(path.Join(*routePrefix, "/v1"), middlewares...)
	initOps(v1.Group("/ops"), app)
	initStatus(v1.Group("/status"), app)
	initCommands(v1.Group("/commands"), app)

	if _, err := os.Stat("web"); err == nil {
		log.Infof("serving static files from web")
		e.Static("/", "web")
	}

	if err := e.Start(":8080"); err != nil {
		log.Fatal(err)
	}
}
