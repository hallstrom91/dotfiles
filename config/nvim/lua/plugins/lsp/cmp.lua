-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance

-- disable completion context
local disable_in_ctx = function()
	local ctx = require("cmp.config.context")

	if vim.bo.buftype == "prompt" then
		return false
	end
	if vim.bo.filetype == "TelescopePrompt" then
		return false
	end
	return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
end

return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip", -- LuaSnip integration in CMP
			"roginfarrer/cmp-css-variables", -- CSS variables without LSP attached (css_variables)
		},
		opts = function()
			local cmp = require("cmp")
			-- local ctx = require("cmp.config.context")
			local luasnip = require("luasnip")

			-- create hl
			local hl = require("utils.highlight")
			hl.soft_pmenu_sel("CmpSelSoft", 0.6)

			-- autopairs on `confirm`
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

			-- cmdline completion: search (`/` and/or `?`) = buffer
			cmp.setup.cmdline({ "/" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- cmdline completion: command (`:`) = path & cmdline
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})

			-- LSP capabilities for a given server, try this in a LSP-enabled buffer:
			--     :lua =vim.lsp.get_clients()[1].server_capabilities
			local ext_capabilities = require("cmp_nvim_lsp").default_capabilities()
			vim.lsp.config("*", {
				capabilities = ext_capabilities,
			})

			return {
				enabled = disable_in_ctx,
				completion = {
					autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
					completeopt = "menu, menuone, noinsert",
					-- keyword_length = 1,
				},
				snippet = {
					expand = function(args)
						-- luasnip.lsp_expand(args.body)
						require("luasnip").lsp_expand(args.body) -- luasnip
					end,
				},
				performance = {
					max_view_entries = 20,
					debounce = 0, -- default: 60
					throttle = 0, -- default: 30
					-- 	fetching_timeout = 200,
				},
				window = {
					documentation = {
						border = "rounded",
						-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:CmpSelSoft,Search:None",
					},
					completion = {
						border = "rounded",
						-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:CmpSelSoft,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
				},
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.close(),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						-- elseif require("luasnip").expand_or_jumpable() then
						-- 	require("luasnip").expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.expand_or_jumpable(-1) then
							luasnip.expand_or_jump(-1)
						-- elseif require("luasnip").jumpable(-1) then
						-- 	require("luasnip").jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- nvim lsp
					{ name = "luasnip", keyword_length = 3 }, -- snippet integration
				}, {
					{ name = "path", keyword_length = 4 },
					{ name = "buffer", keyword_length = 3 },
					{ name = "css-variables", keyword_length = 3 },
				}),

				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, item)
						local cmp_icons = require("utils.icons").cmp_icons
						local kind_box = hl.kind_hlite_box

						local kind = item.kind
						local icon = cmp_icons[kind] or ""

						-- `kind`: highlighted (bg) box -> left column
						item.kind = (" %s %s "):format(icon, kind)
						item.kind_hl_group = kind_box(kind)

						-- `abbr`: search -> suggestions -> center column
						local abbr_truncate = math.floor(vim.api.nvim_win_get_width(0) * 0.5)

						if vim.api.nvim_strwidth(item.abbr) > abbr_truncate then
							item.abbr = ("%s... "):format(item.abbr:sub(1, abbr_truncate))
						end

						--> `menu`: show completion from what [SRC] -> right column
						local src = entry.source.name
						local menu_src = ({
							nvim_lsp = "[LSP]",
							luasnip = "[SNIP]",
							path = "[PATH]",
							buffer = "[BUF]",
							["css-variables"] = "[CSS]",
						})[src] or src

						item.menu = ("[ %s ]").format(menu_src)
						if src == "nvim_lsp" then
							item.menu_hl_group = ("CmpItemKind%s"):format(kind)
						elseif src == "luasnip" then
							item.menu_hl_group = "Comment" -- or something else ?
						else
							item.menu_hl_group = "CmpItemMenu"
						end

						return item
					end,
				},
			}
		end,
	},

	----| snippet support |----
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		build = "make install_jsregexp",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })
		end,
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
