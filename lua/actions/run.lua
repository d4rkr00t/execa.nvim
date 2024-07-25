local M = {}

M.run = function(args, config)
	local cmd = require("common.process_command").process_command(args)
	vim.cmd(config.split .. " | terminal " .. cmd)
	return args
end

return M
