local M = {}

M.run = function(CONFIG)
	local predefined_commands = {}

	for k, v in pairs(CONFIG.commands) do
		table.insert(predefined_commands, k)
	end

	vim.ui.select(predefined_commands, {
		prompt = "Execa Commands",
	}, function(item)
		if not item then
			return
		end
		vim.cmd("Execa command " .. item)
	end)
end

return M
