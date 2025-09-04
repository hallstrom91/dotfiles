return {

  ----| Always needed (almost) |----
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  ----| Mason |----
  {
    "mason-org/mason.nvim",
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
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      -- Extra completion sources
      "onsails/lspkind.nvim",
      "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
      require("config.cmp")
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
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
          "lua",
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
        :wait(300000) -- 5min
      -- vim.treesitter.language.register("markdown", "mdx")
    end,
  },

  ----| Treesitter Context Window |----
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        multiwindow = true,
        additional_vim_regex_highlighting = false,
        max_lines = 10,
        min_window_height = 50,
      })

      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true })
    end,

    vim.api.nvim_set_hl(0, "TreesitterContext", {
      bg = "#205781",
    }),
  },
}
