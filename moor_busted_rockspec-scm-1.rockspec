package = "moor_busted_rockspec"
version = "scm-1"
source = {
	url = "git://github.com/Nymphium/moor"
}
description = {
	summary = "modules for travis CI of moor",
	license = "MIT"
}

dependencies = {
	"busted",
	"loadkit",
	"luakatsu"
}

build = {
	type = "builtin",
	modules = {}
}

