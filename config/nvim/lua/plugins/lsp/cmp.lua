-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
local kind_icons = {
	Text = "",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "",
	Field = "󰇽",
	Variable = "󰂡",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰅲",
}

local function truncate(str, max)
	if not str or max <= 0 then
		return ""
	end
	if vim.fn.strdisplaywidth(str) <= max then
		return str
	end
	return vim.fn.strcharpart(str, 0, max - 1) .. "..."
end

local source_label = {
	nvim_lsp = "[LSP]",
	luasnip = "[SNIP]",
	nvim_lua = "[LUA]",
	buffer = "[BUF]",
	path = "[PATH]",
}

return {
	----| autocomplete/intellisense |----
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",

			"saadparwaiz1/cmp_luasnip",
			"roginfarrer/cmp-css-variables",
		},
		opts = function()
			local cmp = require("cmp")
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")

			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

			return {
				completion = {
					-- autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
					-- completeopt = "menu,menuone,preview,noinsert",
					completeopt = "menu, menuone, noinsert",
				},

				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- luasnip
					end,
				},

				performance = {
					max_view_entries = 30,
					-- 	debounce = 60,
					-- 	trottle = 30,
					-- 	fetching_timeout = 200,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							require("luasnip").expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							require("luasnip").jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp", keyword_length = 1 },
					{ name = "luasnip", keyword_length = 2 },
					{ name = "css-variables", keyword_length = 3 },
					{ name = "buffer", keyword_length = 3 },
					{ name = "path", keyword_length = 3 },
				}),

				window = {
					documentation = {
						border = "rounded",
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
					},
					completion = {
						border = "rounded",
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
				},

				-- enabled = function()
				--
				-- 	local context = require("cmp.config.context")
				--
				--
				-- end

				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, item)
						local icon = kind_icons[item.kind] or "" --na-fa-flash (fallback icon)
						local kind_name = item.kind

						item.kind = " " .. icon .. " "

						item.abbr = truncate(item.abbr, 50)

						-- local src = source_label[entry.source.name] or ("[" .. entry.source.name .. "]")
						-- item.menu = (" (%s) . %s"):format(kind_name, src)
						item.menu = (" (%s)"):format(kind_name)
						return item
					end,
				},

				cmp.setup.cmdline({ "/", "?" }, {
					mapping = cmp.mapping.preset.cmdline(),
					sources = {
						{ name = "buffer" },
					},
				}),

				cmp.setup.cmdline(":", {
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = "path" },
					}, {
						{ name = "cmdline" },
					}),
				}),
			}
		end,
	},

	----| snippet support |----
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		build = "make install_jsregexp",
	},

	----| colorizer |----
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
		--lazy = true,
		event = "VeryLazy",
		opts = {
			color_square_width = 2,
		},
	},

	{
		"roginfarrer/cmp-css-variables",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "css" },
		lazy = true,
	},
}
