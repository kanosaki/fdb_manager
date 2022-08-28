package main

import (
	"os/exec"
)

func execFdbcli(cmd string, args ...string) {
	c := exec.Command("fdbcli", "--exec", "kill")
	if err := c.Run(); err != nil {
	}
}
