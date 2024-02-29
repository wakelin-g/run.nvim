local utils = require("run.utils")

local M = {}

M.run_commands = {
	["c"] = "clang " .. vim.fn.expand("%") .. " && ./a.out",
	["cpp"] = "clang++ " .. vim.fn.expand("%") .. " && ./a.out",
	["py"] = "python3 " .. vim.fn.expand("%"),
	["rs"] = "cargo run",
	["go"] = "go run " .. vim.fn.expand("%"),
	["lua"] = "lua " .. vim.fn.expand("%"),
}

function M.get_command(bufnr)
	local ft = function()
		if bufnr ~= nil then
			return vim.filetype.match({ buf = bufnr })
		end
	end
	for ft_match, command in pairs(M.run_commands) do
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
	vim.notify("[run.nvim]: Attached to buffer.")
end

function M.run()
	local bufnr = vim.api.nvim_get_current_buf()
	local command = M.get_command(bufnr)
	local bufnr_out = utils.create_buf()
	vim.api.nvim_buf_set_lines(bufnr_out, 0, -1, false, { "output:" })
	local append_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(bufnr_out, -1, -1, false, data)
		end
	end
	local win = vim.api.nvim_open_win(bufnr_out, true, { split = "right", win = 0, style = "minimal" })
	vim.api.nvim_win_set_width(win, 40)
	M.run_job(command, append_data)
	M.buffer_attach(vim.api.nvim_win_get_buf(win), command)
end

function M.setup(commands)
	commands = commands or {}
	M.run_commands = vim.tbl_deep_extend("force", commands, M.run_commands)
end

return M
