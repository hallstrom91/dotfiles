vim.filetype.add({
  extension = {
    conf = "conf",
    env = "dotenv",
    sh = "sh",
  },
  filename = {
    [".bash_functions"] = "sh",
    [".bash_aliases"] = "sh",
    [".bash_exports"] = "sh",
    ["bash_functions"] = "sh",
    ["bash_aliases"] = "sh",
    ["bash_exports"] = "sh",
  },
  pattern = {
    [".*%.env.*"] = "dotenv", -- match all .env* -files
    [".*%.bash*"] = "sh", -- match all .bash* -files
    ["^bash*"] = "sh", -- match all bash* -files
    -- [".*/%.bash/bash_*"] = "sh",
  },
})
