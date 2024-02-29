if vim.g.load_run then
	return
end

vim.g.load_run = true

vim.api.nvim_create_user_command("Run", function()
	require("run").run()
end, { desc = "run current file", force = false })

vim.keymap.set("n", "<C-b>", "<cmd>Run<CR>", { silent = true, noremap = true, desc = "run current file" })
