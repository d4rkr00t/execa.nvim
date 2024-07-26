local api = vim.api
local command = api.nvim_create_user_command

local M = {}
local CONFIG = {
	split = "split",
	verbose = false,
}
local LAST_EXECUTED_CMD = nil

M.config = function(config)
	CONFIG = vim.tbl_deep_extend("force", CONFIG, config)
end

M.exec = function(args)
	local action = table.remove(args.fargs, 1)

	if action == "run" then
		local cmd = table.concat(args.fargs, " ")
		LAST_EXECUTED_CMD = cmd
		require("actions.run").run(cmd, CONFIG)
	elseif action == "repeat" then
		if not LAST_EXECUTED_CMD then
			vim.notify("No command to repeat")
			return
		end
		require("actions.run").run(LAST_EXECUTED_CMD, CONFIG)
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
			return { "run", "command", "repeat" }
		end,
	})
end

return M

-- TODO: Config:
--     3. Allow to redefine what gets executed,
--        e.g. let people pass a function that
--        receives the command
-- TODO: More variables
--   1. Test name
--   2. String value
-- TODO: Readme
-- TODO: Docs
