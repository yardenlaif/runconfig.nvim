-- nvim-runconfig
-- By Yarden Laifenfeld
-- github.com/yardenlaif
-- @yardenlaif

-------------------- VARIABLES -----------------------------
local api, cmd, fn, vim = vim.api, vim.cmd, vim.fn, vim
local fmt = string.format
local nkeys = api.nvim_replace_termcodes('<C-\\><C-n>G', true, false, true)
local job_buffer, job_id
local M = {}

-------------------- OPTIONS -------------------------------
local options = {
  buildfile = '.buildme.sh',  -- the build file to execute
  interpreter = 'bash',       -- the interpreter to use (bash, python, ...)
  force = '--force',          -- the option to pass when the bang is used
  wincmd = '',                -- a window command to run prior to a build job
}

-------------------- PRIVATE -------------------------------
local function buffer_exists()
  return job_buffer and fn.buflisted(job_buffer) == 1
end

local function move_to_buffer()
	if not buffer_exists() then
		job_buffer = api.nvim_create_buf(true, true)
	end
	if not win or not api.nvim_get_current_win() == win then
		prev_win = api.nvim_get_current_win()
	end
	if not win or not api.nvim_win_is_valid(win) then
		api.nvim_exec('below 10sp', true)
		win = vim.api.nvim_get_current_win()
	else
		vim.api.nvim_set_current_win(win)
	end
	vim.api.nvim_win_set_buf(win, job_buffer)
	api.nvim_buf_set_option(job_buffer, 'filetype', 'term')
	api.nvim_buf_set_option(job_buffer, 'modified', false)
end

local function autoscroll()
	vim.cmd("norm G")
end

local function return_to_prev_win()
	if prev_win and api.nvim_win_is_valid(prev_win) then
		api.nvim_set_current_win(prev_win)
	end
end


-------------------- PUBLIC --------------------------------
function M.run(config_name, config_file)
	configs = require(config_file)
	config = configs[config_name]
	local cmd = config.cmd
	env = config.env
	opts = {
		clear_env = true,
		env = env,
		on_exit = return_to_prev_win,
	}
	move_to_buffer()
	-- Start build job
	if job_id then
		local temp_prev_win = prev_win
		prev_win = win
		fn.jobstop(job_id)
		prev_win = temp_prev_win
	end
	job_id = fn.termopen(table.concat(cmd, " && "), opts)
	api.nvim_buf_set_name(job_buffer, config_name .. " (RunConfig)")
	autoscroll()
end

------------------------------------------------------------
return M
