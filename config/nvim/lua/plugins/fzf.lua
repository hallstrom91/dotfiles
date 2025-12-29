return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- or: "nvim-mini/mini.icons"
	keys = function()
		return {
			--- Fzf-lua: Search pickers
			{ "<leader>sh", require("fzf-lua").helptags, desc = "Fzf-lua: Search Help" },
			{ "<leader>sk", require("fzf-lua").keymaps, desc = "Fzf-lua: Search Keymaps" },
			{ "<leader>ss", require("fzf-lua").builtin, desc = "Fzf-lua: Search Fzf-lua" },
			{ "<leader>sd", require("fzf-lua").diagnostics, desc = "Fzf-lua: Search Diagnostic" },
			{ "<leader>sr", require("fzf-lua").resume, desc = "Fzf-lua: Search Resume" },
			--- Fzf-lua: Find
			{ "<leader>ff", require("fzf-lua").files, desc = "Fzf-lua: Find files" },
			{ "<leader>fg", require("fzf-lua").live_grep, desc = "Fzf-lua: Live grep" },
			{
				"<leader>fr",
				function()
					require("fzf-lua").oldfiles({ cwd_only = true })
				end,
				desc = "Fzf-lua: Old files (cwd)",
			},
			{ "<leader>fb", require("fzf-lua").buffers, desc = "Fzf-lua: Buffers" },
			{ "<leader>ft", require("fzf-lua").treesitter, desc = "Fzf-lua: Treesitter symbols" },
			--- Fzf-lua:  git pickers
			{ "<leader>gf", require("fzf-lua").git_files, desc = "Fzf-lua: Git files" },
			{ "<leader>gs", require("fzf-lua").git_status, desc = "Fzf-lua: Git status" },
			{ "<leader>gb", require("fzf-lua").git_branches, desc = "Fzf-lua: Git branches" },
			{ "<leader>gw", require("fzf-lua").git_worktrees, desc = "Fzf-lua: Git worktrees" },
			{ "<leader>gi", require("fzf-lua").git_diff, desc = "Fzf-lua: Git diff" },
		}
	end,
	opts = {},
}
