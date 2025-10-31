return {
	----| color brackets etc|----
	{
		"HiPhish/rainbow-delimiters.nvim",
		-- event = "BufReadPost",
		event = "BufReadPre",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					javascript = "rainbow-parens",
					typescript = "rainbow-parens",
					tsx = "rainbow-parens",
					lua = "rainbow-blocks",
				},
				priority = {
					[""] = 110,
					lua = 210,
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},

	----| indent, chunks |----
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local function safe_hl_color(hl)
				local color = vim.fn.synIDattr(vim.fn.hlID(hl), "fg", "gui")
				return color ~= "" and color or "#FFFFFF"
			end

			return {
				line_num = {
					enable = true,
					use_treesitter = false,
					style = "#9112BC",
				},
				chunk = {
					enable = true,
					use_treesitter = false, -- def = true -- not recommended after v1.2.1
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "╭",
						left_bottom = "╰",
						--right_arrow = ">",
						right_arrow = "",
					},
					error_sign = true,
					style = {
						"#9112BC",
						"#c21f30",
					},
				},

				indent = {
					enable = true,
					--chars = { "│" },
					chars = {
						"",
					},
					style = {
						safe_hl_color("RainbowDelimiterBlue"),
						safe_hl_color("RainbowDelimiterViolet"),
						safe_hl_color("RainbowDelimiterCyan"),
					},
					filter_list = {
						function(v)
							return v.level ~= 1
						end,
					},
				},

				blank = {
					enable = false,
					chars = {
						" ",
					},
				},
			}
		end,
	},
}
