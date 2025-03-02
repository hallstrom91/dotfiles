return {

  ----| Always needed (almost) |----
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  ----| LSP, Mason etc.. |----
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo", "LspInstall", "LspStart", "Mason" },
    dependencies = {
      { "williamboman/mason.nvim", build = ":MasonUpdate" },
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hinell/lsp-timeout.nvim",
    },
    config = function()
      require("core.lsp.init")
      require("core.lsp.timeout").setup()
    end,
  },

  ----| CMP, Intellisense/Completion |----
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippets
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
      "saadparwaiz1/cmp_luasnip",

      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      -- Extra completion sources
      "onsails/lspkind.nvim",
      "SergioRibera/cmp-dotenv",
      "petertriho/cmp-git",
      "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
      require("config.cmp")
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  ----| Treesitter |----
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "vim",
          "lua",
          "bash",
          "markdown",
          "markdown_inline",
          "html",
          "css",
          "scss",
          "javascript",
          "tsx",
          "typescript",
          "json",
          "jsonc",
          "c_sharp",
          "styled",
          "gitcommit",
          "git_rebase",
          "git_config",
          "gitattributes",
          "gitignore",
        },
        sync_install = true,
        auto_install = false,
        fold = { enable = false },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = { "scheme" },
        },
      })
    end,
  },

  ----| Treesitter Context Window |----

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        multiwindow = true,
        additional_vim_regex_highlighting = false,
      })

      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true })
    end,
  },
}
