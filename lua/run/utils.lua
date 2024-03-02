local M = {}

function M.contains(key, table)
	for k, _ in pairs(table) do
		if k == key then
			return true
		end
	end
	return false
end

function M.is_visible(bufnr)
	for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
		for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
			local winbufnr = vim.api.nvim_win_get_buf(winid)
			local winvalid = vim.api.nvim_win_is_valid(winid)
			if winvalid and winbufnr == bufnr then
				return true
			end
		end
	end
	return false
end

return M
