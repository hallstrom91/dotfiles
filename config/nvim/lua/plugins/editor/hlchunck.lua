local chars_thin = {
	horizontal_line = "─",
	vertical_line = "│",
	left_top = "╭",
	left_bottom = "╰",
	right_arrow = "",
	-- right_arrow = ">",
}

local chars_bold = {
	left_arrow = "━",
	horizontal_line = "━",
	vertical_line = "┃",
	left_top = "┏",
	left_bottom = "┗",
	right_arrow = "━",
}

return
----| indent, chunks |----
{
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPost", "BufReadPre", "BufNewFile" },
	opts = function()
		local utils = require("utils.highlight")

		local FALLBACK_HL = {
			"#AD5E5E",
			"#CF8467",
			"#C9C984",
			"#297594",
			"#4A6F3B",
			"#AD73A9",
			"#3293C7",
		}
		local RAINBOW_GROUPS = {
			"RainbowDelimiterRed",
			"RainbowDelimiterOrange",
			"RainbowDelimiterYellow",
			"RainbowDelimiterBlue",
			"RainbowDelimiterGreen",
			"RainbowDelimiterViolet",
			"RainbowDelimiterCyan",
		}

		local chunck_hl = utils.get_hl_fg("Visual")
		local chunck_hl_err = utils.get_hl_fg("Removed")

		local function indent_rainbow()
			local style = {}
			for i, group in ipairs(RAINBOW_GROUPS) do
				style[i] = utils.get_hl_fg(group) or FALLBACK_HL[i]
			end
			return style
		end

		return {
			-- chunck settings
			chunk = {
				enable = true,
				use_treesitter = false,
				error_sign = true,
				-- chars = chars_thin,
				chars = chars_bold,
				duration = 300,
				delay = 200,
				style = {
					{ fg = chunck_hl }, -- same as "Visual"
					{ fg = chunck_hl_err }, -- same as "Removed"
				},
			},
			-- indent settings
			indent = {
				enable = true,
				chars = {
					-- "┃",
					"│",
				},
				delay = 50,
				style = indent_rainbow(),
			},
		}
	end,
}

-- chars = {
-- 	horizontal_line = "─",
-- 	vertical_line = "│",
-- 	left_top = "╭",
-- 	left_bottom = "╰",
-- 	--right_arrow = ">",
-- 	right_arrow = "",
-- },
