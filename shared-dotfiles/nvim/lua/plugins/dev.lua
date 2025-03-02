return {
  {
    dir = "~/.local/share/nvim/lazy/webdever-theme",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("webdever-theme").setup({
        mode = "dark",
        cmp = true,
        telescope = true,
        whichkey = true,
        rainbow = true,
        ibl = true,
        neotree = true,
        bufferline = false,
        treesitter = true,
        debug = false,
      })
    end,
  },
}
