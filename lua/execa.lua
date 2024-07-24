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

M.setup = function()
	command("Execa", M.exec, {
		nargs = "*",
		complete = function()
			return { "run", "command", "repeat" }
		end,
	})
end

return M

-- TODO: CLI
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
--     2. Define vsplit vs split for the output
--     3. Allow redefine what gets executed, e.g. let people pass a function that receives the command
-- TODO: Tresitter queries for more languages
--     1. Javascript
--     2. Typescript
--     3. Python
--     4. Rust
--     5. Go
-- TODO: Extract query to a separate file
-- TODO: Escape special characters:
--    1. #
--    2. %
-- TODO: Extract all non-setup code to a separate file -- DONE
