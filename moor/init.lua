local parse = require('moonscript.parse')
local compile = require('moonscript.compile')
local ln = require('linenoise')
local inspect = require('inspect')
local remove, insert, concat
do
  local _obj_0 = table
  remove, insert, concat = _obj_0.remove, _obj_0.insert, _obj_0.concat
end
local printerr
printerr = function(...)
  return io.stderr:write(tostring(concat({
    ...
  }, "\t")) .. "\n")
end
local prompt = {
  p = ">",
  deepen = function(self)
    self.p = "? "
  end,
  reset = function(self)
    self.p = ">"
  end
}
local to_lua
to_lua = function(code)
  local tree, err = parse.string(code)
  if err then
    return nil, err
  else
    local lua_code, pos
    lua_code, err, pos = compile.tree(tree)
    if not (lua_code) then
      return nil, compile.format_error(err, pos, code)
    else
      return lua_code
    end
  end
end
local fnwrap
fnwrap = function(code)
  return "return function(__newenv) local _ENV = setmetatable(__newenv, {__index = _ENV}) " .. tostring(code) .. " end"
end
local evalprint
evalprint = function(env, lua_code)
  local is_mod = true
  do
    local vardec = lua_code:match("^local%s+(.*)$")
    if vardec then
      lua_code = fnwrap(vardec)
    elseif lua_code:match("^return%s+%(?%s*%w+%s*%)?") then
      lua_code = fnwrap(lua_code)
    else
      is_mod = false
      lua_code = lua_code
    end
  end
  local luafn, err = loadstring(lua_code, "tmp")
  if err then
    return printerr(err)
  else
    if is_mod then
      luafn = luafn()
    end
    local result = {
      pcall(luafn, env)
    }
    local ok = remove(result, 1)
    if not (ok) then
      return printerr(result[1])
    else
      if #result > 0 then
        print((inspect(result)):match("^%s*{%s*(.*)%s*}%s*%n?%s*$"))
        return unpack(result)
      end
    end
  end
end
local cndgen
cndgen = function(env)
  return function(line)
    do
      local i1 = line:find('[.\\%w_]+$')
      if i1 then
        do
          local res = { }
          local front = line:sub(1, i1 - 1)
          local partial = line:sub(i1)
          local prefix, last = partial:match('(.-)([^.\\]*)$')
          local t, all = env
          if #prefix > 0 then
            local P = prefix:sub(1, -2)
            all = last == ''
            for w in P:gmatch('[^.\\]+') do
              t = t[w]
              if not (t) then
                return 
              end
            end
          end
          prefix = front .. prefix
          local append_candidates
          append_candidates = function(t)
            if type(t) == 'table' then
              for k in pairs(t) do
                if all or k:sub(1, #last) == last then
                  table.insert(res, prefix .. k)
                end
              end
            end
          end
          append_candidates(t)
          do
            local mt = getmetatable(t)
            if mt then
              append_candidates(mt.__index)
            end
          end
          return res
        end
      end
    end
  end
end
local compgen
compgen = function(env)
  local candidates = cndgen(env)
  return function(c, s)
    do
      local cc = candidates(s)
      if cc then
        local _list_0 = cc
        for _index_0 = 1, #_list_0 do
          local name = _list_0[_index_0]
          ln.addcompletion(c, name)
        end
      end
    end
  end
end
local repl
repl = function(env, _ENV)
  if env == nil then
    env = { }
  end
  if _ENV == nil then
    _ENV = _ENV
  end
  local block = { }
  ln.setcompletion(compgen(_ENV))
  local get_line
  get_line = function()
    do
      local line = ln.linenoise(prompt.p .. " ")
      if line and line:match('%S') then
        ln.historyadd(line)
      end
      return line
    end
  end
  while true do
    local _continue_0 = false
    repeat
      local line = get_line()
      if not (line) then
        break
      elseif #line < 1 then
        _continue_0 = true
        break
      end
      if line:match("^:") then
        (require('moor.replcmd'))(line)
        _continue_0 = true
        break
      end
      local lua_code, err = to_lua(line)
      if lua_code and not err then
        evalprint(env, lua_code)
      elseif err:match("^Failed to parse") then
        insert(block, line)
        prompt.reset((function()
          do
            prompt:deepen()
            while line and #line > 0 do
              line = get_line()
              insert(block, " " .. tostring(line))
            end
            return prompt
          end
        end)())
        lua_code, err = to_lua(concat(block, "\n"))
        if lua_code then
          evalprint(env, lua_code)
        end
        block = { }
      end
      if err then
        printerr(err)
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return env
end
return setmetatable({
  printerr = printerr,
  to_lua = to_lua,
  evalprint = evalprint,
  repl = repl
}, {
  __call = function(self, env, _ENV)
    return repl(env, _ENV)
  end
})
