package cmd

import (
	"strings"
	"tool/cli"
	"tool/exec"
	"tool/file"
	"tool/os"
)

Git:  _
With: _

App: Kube: Git.Rev & {
	#var: apps: _

	_local: {
		env: os.Environ
		git: {
			commit:   *strings.TrimSpace(G.HEAD.stdout) | _
			toplevel: *strings.TrimSpace(G.toplevel.stdout) | _
			prefix:   *strings.TripSpace(G.prefix.stdout) | _
		}
		if env.ARGOCD_ENV_GIT_REV != _|_ {
			git: commit: env.ARGOCD_ENV_GIT_REV
		}
		inject: [_]: {
			kv: gitRev: _local.git.commit
			text: strings.Join([for k, v in kv {#"--inject \#(k)=\#(v)"#}], " ")
		}
	}

	G="git-rev-parse": _

	for name, app in #var.apps {
		_local: inject: (name): _

		let KN = "kube-" + name
		if app.alpha.kubernetes != _|_ {
			// export desired kubernetes manifests
			kube: _
			// export desired kubernetes manifests of specific app
			(KN): {
				glob: file.Glob & {glob: "kustomization.yaml"}
				if len(glob.files) > 0 {
					run: exec.Run & {cmd: "kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor=LoadRestrictionsNone"}
				}
				let KC = #"cue export \#(_local.inject[name].text) --expression application."\#(name)".alpha.kubernetes.manifests --out text"#
				run: *(exec.Run & {cmd: KC}) | _
				print: cli.Print & {
					$after: run
					text:   "#!\(run.cmd)"
				}
				if app.alpha.sops != _|_ {
					With.Sops & {
						#var: {
							"name": name
							enc: filename: app.alpha.sops.filename
						}
						SI="sops-import": _
						run: {$after: SI}
					}
				}
			}
		}
	}
}
