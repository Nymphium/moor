-- MoonScript REPL based mooni
repl = (args, env = _ENV) ->
	parse = require "moonscript.parse"
	compile = require "moonscript.compile"
	linenoise = require 'linenoise'
	typedet = (obj, typ) -> (type obj) == typ
	import insert from table
	-- insert = (t, pos) -> t[#t + 1] = pos

	------- a useful table dumper ------

	quote  = (v) ->
		if typedet(v, 'string')
			'%q'\format v
		else
			tostring v

	dump = (t, options) ->
		options = options or {}
		limit = options.limit or 1000
		buff = tables:{[t]:true}
		k, tbuff = 1, nil

		put = (v) ->
			buff[k] = v
			k += 1

		put_value = (value) ->
			unless typedet(value, 'table')
				put quote value
				if limit and k > limit
					buff[k] = '...'
					error 'buffer overrun'
			else
				unless buff.tables[value] -- cycle detection
					buff.tables[value] = true
					tbuff value
				else
					put '<cycle>'
			put ', '

		tbuff = (t) ->
			mt = getmetatable t unless options.raw
			if not typedet(t, 'table') or mt and mt.__tostring
				put quote t
			else
				put '{'
				indices = #t > 0 and {i, true for i = 1, #t}
				for key, value in pairs t -- first do the hash part
					continue if indices and indices[key]

					if not typedet(key, 'string')
						key = '[' .. tostring key .. ']'
					elseif key\match '%s'
						key = quote key
					put key .. ':'
					put_value value
				if indices -- then bang out the array part
					for v in *t do put_value v
				if buff[k - 1] == ', ' then k -= 1
				put '}'

		-- we pcall because that's the easiest way to bail out if there's an overrun.
		pcall tbuff, t
		table.concat buff


	---- tab-completion logic from luaish ------------
	lua_candidates = (line) ->
	  -- identify the expression!
		i1 = line\find '[.\\%w_]+$'
		unless i1 then return
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
				unless t then return

		prefix = front .. prefix

		append_candidates = (t) -> for k in pairs t do if all or k\sub(1, #last) == last then insert(res, prefix .. k)

		if typedet(t, 'table') then append_candidates t
		mt = getmetatable t
		if mt and typedet(mt.__index, 'table') then append_candidates mt.__index
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
		if #ret < 1 then insert(ret, singularity)
		ret


	chopline = (txt) -> txt\gsub '^[^\n]+\n', '', 1
	firstline = (txt) -> txt\match '^[^\n]*'

	capture = (ok, ...) ->
		t = {...}
		t.n = select '#', ...
		ok, t

	eval_lua = (lua_code) ->
		chunk, err = loadstring lua_code, 'tmp'
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
			out = [dump res[i] for i = 1, res.n]
			io.write table.concat(out, '\t'), '\n'

	old_lua_code = nil

	eval_moon = (moon_code) ->
		-- Ugly fiddle #2: we force Moonscript code to regard
		-- any _new_ globals as known globals
		locs = 'local '..table.concat(newglobs!, ', ')
		moon_code = locs..'\n'..moon_code
		tree, err = parse.string moon_code
		-- if not tree
		unless tree
			print err
			return
		lua_code, err, pos = compile.tree tree
		-- if not lua_code
		unless lua_code
			print compile.format_error err, pos, moon_code
			return
		-- our code is ready
		-- Fiddle #2 requires us to lose the top local declarations we inserted
		lua_code = chopline lua_code
		-- Fiddle #1 Moonscript will of course declare any new variables
		-- as local. This fiddle removes the 'local'
		was_local, rest = lua_code\match '^local (%S+)(.+)'
		if was_local
			if rest\match '\n' then rest = firstline rest
			-- two cases; either a direct local assignmnent or a declaration line
			if rest\match '='
				lua_code = lua_code\gsub '^local%s+', ''
			else
				lua_code = chopline lua_code
		old_lua_code = lua_code
		eval_lua lua_code

	---- parsing command line -------
	cmdop = (args) ->
		cnt, repl_flag, earg, oneshot = 0

		nexta = ->
			cnt += 1

			args[cnt]

		msg = ->
			io.write 'Usage: moonr [options]\n',
				'\n',
				'   -h         print this message\n',
				'   -n         continue running REPL after "e" option completed\n',
				'   -e STR     execute string as MoonScript code\n',
				'   -l LIB     load library before run REPL\n\n'

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
				when 'n'
					repl_flag = true
				when 'e'
					earg = true
					oneshot = true
					ok, err = pcall eval_moon, nexta!
					unless ok
						print err
						msg!
				else
					msg!

		print "moor on MoonScript version #{(require 'moonscript.version').version} on #{_VERSION}" if not earg

		repl_flag or not oneshot

	if args
		os.exit! if not cmdop args

	---- repl function
	linenoise.setcompletion completion_handler

	prompt = '> '
	indent, rex = '', require'rex_posix'

	get_line = ->
		line = linenoise.linenoise prompt .. indent

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
			line\match'[=-]>$' or
			line\match'%s*\\%s*$'

	env.moor = :dump

	while true
		line = get_line!

		return if not line

		if is_blockstart line
			line = line\match"^(.-)%s*\\?%s*$"
			code = setmetatable {line}, __mode: 'k'
			indent ..= ' '
			line = get_line!

			while line and #line > 0
				insert code, indent .. line

				line = get_line!

			code = table.concat code, '\n'
			indent = ''

			eval_moon code

		elseif line\match '^%?que'
			print old_lua_code
		else
			eval_moon line

repl

