module main

import veb

@['/']
pub fn (mut app App) index(mut ctx Context) veb.Result {
	mut packages := []Package{}
	lock app.packages {
		packages = app.packages.clone()
	}
	return $veb.html('index.html')
}
