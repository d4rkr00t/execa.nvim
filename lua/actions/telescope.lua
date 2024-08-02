local M = {}

M.run = function(CONFIG)
	local exist, pickers = pcall(require, "telescope.pickers")

	if not exist then
		vim.notify("Telescope is not installed")
		return
	end

	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local predefined_commands = {}

	for k, v in pairs(CONFIG.commands) do
		table.insert(predefined_commands, k)
	end

	local commands_picker = function(opts)
		pickers
			.new(require("telescope.themes").get_dropdown({}), {
				prompt_title = "Execa Commands",
				finder = finders.new_table({
					results = predefined_commands,
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						vim.cmd("Execa command " .. selection.value)
					end)
					return true
				end,
			})
			:find()
	end

	-- to execute the function
	commands_picker()
end

return M
