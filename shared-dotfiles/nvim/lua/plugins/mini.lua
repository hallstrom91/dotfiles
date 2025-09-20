return {
  -- Only stable branch
  -- {
  --   "nvim-mini/mini.icons",
  --   version = "*",
  --   config = function()
  --     require("mini.icons").setup()
  --   end,
  -- },

  {
    "nvim-mini/mini.comment",
    version = "*",
    event = "InsertEnter",
    config = function()
      require("mini.comment").setup()
    end,
  },

  -- {
  --   "nvim-mini/mini.pairs",
  --   version = "*",
  --   event = "InsertEnter",
  --   config = function()
  --     require("mini.pairs").setup()
  --   end,
  -- },

  {
    "nvim-mini/mini.surround",
    version = "*",
    event = "InsertEnter",
    config = function()
      require("mini.surround").setup()
    end,
  },

  {
    "nvim-mini/mini.cursorword",
    version = "*",
    event = "InsertEnter",
    config = function()
      require("mini.cursorword").setup()
    end,
  },

  -- {
  --   "nvim-mini/mini-git",
  --   version = "*",
  --   main = "mini.git",
  --   config = function()
  --     require("mini.git").setup()
  --   end,
  -- },

  -- {
  --   "nvim-mini/mini.statusline",
  --   version = "*",
  --   config = function()
  --     require("mini.statusline").setup()
  --   end,
  -- },

  -- {
  --   "nvim-mini/mini.notify",
  --   version = "*",
  --   opts = {},
  --   config = function()
  --     require("mini.notify").setup()
  --   end,
  -- },

  -- { "nvim-mini/mini.tabline", version = "*" },

  -- {
  --   "nvim-mini/mini.notify",
  --   version = "*",
  --   opts = {
  --     lsp_progress = { enable = true, level = "INFO", duration_last = 1000 },
  --   },
  --   config = function(_, opts)
  --     local notify = require("mini.notify")
  --     notify.setup(opts)
  --
  --     vim.notify = notify.make_notify({
  --       ERROR = { duration = 8000 },
  --       WARN = { duration = 6000 },
  --       INFO = { duration = 4000 },
  --       DEBUG = { duration = 0 },
  --       TRACE = { duration = 0 },
  --     })
  --     -- require("mini.notify").setup({})
  --   end,
  -- },

  -- {
  --   "nvim-mini/mini.animate",
  --   version = "*",
  --   config = function()
  --     require("mini.animate").setup()
  --   end,
  -- },

  --  { 'nvim-mini/mini.diff', version = '*',
  --  config = function()
  --      require("mini.diff").setup()
  --    end,
  -- },
}
