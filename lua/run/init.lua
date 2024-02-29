local utils = require("run.utils")

local M = {}

local default_run_commands = {
	["c"] = "clang " .. vim.fn.expand("%") .. " && ./a.out",
	["cpp"] = "clang++ " .. vim.fn.expand("%") .. " && ./a.out",
	["py"] = "python3 " .. vim.fn.expand("%"),
	["rs"] = "cargo run",
	["go"] = "go run " .. vim.fn.expand("%"),
	["lua"] = "lua " .. vim.fn.expand("%"),
}

M.run_commands = default_run_commands

function M.get_command(bufnr)
	local ft = utils.get_ft(bufnr)
	for ft_match, command in pairs(default_run_commands) do
		if ft_match == ft then
			return command
		end
	end
	vim.notify("[run.nvim]: Could not find the `run` command for this filetype.")
end

function M.run_job(command, callback)
	vim.fn.jobstart(command, {
		stdout_buffered = true,
		on_stdout = callback,
		on_stderr = callback,
	})
end

function M.run()
	local buf = vim.api.nvim_get_current_buf()
	local cmd = M.get_command(buf)
	local out = utils.create_buf()
	vim.api.nvim_buf_set_lines(out, 0, -1, false, { "output:" })
	local append_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(out, -1, -1, false, data)
		end
	end
	local win = vim.api.nvim_open_win(out, true, { split = "right", win = 0, style = "minimal" })
	vim.api.nvim_win_set_width(win, 40)
	M.run_job(cmd, append_data)
	M.buffer_attach(vim.api.nvim_win_get_buf(win), cmd)
end

function M.buffer_attach(bufnr, command)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("run-main", { clear = true }),
		callback = function()
			local append_data = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
				end
			end

			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "output:" })
			M.run_job(command, append_data)
		end,
	})
end

return M
