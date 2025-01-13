package cmd

import (
	"list"
	"strings"
	"tool/cli"
	"tool/exec"
)

// NB: command."kust-vault-secrets-operator-config".print.text: invalid string argument: non-concrete value string:
// ../../../../../cmd/runp.cue:13:3
Util: RunP: {
	C=[_]: {
		// name task as `runP` in `exec.Run` to trigger command print
		runP?: _
		if runP.cmd != _|_ {
			print: cli.Print & {
				let RC = strings.Join(list.FlattenN([runP.cmd], -1), " ")
				text: *("#!" + RC) | _
			}
		}

		// declare task `printR: _` to print all run commands
		printR?: cli.Print & {
			text: strings.Join([for _, t in C if (t & exec.Run) != _|_ {"#!\(t.cmd)"}], "\n")
		}
	}
}
