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
		assert.is_true opts env, {"-luakatsu", "-E", [[kii = Aikatsu\find_birthday "12/03"]]}
		assert.is_not_nil env.kii
		assert.is_not_nil Aikatsu  --- yes, it's correct behavior
	
	it "load library as LIB test", ->
		expected_txt = "{\n  x = 3\n}"
		assert.is_true opts env, {"-Linspect", "-E", [[foo = inspect {x: 3}]]}
		assert.is_same env.foo, expected_txt

	it "help and exit test", ->
		opts env, {'-h'}
		assert.is_same 1, env.MOOR_EXITCODE

