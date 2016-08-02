package = "moor"
version = "v4.0-7"
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
   "moonscript >= 0.4", "inspect", "linenoise"
}
build = {
   type = "make",
   modules = {},
   install = {
      bin = {
         moor = "bin/moor.lua"
      },
      lua = {
         ["moor.init"] = "moor/init.lua",
         ["moor.opts"] = "moor/opts.lua",
         ["moor.utils"] = "moor/utils.lua"
      }
   }
}
