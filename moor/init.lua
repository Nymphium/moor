local repl
repl = function(args, env)
  if env == nil then
    env = _ENV
  end
  local parse = require("moonscript.parse")
  local compile = require("moonscript.compile")
  local linenoise = require('linenoise')
  local inspect = require('inspect')
  local typedet
  typedet = function(obj, typ)
    return (type(obj)) == typ
  end
  local insert
  insert = table.insert
  local lua_candidates
  lua_candidates = function(line)
    local i1 = line:find('[.\\%w_]+$')
    if not (i1) then
      return 
    end
    local front = line:sub(1, i1 - 1)
    local partial = line:sub(i1)
    local res = { }
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
      for k in pairs(t) do
        if all or k:sub(1, #last) == last then
          insert(res, prefix .. k)
        end
      end
    end
    if typedet(t, 'table') then
      append_candidates(t)
    end
    local mt = getmetatable(t)
    if mt and typedet(mt.__index, 'table') then
      append_candidates(mt.__index)
    end
    return res
  end
  local completion_handler
  completion_handler = function(c, s)
    local cc = lua_candidates(s)
    if cc then
      for _index_0 = 1, #cc do
        local name = cc[_index_0]
        linenoise.addcompletion(c, name)
      end
    end
  end
  local oldg
  do
    local _tbl_0 = { }
    for k, v in pairs(env) do
      _tbl_0[k] = v
    end
    oldg = _tbl_0
  end
  local newglobs
  newglobs = function()
    local ret
    do
      local _accum_0 = { }
      local _len_0 = 1
      for k in pairs(env) do
        if not oldg[k] then
          _accum_0[_len_0] = k
          _len_0 = _len_0 + 1
        end
      end
      ret = _accum_0
    end
    local singularity = "true"
    if #ret < 1 then
      insert(ret, singularity)
    end
    return ret
  end
  local chopline
  chopline = function(txt)
    return txt:gsub('^[^\n]+\n', '', 1)
  end
  local firstline
  firstline = function(txt)
    return txt:match('^[^\n]*')
  end
  local capture
  capture = function(ok, ...)
    local t = {
      ...
    }
    t.n = select('#', ...)
    return ok, t
  end
  local eval_lua
  eval_lua = function(lua_code)
    local chunk, err = loadstring(lua_code, 'tmp')
    if err then
      print(err)
      return 
    end
    local ok, res = capture(pcall(chunk))
    if not ok then
      print(res[1])
      return 
    elseif #res > 0 then
      env._l = res[1]
      local out
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, res.n do
          _accum_0[_len_0] = inspect(res[i])
          _len_0 = _len_0 + 1
        end
        out = _accum_0
      end
      return io.write(table.concat(out, '\t'), '\n')
    end
  end
  local old_lua_code = nil
  local eval_moon
  eval_moon = function(moon_code)
    local locs = 'local ' .. table.concat(newglobs(), ', ')
    moon_code = locs .. '\n' .. moon_code
    local tree, err = parse.string(moon_code)
    if not (tree) then
      print(err)
      return 
    end
    local lua_code, pos
    lua_code, err, pos = compile.tree(tree)
    if not (lua_code) then
      print(compile.format_error(err, pos, moon_code))
      return 
    end
    lua_code = chopline(lua_code)
    local was_local, rest = lua_code:match('^local (%S+)(.+)')
    if was_local then
      if rest:match('\n') then
        rest = firstline(rest)
      end
      if rest:match('=') then
        lua_code = lua_code:gsub('^local%s+', '')
      else
        lua_code = chopline(lua_code)
      end
    end
    old_lua_code = lua_code
    return eval_lua(lua_code)
  end
  local cmdop
  cmdop = function(args)
    local cnt, repl_flag, earg, oneshot = 0
    local nexta
    nexta = function()
      cnt = cnt + 1
      return args[cnt]
    end
    local msg
    msg = function()
      io.write('Usage: moonr [options]\n', '\n', '   -h         print this message\n', '   -n         continue running REPL after "e" option completed\n', '   -e STR     execute string as MoonScript code\n', '   -l LIB     load library before run REPL\n\n')
      return os.exit(1)
    end
    while true do
      local a = nexta()
      if not (a) then
        break
      end
      local flag, rest = a:match('^%-(%a)(%S*)')
      local _exp_0 = flag
      if 'l' == _exp_0 then
        local ok, err = pcall(require, #rest > 0 and rest or nexta())
        if not (ok) then
          print(err, '\n')
          msg()
        end
      elseif 'n' == _exp_0 then
        repl_flag = true
      elseif 'e' == _exp_0 then
        earg = true
        oneshot = true
        local ok, err = pcall(eval_moon, nexta())
        if not (ok) then
          print(err)
          msg()
        end
      else
        msg()
      end
    end
    if not earg then
      print("moor on MoonScript version " .. tostring((require('moonscript.version')).version) .. " on " .. tostring(_VERSION))
    end
    return repl_flag or not oneshot
  end
  if args then
    if not cmdop(args) then
      os.exit()
    end
  end
  linenoise.setcompletion(completion_handler)
  local prompt = '> '
  local indent, rex = '', require('rex_posix')
  local get_line
  get_line = function()
    local line = linenoise.linenoise(prompt .. indent)
    if line and line:match('%S') then
      linenoise.historyadd(line)
    end
    return line
  end
  local is_blockstart
  is_blockstart = function(line)
    local h, b = line:match('([^%[]-%s?)(for%s).*')
    if b and #b > 0 then
      return #h < 1
    else
      return rex.match(line, '\\b(class|switch|when|while)\\b') or rex.match(line, '\\b(do)\\b$') or rex.match(line, '\\b((else)?if|unless)\\b') and not rex.match(line, '.-\\bthen\\b') or line:match('[=-]>$') or line:match('%s*\\%s*$')
    end
  end
  while true do
    local line = get_line()
    if not line then
      return 
    end
    if is_blockstart(line) then
      line = line:match("^(.-)%s*\\?%s*$")
      local code = setmetatable({
        line
      }, {
        __mode = 'k'
      })
      indent = indent .. ' '
      line = get_line()
      while line and #line > 0 do
        insert(code, indent .. line)
        line = get_line()
      end
      code = table.concat(code, '\n')
      indent = ''
      eval_moon(code)
    elseif line:match('^%?que') then
      print(old_lua_code)
    else
      eval_moon(line)
    end
  end
end
return repl
