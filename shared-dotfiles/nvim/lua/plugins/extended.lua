return {

  ----| Rainbow delimiters (brackets etc colors) |----
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          javascript = "rainbow-parens",
          typescript = "rainbow-parens",
          tsx = "rainbow-parens",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  ----| Telescope, FZF   |----
  {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.8",
    event = "VimEnter",
    keys = { "<leader>f", "<leader>p" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("config.telescope")
    end,
  },

  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  ----| Autopairs (){}[] etc |----
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      require("config.autopairs").setup()
    end,
  },

  ----| Autotag   |----
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
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

  ----| csharpls extended |----
  -- {
  --   "Decodetalkers/csharpls-extended-lsp.nvim",
  --   ft = { "cs" },
  --   dependencies = { "neovim/nvim-lspconfig" },
  -- },

  ----| hlchunck - indent |----
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.indents")
    end,
  },

  ----|  Conform (Formatting) |----
  {
    "stevearc/conform.nvim",
    opts = {},
    event = { "BufWritePre", "BufWritePost" },
    config = function()
      require("config.conform")
    end,
  },

  ----| Spectre (Find & Replace Text) |----
  {
    "nvim-pack/nvim-spectre",
    config = function()
      require("config.spectre")
    end,
  },

  ----| Surround (Brackets etc)  |----
  {
    "tpope/vim-surround",
    event = "BufReadPre",
  },

  ----| Which Key (did i bind to what?)  |----
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({})
    end,
  },

  ----| Noice  |----
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          signature = {
            enabled = true,
          },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = false,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
        -- remove routes ? err fixed in plugins?
        routes = {
          {
            filter = {
              event = "notify",
              find = "vim%.deprecated",
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },

  ----| Resession |----
  {
    "stevearc/resession.nvim",
    opts = {},
    config = function()
      require("config.resession")
    end,
  },
}
