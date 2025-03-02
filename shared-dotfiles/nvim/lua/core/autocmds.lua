local autocmd = vim.api.nvim_create_autocmd

local augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

--> Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("Formatter"),
  pattern = "*",
  callback = function(args)
    local utils = require("modules.utils")

    if utils.is_excluded_project(args.buf) then
      return
    end
    require("conform").format({ bufnr = args.buf })
  end,
})

--> open help window in vertical mode
autocmd("FileType", {
  group = augroup("HelpWindow"),
  pattern = "help",
  command = "wincmd L",
})

--> Auto update Treesitter Parsers
autocmd("VimEnter", {
  group = augroup("TreesitterUpdate"),
  pattern = "VeryLazy",
  callback = function()
    vim.cmd("TSUpdate")
  end,
})

--> Recognize .bash_* files
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("BashFiles"),
  pattern = ".bash_*",
  command = "set filetype=bash",
})

--> set .env files to "conf"
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("EnvFiles"),
  pattern = ".env*",
  command = "set filetype=conf",
})

autocmd("CursorMoved", {
  group = augroup("CursorHighlight"),
  callback = function()
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
    if buftype == "" then
      vim.cmd("highlight CursorLine guibg=#88C0D0 guifg=#31363F")
      vim.cmd("setlocal cursorline")
      vim.defer_fn(function()
        vim.cmd("setlocal nocursorline")
      end, 300)
    end
  end,
})

--> Highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

--> Close with 'q'
autocmd("FileType", {
  group = augroup("ClosePlugin"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "gitsigns-blame",
    "help",
    "lspinfo",
    "notify",
    "spectre_panel",
    "startuptime",
    "TelescopePrompt",
    "neo-tree",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("quit!")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.cs",
  callback = function()
    vim.opt.fileformat = "dos"
  end,
})

----| No comment on new row |----
autocmd("FileType", {
  group = augroup("NewCommentRow"),
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

--> display macro recording status
autocmd("RecordingEnter", {
  callback = function()
    local reg = vim.fn.reg_recording()
    vim.notify("Macro recording started @" .. reg, vim.log.levels.INFO, { title = "Makro Start" })
  end,
})

autocmd("RecordingLeave", {
  callback = function()
    vim.notify("Macro recording terminated", vim.log.levels.INFO, { title = "Makro Slut" })
  end,
})
