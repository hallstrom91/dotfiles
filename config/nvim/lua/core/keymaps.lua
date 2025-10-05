local M = {}

function M.setup_leaders()
	vim.g.mapleader = " "
	vim.g.maplocalleader = "\\"
end

local function merge(a, b)
	return vim.tbl_extend("force", a or {}, b or {})
end

-- list {mode, keys, cmd, desc, opts, remap}
function M.set_keymap(list, base_opts)
	local map = vim.keymap.set
	local base = merge({ noremap = true, silent = true }, base_opts or {})

	for _, m in ipairs(list) do
		local o = merge(base, m.opts or {})
		o.desc = m.desc
		if m.remap ~= nil then
			o.remap = m.remap
		end
		map(m.mode or "n", m.keys, m.cmd, o)
	end
end

local general = {
	{ mode = "n", keys = ";", cmd = ":", desc = "Cmdline" },
	{ mode = "i", keys = "jk", cmd = "<ESC>", desc = "Exit insert mode" },
	{ mode = "n", keys = "<F13>", cmd = ":noh<CR>", desc = "Clear Search Markings" },
	{ mode = { "i", "x", "n", "s" }, keys = "<C-s>", cmd = "<cmd>w<cr><esc>", desc = "Save File" },

	-- Move rows
	{ mode = "n", keys = "<A-Up>", cmd = ":m .-2<CR>==", desc = "Move row up" },
	{ mode = "n", keys = "<A-Down>", cmd = ":m .+1<CR>==", desc = "Move row down" },

	-- Move selection
	{ mode = "v", keys = "<A-Up>", cmd = ":m '<-2<CR>gv=gv", desc = "Move selection up" },
	{ mode = "v", keys = "<A-Down>", cmd = ":m '>+1<CR>gv=gv", desc = "Move selection down" },

	-- Resize
	{ mode = "n", keys = "<A-w>", cmd = "<cmd>resize +2<cr>", desc = "Increase Window Height" },
	{ mode = "n", keys = "<A-s>", cmd = "<cmd>resize -2<cr>", desc = "Decrease Window Height" },
	{ mode = "n", keys = "<A-a>", cmd = "<cmd>vertical resize -2<cr>", desc = "Decrease Window Width" },
	{ mode = "n", keys = "<A-d>", cmd = "<cmd>vertical resize +2<cr>", desc = "Increase Window Width" },

	-- Splits
	{ mode = "n", keys = "<leader><Down>", cmd = "<C-W>s", desc = "Horizontal Split Below", remap = true },
	{ mode = "n", keys = "<leader><Up>", cmd = ":split<CR>", desc = "Horizontal Split Above", remap = true },
	{ mode = "n", keys = "<leader><Right>", cmd = "<C-W>v", desc = "Vertical Split Right", remap = true },
	{ mode = "n", keys = "<leader><Left>", cmd = ":vsplit<CR>", desc = "Vertical Split Left", remap = true },
	{ mode = "n", keys = "<leader>q", cmd = "<C-W>c", desc = "Close Window", remap = true },
}

-- setup default global keymaps @ init
function M.setup()
	M.setup_leaders()
	M.set_keymap(general)
end

return M
