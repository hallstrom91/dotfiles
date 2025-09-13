local autocmd = vim.api.nvim_create_autocmd

local augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

----| Format on save |----
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("Formatter"),
  pattern = "*",
  callback = function(args)
    require("conform").format({
      bufnr = args.buf,
      lsp_format = "fallback",
      timeout_ms = 500,
      stop_after_first = true,
      async = false,
    })
  end,
})


----| open help window in vertical mode |----
autocmd("FileType", {
  group = augroup("HelpWindow"),
  pattern = "help",
  command = "wincmd L",
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

-- DetachLSP
autocmd("LspDetach", {
  group = augroup("LspAutoStop"),
  callback = function(args)
    local id = args.data and args.data.client_id
    if not id then
      return
    end
    require("core.lsp").kill_or_spare_client(id, 1500)
  end,
})

autocmd({ "BufWipeout", "BufDelete" }, {
  group = augroup("LspAutoStopBuf"),
  callback = function()
    local lsp = require("core.lsp")
    for _, client in pairs(vim.lsp.get_clients()) do
      if lsp.is_orphan(client) then
        lsp.kill_or_spare_client(client.id, 1500)
      end
    end
  end,
})
