module main

import veb

@['/styles.css']
pub fn (app &App) styles(mut ctx Context) veb.Result {
	ctx.set_content_type('text/css')
	return ctx.ok($embed_file('static/styles.css').to_string())
}
