local M = {}

function M.get_current_branch()
  local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
  if branch and branch ~= '' then
    return branch
  else
    return 'No active GIT repo'
  end
end

return M
