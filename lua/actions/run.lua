local M = {}

local winid = nil

local function check_terminal(bufrn)
	local buftype = vim.api.nvim_buf_get_option(bufrn, "buftype")
	if buftype == "terminal" then
		return true
	end
	return false
end

M.run = function(args, config)
	local cmd = require("common.process_command").process_command(args)
	local cur_win = vim.api.nvim_get_current_win()

	if config.verbose then
		vim.notify("Running command → " .. cmd)
	end

	local bufrn = nil
	if winid ~= nil and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_set_current_win(winid)
		bufrn = vim.api.nvim_get_current_buf()
	else
		winid = nil
	end

	if bufrn ~= nil and check_terminal(bufrn) then
		vim.cmd("terminal " .. cmd)
	else
		vim.cmd(config.split .. " | terminal " .. cmd)
		winid = vim.api.nvim_get_current_win()
	end

	vim.api.nvim_set_current_win(cur_win)

	return args
end

return M
