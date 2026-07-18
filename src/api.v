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
		else { 'failed' }
	}

	ctx.set_content_type('text/json')
	return ctx.ok(ret)
}

@['/api/windows/:request']
pub fn (mut app App) windows_api(mut ctx Context, request string) veb.Result {
  mut packages := []Package{}
	lock app.packages {
		packages = app.packages.clone()
	}

	ret := match request {
    'packages' {
      mut win_packages := []Package{}

      for package in packages {
        if package.platform == .windows {
          win_packages << package
        }
      }

      json2.encode(win_packages)
    }
    'dag' {
      mut windows := dag.new_graph()

      for pkg in packages {
        if pkg.platform == .windows {
          windows.add_node(pkg.name, pkg.version)
        }
      }

      for pkg in packages {
        if pkg.platform == .windows {
          for dep in pkg.depends {
            windows.add_edge(pkg.name, dep) or { return ctx.text('internal server error') }
          }
        }
      }

      windows.as_json()
    }
		else { 'failed' }
	}

	ctx.set_content_type('text/json')
	return ctx.ok(ret)
}

@['/api/linux/:request']
pub fn (mut app App) linux_api(mut ctx Context, request string) veb.Result {
  mut packages := []Package{}
	lock app.packages {
		packages = app.packages.clone()
	}

  ret := match request {
    'packages' {
      mut linux_packages := []Package{}

      for package in packages {
        if package.platform == .linux {
          linux_packages << package
        }
      }

      json2.encode(linux_packages)
    }
    'dag' {
      mut linux := dag.new_graph()

      for pkg in packages {
        if pkg.platform == .linux {
          linux.add_node(pkg.name, pkg.version)
        }
      }

      for pkg in packages {
        if pkg.platform == .linux {
          for dep in pkg.depends {
            linux.add_edge(pkg.name, dep) or { return ctx.text('internal server error') }
          }
        }
      }

      linux.as_json()
    }
    else { 'failed' }
  }

  ctx.set_content_type('text/json')
  return ctx.ok(ret)
}
