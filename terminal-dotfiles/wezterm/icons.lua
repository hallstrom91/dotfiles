local wezterm = require("wezterm")

local icons = {}

icons.process = {
  ["docker"] = wezterm.nerdfonts.linux_docker,
  ["docker-compose"] = wezterm.nerdfonts.linux_docker,
  ["psql"] = wezterm.nerdfonts.dev_postgresql,
  ["kuberlr"] = wezterm.nerdfonts.linux_docker,
  ["kubectl"] = wezterm.nerdfonts.linux_docker,
  ["stern"] = wezterm.nerdfonts.linux_docker,
  ["nvim"] = wezterm.nerdfonts.custom_vim,
  ["make"] = wezterm.nerdfonts.seti_makefile,
  ["vim"] = wezterm.nerdfonts.dev_vim,
  ["bash"] = wezterm.nerdfonts.cod_terminal_bash,
  ["btm"] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ["cargo"] = wezterm.nerdfonts.dev_rust,
  ["sudo"] = wezterm.nerdfonts.fa_hashtag,
  ["lazydocker"] = wezterm.nerdfonts.linux_docker,
  ["lazygit"] = wezterm.nerdfonts.dev_git_branch,
  ["git"] = wezterm.nerdfonts.dev_git,
  ["lua"] = wezterm.nerdfonts.seti_lua,
  ["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
  ["curl"] = wezterm.nerdfonts.mdi_flattr,
  ["gh"] = wezterm.nerdfonts.dev_github_badge,
  ["node"] = wezterm.nerdfonts.dev_nodejs_small,
  ["dotnet"] = wezterm.nerdfonts.md_language_csharp,
  ["ssh"] = wezterm.nerdfonts.md_connection,
}

icons.system = {
  CPU_ICON = wezterm.nerdfonts.md_cpu_64_bit,
  RAM_ICON_LOW = wezterm.nerdfonts.md_speedometer_slow,
  RAM_ICON_MED = wezterm.nerdfonts.md_speedometer_medium,
  RAM_ICON_HIGH = wezterm.nerdfonts.md_speedometer,
  TEMP_ICON_LOW = wezterm.nerdfonts.fae_thermometer_low,
  TEMP_ICON_MED = wezterm.nerdfonts.fae_thermometer,
  TEMP_ICON_HIGH = wezterm.nerdfonts.fae_thermometer_high,
  DEV_LINUX = wezterm.nerdfonts.dev_linux,
  WARNING_ICON = wezterm.nerdfonts.cod_warning,
}

function icons.get_process_icon(process_name)
  local clean_name = process_name:match("([^/]+)$") or process_name
  local icon = icons.process[clean_name] or wezterm.nerdfonts.seti_checkbox_unchecked
  return icon .. " " .. " " .. clean_name
end

function icons.get_directory_display(uri, is_active)
  if not uri then
    return wezterm.nerdfonts.fa_folder .. "~"
  end

  local home = os.getenv("HOME") or ""
  local path = uri:gsub("file://", ""):gsub("^.+:", "")

  local folder = path
  if path:match("^" .. home .. "/?$") then
    folder = "~"
  else
    folder = path:match("([^/]+)/*$") or path
  end

  local icon = wezterm.nerdfonts.md_folder
  local filepath_icon = wezterm.nerdfonts.oct_rel_file_path

  if is_active then
    if folder == "~" then
      icon = " " .. wezterm.nerdfonts.md_folder_home
    elseif folder == " " .. "Downloads" then
      icon = wezterm.nerdfonts.md_folder_download
    elseif folder == " " .. "Pictures" or folder == "Images" then
      icon = " " .. wezterm.nerdfonts.md_folder_image
    elseif folder == ".config" or folder == ".dotfiles" then
      icon = " " .. wezterm.nerdfonts.md_folder_cog
    else
      icon = wezterm.nerdfonts.md_folder_open
    end
  end

  return icon .. " " .. " " .. filepath_icon .. " " .. folder
end

return icons
