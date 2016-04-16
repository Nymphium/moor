package.path = package.path .. ";./?/init.lua;"
return describe("moor module", function()
  local moor
  local bkenv
  local env
  local _ENV = _ENV or setmetatable({ }, {
    __index = _G
  })
  setup(function()
    moor = require('moor.repl')
    local deepcpy
    deepcpy = function(t, list)
      if list == nil then
        list = { }
      end
      do
        local ret = { }
        for k, v in pairs(t) do
          if type(v) == "table" then
            local kk = tostring(v)
            if not (list[kk]) then
              list[kk] = v
              ret[k] = deepcpy(v, list)
            else
              ret[k] = list[kk]
            end
          else
            ret[k] = v
          end
        end
        return ret
      end
    end
    bkenv = deepcpy(_ENV)
    env = { }
  end)
  it("to_lua test", function()
    local moon_code = io.open("spec/init_spec.moon")
    local lua_code = io.open("spec/compiled/test.lua")
    do
      local _with_0 = assert
      _with_0.is_true(moon_code ~= nil)
      _with_0.is_true(lua_code ~= nil)
      _with_0.are.equals(moor.to_lua(moon_code:read("*a")), lua_code:read("*a"))
    end
    moon_code:close()
    return lua_code:close()
  end)
  describe("evalprint test", function()
    local evalprint, to_lua
    evalprint, to_lua = moor.evalprint, moor.to_lua
    it("ex1. variable declaration", function()
      evalprint(env, (to_lua("x, y, z = 1, 2, 3")))
      do
        local _with_0 = assert
        _with_0.are.same(env, {
          x = 1,
          y = 2,
          z = 3
        })
        _with_0.are.same(bkenv, _ENV)
        return _with_0
      end
    end)
    it("ex2. do-export variable declaration", function()
      evalprint(env, (to_lua("do indo = 0")))
      evalprint(env, (to_lua("do export eindo = 1")))
      do
        local _with_0 = assert
        _with_0.is.falsy(env.indo)
        _with_0.are.same(env.eindo, 1)
        return _with_0
      end
    end)
    return it("ex3. eval with env", function()
      local ans = evalprint(env, (moor.to_lua("x + y + z")))
      do
        local _with_0 = assert
        _with_0.is_true(ans == (env.x + env.y + env.z))
        return _with_0
      end
    end)
  end)
  return describe("repl test", function()
    return it("repl", function()
      local lines = {
        [=====[class Foo]=====],
        [=====[f: -> print "Foo"]=====],
        "",
        [=====[Foo.f!]=====]
      }
      local coline = coroutine.create(function()
        for _index_0 = 1, #lines do
          local l = lines[_index_0]
          coroutine.yield(l)
        end
      end)
      local get_line
      get_line = function()
        return coroutine.status(coline) ~= "dead" and select(2, coroutine.resume(coline))
      end
      (moor.replgen(get_line))(env, _ENV)
      do
        local _with_0 = assert
        _with_0.is_true(env.Foo.f ~= nil)
        _with_0.are.same(_ENV, bkenv)
        return _with_0
      end
    end)
  end)
end)