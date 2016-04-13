package = "moor"
version = "v3.0-1"
source = {
	url = "git://github.com/nymphium/moor",
	tag = "v3.0"
}
description = {
	summary = "MoonScript REPL",
	detailed = "MoonScript REPL based on [mooni](https://github.com/leafo/moonscript/wiki/Moonscriptrepl)",
	homepage = "https://github.com/Nymphium/moor",
	license = "MIT"
}
dependencies = {
	"inspect",
	"moonscript >= 0.40",
	"linenoise"
}
build = {
	type = "builtin",
	modules = {
		moor = "moor/init.lua",
		["moor.opts"] = "moor/opts.lua",
		["moor.replcmd"] = "moor/replcmd.lua"
	},
	install = {
		bin = {
			moor = "bin/moor"
		}
	}
}
