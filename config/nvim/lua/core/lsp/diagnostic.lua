local M = {}
local severity = vim.diagnostic.severity
local icons = require("utils.icons")
local dx_shapes = icons.get_icon_tbl("dx.shapes", { pr = 1 })
local dx_nf_md = icons.get_icon_tbl("dx.nf_md", { pr = 1 })

------------------------------------------
--> Diagnostic
-- https://neovim.io/doc/user/diagnostic.html
--
-- :help vim.diagnostic
-- :h vim.lsp
-- :h vim.lsp.util.convert_input_to_markdown_lines
-- :h vim.lsp.util.convert_signature_help_to_markdown_lines
-- :h *vim.lsp.util.make_floating_popup_options()*
------------------------------------------
--- Highlights helper
-- Hl-mapping to all diagnostic

---@type table<integer,string>
M.dx_hl = {
	[severity.ERROR] = "DiagnosticError",
	[severity.WARN] = "DiagnosticWarn",
	[severity.INFO] = "DiagnosticInfo",
	[severity.HINT] = "DiagnosticHint",
}

-- helper severity highlight with fallback
local function _severity_hl(sev)
	return M.dx_hl[sev] or "DiagnosticInfo"
end

-----------------------------------------
--- vim.diagnostic.Opts.virtual_text

-- Virtual Text Icons
local VT_ICONS = {
	[severity.ERROR] = dx_nf_md.ERROR,
	[severity.WARN] = dx_nf_md.WARN,
	[severity.INFO] = dx_nf_md.INFO,
	[severity.HINT] = dx_nf_md.HINT,
}

---Icons + Highlights for virtual_lines.prefix
---@param diag vim.Diagnostic
---@return string text
---@return string hl
function M.dx_vline_prefix(diag)
	local ic = VT_ICONS[diag.severity] or "dx_nf_md.INFO"
	local hl = _severity_hl(diag.severity)
	return ic, hl
end

---@type vim.diagnostic.Opts.VirtualText
M.dx_vtext = {
	spacing = 2,
	current_line = false,
	hl_mode = "blend",
	-- severity = {
	-- 	min = vim.diagnostic.severity.ERROR,
	-- },
	prefix = M.dx_vline_prefix,
}
------------------------------------------------
--- vim.diagnostic.Opts.signs
--- Icons/Text for signs.text
---@type table<integer, string>
M.dx_text = {
	[severity.ERROR] = dx_shapes.circle_arrow,
	[severity.WARN] = dx_shapes.box_arrow,
	[severity.INFO] = dx_shapes.bold_arrow,
	[severity.HINT] = dx_shapes.norm_arrow,
}
---@type vim.diagnostic.Opts.Signs
M.dx_signs = {
	text = M.dx_text,
	numhl = M.dx_hl,
	linehl = M.dx_hl,
}

------------------------------------------------
--- vim.diagnostic.Opts.float
--- Icons for float.prefix
local FLOAT_ICONS = {
	[severity.ERROR] = dx_shapes.circle,
	[severity.WARN] = dx_shapes.circle,
	[severity.INFO] = dx_shapes.square,
	[severity.HINT] = dx_shapes.square,
}

---Icons + Highlights for float.prefix
---@param diag vim.Diagnostic
---@return string text
---@return string hl
function M.dx_float_prefix(diag)
	local ic = FLOAT_ICONS[diag.severity] or dx_shapes.square
	local hl = _severity_hl(diag.severity)
	return ic .. " ", hl
end

---@type vim.diagnostic.Opts.Float
M.dx_float = {
	scope = "line",
	source = "if_many",
	header = { "Diagnostic", "DiagnosticHeader" },
	border = "rounded",
	prefix = M.dx_float_prefix,
	format = function(diag)
		local msg = diag.message:gsub("\n", " ") or ""
		return msg
	end,
}

return M
