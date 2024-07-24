local api = vim.api
local command = api.nvim_create_user_command

local M = {}
local CONFIG = {
	split = "split",
}

M.config = function(config)
	CONFIG = vim.tbl_deep_extend("force", CONFIG, config)
end

M.exec = function(args)
	local action = table.remove(args.fargs, 1)
	if action == "run" then
		require("actions.run").run(args.fargs, CONFIG)
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

-- TODO: CLI -- DONE
--     1. Parse arguments  -- DONE
--     2. Autocomplete     -- DONE
-- TODO: Variables:
--     1. EX_FN            -- DONE
--     2. EX_FILE_PATH     -- DONE
--     3. EX_LINE          -- DONE
--     4. EX_COL           -- DONE
--     5. EX_DIR
-- TODO: Replace variables -- DONE
-- TODO: Commands:
--     1. Execa run <cmd> <args>
--     2. Execa command <predefined_cmd>
--     3. Execa repeat <- repeat last command
-- TODO: Config:
--     1. Predefined commands
--     2. Define vsplit vs split for the output -- DONE
--     3. Allow to redefine what gets executed, e.g. let people pass a function that receives the command
-- TODO: Tresitter queries for more languages -- DONE
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
