describe "moor.opt module", ->
	local opts, moor, bkenv, env

	setup ->
		opts = require'moor.opts'
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


		if _ENV then bkenv =  deepcpy _ENV
		else _G["_ENV"] = deepcpy _G

		bkenv = deepcpy _ENV
		env = {}

	it "execute and exit test", ->
		assert.falsy opts {}, {"-e", "nil"}

	it "load library to global test", ->
		with assert
			.is_true opts env, {"-luakatsu", "-E", [[kii = Aikatsu\find_birthday "12/03"]]}
			.is_not_nil env.kii
			.is_not_nil Aikatsu  --- yes, it's correct behavior

	it "load library as LIB test", ->
		with assert
			.is_true opts env, {"-Linspect", "-E", [[foo = inspect {x: 3}, newline: ""]]}
			.is_same env.foo, "{  x = 3}"
	it "load moon file test", ->
		opts env, {"-E", [[test = require"spec.test_for_require"]], "-E", [[ok = nil]]}
		opts env, {[[-Lspec.test_for_require]]}

		with assert
			.is_same 0, env.MOOR_EXITCODE
			.is_same "hello", env.test
			.is_same "ok", env.ok_require
			.is_not_nil ok_require

	it "help and exit test", ->
		opts env, {'-h'}
		assert.is_same 1, env.MOOR_EXITCODE

