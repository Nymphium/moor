-- MoonScript REPL based mooni
repl = (args, env = _ENV) ->
	parse = require "moonscript.parse"
	compile = require "moonscript.compile"
	linenoise = require 'linenoise'
	inspect = require'inspect'
	typedet = (obj, typ) -> (type obj) == typ
	import insert, concat from table

	---- tab-completion logic from luaish ------------
	lua_candidates = (line) ->
	  -- identify the expression!
		i1 = line\find '[.\\%w_]+$'

		return unless i1

		front = line\sub(1, i1 - 1)
		partial = line\sub i1
		res = {}
		prefix, last = partial\match '(.-)([^.\\]*)$'
		t, all = env

		if #prefix > 0
			P = prefix\sub(1, -2)
			all = last == ''

			for w in P\gmatch '[^.\\]+'
				t = t[w]

				return unless t

		prefix = front .. prefix

		append_candidates = (t) -> for k in pairs t do insert(res, prefix..k) if all or k\sub(1, #last) == last

		append_candidates t if typedet(t, 'table')

		mt = getmetatable t

		append_candidates mt.__index if mt and typedet(mt.__index, 'table')

		res

	completion_handler = (c, s) ->
		cc = lua_candidates s

		if cc then for name in *cc do linenoise.addcompletion c, name

	-- need to keep track of what globals have been added during the session
	oldg = {k, v for k, v in pairs env}

	-- (this will return their names)
	newglobs = ->
		ret = [k for k in pairs env when not oldg[k]]
		singularity = "true"

		insert(ret, singularity) if #ret < 1

		ret

	chopline = (txt) -> txt\gsub('^[^\n]+\n', '', 1)
	firstline = (txt) -> txt\match'^[^\n]*'

	capture = (ok, ...) ->
		t = {...}
		t.n = select('#', ...)

		ok, t

	eval_lua = (lua_code) ->
		chunk, err = loadstring(lua_code, 'tmp')

		if err -- Lua compile error is rare!
			print err
			return

		ok, res = capture pcall chunk

		if not ok -- runtime error
			print res[1]
			return
		elseif #res > 0
			-- this allows for overriding basic value printing
			env._l = res[1] -- save last value calculated
			out = [inspect res[i] for i = 1, res.n]

			io.write(concat(out, '\t'), '\n')

	old_lua_code = nil

	eval_moon = (moon_code) ->
		-- Ugly fiddle #2: we force Moonscript code to regard
		-- any _new_ globals as known globals
		ngl = newglobs!
		locs = type(ngl) != "table" and 'local '..concat(ngl, ', ') or "return nil"
		moon_code = locs..'\n'..moon_code
		tree, err = parse.string moon_code

		unless tree
			print err
			return

		lua_code, err, pos = compile.tree tree

		unless lua_code
			print(compile.format_error err, pos, moon_code)
			return

		-- our code is ready
		-- Fiddle #2 requires us to lose the top local declarations we inserted
		lua_code = chopline lua_code

		-- Fiddle #1 Moonscript will of course declare any new variables
		-- as local. This fiddle removes the 'local'
		was_local, rest = lua_code\match '^local (%S+)(.+)'

		if was_local
			rest = firstline rest if rest\match '\n'

			-- two cases; either a direct local assignmnent or a declaration line
			if rest\match '='
				lua_code = lua_code\gsub '^local%s+', ''
			else
				lua_code = chopline lua_code

		old_lua_code = lua_code

		eval_lua lua_code

	---- parsing command line -------
	cmdop = (args) ->
		local repl_flag, earg, oneshot

		nexta = ->
			table.remove args, 1

		msg = ->
			io.write 'Usage: moonr [options]\n',
				'\n',
				'   -h         print this message\n',
				'   -n         continue running REPL after "e" option completed\n',
				'   -e STR     execute string as MoonScript code\n',
				'   -l LIB     load library before run REPL\n',
				'   -L LIB     execute `LIB = require"LIB"` before run REPL\n\n'

			os.exit 1

		while true
			a = nexta!

			break unless a

			flag, rest = a\match '^%-(%a)(%S*)'

			switch flag
				when 'l'
					ok, err = pcall require, #rest > 0 and rest or nexta!
					unless ok
						print err, '\n'
						msg!
				when 'L'
					lib = #rest > 0 and rest or nexta!
					ok, cont = pcall require, lib
					unless ok
						print cont, '\n'
						msg!
					else
						env[rest] = cont
				when 'n'
					repl_flag = true
				when 'e'
					earg = true
					oneshot = true
					ok, err = pcall eval_moon, (#rest > 0 and rest or nexta!)
					unless ok
						print err
						msg!
				else
					msg!

		print "moor on MoonScript version #{(require 'moonscript.version').version} on #{_VERSION}" if not earg

		repl_flag or not oneshot

	if args
		os.exit! unless cmdop args

	---- repl function
	linenoise.setcompletion completion_handler

	prompt = '> '
	indent, rex = '', require'rex_posix'

	get_line = (prm = prompt, idt = indent) ->
		line = linenoise.linenoise prm .. idt

		if line and line\match '%S'
			linenoise.historyadd line

		line

	is_blockstart = (line) ->
		h, b = line\match '([^%[]-%s?)(for%s).*'

		if b and #b > 0
			#h < 1
		else
			rex.match(line, '\\b(class|switch|when|while)\\b') or
			rex.match(line, '\\b(do)\\b$') or
			rex.match(line, '\\b((else)?if|unless)\\b') and not rex.match(line, '.-\\bthen\\b') or
			line\match"%s*with%s" or
			line\match'[=-]>$' or
			line\match'%s*\\%s*$'

	while true
		line = get_line!

		return if not line

		if is_blockstart line
			line = line\match"^(.-)%s*\\?%s*$"
			code = setmetatable({line}, __mode: 'kv')
			indent ..= ' '
			line = get_line '?', indent..' '

			while line and #line > 0
				insert(code, indent .. line)
				line = get_line '?', indent..' '

			code = concat(code, '\n')
			indent = ''

			eval_moon code
		elseif line\match'^%?que'
			print old_lua_code
		else
			eval_moon line

repl

