return {
	----| Autopairs (){}[]  |----
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = function()
		local npairs = require("nvim-autopairs")
		npairs.setup(opts)

		local Rule = require("nvim-autopairs.rule")
		local ts_conds = require("nvim-autopairs.ts-conds")

		npairs.add_rules({
			Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript" })
				:use_regex(true)
				:set_end_pair_length(2),
		})

		-- add trailing commas to "'} inside Lua tables
		npairs.add_rules({
			Rule("{", "},", "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
			Rule("'", "',", "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
			Rule('"', '",', "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
		})
		return {
			check_ts = true,
			enable_check_bracket_line = true,
			disable_filetype = { "TelescopePrompt", "spectre_panel", "neo-tree" },
		}
	end,
}
