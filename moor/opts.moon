import printerr, to_lua, evalprint from require'moor.repl'

eval_moon = (env, txt) ->
	lua_code, err = to_lua txt

	if err then nil, err
	else evalprint env, lua_code

nextagen = => -> table.remove @, 1

msg = ->
	printerr 'Usage: moonr [options]\n',
		'\n',
		'   -h         print this message\n',
		'   -e STR     execute string as MoonScript code and exit\n',
		'   -E STR     execute string as MoonScript code and run REPL\n',
		'   -l LIB     load library before running REPL\n',
		'   -L LIB     execute `LIB = require"LIB"` before running REPL\n',
		''

	os.exit 1

loadlib = (lib) ->
	ok, cont = pcall require, lib

	unless ok
		printerr cont, '\n'
		msg!
	
	cont

evalline = (env, line) ->
	ok, err = pcall eval_moon, env, line

	unless ok
		printerr err
		msg!

(env, arg) ->
	local is_exit
	is_splash = true
	nexta = nextagen arg

	while true
		a = nexta!

		break unless a

		flag, rest = a\match '^%-(%a)(.*)'

		unless flag
			printerr "Failed to parse argument: #{a}"
			msg!

		lstuff = #rest > 0 and rest or nexta!

		switch flag
			when 'l'
				loadlib lstuff
			when 'L'
				if lib = loadlib lstuff
					env[rest] = lib
			when 'e'
				is_exit = true
				is_splash = evalline env, lstuff
			when 'E'
				is_splash = evalline env, lstuff
			else
				if "#{flag}#{rest}" == "no-splash" then is_splash = false
				else
					printerr "invlid flag: #{flag}"
					msg!

	printerr "moor on MoonScript version #{(require 'moonscript.version').version} on #{_VERSION}" if is_splash

	not is_exit

