module main

import time
import veb
import os

pub struct Package {
pub mut:
	name    string
	version string
	source  string
  platform Platform
}

enum Platform {
  linux
  windows
}

pub struct App {
pub mut:
	packages shared []Package
	updated  bool
  authkeys []string
}

pub struct Context {
	veb.Context
}

fn main() {
	if !os.exists(pkg_dir) || !os.is_dir(pkg_dir) {
		os.mkdir(pkg_dir)!
	}

  if !os.exists(authkeys_path) {
    os.create(authkeys_path)!
  }

	mut app := &App{
    updated: false
    authkeys: parse_authkeys()!
  }

  print_setup()

  mut package_paths := os.ls(pkg_dir) or { panic(err.msg()) }
  mut packages := []Package{}

  for package_path in package_paths {
    package_file := os.read_file(os.join_path(pkg_dir, package_path)) or {
      panic(err.msg())
    }

    package := parse(package_file) or { panic(err.msg()) }
    packages << package
  }

  lock app.packages {
    app.packages = packages
  }

	go fn [mut app] () {
		for {
			for {
        if app.updated {
          break
        }
				time.sleep(time.second * 4)
			}

      println('LOG: updating packages...')

			mut package_paths := os.ls(pkg_dir) or { panic(err.msg()) }
			mut packages := []Package{}

			for package_path in package_paths {
				package_file := os.read_file(os.join_path(pkg_dir, package_path)) or {
					panic(err.msg())
				}

				package := parse(package_file) or { panic(err.msg()) }
				packages << package
			}

			lock app.packages {
				app.packages = packages
			}
      app.updated = false

      println('LOG: update complete!')
		}
	}()

	veb.run[App, Context](mut app, 3001)
}

pub fn parse(pkgfile string) !Package {
	mut package := Package{}

	for line in pkgfile.split_into_lines() {
		if line.starts_with('#') || line == '' {
			continue
		}
		parts := line.split_nth('=', 2)

		if parts.len != 2 || parts[0] == '' || parts[1] == '' {
			return error('invalid line: ${line}')
		}

		key := parts[0]
		val := parts[1]

		match key {
			'name' { package.name = val }
			'version' { package.version = val }
			'source' { package.source = val }
      'platform' {
      match val {
        'windows' { package.platform = .windows }
        'linux' { package.platform = .linux }
        else { return error('invalid platform `${val}`') }
      }
    }
			else { return error('invalid key `${key}`') }
		}
	}

	return package
}

pub fn parse_authkeys() ![]string {
  mut authkeys := []string{}

  authkeys_raw := os.read_file(authkeys_path)!

  for line in authkeys_raw.split_into_lines() {
    if line.trim_space() != '' {
      authkeys << line
    }
  }

  return authkeys
}
