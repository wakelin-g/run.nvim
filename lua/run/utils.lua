local M = {}

function M.create_buf()
	return vim.api.nvim_create_buf(false, true)
end

function M.delete_buf(handle)
	vim.api.nvim_buf_delete(handle, { force = true })
end

function M.get_ft(bufnr)
	if bufnr ~= nil then
		-- return require("plenary.filetype").detect(vim.api.nvim_buf_get_name(bufnr))
		return vim.filetype.match({ buf = bufnr })
	end
end

return M
