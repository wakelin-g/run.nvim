local M = {}

local u = require("run.utils")

local default_run_commands = {
	["c"] = "clang " .. vim.fn.expand("%") .. " && ./a.out",
	["cpp"] = "clang++ " .. vim.fn.expand("%") .. " && ./a.out",
	["python"] = "python " .. vim.fn.expand("%"),
	["rs"] = "cargo run",
	["go"] = "go run " .. vim.fn.expand("%"),
	["lua"] = "lua " .. vim.fn.expand("%"),
}

M.config = {}

function M.setup(args)
	M.config.use_default_bindings = args.use_default_bindings or true
	if M.config.use_default_bindings then
		vim.keymap.set("n", "<C-b>", "<cmd>Run<CR>", { silent = true, noremap = true, desc = "run current file" })
	end
	M.config.win_width = tonumber(args.win_width) or 40
	M.config.output_msg = args.output_msg or " -- OUTPUT -- "
	M.config.run_commands = vim.tbl_deep_extend("force", args.commands or {}, default_run_commands)
end

function M.get_command(ft)
	for ft_match, command in pairs(M.config.run_commands) do
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

function M.is_available(ft)
	return u.contains(ft, M.config.run_commands)
end

local function buffer_attach(bufnr, command)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("run-main", { clear = true }),
		callback = function()
			local append_data = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
				end
			end

			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { M.config.output_msg, "" })
			M.run_job(command, append_data)
		end,
	})
end

function M.main()
	local bufnr_cur = vim.api.nvim_get_current_buf()
	local ft = vim.filetype.match({ buf = bufnr_cur })

	if not M.is_available(ft) then
		vim.notify("[run.nvim]: Could not find the `run` command for this filetype.")
		return
	end

	local command = M.get_command(ft)
	local bufnr_out = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_set_option_value("filetype", "runwin", { buf = bufnr_out })
	vim.api.nvim_buf_set_lines(bufnr_out, 0, -1, false, { M.config.output_msg, "" })

	local append_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(bufnr_out, -1, -1, false, data)
		end
	end

	local win = vim.api.nvim_open_win(bufnr_out, false, { split = "right", win = 0, style = "minimal" })
	vim.api.nvim_win_set_width(win, M.config.win_width)

	M.run_job(command, append_data)

	buffer_attach(vim.api.nvim_win_get_buf(win), command)
end

return M
