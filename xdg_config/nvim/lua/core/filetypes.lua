vim.filetype.add({
  extension = {
    conf = "conf",
    env = "dotenv",
    sh = "sh",
  },
  filename = {
    -- ["filename"] = "name"
  },
  pattern = {
    [".*%.env.*"] = "dotenv", -- match all .env* -files
    [".*%.bash.*"] = "sh", -- match all .bash* -files
    ["^bash.*"] = "sh", -- match all bash* -files
  },
})
