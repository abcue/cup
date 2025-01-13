package cmd

import (
	"strings"
	"tool/cli"
	"tool/exec"
	"tool/file"
)

With: Sops: {
	#var: {
		name: _
		enc: filename: _
		package: *"deploy" | _
		path: ["application", name, "alpha", "sops", "data"]
		expression: #"application."\#(name)".alpha.sops.data"#
	}
	_local: {
		dec: {
			filename: strings.Replace(#var.enc.filename, ".enc.", ".dec.", 1)
			imported: strings.Join([filename, "cue"], ".")
		}
		path: strings.Join([for p in #var.path {#"--path "\#(p)""#}], " ")
	}
	SD="sops-decrypt": exec.Run & {
		cmd:    "sops --decrypt \(#var.enc.filename)"
		stdout: string
	}
	SO="sops-output": file.Create & {
		filename: _local.dec.filename
		contents: SD.stdout
	}
	SI="sops-import": exec.Run & {
		$after: SO
		cmd:    "cue import \(_local.dec.filename) \(_local.path) --package \(#var.package) --outfile \(_local.dec.imported)"
	}
	"sops-print": cli.Print & {
		text: strings.Join([for cmd in [SD.cmd, SI.cmd] {"#!" + cmd}], "\n")
	}
}
