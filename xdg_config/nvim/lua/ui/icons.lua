local icons = {}

icons.mode_icons = {
  NORMAL = " ",
  INSERT = "󱓥 ",
  VISUAL = "󱘣 ",
  REPLACE = "󰛈 ",
  COMMAND = " ",
}

icons.git_icons = {
  added = "✚ ",
  modified = "✎ ",
  removed = "✖ ",
}

icons.git_signs = {
  add = { text = "" },
  change = { text = "" },
  delete = { text = "" },
  topdelete = { text = "" },
  changedelete = { text = "" },
  untracked = { text = "󱀶" },
}

icons.git_signs_staged = {
  add = { text = "" },
  change = { text = "" },
  delete = { text = "" },
  topdelete = { text = "" },
  changedelete = { text = "" },
  untracked = { text = "󱀶" },
}

icons.cmpkind_icons = {
  Text = "󰦨", -- nf-md-text
  Method = "", -- nf-cod-symbol_method
  Function = "󰊕", --nf-md-function |-- or "󰡱" -- nf-md-function-variant
  Constructor = "󰒓", --nf-md-cog
  Field = "", --nf-cod-symbol_field
  Variable = "󰫧", --nf-md-variable
  Class = "", --mf-cod-symbol_class
  Interface = "", --nf-cod-symbol_interface
  --
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

return icons
