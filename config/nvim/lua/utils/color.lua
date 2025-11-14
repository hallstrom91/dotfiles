local M = {}

function M.hex(num)
	return num and ("#%06x"):format(num) or nil
end

function M.blend(fg_hex, bg_hex, a)
	if not (fg_hex and bg_hex) then
		return bg_hex or fg_hex
	end

	local function h2r(h)
		return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
	end

	local r1, g1, b1 = h2r(fg_hex)
	local r2, g2, b2 = h2r(bg_hex)
	local r = math.floor(a * r1 + (1 - a) * r2 + 0.5)
	local g = math.floor(a * g1 + (1 - a) * g2 + 0.5)
	local b = math.floor(a * b1 + (1 - a) * b2 + 0.5)
	return ("#%02x%02x%02x"):format(r, g, b)
end

function M.luma(hex)
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)
	return (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
end

return M
