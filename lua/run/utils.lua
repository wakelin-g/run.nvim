local M = {}

function M.contains(key, table)
	for k, _ in pairs(table) do
		if k == key then
			return true
		end
	end
	return false
end

return M
