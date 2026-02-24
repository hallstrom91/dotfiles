return {
	----| Mason |----
	-- replace with npm ?
	"mason-org/mason.nvim",
	-- cmd = { "Mason", "MasonInstall", "MasonUpdate" },
	config = function()
		require("mason").setup({
			registries = {
				"github:Crashdummyy/mason-registry",
				"github:mason-org/mason-registry",
			},
		})
	end,
}
