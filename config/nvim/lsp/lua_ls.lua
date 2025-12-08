local root = require("utils.root")

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/lua_ls.lua
-- https://github.com/luals/lua-language-server
---@type vim.lsp.Config
return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_dir = root({
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		".git",
	}),
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
				},
			},
			completion = { enable = true, callSnippet = "Replace" },
			hint = {
				enable = true,
				setType = false,
				paramType = "Disable",
				semicolon = "Disable",
				arrayIndex = "Disable",
			},
			format = {
				enable = false,
			},
		},
	},
}
