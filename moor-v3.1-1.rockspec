package = "moor"
version = "v3.1-1"
source = {
   url = "git://github.com/nymphium/moor"
}
description = {
   summary = "MoonScript REPL",
   detailed = "MoonScript REPL",
   homepage = "https://github.com/Nymphium/moor",
   license = "MIT"
}
dependencies = {
  "moonscript >= 0.4",
  "inspect",
  "linenoise"
}
build = {
   -- type = "make",
   -- modules = {
      -- build_variables = {},
     -- install_variables = {}
   -- }
   type = "builtin",
   modules = {},
   install =  {
   	bin = {moor = "bin/moor"},
	   lua = {
	   	["moor.repl"] = "moor/repl.moon",
		   ["moor.utils"] = "moor/utils.moon",
		   ["moor.opts"] = "moor/opts.moon"
	   }
   }
}
