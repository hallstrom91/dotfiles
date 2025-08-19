local autocmd = vim.api.nvim_create_autocmd

local augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

----| Format on save |----
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("Formatter"),
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

----| Resession reload |----
vim.api.nvim_create_autocmd("User", {
  group = augroup("session"),
  pattern = "ResessionLoadPost",
  callback = function()
    --> lsp reload
    vim.cmd("silent! doautocmd BufRead")

    --> indent/hlight reload
    local ok, hlchunk = pcall(require, "hlchunk")
    if ok and hlchunk.reload then
      hlchunk.reload()
    end
  end,
})

----| open help window in vertical mode |----
autocmd("FileType", {
  group = augroup("HelpWindow"),
  pattern = "help",
  command = "wincmd L",
})

----| Auto update Treesitter Parsers |----
autocmd("VimEnter", {
  group = augroup("TreesitterUpdate"),
  pattern = "VeryLazy",
  callback = function()
    vim.cmd("TSUpdate")
  end,
})

----| Recognize .bash_* files |----
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("BashFiles"),
  pattern = { ".bash_*", "bash_*" },
  command = "set filetype=bash",
})

----| set .env files to "conf" |---
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("EnvFiles"),
  pattern = ".env*",
  command = "set filetype=conf",
})

----| Highlight on yank |----
autocmd("TextYankPost", {
  group = augroup("HighlightYank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

----| Close with 'q' |----
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
    vim.notify("Macro recording started @" .. reg, vim.log.levels.INFO, { title = "Macro Start" })
  end,
})

autocmd("RecordingLeave", {
  callback = function()
    vim.notify("Macro recording terminated", vim.log.levels.INFO, { title = "Macro Ended" })
  end,
})
