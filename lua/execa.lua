local api = vim.api
local command = api.nvim_create_user_command
local ts_utils = require("nvim-treesitter.ts_utils")

---@param bufnr integer
---@param range Range4
---@return vim.treesitter.LanguageTree[]
local function get_parent_langtrees(bufnr, range)
	local root_tree = vim.treesitter.get_parser(bufnr)
	if not root_tree then
		return {}
	end

	local ret = { root_tree }

	while true do
		local child_langtree = nil

		for _, langtree in pairs(ret[#ret]:children()) do
			if langtree:contains(range) then
				child_langtree = langtree
				break
			end
		end

		if not child_langtree then
			break
		end
		ret[#ret + 1] = child_langtree
	end

	return ret
end

--- @param langtree vim.treesitter.LanguageTree
--- @param range Range4
--- @return TSNode[]?
local function get_parent_nodes(langtree, range)
	local tree = langtree:tree_for_range(range, { ignore_injections = true })
	if not tree then
		return
	end

	local n = tree:root():named_descendant_for_range(unpack(range))

	local ret = {} --- @type TSNode[]
	while n do
		ret[#ret + 1] = n
		n = n:parent()
	end
	return ret
end

local function get_fn_name(bufnr, line, col)
	local trees = get_parent_langtrees(bufnr, { line, col, line, col })
	local query = vim.treesitter.query.parse("lua", "((function_declaration name: (identifier) @function-name))")

	for i = 1, #trees do
		local nodes = get_parent_nodes(trees[i], { line, col, line, col })
		for j = 1, #nodes do
			if nodes and nodes[j]:type() == "function_declaration" then
				local iter = query:iter_captures(nodes[j], 0)
				local capture_ID, capture_node = iter()
				local fn_name = ts_utils.get_node_text(capture_node, 0)[1]
				return fn_name
			end
		end
	end

	return ""
end

local M = {}

M.config = function()
	print("Config execa")
end

M.exec = function(args)
	local action = table.remove(args.fargs, 1)
	local bufnr = api.nvim_get_current_buf()

	local line = api.nvim_win_get_cursor(0)[1]
	local col = api.nvim_win_get_cursor(0)[2]
	local fn_name = get_fn_name(bufnr, line, col)
	local file_path = vim.fn.expand("%:p")

	local cmd = table.concat(args.fargs, " ")
	cmd = cmd:gsub("$EX_FN", fn_name)
	cmd = cmd:gsub("$EX_FILE_PATH", file_path)
	cmd = cmd:gsub("$EX_LINE", line)
	cmd = cmd:gsub("$EX_COL", col)

	print(vim.inspect(args))
	print(vim.inspect(action))
	print(vim.inspect(cmd))
	vim.cmd("split | terminal " .. cmd)
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
-- TODO: Extract all non-setup code to a separate file
