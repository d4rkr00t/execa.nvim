local M = {}

M.run = function(args)
	local cmd = require("common.process_command").process_command(args)
	vim.cmd("split | terminal " .. cmd)
end

return M
