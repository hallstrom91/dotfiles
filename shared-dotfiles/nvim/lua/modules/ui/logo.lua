local M = {}
local neovim_logo = require("modules.ui.colors").neovim_logo
local colors = require("modules.ui.colors").vsc_dark_modern

vim.api.nvim_set_hl(0, "NeovimDarkLeaf", { fg = neovim_logo.dark_leaf, bg = nil, bold = false })
vim.api.nvim_set_hl(0, "NeovimLeaf", { fg = neovim_logo.leaf, bg = nil, bold = false })
vim.api.nvim_set_hl(0, "NeovimDustyTeal", { fg = neovim_logo.dusty_teal, bg = nil, bold = false })
vim.api.nvim_set_hl(0, "NeovimLightSky", { fg = neovim_logo.light_sky, bg = nil, bold = true })
vim.api.nvim_set_hl(0, "NeovimSky", { fg = neovim_logo.sky, bg = nil, bold = true })
vim.api.nvim_set_hl(0, "NeovimDarkSky", { fg = neovim_logo.dark_sky, bg = nil, bold = true })
vim.api.nvim_set_hl(0, "NeovimIcon", { fg = neovim_logo.icon, bg = nil, bold = false })
vim.api.nvim_set_hl(0, "NeovimText", { fg = neovim_logo.text, bg = nil, bold = true })
vim.api.nvim_set_hl(0, "NeovimNumber", { fg = neovim_logo.number, bg = nil, bold = true })

M.nvim_logo_and_version = {
  function()
    return " neovim v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
  end,
  cond = function()
    return vim.v.hlsearch == 0 and not vim.fn.mode():match("[vV]")
  end,
  color = {
    fg = colors.fg,
    bg = colors.visual_color,
    --bg = colors.bg_local,
    gui = "bold",
  },
}

M.nvim_logo_and_version_color = {
  function()
    local n = "%#NeovimDarkLeaf#n"
    local e = "%#NeovimLeaf#e"
    local o = "%#NeovimDustyTeal#o"
    local v = "%#NeovimLightSky#v"
    local i = "%#NeovimSky#i"
    local m = "%#NeovimDarkSky#m"

    local version_major = "%#NeovimNumber#" .. vim.version().major
    local version_minor = "%#NeovimNumber#" .. vim.version().minor
    local version_patch = "%#NeovimNumber#" .. vim.version().patch

    local logo = "%#NeoVimIcon# "
    local version = "%#NeovimText#" .. " v" .. version_major .. "." .. version_minor .. "." .. version_patch
    return logo .. n .. e .. o .. v .. i .. m .. version
  end,
  cond = function()
    return vim.v.hlsearch == 0 and not vim.fn.mode():match("[vV]")
  end,
}

M.neovim_ascii_art = {
  "                                                       ",
  "                                                       ",
  "                                                       ",
  " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
  " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
  " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
  " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
  " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
  " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
  "                                                       ",
  "                                                       ",
  "                                                       ",
  "                                                       ",
}

M.nvim_ascii_art = {
  "                                  ",
  "                                  ",
  "                                  ",
  " ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
  " ████╗  ██║██║   ██║██║████╗ ████║",
  " ██╔██╗ ██║██║   ██║██║██╔████╔██║",
  " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
  " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
  " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
  "                                  ",
  "                                  ",
  "                                  ",
  "                                  ",
}

return M
