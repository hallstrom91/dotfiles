require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true, frequency = 86400 },
  opts = {
    rocks = {
      enabled = false,
      hererocks = false,
    },
  },
})
