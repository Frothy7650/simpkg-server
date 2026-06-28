module main

import json
import veb

@['/api/:request']
pub fn (mut app App) api(mut ctx Context, request string) veb.Result {
	mut packages := []Package{}
	lock app.packages {
		packages = app.packages.clone()
	}

	ret := match request {
		'packages' { json.encode(packages) }
    'windows' {
      mut win_packages := []Package{}

      for package in packages {
        if package.platform == .windows {
          win_packages << package
        }
      }

      json.encode(win_packages)
    }
    'linux' {
      mut linux_packages := []Package{}

      for package in packages {
        if package.platform == .linux {
          linux_packages << package
        }
      }

      json.encode(linux_packages)
    }
		else { 'failed' }
	}

	ctx.set_content_type('text/json')
	return ctx.ok(ret)
}
