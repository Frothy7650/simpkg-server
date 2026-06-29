module main

import os

const pkg_dir = os.join_path(os.getwd(), 'packages')
const authkeys_path = os.join_path(os.config_dir()!, 'simpkg', 'authkeys')

pub fn print_setup() {
  println('SETUP: pkg_dir = ${pkg_dir}')
  println('SETUP: authkeys_path = ${authkeys_path}')
}
