return {
  {
    "Mofiqul/vscode.nvim",
    opts = {
      style = "dark",
      transparent = false,
      italic_comments = true,
      italic_inlayhints = true,
      disable_nvimtree_bg = true,
    },
    config = function(_, opts)
      require("vscode").setup(opts)
    end,
  },
}
