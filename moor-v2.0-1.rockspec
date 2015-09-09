package = "moor"
version = "v2.0-1"
source = {
   url = "git://github.com/Nymphium/moor",
   tag = "v2.1"
}
description = {
   summary = "MoonScript REPL",
   detailed = "MoonScript REPL based on [mooni](https://github.com/leafo/moonscript/wiki/Moonscriptrepl)",
   homepage = "https://github.com/Nymphium/moor",
   license = "MIT"
}
dependencies = {
   "lua >= 5.2",
   "moonscript >= 0.3.1",
   "linenoise >= 0.7",
   "lrexlib-posix"
}
build = {
   type = "builtin",
   modules = {
	   ["moor.init"] = "moor/init.lua"
   },
   install = {
	   bin= {"bin/moor"}
   }
}
