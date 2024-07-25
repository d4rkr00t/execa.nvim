local M = {}

M.run = function(args, config)
	local cmd = require("common.process_command").process_command(args)
	if config.verbose then
		vim.notify("Running command → " .. cmd)
	end
	vim.cmd(config.split .. " | terminal " .. cmd)
	return args
end

return M
