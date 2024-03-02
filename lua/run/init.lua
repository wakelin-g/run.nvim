local M = {}

local u = require("run.utils")

local default_run_commands = {
	["c"] = { "clang " .. vim.fn.expand("%") .. " && ./a.out" },
	["cpp"] = { "clang++ " .. vim.fn.expand("%") .. " && ./a.out" },
	["python"] = { "python3 " .. vim.fn.expand("%") },
	["rust"] = { "cargo run" },
	["go"] = { "go run " .. vim.fn.expand("%") },
	["lua"] = { "lua " .. vim.fn.expand("%") },
}

M.config = {}

function M.setup(args)
	M.config.use_default_bindings = args.use_default_bindings or true
	if M.config.use_default_bindings then
		vim.keymap.set("n", "<C-b>", "<cmd>RunRun<CR>", { silent = true, noremap = true, desc = "run current file" })
	end
	M.config.win_width = tonumber(args.win_width) or 40
	M.config.output_msg = args.output_msg or " -- OUTPUT -- "

	for arg_key, arg_val in pairs(args.commands or {}) do
		if default_run_commands[arg_key] == nil then
			default_run_commands[arg_key] = arg_val
		else
			for _, val in pairs(arg_val) do
				table.insert(default_run_commands[arg_key], val)
			end
		end
	end
	M.config.run_commands = default_run_commands
end

function M.get_command(ft)
	for ft_match, command in pairs(M.config.run_commands) do
		if ft_match == ft then
			if #command == 1 then
				return command[1]
			else
				local selected
				vim.ui.select(command, {
					prompt = "Select command to run: ",
					format_item = function(item)
						return ft .. " : " .. item
					end,
				}, function(choice)
					selected = choice
				end)
				return selected
			end
		end
	end
	vim.notify("[run.nvim]: Could not find the `run` command for this filetype.")
end

function M.get_command_list()
	return M.config.run_commands
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
	vim.b.run_autocmd = vim.api.nvim_create_autocmd("BufWritePost", {
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

function M.change_command()
	local ft = vim.api.nvim_get_current_buf()
	vim.b.run_buf_command = M.get_command(vim.filetype.match({ buf = ft }))
	vim.api.nvim_del_autocmd(vim.b.run_autocmd)
	buffer_attach(vim.api.nvim_win_get_buf(vim.b.run_win), vim.b.run_buf_command)
end

local function make_window(bufnr)
	vim.b.run_win = vim.api.nvim_open_win(bufnr, false, { split = "right", win = 0, style = "minimal" })
	vim.api.nvim_win_set_width(vim.b.run_win, M.config.win_width)
end

function M.main()
	local bufnr_cur = vim.api.nvim_get_current_buf()
	local ft = vim.filetype.match({ buf = bufnr_cur })

	if not M.is_available(ft) then
		vim.notify("[run.nvim]: Could not find the `run` command for this filetype.")
		return
	end

	if vim.b.run_buf_handle == nil then
		vim.b.run_buf_handle = vim.api.nvim_create_buf(false, true)
		vim.b.run_buf_command = M.get_command(ft)

		vim.api.nvim_set_option_value("filetype", "runwin", { buf = vim.b.run_buf_handle })
		vim.api.nvim_buf_set_lines(vim.b.run_buf_handle, 0, -1, false, { M.config.output_msg, "" })

		make_window(vim.b.run_buf_handle)
		buffer_attach(vim.api.nvim_win_get_buf(vim.b.run_win), vim.b.run_buf_command)
	end

	if u.is_visible(vim.b.run_buf_handle) == false then
		make_window(vim.b.run_buf_handle)
	end
	vim.api.nvim_buf_set_lines(vim.b.run_buf_handle, 0, -1, false, { M.config.output_msg, "" })
	M.run_job(vim.b.run_buf_command, function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(vim.b.run_buf_handle, -1, -1, false, data)
		end
	end)
end

return M
