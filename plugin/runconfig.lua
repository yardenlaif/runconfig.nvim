local api = vim.api

if vim.g.runconfig ~= nil then
	return
end
vim.g.runconfig = 1

-- Exposes the plugin's functions for use as commands in Neovim.
api.nvim_create_user_command('RunConfig', function(info)
	local args = string.len(info.args) > 0 and info.args or "default"
	local argTab = { }
	for w in args:gmatch("%S+") do
		table.insert(argTab, w)
	end
	local config_file = "runconfigs"
	local config_name = argTab[1]
	table.remove(argTab, 1)

	require("runconfig").run(config_name, config_file, argTab)
end, {
	desc = 'Run a configuration',
	nargs = '+',
	complete = require("runconfig").complete,
})
api.nvim_create_user_command('RerunConfig', function()
	require("runconfig").rerun()
end, {
	desc = 'Rerun previous configuration',
})
