local detect = require("utils.detect")
return {

  ----| Autotag   |----
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    enabled = detect.is_webdev,
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup({
        enable = true,
        filetypes = { "html", "xml", "javascript", "typescript", "typescriptreact", "javascriptreact" },
        opts = {
          enable_close = true,
          enable_rename = false,
          enable_close_on_slash = true,
        },
      })
    end,
  },

  ----| tailwind colorizer (CMP completion) |----
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    lazy = true,
    enabled = detect.has_tailwind,
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  ----| CSS Variables (CMP) |----
  {
    "roginfarrer/cmp-css-variables",
    lazy = true,
    --enabled = detect.profile(name),
  },
  ----| TS comment |----
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = detect.is_webdev,
  },

  ----| TS Error Translator |----
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "typescriptreact" },
    enabled = detect.is_webdev,
    config = function()
      require("ts-error-translator").setup()
    end,
  },
}
