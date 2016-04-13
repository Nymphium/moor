local printerr, to_lua, evalprint
do
  local _obj_0 = require('moor')
  printerr, to_lua, evalprint = _obj_0.printerr, _obj_0.to_lua, _obj_0.evalprint
end
local eval_moon
eval_moon = function(env, txt)
  local lua_code, err = to_lua(txt)
  if err then
    return nil, err
  else
    return evalprint(env, lua_code)
  end
end
local nextagen
nextagen = function(self)
  return function()
    return table.remove(self, 1)
  end
end
local msg
msg = function()
  printerr('Usage: moonr [options]\n', '\n', '   -h         print this message\n', '   -e STR     execute string as MoonScript code and exit\n', '   -E STR     execute string as MoonScript code and run REPL\n', '   -l LIB     load library before running REPL\n', '   -L LIB     execute `LIB = require"LIB"` before running REPL\n')
  return os.exit(1)
end
local loadlib
loadlib = function(lib)
  local ok, cont = pcall(require, lib)
  if not (ok) then
    printerr(cont, '\n')
    msg()
  end
  return cont
end
local evalline
evalline = function(env, line)
  local ok, err = pcall(eval_moon, env, line)
  if not (ok) then
    printerr(err)
    return msg()
  end
end
return function(env, arg)
  local is_exit
  local is_splash = true
  local nexta = nextagen(arg)
  while true do
    local a = nexta()
    if not (a) then
      break
    end
    local flag, rest = a:match('^%-(%a)(.*)')
    if not (flag) then
      printerr("Failed to parse argument: " .. tostring(a))
      msg()
    end
    local lstuff = #rest > 0 and rest or nexta()
    local _exp_0 = flag
    if 'l' == _exp_0 then
      loadlib(lstuff)
    elseif 'L' == _exp_0 then
      do
        local lib = loadlib(lstuff)
        if lib then
          env[rest] = lib
        end
      end
    elseif 'e' == _exp_0 then
      is_exit = true
      is_splash = evalline(env, lstuff)
    elseif 'E' == _exp_0 then
      is_splash = evalline(env, lstuff)
    else
      printerr("invlid flag: " .. tostring(flag))
      msg()
    end
  end
  if is_splash then
    printerr("moor on MoonScript version " .. tostring((require('moonscript.version')).version) .. " on " .. tostring(_VERSION))
  end
  return not is_exit
end
