local api = vim.api
local command = api.nvim_create_user_command

local M = {}
local CONFIG = {
	split = "split",
	confirm = true,
}
local LAST_EXECUTED_CMD = nil

M.config = function(config)
	CONFIG = vim.tbl_deep_extend("force", CONFIG, config)
end

M.exec = function(args)
	local action = table.remove(args.fargs, 1)

	--
	-- Main action – execute the command
	--
	if action == "run" then
		local cmd = table.concat(args.fargs, " ")
		LAST_EXECUTED_CMD = cmd
		require("actions.run").run(cmd, CONFIG)

	--
	-- Repeat the last executed command
	--
	elseif action == "repeat" then
		if not LAST_EXECUTED_CMD then
			vim.notify("No command to repeat")
			return
		end
		require("actions.run").run(LAST_EXECUTED_CMD, CONFIG)

	--
	-- Execute a predefined command
	--
	elseif action == "command" then
		local cmd_name = table.remove(args.fargs, 1)
		local cmd = CONFIG.commands[cmd_name]

		if not cmd then
			vim.notify("No predefined command with name '" .. cmd_name .. "' found")
			return
		end

		cmd = cmd .. " " .. table.concat(args.fargs, " ")
		LAST_EXECUTED_CMD = cmd
		require("actions.run").run(cmd, CONFIG)

	--
	-- Open telescope picker with predefined commands
	--
	elseif action == "telescope" then
		require("actions.telescope").run(CONFIG)
	else
		vim.notify("Invalid action: " .. action)
	end
end

M.setup = function(opts)
	M.config(opts)

	command("Execa", M.exec, {
		nargs = "*",
		complete = function(arg_lead, cmd_line, cursor_pos)
			if string.match(cmd_line, "command") then
				return vim.tbl_keys(CONFIG.commands)
			end
			return { "run", "command", "repeat", "telescope" }
		end,
	})
end

return M

-- TODO: add command history
-- TODO: Config:
--     3. Allow to redefine what gets executed,
--        e.g. let people pass a function that
--        receives the command
-- TODO: add command description
-- TODO: add context to the command
--       - in telescope picker show only commands matching current file language
--       - when run check that the context match current file language
