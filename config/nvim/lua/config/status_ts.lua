local M = {}

function M.ts_status()
	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	if ok and parser then
		return "TS:on"
	end
	return "TS:off"
end

return M
