parse = require'moonscript.parse'
compile = require'moonscript.compile'
inspect = require'inspect'
import remove, insert, concat from table

printerr = (...) -> io.stderr\write "#{concat {...}, "\t"}\n"

to_lua = (code) ->
	tree, err = parse.string code

	return nil, err if err

	lua_code, err, pos = compile.tree tree

	unless lua_code
		nil, compile.format_error err, pos, code
	else lua_code

-- Lua evaluator & printer
fnwrap = (code) -> "return function(__newenv) local _ENV = setmetatable(__newenv, {__index = _ENV}) #{code} end"

evalprint = (env, lua_code) ->
	lua_code = if vardec = lua_code\match"^local%s+(.*)$"
			if exportFnCl = vardec\match "^%w+%s+(.*)$"
				if exportFnCl\match "^="
					"#{lua_code\match"local%s+(%w+)"} #{exportFnCl}"
				else exportFnCl
			else vardec
		elseif lua_code\match"__class"
			lua_code = lua_code\gsub "^local%s+", "export" , "1"
		else lua_code

	luafn, err = load fnwrap(lua_code), "tmp"

	return printerr err if err

	result = {pcall luafn!, env}

	ok = remove result, 1

	unless ok then printerr result[1]
	else
		if #result > 0
			print (inspect result)\match"^%s*{%s*(.*)%s*}%s*%n?%s*$"
			table.unpack result

{:printerr, :to_lua, :fnwrap, :evalprint}
