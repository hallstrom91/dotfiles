local M = {}

---@param config table
---@return table
function M.scale_size(config)
	local def = { width = 0.5, height = 0.5 } -- default size

	config = config or def
	config.width = config.width or def.width
	config.height = config.height or def.height

	local width = vim.fn.round(vim.o.columns * config.width)
	local height = vim.fn.round(vim.o.lines * config.height)

	return {
		width = width,
		height = height,
	}
end

return M
