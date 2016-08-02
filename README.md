#moor

[![Build Status](https://api.travis-ci.org/Nymphium/moor.svg?branch=master)](https://travis-ci.org/Nymphium/moor)

MoonScript REPL


## Demo
```
$ moor
moor on MoonScript version 0.4.0 on Lua 5.3
> for i in *{1,2,3}
?  for j in *{4,5,6}
?   print j
?  print i
?
4
5
6
1
4
5
6
2
4
5
6
3
> class Cls
?  new: =>
?   @a = 1
?   @b = 2
?   @c = 3
?
<1>{
  __base = <2>{
    __class = <table 1>,
    __index = <table 2>
  },
  __init = <function 1>,
  __name = "Cls",
  <metatable> = {
    __call = <function 2>,
    __index = <table 2>
  }
}
```

yes, dump objects with [inspect](https://github.com/kikito/inspect.lua).

This supports tab completion with [linenoise](https://github.com/hoelzro/lua-linenoise), and the history is stored to `~/.moor_history`

## Module
you can call REPL in your code

```lua
...
local var = 10 -- it can be referenced by the repl
local newenv = (require'moor')({}, _ENV)
local hoge = newenv.foo
...

```

## TODO
- repl command (needed?)

## License
[MIT](https://github.com/Nymphium/moor/tree/master/LICENSE)

