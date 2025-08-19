local builtin = require("telescope.builtin")
local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
--require("telescope").load_extension("csharpls_definition")

telescope.setup({
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    path_display = { "truncate" },
    file_ignore_patterns = { "node_modules", ".git/" }, -- Ignore unwanted folders

    mappings = {
      i = {
        ["<CR>"] = function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          local path = selection.path or selection.filename
          if path then
            vim.cmd("tabnew " .. path)
          else
            vim.notify("No valid path found", vim.log.levels.WARN)
          end
        end,
      },
      n = {
        ["<CR>"] = function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          local path = selection.path or selection.filename
          if path then
            vim.cmd("tabnew " .. path)
          else
            vim.notify("No valid path found", vim.log.levels.WARN)
          end
        end,
      },
    },
  },

  pickers = {
    find_files = {
      theme = "dropdown",
    },
    live_grep = {
      theme = "dropdown",
    },
    oldfiles = {
      only_cwd = true,
    },
    help_tags = {
      theme = "dropdown",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("noice")

----> Keybinds for telescope
local keymaps = {
  { "<leader>fc", builtin.commands, "Telescope Commands" },
  { "<leader>fk", builtin.keymaps, "Telescope Keymaps" },
  { "<leader>hh", builtin.help_tags, "Telescope Help Tags" },
  { "<leader>ff", builtin.find_files, "Telescope Find Files" },
  { "<leader>fg", builtin.live_grep, "Telescope Live Grep" },
  { "<leader>fw", builtin.grep_string, "Telescope Grep Current Word" },
  { "<leader>fq", builtin.quickfix, "Telescope Quickfix" },
  { "<leader>fb", builtin.buffers, "Telescope Buffers" },
  { "<leader>fr", builtin.oldfiles, "Telescope Recently Opened Files" },
  { "<leader>fd", builtin.diagnostics, "Telescope Diagnostics" },
  { "<leader>gb", builtin.git_branches, "Telescope Git Branches" },
  { "<leader>gc", builtin.git_commits, "Telescope Git Commits" },
  { "<leader>gs", builtin.git_status, "Telescope Git Status" },
  { "<leader>gB", builtin.git_bcommits, "Telescope Git Buffer Status" },
  { "<leader>gS", builtin.git_stash, "Telescope Git StashBox" },
  { "<leader>gf", builtin.git_files, "Telescope Git Tracked Files" },
  { "<leader>fw", builtin.grep_string, "Grep Word Under Cursor" },
  -- { "<leader>fb", builtin.current_buffer_fuzzy_find, "Fzf in Current Buffer" },
  {
    "<leader>fb",
    function()
      builtin.current_buffer_fuzzy_find({
        default_text = vim.fn.expand("<cword>"),
      })
    end,
    "Fzf Current Word in Buffer",
  },
}

for _, map in ipairs(keymaps) do
  vim.keymap.set("n", map[1], map[2], { desc = map[3], noremap = true, silent = true })
end

----> Create Project Related Notes
vim.api.nvim_create_user_command("CreateNotes", function()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local project_dir = vim.fn.expand("/media/veracrypt1/ws/.notes/" .. project_name)
  local input = vim.fn.input("Name of Note: (skip = projectname): ")

  --> If input is empty or "skip" create note with default name => projectname.md
  if input == "" or input == "skip" then
    input = project_name
  end

  --> creates .md files as default
  if not input:match("%.%w+$") then
    input = input .. ".md"
  end

  local project_note = project_dir .. "/" .. input

  --> Create project folder for notes
  if vim.fn.isdirectory(project_dir) == 0 then
    vim.fn.mkdir(project_dir, "p")
  end

  if vim.fn.filereadable(project_note) == 0 then
    local file = io.open(project_note, "w")
    if file then
      file:write("# " .. input .. "\n\n")
      file:close()
    end
  end

  --> Open notes in new buffertab
  vim.cmd("tabnew " .. vim.fn.fnameescape(project_note))
end, {})

----> Find Project Related Notes
vim.api.nvim_create_user_command("FindNotes", function()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  -- local project_dir = vim.fn.expand('~/.notes/' .. project_name)
  local project_dir = vim.fn.expand("/media/veracrypt1/ws/.notes/" .. project_name)
  local search_dir = vim.fn.isdirectory(project_dir) == 1 and project_dir
    or vim.fn.expand("/media/veracrypt1/ws/.notes/")

  require("telescope.builtin").find_files({
    prompt_title = "Search Notes",
    cwd = search_dir,
    hidden = true,
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          vim.cmd("tabnew " .. vim.fn.fnameescape(selection.path))
        end
      end)
      return true
    end,
  })
end, {})
