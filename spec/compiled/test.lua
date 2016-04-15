return describe("moor module", function()
  local moor
  local bkenv
  local env
  setup(function()
    moor = require('moor')
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
  return describe("evalprint test", function()
    local evalprint, to_lua
    evalprint, to_lua = moor.evalprint, moor.to_lua
    it("ex1. variable declaration", function()
      evalprint(env, (to_lua("x, y, z = 1, 2, 3")))
      assert.are.same(env, {
        x = 1,
        y = 2,
        z = 3
      })
      return assert.are.same(bkenv, _ENV)
    end)
    it("ex2. do-export variable declaration", function()
      evalprint(env, (to_lua("do indo = 0")))
      evalprint(env, (to_lua("do export eindo = 1")))
      assert.is.falsy(env.indo)
      return assert.are.same(env.eindo, 1)
    end)
    return it("ex3. eval with env", function()
      local ans = evalprint(env, (moor.to_lua("x + y + z")))
      return assert.is_true(ans == (env.x + env.y + env.z))
    end)
  end)
end)