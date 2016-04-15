describe "moor module", ->
	local moor
	local bkenv
	local env

	setup ->
		moor = require'moor'

		deepcpy = (t, list = {}) -> with ret = {}
			for k, v in pairs t
				if type(v) == "table"
					kk = tostring v
					
					unless  list[kk]
						list[kk] = v
						ret[k] = deepcpy v, list
					else ret[k] = list[kk]
				else ret[k] = v


		bkenv =  deepcpy _ENV
		env = {}

	-- it "to_lua test", ->
		-- moon_code = io.open"spec/test_spec.moon"
		-- lua_code = io.open"spec/compiled/test.lua"

		-- assert.is(moon_code)
		-- assert.is(lua_code)

		-- assert.are.equals(moor.to_lua(moon_code\read "*a"), lua_code\read "*a")

		-- moon_code\close!
		-- lua_code\close!

	describe "evalprint test", ->
		import evalprint, to_lua from moor

		it "ex1. variable declaration", ->
			evalprint env, (to_lua "x, y, z = 1, 2, 3")
			assert.are.same(env, {x:1,y:2,z:3})
			assert.are.same(bkenv, _ENV)

		it "ex2. do-export variable declaration", ->
			evalprint env, (to_lua "do indo = 0")
			evalprint env, (to_lua "do export eindo = 1")
			assert.is.falsy(env.indo)
			assert.are.same(env.eindo, 1)

		it "ex3. eval with env", ->
			ans = evalprint env, (moor.to_lua "x + y + z")
			assert.is_true(ans == (env.x + env.y + env.z))

