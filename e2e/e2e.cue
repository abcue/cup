package e2e

import (
	"tool/exec"

	"github.com/abcue/cup"
)

#Command: cup.PrintRun & {
	// test cup.PrintRun
	"e2e-print-run": {
		gen: exec.Run & {
			cmd: "echo 'gen'"
		}
		init: exec.Run & {
			$after: gen
			cmd:    "echo 'init'"
		}
		apply: exec.Run & {
			$after: init
			cmd:    "echo 'apply'"
		}
		printR: _
	}
	// test cup.RunPrint
	"e2e-run-print": cup.RunPrint & {
		runP: exec.Run & {cmd: "echo 'runP'"}
	}
}
