local utils_keymap = require("utils.keymap")
local last_notify = 0

--- Notify func for arrowkeys
local function info_arrow()
	local now = vim.loop.now()
	if now - last_notify < 8000 then
		return
	end -- 8000ms anti-spam timer

	last_notify = now
	local ic = {
		h = " ", --h
		j = " ", --j
		k = " ", --k
		l = " ", --l
	}

	vim.notify(
		("Use %s<h> %s<j> %s<k> %s<l> instead of arrowkeys."):format(ic.h, ic.j, ic.k, ic.l),
		vim.log.levels.INFO,
		{ title = "Movement Info" }
	)
end

local base = {
	---> Normal Mode: "n"
	{ mode = "n", lhs = "<leader>q", rhs = "<cmd>bdelete<CR>", desc = "Delete buffer" },
	{ mode = "n", lhs = "<C-s>", rhs = "<cmd>w<cr><esc>", desc = "Save file" },
	---text movement
	{ mode = "n", lhs = "<A-k>", rhs = "<cmd>execute 'move .+' . v:count1<cr>==", desc = "Move row down" },
	{ mode = "n", lhs = "<A-j>", rhs = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", decs = "Move row up" },
	---buffers
	{ mode = "n", lhs = "<leader>bn", rhs = "<cmd>bnext<cr>", desc = "Next buffer" },
	{ mode = "n", lhs = "<leader>bp", rhs = "<cmd>bprevious<cr>", desc = "Prev buffer" },
	{ mode = "n", lhs = "<leader>bd", rhs = "<cmd>bp|bd #<CR>", desc = "Delete buf: Keep win" },
	{ mode = "n", lhs = "<leader>bo", rhs = "<cmd>enew<cr>", desc = "Open new/empty buf" },
	---window-size
	{ mode = "n", lhs = "<A-Up>", rhs = "<cmd>resize +2<cr>", desc = "Increase window height" },
	{ mode = "n", lhs = "<A-Down>", rhs = "<cmd>resize -2<cr>", desc = "Decrease window height" },
	{ mode = "n", lhs = "<A-Left>", rhs = "<cmd>vertical resize -2<cr>", desc = "Decrease window width" },
	{ mode = "n", lhs = "<A-Right>", rhs = "<cmd>vertical resize +2<cr>", desc = "Increase window width" },

	---tabs
	{ mode = "n", lhs = "<leader><tab>n", rhs = "<cmd>tabnext<cr>", desc = "Next tab" },
	{ mode = "n", lhs = "<leader><tab>p", rhs = "<cmd>tabprev<cr>", desc = "Prev tab" },
	{ mode = "n", lhs = "<leader><tab>o", rhs = "<cmd>tabnew<cr>", desc = "Open new tab" },
	-- { mode "n", lhs = "", rhs = "", desc = "" },
	-- { mode "n", lhs = "", rhs = "", desc = "" },

	---search
	{ mode = "n", lhs = "n", rhs = "'Nn'[v:searchforward].'zv'", expr = true, desc = "Next search result" },
	{ mode = "n", lhs = "N", rhs = "'nN'[v:searchforward].'zv'", expr = true, desc = "Prev search result" },
	---> Visual Mode: "x"
	{ mode = "x", lhs = "n", rhs = "'Nn'[v:searchforward]", expr = true, desc = "Next search result" },
	{ mode = "x", lhs = "N", rhs = "'nN'[v:searchforward]", expr = true, desc = "Prev search result" },
	--- Operator-pending mode: "o"
	{ mode = "o", lhs = "n", rhs = "'Nn'[v:searchforward]", expr = true, desc = "Next search result" },
	{ mode = "o", lhs = "N", rhs = "'nN'[v:searchforward]", expr = true, desc = "Prev search result" },

	---> Insert Mode: "i"
	{ mode = "i", lhs = "jk", rhs = "<ESC>", desc = "Exit insert mode" },

	---> Multi Mode:
	---Dont use arrowkeys for movement
	{ mode = { "i", "x", "n", "s" }, lhs = "<Up>", rhs = info_arrow, desc = "Disabled arrowkeys movement" },
	{ mode = { "i", "x", "n", "s" }, lhs = "<Down>", rhs = info_arrow, desc = "Disabled arrowkeys movement" },
	{ mode = { "i", "x", "n", "s" }, lhs = "<Left>", rhs = info_arrow, desc = "Disabled arrowkeys movement" },
	{ mode = { "i", "x", "n", "s" }, lhs = "<Right>", rhs = info_arrow, desc = "Disabled arrowkeys movement" },
}

utils_keymap.map(base)
