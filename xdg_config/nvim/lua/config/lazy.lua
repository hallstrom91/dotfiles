require("lazy").setup({
  spec = {
    { import = "plugins.base" },
    { import = "plugins.ext" },
    { import = "plugins.webdev" },
  },
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false, frequency = 86400 },
  ui = { border = "rounded" },
})
