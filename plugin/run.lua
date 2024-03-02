if vim.g.load_run then
	return
end

vim.g.load_run = true

local group = vim.api.nvim_create_augroup("RunGroup", { clear = true })

vim.api.nvim_create_user_command("RunRun", function()
	require("run").main()
end, { desc = "[run.nvim]: run current file", force = false })

vim.api.nvim_create_user_command("RunSwitch", function()
	require("run").change_command()
end, { desc = "[run.nvim]: change current run command", force = false })

vim.filetype.add({ runwin = "runwin" })

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "runwin" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})
