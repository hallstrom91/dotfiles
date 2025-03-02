local wezterm = require("wezterm")
local config = {}
local mux = wezterm.mux

--| custom config files |---
local keymaps = require("keymaps")
local cpu_ram_status = require("status")

---------------------
---- Keymaps config
---------------------
config.disable_default_key_bindings = true
config.keys = keymaps.keys
config.key_tables = keymaps.key_tables

---------------------
---- Core settings
---------------------
local dimmer = { brightness = 0.1 }
local font_size = 11.0

---------------------
---- Window
---------------------

config.window_padding = {
  top = 2,
  right = 12,
  bottom = 2,
  left = 2,
}

config.initial_rows = 40
config.initial_cols = 120
---------------------
---- Fonts
---------------------

config.font = wezterm.font({ family = "CaskaydiaCove NFM", stretch = "Expanded", weight = "Regular" })
config.font_size = font_size

---------------------
---- Scrollbar
---------------------
config.enable_scroll_bar = true

---------------------
---- Performance
---------------------
config.animation_fps = 60
config.max_fps = 60
config.front_end = "OpenGL"
config.webgpu_power_preference = "HighPerformance"

---------------------
---- Cursor
---------------------
config.default_cursor_style = "SteadyBar"

---------------------
---- Tab bar
---------------------

config.use_fancy_tab_bar = true
config.enable_tab_bar = true
config.tab_max_width = 60
config.inactive_pane_hsb = {
  saturation = 0.4,
  brightness = 0.5,
}

---------------------
---- Indicators
---------------------

config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
}
---------------------
---- Graphics & BG
---------------------

config.enable_kitty_graphics = true

---------------------
---- Icons
---------------------
local SSH_SERVER = wezterm.nerdfonts.fa_server

local process_icons = {
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

local function get_process_icon(process_name)
  local clean_name = process_name:match("([^/]+)$") or process_name
  local icon = process_icons[clean_name] or wezterm.nerdfonts.seti_checkbox_unchecked
  return icon .. " " .. clean_name
end

---------------------
---- Tabs
---------------------

local function get_last_folder_segment(uri)
  if not uri then
    return "~"
  end

  local path = uri:gsub("file://", ""):gsub("^.+:", "")
  return path:match("([^/]+)/*$") or path
end

wezterm.on("format-tab-title", function(tab)
  local active_tab = tab.active_pane
  local pane_id = tostring(active_tab.pane_id)
  local process_name = active_tab.foreground_process_name or "Shell"

  local process_display = get_process_icon(process_name)

  local filepath_icon = wezterm.nerdfonts.oct_rel_file_path
  local folder_icon = wezterm.nerdfonts.cod_folder_opened
  local formatted_title = folder_icon .. " " .. filepath_icon .. get_last_folder_segment(active_tab.title)

  local process_fg = "#B0BEC5"
  local separator_fg = "#546E7A"
  local folder_fg = "#6a7fb5"

  if process_name:match("ssh") then
    formatted_title = SSH_SERVER .. " " .. "remote session"
  end

  return wezterm.format({
    { Text = " " .. pane_id .. ": " },
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = process_fg } },
    { Text = process_display .. " " },
    { Foreground = { Color = separator_fg } },
    { Text = " | " .. " " },
    { Attribute = { Italic = true } },
    { Foreground = { Color = folder_fg } },
    { Text = formatted_title .. " " },
  })
end)

wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local process_name = pane:get_foreground_process_name()

  if process_name and process_name:match("ssh") then
    overrides.color_scheme = "Fideloper"
    overrides.background = {
      {
        source = {
          File = wezterm.home_dir .. "/.config/wezterm/backgrounds/techpinguine1920x1080.png",
        },
        hsb = dimmer,
      },
    }
  else
    overrides.color_scheme = "farmhouse-dark"
    overrides.background = {
      {
        source = {
          File = wezterm.home_dir .. "/.config/wezterm/backgrounds/anonbgdark1920x1080.png",
        },
        hsb = dimmer,
      },
    }
  end

  window:set_config_overrides(overrides)
end)

---------------------
---- Format Panes
---------------------
wezterm.on("gui-startup", function()
  local mount_path = "/media/veracrypt2"
  local script_path = wezterm.home_dir .. "/.bin/mountwsx_and_navigate.sh"

  local max_attempts = 120
  local attempt = 0

  local tab1, pane, window = mux.spawn_window({
    workspace = "Main",
    cwd = wezterm.home_dir,
    args = { script_path },
  })

  local function poll_mount()
    attempt = attempt + 1
    local f = io.open(mount_path, "r")

    if f then
      io.close(f)
      wezterm.log_info("󰸞 Disk mounted. Creating split...")
      local split = pane:split({
        direction = "Right",
        size = 0.5,
        cwd = mount_path,
      })
      split:send_text("lazydocker\n")
    elseif attempt < max_attempts then
      wezterm.time.call_after(1.0, poll_mount)
    else
      wezterm.log_error("󱈸 Mount timeout: " .. mount_path .. " not found after waiting.")
      pane:send_text("echo ' Mount failed or took too long.'\n")
    end
  end

  -- Start poll after 5s
  wezterm.time.call_after(5.0, poll_mount)

  window:spawn_tab({ cwd = wezterm.home_dir .. "/Documents/dotfiles" })

  wezterm.time.call_after(0.3, function()
    tab1:activate()
  end)
end)

-- Original
-- wezterm.on("gui-startup", function()
--   local tab1, _, window = mux.spawn_window({
--     workspace = "Main",
--     cwd = wezterm.home_dir,
--     args = { wezterm.home_dir .. "/.bin/mountwsx_and_navigate.sh" },
--   })
--
--   --   ------ Split vertical
--   --   -- local system_info = pane:split({
--   --   --   direction = "Right",
--   --   --   workspace = "sysinfo",
--   --   --   size = 0.5,
--   --   -- })
--   --   --
--   --   --system_info:send_text("\n")
--
--   window:spawn_tab({
--     cwd = wezterm.home_dir .. "/Documents/dotfiles",
--   })
--
--   wezterm.time.call_after(0.1, function()
--     tab1:activate()
--   end)
-- end)

-------------------------
---- CPU & RAM USAGE
-------------------------

cpu_ram_status.setup()

return config
