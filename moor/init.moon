parse = require'moonscript.parse'
compile = require'moonscript.compile'
ln = require'linenoise'
inspect = require'inspect'
import remove, insert, concat from table

printerr = (...) -> io.stderr\write "#{concat {...}, "\t"}\n"

prompt =
	p: ">"
	deepen: => @p = "? "
	reset: => @p = ">"

-- MoonScript transpiler
to_lua = (code) ->
	tree, err = parse.string code

	if err
		nil, err
	else
		lua_code, err, pos = compile.tree tree

		unless lua_code
			nil, compile.format_error err, pos, code
		else
			lua_code

-- Lua evaluator & printer
fnwrap = (code) -> "return function(__newenv) local _ENV = setmetatable(__newenv, {__index = _ENV}) #{code} end"

evalprint = (env, lua_code) ->
	is_mod = true

	lua_code = if vardec = lua_code\match"^local%s+(.*)$"
		if exportFnCl = vardec\match "^%w+%s+(.*)$"
			fnwrap exportFnCl
		else
			fnwrap vardec
	elseif lua_code\match"^return%s+%(?%s*%w+%s*%)?"
		fnwrap lua_code
	else
		is_mod = false
		lua_code

	luafn, err = loadstring lua_code, "tmp"

	if err then printerr err
	else
		if is_mod then luafn = luafn()
		result = {pcall luafn, env}

		ok = remove result, 1

		unless ok then printerr result[1]
		else
			if #result > 0
				print (inspect result)\match"^%s*{%s*(.*)%s*}%s*%n?%s*$"
				unpack result

---- tab completion
cndgen = (env) ->  (line) ->
	if i1 = line\find '[.\\%w_]+$' -- if completable
		with res = {}
			front = line\sub(1, i1 - 1)
			partial = line\sub i1
			prefix, last = partial\match '(.-)([^.\\]*)$'
			t, all = env

			if #prefix > 0 -- tbl.ky or not
				P = prefix\sub(1, -2)
				all = last == ''

				for w in P\gmatch '[^.\\]+'
					t = t[w]

					return unless t

			prefix = front .. prefix

			append_candidates = (t) ->
				if type(t) == 'table'
					table.insert(res, prefix .. k) for k in pairs t when all or k\sub(1, #last) == last

			append_candidates t

			if mt = getmetatable t then append_candidates mt.__index

compgen = (env) ->
	candidates = cndgen env

	(c, s) -> if cc = candidates s
		ln.addcompletion c, name for name in *cc

-- main repl
repl = (env = {}, _ENV = _ENV) ->
	block = {}

	ln.setcompletion compgen _ENV

	get_line = ->
		with line = ln.linenoise prompt.p .. " "
			if line and line\match '%S' then ln.historyadd line

	while true
		line = get_line!

		unless line then break
		elseif #line < 1 then continue

		if line\match"^:"
			(require'moor.replcmd') line
			continue

		-- continue `->` or `class .....`
		lua_code, err = to_lua line

		if lua_code and not err
			evalprint env, lua_code
		elseif err\match "^Failed to parse"
			insert block, line

			prompt.reset with prompt
				\deepen!
				while line and #line > 0
					line = get_line!
					insert block, " #{line}"

			lua_code, err = to_lua concat block, "\n"

			if lua_code then evalprint env, lua_code

			block = {}

		if err
			printerr err

	env

setmetatable {:printerr, :to_lua, :evalprint, :repl}, __call: (env, _ENV) => repl env, _ENV

