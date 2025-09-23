return {
  ----| Always needed (almost) |----
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons" },
  { "b0o/schemastore.nvim", ft = "json" },

  ----| Mason |----
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    config = function()
      require("mason").setup({
        registries = {
          "github:Crashdummyy/mason-registry",
          "github:mason-org/mason-registry",
        },
      })
    end,
  },

  ----| CMP, Intellisense/Completion |----
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippets
      "saadparwaiz1/cmp_luasnip",

      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      -- css
      -- "roginfarrer/cmp-css-variables",

      -- Extra completion sources
      "onsails/lspkind.nvim",
      --      "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
      require("config.cmp")
    end,
  },

  ----| LuaSnip |----
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
  },

  ----| Treesitter |----
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- latest
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter")
        .install({
          -- "lua",
          "bash",
          "html",
          "css",
          "javascript",
          "typescript",
          "json",
          "jsonc",
          "csharp",
          "gitcommit",
          "git_rebase",
          "git_config",
          "gitignore",
          "regex",
          "tsx",
        })
        :wait(300000) -- 5min -- NO-OP if install
    end,
  },

  ----| Treesitter Context Window |----
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        multiwindow = true,
        max_lines = 10,
        min_window_height = 50,
        line_number = true,
      })

      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true })
    end,

    vim.api.nvim_set_hl(0, "TreesitterContext", {
      bg = "#205781",
    }),
  },

  ----| Telescope, FZF   |----
  {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.8",
    event = "VimEnter",
    keys = { "<leader>f", "<leader>p" },
    dependencies = {
      "nvim-lua/plenary.nvim",
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

  ----|  Conform (Formatting) |----
  {
    "stevearc/conform.nvim",
    opts = {},
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.formatter")
    end,
  },

  ----| Whichkey |----
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({})
    end,
  },
}
