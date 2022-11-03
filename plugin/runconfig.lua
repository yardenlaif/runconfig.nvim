local api = vim.api

if vim.g.runconfig ~= nil then
  return
end
vim.g.runconfig = 1

-- Exposes the plugin's functions for use as commands in Neovim.
api.nvim_create_user_command('RunConfig', function(info)
  local current_buf = vim.api.nvim_get_current_buf()
  local config_name = string.len(info.args) > 0 and info.args or "default"
  local config_file = "runconfigs"

  require("runconfig").run(config_name, config_file)
end, {
  desc = 'Run a configuration',
  nargs = '?',
  complete = runconfig_get_configs,
})
