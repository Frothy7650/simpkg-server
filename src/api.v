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

@['/api/:platform/:request']
pub fn (mut app App) platform_api(mut ctx Context, platform string, request string) veb.Result {
	target := match platform {
		'windows' { Platform.windows }
		'linux' { Platform.linux }
		else { return ctx.text('unknown platform') }
	}

	mut packages := []Package{}
	lock app.packages {
		packages = app.packages.clone()
	}

	mut filtered := []Package{}
	for package in packages {
		if package.platform == target {
			filtered << package
		}
	}

	ret := match request {
		'packages' {
			json2.encode(filtered)
		}
		'dag' {
			mut graph := dag.new_graph()

			for package in filtered {
				graph.add_node(package.name, package.version, package.source)
			}

			for package in filtered {
				for dep in package.depends {
					graph.add_edge(package.name, dep) or {
						return ctx.text('internal server error')
					}
				}
			}

			graph.as_json()
		}
		else {
			'failed'
		}
	}

	ctx.set_content_type('text/json')
	return ctx.ok(ret)
}
