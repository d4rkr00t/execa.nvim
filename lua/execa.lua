local api = vim.api
local command = api.nvim_create_user_command

local M = {}
local CONFIG = {
	split = "split",
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
		complete = function()
			return { "run", "command", "repeat" }
		end,
	})
end

return M

-- TODO: CLI               -- DONE
--     1. Parse arguments  -- DONE
--     2. Autocomplete     -- DONE
-- TODO: Variables:
--     1. EX_FN            -- DONE
--     2. EX_FILE_PATH     -- DONE
--     3. EX_LINE          -- DONE
--     4. EX_COL           -- DONE
--     5. EX_DIR
--     6. EX_FNAME
--     7. EX_FNAME_NO_EXT
-- TODO: Replace variables -- DONE
-- TODO: Commands:         -- DONE
--     1. Execa run <cmd> <args>                -- DONE
--     2. Execa command <predefined_cmd>        -- DONE
--     3. Execa repeat <- repeat last command   -- DONE
-- TODO: Config:
--     1. Predefined commands                   -- DONE
--     2. Define vsplit vs split for the output -- DONE
--     3. Allow to redefine what gets executed,
--        e.g. let people pass a function that
--        receives the command
-- TODO: Tresitter queries for more languages   -- DONE
--     1. Javascript -- DONE
--     2. Typescript -- DONE
--     3. Python     -- DONE
--     4. Rust       -- DONE
--     5. Go         -- DONE
-- TODO: Extract query to a separate file
-- TODO: Escape special characters:
--    1. #
--    2. %
-- TODO: Extract all non-setup code to a separate file -- DONE
-- TODO: Readme
-- TODO: Docs
