local f
f = function()
  return print("hello")
end
print(_ENV.f)
return (require("moor"))()
