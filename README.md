#moor

MoonScript REPL based on [mooni](https://github.com/leafo/moonscript/wiki/Moonscriptrepl)


## Demo
```
$ moor
moor on MoonScript version 0.3.1 on Lua 5.3
> for i in *{1,2,3}
>  for j in *{4,5,6}
>   print j
>  print i
>
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
>  new: =>
>   @a = 1
>   @b = 2
>   @c = 3
>
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

## Issue
a lot of. `is_blockstart` function is so bad...


## License
[MIT](https://github.com/Nymphium/moor/LICENSE)

