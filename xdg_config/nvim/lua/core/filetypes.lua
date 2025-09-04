vim.filetype.add({
  extension = {
    conf = "conf",
    env = "dotenv",
    mdx = "mdx",
    sh = "sh",
  },
  filename = {
    -- ["filename"] = "name"
  },
  pattern = {
    [".*%.env.*"] = "dotenv", -- match all .env* -files
    [".*%.bash.*"] = "bash", -- match all .bash* -files
    ["^bash.*"] = "bash", -- match all bash* -files
  },
})
