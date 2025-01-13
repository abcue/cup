package cmd

import (
	"list"
	"strings"
	"tool/cli"
	"tool/exec"
)

Git: Rev: {
	// Run `git rev-parse` to pick out and massage parameters
	"git-rev-parse": {
		HEAD: exec.Run & {
			cmd:    "git rev-parse HEAD"
			stdout: string
		}
		toplevel: exec.Run & {
			cmd:    "git rev-parse --show-toplevel"
			stdout: string
		}
		prefix: exec.Run & {
			cmd:    "git rev-parse --show-prefix"
			stdout: string
		}
		print: cli.Print & {
			text: strings.Join(list.FlattenN( [for task in [HEAD, toplevel, prefix] {["#!" + task.cmd, task.stdout]}], 1), "\n")
		}
	}
}
