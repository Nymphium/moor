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

	it "to_lua test", ->
		moon_code = io.open"spec/init_spec.moon"
		lua_code = io.open"spec/compiled/test.lua"

		with assert
			.is_true(moon_code != nil)
			.is_true(lua_code != nil)
			.are.equals moor.to_lua(moon_code\read "*a"), lua_code\read "*a"

		moon_code\close!
		lua_code\close!

	describe "evalprint test", ->
		import evalprint, to_lua from moor

		it "ex1. variable declaration", ->
			evalprint env, (to_lua "x, y, z = 1, 2, 3")

			with assert
				.are.same(env, {x:1,y:2,z:3})
				.are.same(bkenv, _ENV)

		it "ex2. do-export variable declaration", ->
			evalprint env, (to_lua "do indo = 0")
			evalprint env, (to_lua "do export eindo = 1")

			with assert
				.is.falsy(env.indo)
				.are.same(env.eindo, 1)

		it "ex3. eval with env", ->
			ans = evalprint env, (moor.to_lua "x + y + z")

			with assert
				.is_true(ans == (env.x + env.y + env.z))

	describe "repl test", ->
		it "repl", ->
			lines = {
				[=====[class Foo]=====]
				[=====[f: -> print "Foo"]=====]
				""
				[=====[Foo.f!]=====]
			}

			coline = coroutine.create ->
				coroutine.yield l for l in *lines

			get_line = ->
				coroutine.status(coline) != "dead" and select 2, coroutine.resume coline

			(moor.replgen get_line) env, _ENV

			with assert
				.is_true env.Foo.f != nil
				.are.same _ENV, bkenv

