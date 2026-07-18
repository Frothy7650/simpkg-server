module main

import frothy7650.dag
import json2
import veb

@['/api/:request']
pub fn (mut app App) api(mut ctx Context, request string) veb.Result {
	mut packages := []Package{}
	lock app.packages {
		packages = app.packages.clone()
	}

	ret := match request {
		'packages' { json2.encode(packages) }
    'windows' {
      mut win_packages := []Package{}

      for package in packages {
        if package.platform == .windows {
          win_packages << package
        }
      }

      json2.encode(win_packages)
    }
    'linux' {
      mut linux_packages := []Package{}

      for package in packages {
        if package.platform == .linux {
          linux_packages << package
        }
      }

      json2.encode(linux_packages)
    }
    'dag' {
      mut graph := dag.new_graph()

      for pkg in packages {
        graph.add_node(pkg.name, pkg.version)
      }

      for pkg in packages {
        for dep in pkg.depends {
          graph.add_edge(pkg.name, dep) or {
            return ctx.text(err.msg())
          }
        }
      }

      graph.to_json()
    }
		else { 'failed' }
	}

	ctx.set_content_type('text/json')
	return ctx.ok(ret)
}
