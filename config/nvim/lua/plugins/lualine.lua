return {
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			icons_enabled = true,
			theme = "auto",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			always_show_tabline = true,
			globalstatus = false,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
				refresh_time = 16, -- ~60fps
				events = {
					"WinEnter",
					"BufEnter",
					"BufWritePost",
					"SessionLoadPost",
					"FileChangedShellPost",
					"VimResized",
					"Filetype",
					"CursorMoved",
					"CursorMovedI",
					"ModeChanged",
				},
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},

		winbar = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename", path = 2 },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {
				{
					"datetime",
					padding = 1,
					style = "%H:%M",
					-- icon = { ll_ic.clock, aling = "left" },
					-- color = { bg = c.bg4, gui = "bold" },
					-- separator = { left = ll_ic.sep_left, right = ll_ic.sep_right },
				},
			},
		},
		inactive_winbar = {},
		extensions = {},
	},
}

-- -- local c = {
-- -- 	bg = require("utils.highlight").get_hl_with_hex("Normal").bg_hex,
-- -- 	bg2 = "#2B303B",
-- -- 	bg3 = "#383F4E",
-- -- 	bg4 = "#464E5F",
-- -- 	fg_dark = "#191B1F",
-- -- 	fg_light = "#CACCCE",
-- -- 	green = "#A3BE8C",
-- -- 	blue = "#5E81AC",
-- -- 	pink = "#B48EAD",
-- -- 	yellow = "#EBCD8B",
-- -- 	red = "#BF616A",
-- -- 	error = "#E26161",
-- -- 	warn = "##E29B61",
-- -- 	info = "#61D5E2", -- or "#61D5E2"
-- -- 	hint = "#6197E2", -- or "#61B3E2" || or "#6170E2"
-- -- 	hint2 = "#61B3E2",
-- -- }
--
-- -- local custom_theme = {
-- -- 	normal = {
-- -- 		a = { fg = c.fg_dark, bg = c.green, gui = "bold" },
-- -- 		b = { fg = c.fg_light, bg = c.bg_sec_b },
-- -- 		c = { fg = c.fg_light, bg = c.bg },
-- -- 	},
-- -- 	insert = { a = { fg = c.fg_light, bg = c.blue, gui = "bold" } },
-- -- 	visual = { a = { fg = c.fg_dark, bg = c.pink, gui = "bold" } },
-- -- 	replace = { a = { fg = c.fg_light, bg = c.red, gui = "bold" } },
-- -- 	command = { a = { fg = c.fg_dark, bg = c.yellow, gui = "bold" } },
-- -- }
--
-- -- local ll_ext = require("modern-north.groups.plugins.lualine")
--
-- local function search_result()
-- 	if vim.v.hlsearch == 0 then
-- 		return ""
-- 	end
-- 	local last_search = vim.fn.getreg("/")
-- 	if not last_search or last_search == "" then
-- 		return ""
-- 	end
-- 	local s_count = vim.fn.searchcount({ maxcount = 999 })
-- 	return last_search .. " [" .. s_count.current .. "/" .. s_count.total .. "]"
-- end
--
-- return {
-- 	"nvim-lualine/lualine.nvim",
-- 	event = "BufWinEnter",
-- 	opts = function()
-- 		-- local lsp_status = require("config.status_lsp")
-- 		-- local status_ts = require("config.status_ts").ts_status
-- 		-- local lsp_clients = lsp_status.lsp_clients
-- 		-- local lsp_active_ws = lsp_status.lsp_active_workspace
-- 		-- local icons = require("utils.icons")
--
-- 		-- local ll_ic = {
-- 		-- 	sep_right = icons.ple.round_right,
-- 		-- 	sep_left = icons.ple.round_left,
-- 		-- 	search = icons.get_icon("general", "search", { pr = 1 }),
-- 		-- 	mode_ic = icons.general.neovim,
-- 		-- 	clock = icons.get_icon("general", "clock", { pr = 1 }),
-- 		-- 	git_branch = icons.get_icon("git.nf_md", "git", { pr = 1 }),
-- 		-- 	git_add = icons.get_icon("git.nf_cod", "diff_added", { pr = 1 }),
-- 		-- 	git_modified = icons.get_icon("git.nf_cod", "diff_modified", { pr = 1 }),
-- 		-- 	git_removed = icons.get_icon("git.nf_cod", "diff_removed", { pr = 1 }),
-- 		-- }
--
-- 		return {
-- 			options = {
-- 				-- theme = custom_theme,
-- 				-- theme = ll_ext.ll_theme(),
-- 				component_separators = "",
-- 				section_separators = "",
-- 				always_divide_middle = true,
-- 				always_show_tabline = true,
-- 				disabled_filetypes = {
-- 					statusline = { "neo-tree", "git", "fugitive", "trouble", "dashboard" },
-- 					winbar = { "neo-tree", "DiffviewFiles", "git", "dashboard" },
-- 				},
-- 			},
--
-- 	-- 		sections = {
-- 	-- 			lualine_a = {
-- 	-- 				{
-- 	-- 					"mode",
-- 	-- 					padding = 1,
-- 	-- 					-- icon = { ll_ic.mode_ic, align = "left" },
-- 	-- 					-- separator = { left = ll_ic.sep_left, right = ll_ic.sep_right },
-- 	-- 				},
-- 	-- 			},
-- 	--
-- 	-- 			lualine_b = {
-- 	-- 				{
-- 	-- 					"filetype",
-- 	-- 					icon_only = false,
-- 	-- 					icon = { align = "left" },
-- 	-- 					color = { bg = c.bg2 },
-- 	-- 					separator = { right = ll_ic.sep_right },
-- 	-- 				},
-- 	--
-- 	-- 				{
-- 	-- 					"filename",
-- 	-- 					file_status = false,
-- 	-- 					path = 0,
-- 	-- 					separator = { right = ll_ic.sep_right },
-- 	-- 					color = { bg = c.bg2 },
-- 	-- 				},
-- 	-- 				{
-- 	-- 					"diff",
-- 	-- 					padding = 1,
-- 	-- 					symbols = { added = ll_ic.git_add, modified = ll_ic.git_modified, removed = ll_ic.git_removed },
-- 	-- 					source = function()
-- 	-- 						local git = vim.b.gitsigns_status_dict
-- 	-- 						if git then
-- 	-- 							return {
-- 	-- 								added = git.added,
-- 	-- 								modified = git.changed,
-- 	-- 								removed = git.removed,
-- 	-- 							}
-- 	-- 						end
-- 	-- 					end,
-- 	-- 					separator = { right = ll_ic.sep_right },
-- 	--
-- 	-- 					color = { bg = c.bg3 },
-- 	-- 				},
-- 	-- 				{
-- 	--
-- 	-- 					"branch",
-- 	-- 					icon = ll_ic.git_branch,
-- 	-- 					color = { bg = c.bg3, fg = c.blue, gui = "italic" },
-- 	-- 					separator = { right = ll_ic.sep_right },
-- 	-- 				},
-- 	-- 			},
-- 	-- 			lualine_c = {}, -- leave empty for 'transparent' center section
-- 	-- 			lualine_x = {}, -- leave empty for 'transparent' center section
-- 	-- 			lualine_y = {
-- 	-- 				{
-- 	-- 					search_result,
-- 	-- 					padding = 1,
-- 	-- 					color = { bg = c.bg3 },
-- 	-- 					icon = { ll_ic.search, align = "left" },
-- 	-- 					separator = { left = ll_ic.sep_left },
-- 	-- 				},
-- 	-- 				{
-- 	-- 					"progress",
-- 	-- 					color = { bg = c.bg2, fg = c.blue },
-- 	-- 					padding = 1,
-- 	-- 					separator = { left = ll_ic.sep_left },
-- 	-- 				},
-- 	-- 				{
-- 	-- 					"location",
-- 	-- 					padding = 1,
-- 	-- 					icon = { "" },
-- 	-- 					color = { bg = c.bg2 },
-- 	-- 				},
-- 	-- 				{
-- 	-- 					"diagnostics",
-- 	-- 					sources = { "nvim_lsp", "nvim_diagnostic" },
-- 	-- 					sections = { "error" },
-- 	-- 					diagnostics_color = { error = { bg = c.red, fg = c.fg_light } },
-- 	-- 					separator = { left = ll_ic.sep_left },
-- 	-- 				},
-- 	-- 				{
-- 	-- 					"diagnostics",
-- 	-- 					sources = { "nvim_lsp", "nvim_diagnostic" },
-- 	-- 					sections = { "warn" },
-- 	-- 					diagnostics_color = { warn = { bg = c.yellow, fg = c.fg_dark } },
-- 	-- 				},
-- 	-- 				{
-- 	-- 					"diagnostics",
-- 	-- 					sources = { "nvim_lsp", "nvim_diagnostic" },
-- 	-- 					sections = { "info", "hint" },
-- 	-- 					diagnostics_color = {
-- 	-- 						info = { bg = c.info, fg = c.fg_dark },
-- 	-- 						hint = { bg = c.hint, fg = c.fg_dark },
-- 	-- 					},
-- 	-- 				},
-- 	-- 			},
-- 	-- 			lualine_z = {
-- 	-- 				{
-- 	-- 					"hostname",
-- 	-- 					separator = { left = ll_ic.sep_left, right = ll_ic.sep_right },
-- 	-- 				},
-- 	-- 			},
-- 	-- 		},
-- 	--
-- 	-- 		------------------------------
-- 	-- 		--- WINBAR: top of active buf
-- 	-- 		winbar = {
-- 	-- 			lualine_a = {
-- 	-- 				{
-- 	-- 					"mode",
-- 	-- 					padding = 1,
-- 	-- 					icon = { ll_ic.mode_ic, align = "left" },
-- 	-- 					separator = { left = ll_ic.sep_left, right = ll_ic.sep_right },
-- 	-- 				},
-- 	-- 			},
-- 	-- 			-- lualine_b = {
-- 	-- 			-- 	{
-- 	-- 			-- 		lsp_clients,
-- 	-- 			-- 		padding = 1,
-- 	-- 			-- 		separator = { right = ll_ic.sep_right },
-- 	-- 			-- 		color = { bg = c.bg2, fg = c.blue, gui = "bold" },
-- 	-- 			-- 	},
-- 	-- 			-- 	{
-- 	-- 			-- 		lsp_active_ws,
-- 	-- 			-- 		padding = 1,
-- 	-- 			-- 		color = { bg = c.bg3, gui = "italic" },
-- 	-- 			-- 		separator = { right = ll_ic.sep_right },
-- 	-- 			-- 	},
-- 	-- 				{
-- 	-- 					"datetime",
-- 	-- 					padding = 1,
-- 	-- 					style = "%H:%M",
-- 	-- 					icon = { ll_ic.clock, aling = "left" },
-- 	-- 					color = { bg = c.bg4, gui = "bold" },
-- 	-- 					separator = { left = ll_ic.sep_left, right = ll_ic.sep_right },
-- 	-- 				},
-- 	-- 			},
-- 	-- 			lualine_c = {},
-- 	-- 			lualine_x = {},
-- 	-- 			lualine_y = {},
-- 	-- 			lualine_z = {},
-- 	-- 		},
-- 	--
-- 	-- 		-- dont show anything as sections (lualine bottom) in 'inactive' buffer
-- 	-- 		inactive_sections = {
-- 	-- 			lualine_a = {},
-- 	-- 			lualine_b = {},
-- 	-- 			lualine_c = {},
-- 	-- 			lualine_x = {},
-- 	-- 			lualine_y = {},
-- 	-- 			lualine_z = { "filename" },
-- 	-- 		},
-- 	--
-- 	-- 		-- dont show anything as winbar in 'inactive' buffer,
-- 	-- 		inactive_winbar = {
-- 	-- 			lualine_a = {},
-- 	-- 			lualine_b = {},
-- 	-- 			lualine_c = {},
-- 	-- 			lualine_x = {},
-- 	-- 			lualine_y = {},
-- 	-- 			lualine_z = {},
-- 	-- 		},
-- 	-- 	}
-- 	-- end,
-- }
