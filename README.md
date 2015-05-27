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
{[__base]:{[__class]:<cycle>, [__index]:<cycle>}, [__name]:"Cls", [__init]:function: 0x1e39f70}
```

## Issue
a lot of. `is_blockstart` function is so bad...


## License
[MIT](https://github.com/Nymphium/moor/LICENSE)

