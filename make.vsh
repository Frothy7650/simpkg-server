#!/usr/bin/env -S v run

import build

const app_name = 'bin/simpkg-server'

mut context := build.context(
	default: 'build'
)

context.task(
	name:    'build'
	run:     |self| system('v src/. -o ${app_name}')
)

context.task(
	name:    'build-prod'
	run:     |self| system('v -cc clang -prod src/. -o ${app_name}')
)

context.task(
	name: 'format'
	run:  |self| system('v fmt -w src/.')
)

context.run()
