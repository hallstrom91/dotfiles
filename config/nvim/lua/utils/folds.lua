local ts_get_captures = vim.treesitter.get_captures_at_pos

local function fold_virt_text(result, line, lnum, coloff)
	coloff = coloff or 0

	local buf = {}
	local hl = nil

	local function push_segment()
		if #buf == 0 then
			return
		end
		result[#result + 1] = { table.concat(buf), hl }
		buf = {}
	end

	for i = 1, #line do
		local char = line:sub(i, i)

		local captures = ts_get_captures(0, lnum, coloff + i - 1)
		local cap = captures[#captures]

		local new_hl = hl
		if cap then
			new_hl = "@" .. cap.capture
		end

		if new_hl ~= hl then
			push_segment()
			hl = new_hl
		end

		buf[#buf + 1] = char
	end
	push_segment()
end

function _G.custom_foldtext()
	local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
	local end_str = vim.fn.getline(vim.v.foldend)
	local end_ = vim.trim(end_str)
	local result = {}
	fold_virt_text(result, start, vim.v.foldstart - 1)
	table.insert(result, { " ... ", "Delimiter" })
	fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))
	return result
end
