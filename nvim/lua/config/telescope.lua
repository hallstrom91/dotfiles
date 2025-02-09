local builtin = require('telescope.builtin')
local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

telescope.setup({
  defaults = {
    prompt_prefix = ' ',
    selection_caret = ' ',
    path_display = { 'truncate' },
    file_ignore_patterns = { 'node_modules', '.git/' }, -- Ignore unwanted folders
    mappings = {
      i = {
        ['<Esc>'] = require('telescope.actions').close, -- Specifik ESC-funktionalitet
      },
    },
  },
  pickers = {
    find_files = {
      theme = 'dropdown', -- narrow layout
    },
    live_grep = {
      theme = 'dropdown', -- Ivy-layout for grep
    },
    oldfiles = {
      only_cwd = true, -- show only project catalog
    },
    help_tags = {
      theme = 'dropdown',
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- Activate fuzzy find
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
  --[[ 	mappings = {
		i = {
			["<C-a>"] = function(prompt_bufnr)
				local entry = action_state.get_selected_entry()
				local cmd = "git add " .. entry.value
				vim.cmd("!" .. cmd)
				actions.close(prompt_bufnr)
			end,
		},
		n = {
			["<C-a>"] = function(prompt_bufnr)
				local entry = action_state.get_selected_entry()
				local cmd = "git add " .. entry.value
				vim.cmd("!" .. cmd)
				actions.close(prompt_bufnr)
			end,
		},
	}, ]]
})

require('telescope').load_extension('fzf')
require('telescope').load_extension('noice')

-- Keybinds for telescope
local keymaps = {
  { '<leader>fc', builtin.commands, 'Telescope Commands' },
  { '<leader>fk', builtin.keymaps, 'Telescope Keymaps' },
  { '<leader>hh', builtin.help_tags, 'Telescope Help Tags' },
  { '<leader>ff', builtin.find_files, 'Telescope Find Files' },
  { '<leader>fg', builtin.live_grep, 'Telescope Live Grep' },
  { '<leader>fw', builtin.grep_string, 'Telescope Grep Current Word' },
  { '<leader>fq', builtin.quickfix, 'Telescope Quickfix' },
  { '<leader>fb', builtin.buffers, 'Telescope Buffers' },
  { '<leader>fr', builtin.oldfiles, 'Telescope Recently Opened Files' },
  { '<leader>fd', builtin.diagnostics, 'Telescope Diagnostics' },
  { '<leader>gb', builtin.git_branches, 'Telescope Git Branches' },
  { '<leader>gc', builtin.git_commits, 'Telescope Git Commits' },
  { '<leader>gs', builtin.git_status, 'Telescope Git Status' },
  { '<leader>gB', builtin.git_bcommits, 'Telescope Git Buffer Status' },
  { '<leader>gS', builtin.git_stash, 'Telescope Git StashBox' },
  { '<leader>gf', builtin.git_files, 'Telescope Git Tracked Files' },
}

for _, map in ipairs(keymaps) do
  vim.keymap.set('n', map[1], map[2], { desc = map[3], noremap = true, silent = true })
end
