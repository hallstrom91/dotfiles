--| Config for personal theme |-----
require("ibl").setup({
  indent = {
    char = "",
    highlight = {
      "IndentLevel1",
      "IndentLevel2",
      "IndentLevel3",
      "IndentLevel4",
      "IndentLevel5",
      "IndentLevel6",
      "IndentLevel7",
    },
  },
  scope = {
    enabled = true,
    char = "󰞷",
    highlight = {
      "IndentLevel1",
      "IndentLevel2",
      "IndentLevel3",
      "IndentLevel4",
      "IndentLevel5",
      "IndentLevel6",
      "IndentLevel7",
    },
  },
  exclude = {
    filetypes = { "dashboard" },
    buftypes = { "nofile" },
  },
})
