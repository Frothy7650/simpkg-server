module main

import crypto.sha256
import veb
import os

@['/create'; GET]
pub fn (mut app App) new_get(mut ctx Context) veb.Result {
	return $veb.html('create.html')
}

@['/create'; POST]
pub fn (mut app App) new_post(mut ctx Context) veb.Result {
  name := ctx.form['name'] or { return ctx.text('getting name failed') }.trim_space()

  version :=
    ctx.form['version'] or { return ctx.text('getting version failed') }.trim_space()

  source :=
    ctx.form['source'] or { return ctx.text('getting source failed') }.trim_space()

  authkey := ctx.form['authkey'] or { return ctx.text('getting authkey failed') }.trim_space()
  if sha256.hexhash(authkey) !in app.authkeys { return ctx.text('invalid authkey') }
  println('LOG: authkey passed')

  platform_str := ctx.form['platform'] or { return ctx.text('getting platform failed') }.trim_space()
  mut platform := Platform.linux
  platform = match platform_str {
    'windows' { .windows }
    'linux' { .linux }
    else { eprintln('ERR: unknown platform from dropdown menu: `${platform_str}`') return ctx.text('internal error with platform') }
  }

  if name == '' {
    return ctx.text('name missing')
  }
  if !valid(name) {
    return ctx.text('invalid package name, only letters, numbers, `-`, and `_` are allowed.')
  }
  if version == '' {
    return ctx.text('version missing')
  }
  if !valid(version) {
    return ctx.text('invalid package version, only letters, numbers, `-`, and `_` are allowed.')
  }
  if source == '' {
    return ctx.text('source missing')
  }

  mut file := []string{}
  file << 'name=${name}'
  file << 'version=${version}'
  file << 'source=${source}'
  file << 'platform=${platform}'

  os.write_file(os.join_path(pkg_dir, '${name}-${version}-${platform}'), file.join_lines()) or {
    eprintln('failed to write to file: ${err.msg()}')
    exit(1)
  }

  println('LOG: added ${name}')

  app.updated = true

	return ctx.redirect('/')
}

fn valid(name string) bool {
  for c in name {
    if !(c.is_letter() || c.is_digit() || c == `-` || c == `_` || c == `.`) {
      return false
    }
  }
  return name.len > 0
}
