#!/usr/bin/env bash

full="$(readlink -f "$0")"
here="$(dirname "$full")"

main() {
	test_link
	test_double_link
	test_link_with_args
	test_unlink
	test_add
	clean_environment
}

sdms() {
	"$here"/../sdms --source "$here"/source --target "$here"/target "$@" > /dev/null
}

clean_environment() {
	rm -rf "$here"/target
	rm -rf "$here"/source
}

setup_default_environment() {
	clean_environment
	mkdir "$here"/target
	mkdir "$here"/source
}

assert_equals() {
	echo -n "ASSERT RESULT (@${FUNCNAME[1]}): "
	if [ "$1" == "$2" ]; then
		echo "PASS"
	else
		echo "FAIL"
		exit 1
	fi
}

test_link() {
	setup_default_environment
	mkdir -p "$here"/source/.config/nvim/lua
	touch "$here"/source/.bashrc
	touch "$here"/source/.config/nvim/init.lua
	touch "$here"/source/.config/nvim/lua/settings.lua
	touch "$here"/source/.config/nvim/lua/keybinds.lua
	touch "$here"/source/.config/nvim/lua/autocmds.lua

	sdms link

	local expected
	expected="$(find "$here"/source)"
	expected="${expected//source/target}"

	local output
	output="$(find "$here"/target)"

	assert_equals "$expected" "$output"
}

test_double_link() {
	setup_default_environment
	mkdir -p "$here"/source/.config/nvim/lua
	touch "$here"/source/.bashrc
	touch "$here"/source/.config/nvim/init.lua
	touch "$here"/source/.config/nvim/lua/settings.lua
	touch "$here"/source/.config/nvim/lua/keybinds.lua
	touch "$here"/source/.config/nvim/lua/autocmds.lua

	sdms link
	sdms link

	local expected
	expected="$(find "$here"/source)"
	expected="${expected//source/target}"

	local output
	output="$(find "$here"/target)"

	assert_equals "$expected" "$output"
}

test_unlink() {
	setup_default_environment
	mkdir -p "$here"/source/.config/nvim/lua
	touch "$here"/source/.bashrc
	touch "$here"/source/.config/nvim/init.lua
	touch "$here"/source/.config/nvim/lua/settings.lua
	touch "$here"/source/.config/nvim/lua/keybinds.lua
	touch "$here"/source/.config/nvim/lua/autocmds.lua

	local expected
	expected="$(find "$here"/target)"

	sdms link
	sdms unlink
	sdms unlink

	local output
	output="$(find "$here"/target)"

	assert_equals "$expected" "$output"
}

test_add() {
	setup_default_environment
	mkdir "$here"/target/.config
	touch "$here"/target/.config/file.conf
	touch "$here"/target/.config/program.conf
	touch "$here"/target/file.conf

	sdms add "$here"/target/file.conf
	sdms add "$here"/target/.config

	local expected
	expected="$(find "$here"/source)"
	expected="${expected//source/target}"

	local output
	output="$(find "$here"/target)"

	assert_equals "$expected" "$output"
}

test_link_with_args() {
	setup_default_environment
	touch "$here"/source/file.conf
	touch "$here"/source/another-file.conf
	mkdir -p "$here"/source/config/program
	touch "$here"/source/config/program/conf
	touch "$here"/source/config/program/theme
	touch "$here"/source/config/program/script

	sdms link ./another-file.conf
	cd || exit 1
	sdms link file.conf
	sdms link config

	local expected output
	expected="$(find "$here"/source)"
	expected="${expected//source/target}"
	output="$(find "$here"/target)"

	assert_equals "$expected" "$output"
}

main "$@"

exit 0
