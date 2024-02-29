local utils = require("run.utils")

local M = {}

function M.init()
	local ft = {}
end

local function attach(bufnr, pattern, command)
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = pattern,
		group = vim.api.nvim_create_augroup("run", { clear = true }),
		callback = function()
			local append_data = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
				end
			end

			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "output:" })
			vim.fn.jobstart(command, {
				stdout_buffered = true,
				on_stdout = append_data,
				on_stderr = append_data,
			})
		end,
	})
end

local default_run_commands = {
	["c"] = "clang " .. vim.fn.expand("%") .. " && ./a.out",
	["cpp"] = "clang++ " .. vim.fn.expand("%") .. " && ./a.out",
	["py"] = "python3 " .. vim.fn.expand("%"),
	["rs"] = "cargo run",
	["go"] = "go run " .. vim.fn.expand("%"),
}

M.run_commands = default_run_commands

function M.get_command(bufnr)
	local ft = utils.get_ft(bufnr)
	for ft_match, command in pairs(default_run_commands) do
		if ft_match == ft then
			return command -- command["run"]
		end
	end
	vim.notify("[run.nvim]: Could not find the `run` command for this filetype.")
end

function M.setup(config)
	if config then
		M.run_commands = vim.tbl_deep_extend("force", vim.deepcopy(M.run_commands), config)
	end
end

function M.testrun()
	local buf = vim.api.nvim_get_current_buf()
	local cmd = M.get_command(buf)
	local out = utils.create_buf()
	vim.api.nvim_buf_set_lines(out, 0, -1, false, { "output:" })
	local append_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(out, -1, -1, false, data)
		end
	end
	vim.api.nvim_open_win(0, false, { split = "above", win = 0 })
	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = append_data,
		on_stderr = append_data,
	})
end

return M
