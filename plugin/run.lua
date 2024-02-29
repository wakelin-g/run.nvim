if vim.g.load_run then
	return
end

vim.g.load_run = true

vim.api.nvim_create_user_command("Run", function()
	require("run").run()
end, { silent = true, desc = "run current file" })
