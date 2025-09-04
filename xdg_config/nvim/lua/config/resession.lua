local resession = require("resession")
resession.setup({
  autosave = {
    enabled = true,
    interval = 300,
    notify = false,
  },
})

local function get_session_name()
  local name = vim.fn.getcwd()
  local branch = vim.trim(vim.fn.system("git branch --show-current"))
  if vim.v.shell_error == 0 then
    return name .. branch
  else
    return name
  end
end

-- Resession does NOTHING automagically, so we have to set up some keymaps
vim.keymap.set("n", "<leader>ss", resession.save, { desc = "save session" })
vim.keymap.set("n", "<leader>sl", resession.load, { desc = "load session" })
vim.keymap.set("n", "<leader>sd", resession.delete, { desc = "delete session" })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only load the session if nvim was started with no args
    if vim.fn.argc(-1) == 0 then
      resession.load(get_session_name(), { dir = "dirsession", silence_errors = true })
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local session_name = get_session_name()

    -- dont save git-related stuff as sessions
    local ignore_patterns = {
      "COMMIT_EDITMSG",
      "MERGE_MSG",
      "gitrebase",
      "/.git/",
    }

    local buffers = vim.fn.getbufinfo({ buflisted = 1 })
    for _, buf in ipairs(buffers) do
      for _, pattern in ipairs(ignore_patterns) do
        if buf.name and buf.name:match(pattern) then
          vim.api.nvim_buf_delete(buf.bufnr, { force = true })
        end
      end
    end

    resession.save(session_name, {
      dir = "dirsession",
      notify = false,
    })
  end,
})
