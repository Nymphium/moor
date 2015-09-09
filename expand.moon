expand = (t, env) ->
	env = env or _G
	
	if type(t[2]) == "string"
		t[2] = tonumber t[2] or t[2]
		if env._lexcep_tmp
			env._lexcep_tmp[t[2]]
		else
			env[t[1]][t[2]]

	elseif t[2].label == "ta"
		env._lexcep_tmp = env._lexcep_tmp and env._lexcep_tmp[t[2][1]] or env[t[1]][t[2][1]]

		expand t[2], env


return expand

