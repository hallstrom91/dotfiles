local wezterm = require("wezterm")
local icons = require("icons")

local tabline = {}

function tabline.title_and_icon(tab)
  local active_pane = tab.active_pane
  local pane_id = tostring(active_pane.pane_id)
  local process_name = active_pane.foreground_process_name or "Shell"
  local process_dir = (active_pane.current_working_dir and active_pane.current_working_dir.file_path) or ""

  ----| Render output
  local process_icon = icons.get_process_icon(process_name)
  local process_path = icons.get_directory_display(process_dir, tab.is_active)
  local formatted_title

  local process_fg = "#B0BEC5"
  local separator_fg = "#546E7A"
  local folder_fg = "#6a7fb5"

  if process_name:match("ssh") then
    formatted_title = wezterm.nerdfonts.md_remote_desktop .. " " .. " remote"
  else
    formatted_title = process_path
  end

  return wezterm.format({
    { Text = " " .. pane_id .. ": " },
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = process_fg } },
    { Text = process_icon .. " " },
    { Foreground = { Color = separator_fg } },
    { Text = " | " .. " " },
    { Attribute = { Italic = true } },
    { Foreground = { Color = folder_fg } },
    { Text = formatted_title },
  })
end

return tabline
