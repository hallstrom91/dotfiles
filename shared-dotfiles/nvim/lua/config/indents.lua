----| hlchunck / indent |----

local function safe_hl_color(hl)
  local color = vim.fn.synIDattr(vim.fn.hlID(hl), "fg", "gui")
  return color ~= "" and color or "#FFFFFF"
end

require("hlchunk").setup({
  chunk = {
    enable = true,
    chars = {
      horizontal_line = "─",
      vertical_line = "│",
      left_top = "╭",
      left_bottom = "╰",
      right_arrow = ">",
    },
    -- style = "#806d9c",
    style = "#D4C9BE",
  },

  indent = {
    enable = true,
    chars = { "│" },
    style = {
      safe_hl_color("IndentLevel1"),
      safe_hl_color("IndentLevel2"),
      safe_hl_color("IndentLevel3"),
      safe_hl_color("IndentLevel4"),
      safe_hl_color("IndentLevel5"),
      safe_hl_color("IndentLevel6"),
      safe_hl_color("IndentLevel7"),
    },
  },

  blank = {
    enable = true,
    chars = {
      " ",
    },
  },
})

--|  Indent blankline |-----
-- require("ibl").setup({
--   indent = {
--     char = "",
--     highlight = {
--       "IndentLevel1",
--       "IndentLevel2",
--       "IndentLevel3",
--       "IndentLevel4",
--       "IndentLevel5",
--       "IndentLevel6",
--       "IndentLevel7",
--     },
--   },
--   scope = {
--     enabled = true,
--     char = "󰞷",
--     highlight = {
--       "IndentLevel1",
--       "IndentLevel2",
--       "IndentLevel3",
--       "IndentLevel4",
--       "IndentLevel5",
--       "IndentLevel6",
--       "IndentLevel7",
--     },
--   },
--   exclude = {
--     filetypes = { "dashboard" },
--     buftypes = { "nofile" },
--   },
-- })
