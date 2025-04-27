local M = {}

function M.left_mouse_open_tab(clicked_tab_id)
  local tabs = vim.api.nvim_list_tabpages()

  for index, tab in ipairs(tabs) do
    if tab == clicked_tab_id then
      vim.api.nvim_set_current_tabpage(tab) -- switch to correct tab
      return
    end
  end

  print("Invalid tab ID: " .. clicked_tab_id)
end

function M.right_mouse_close_tab(bufnr)
  -- add function here
end

return M
