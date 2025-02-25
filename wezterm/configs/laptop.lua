local wezterm = require('wezterm')
local config = {}
local mux = wezterm.mux
--local keymaps = require('keymaps')

---------------------
---- Keymaps config
---------------------
--config.keys = keymaps.keys
--config.key_tables = keymaps.key_tables

---------------------
---- Reusable settings
---------------------
local dimmer = { brightness = 0.1 }

config.window_padding = {
  top = 2,
  right = 12,
  bottom = 2,
  left = 2,
}

---------------------
---- Theme
---------------------
--config.color_scheme = 'Atelierdune (dark) (terminal.sexy)'
--config.color_scheme = 'farmhouse-dark'
--config.color_scheme = 'farmhouse-light'
-- config.colors = {
--   scrollbar_thumb = '#3f537d',
--   visual_bell = '#777777', -- "bell" notifier color, instead of "beep" sound
--   tab_bar = {
--     new_tab = {
--       bg_color = '#262420',
--       fg_color = '#A68B6D',
--       intensity = 'Normal',
--     },
--     new_tab_hover = {
--       bg_color = '#3f537d',
--       fg_color = '#E4C9AF',
--       intensity = 'Bold',
--     },
--   },
-- }

---------------------
---- Fonts
---------------------
config.font = wezterm.font({ family = 'CaskaydiaCove NFM', stretch = 'Expanded', weight = 'Regular' })
config.font_size = 10.0

---------------------
---- Scrollbar
---------------------
config.enable_scroll_bar = true

---------------------
---- Performance
---------------------
config.animation_fps = 60
config.max_fps = 60
config.front_end = 'OpenGL'
config.webgpu_power_preference = 'HighPerformance'

---------------------
---- Cursor
---------------------
config.default_cursor_style = 'SteadyBar'

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

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}
---------------------
---- Graphics & BG
---------------------

config.enable_kitty_graphics = true
-- config.background = {
--   {
--     source = {
--       File = '/home/simon/.config/wezterm/backgrounds/anonbgdark1920x1080.png',
--     },
--     hsb = dimmer,
--   },
-- }

---------------------
---- Icons
---------------------

local process_icons = {
  ['docker'] = wezterm.nerdfonts.linux_docker,
  ['docker-compose'] = wezterm.nerdfonts.linux_docker,
  ['psql'] = wezterm.nerdfonts.dev_postgresql,
  ['kuberlr'] = wezterm.nerdfonts.linux_docker,
  ['kubectl'] = wezterm.nerdfonts.linux_docker,
  ['stern'] = wezterm.nerdfonts.linux_docker,
  ['nvim'] = wezterm.nerdfonts.custom_vim,
  ['make'] = wezterm.nerdfonts.seti_makefile,
  ['vim'] = wezterm.nerdfonts.dev_vim,
  ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
  ['btm'] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ['cargo'] = wezterm.nerdfonts.dev_rust,
  ['sudo'] = wezterm.nerdfonts.fa_hashtag,
  ['lazydocker'] = wezterm.nerdfonts.linux_docker,
  ['lazygit'] = wezterm.nerdfonts.dev_git_branch,
  ['git'] = wezterm.nerdfonts.dev_git,
  ['lua'] = wezterm.nerdfonts.seti_lua,
  ['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
  ['curl'] = wezterm.nerdfonts.mdi_flattr,
  ['gh'] = wezterm.nerdfonts.dev_github_badge,
  ['node'] = wezterm.nerdfonts.dev_nodejs_small,
  ['dotnet'] = wezterm.nerdfonts.md_language_csharp,
  ['ssh'] = wezterm.nerdfonts.md_connection,
}

local function get_process_icon(process_name)
  local clean_name = process_name:match('([^/]+)$') or process_name
  local icon = process_icons[clean_name] or wezterm.nerdfonts.seti_checkbox_unchecked
  return icon .. ' ' .. clean_name
end

local CPU_ICON = wezterm.nerdfonts.md_cpu_64_bit
local RAM_ICON_LOW = wezterm.nerdfonts.md_speedometer_slow
local RAM_ICON_MED = wezterm.nerdfonts.md_speedometer_medium
local RAM_ICON_HIGH = wezterm.nerdfonts.md_speedometer
local TEMP_ICON_LOW = wezterm.nerdfonts.fae_thermometer_low
local TEMP_ICON_MED = wezterm.nerdfonts.fae_thermometer
local TEMP_ICON_HIGH = wezterm.nerdfonts.fae_thermometer_high
local DEV_LINUX = wezterm.nerdfonts.dev_linux
local SSH_SERVER = wezterm.nerdfonts.fa_server
local WARNING_ICON = wezterm.nerdfonts.cod_warning
--local DEV_TERM_LINUX = wezterm.nerdfonts.cod_terminal_linux
--local POPOS_ICON = wezterm.nerdfonts.linux_pop_os

---------------------
---- Tabs
---------------------

local function get_last_folder_segment(uri)
  if not uri then
    return '~'
  end

  local path = uri:gsub('file://', ''):gsub('^.+:', '')
  return path:match('([^/]+)/*$') or path
end

wezterm.on('format-tab-title', function(tab)
  local active_tab = tab.active_pane
  local pane_id = tostring(active_tab.pane_id)
  local process_name = active_tab.foreground_process_name or 'Shell'

  local process_display = get_process_icon(process_name)

  local filepath_icon = wezterm.nerdfonts.oct_rel_file_path
  local folder_icon = wezterm.nerdfonts.cod_folder_opened
  local formatted_title = folder_icon .. ' ' .. filepath_icon .. get_last_folder_segment(active_tab.title)

  local process_fg = '#B0BEC5'
  local separator_fg = '#546E7A'
  local folder_fg = '#6a7fb5'

  if process_name:match('ssh') then
    formatted_title = SSH_SERVER .. ' ' .. 'remote session'
  end

  return wezterm.format({
    { Text = ' ' .. pane_id .. ': ' },
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = process_fg } },
    { Text = process_display .. ' ' },
    { Foreground = { Color = separator_fg } },
    { Text = ' | ' .. ' ' },
    { Attribute = { Italic = true } },
    { Foreground = { Color = folder_fg } },
    { Text = formatted_title .. ' ' },
  })
end)

wezterm.on('update-status', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local process_name = pane:get_foreground_process_name()

  if process_name and process_name:match('ssh') then
    overrides.color_scheme = 'Fideloper'
    overrides.background = {
      {
        source = {
          File = wezterm.home_dir .. '/.config/wezterm/backgrounds/techpinguine1920x1080.png',
        },
        hsb = dimmer,
      },
    }
  else
    overrides.color_scheme = 'farmhouse-dark'
    overrides.background = {
      {
        source = {
          -- File = wezterm.home_dir .. '/.config/wezterm/backgrounds/anonbgdark1920x1080.png',
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

wezterm.on('gui-startup', function()
  local _, pane, _ = mux.spawn_window({
    workspace = 'Main',
    cwd = wezterm.home_dir .. '/.config/wezterm',
    args = { wezterm.home_dir .. '/.bin/mountwsx_and_navigate.sh' },
  })

  ------ Split vertical
  local system_info = pane:split({
    direction = 'Right',
    workspace = 'sysinfo',
    size = 0.3,
  })

  system_info:send_text('fastfetch\n')
  system_info:send_text('task project\n')

  mux.set_active_workspace('Main')
end)

-------------------------
---- CPU & RAM USAGE
-------------------------

wezterm.on('update-right-status', function(window, _)
  local bg_color = '#2d2d2d'
  local fg_color = '#b7babd'
  local divider_color = '#3f537d'
  local header_color = '#619cff'
  local cpu_colors = { '#4CAF50', '#FFB74D', '#D32F2F', '#B71C1C' }
  local ram_colors = { '#4CAF50', '#FFB74D', '#D32F2F', '#B71C1C' }

  --> Get CPU Temp
  local function get_temp(sensor_cmd, grep_pattern, awk_field)
    local success, temp_out, _ = pcall(wezterm.run_child_process, { 'sh', '-c', sensor_cmd })
    if not success or not temp_out then
      return 'N/A'
    end

    local extract_cmd = string.format("%s | grep '%s' | awk '{print $%d}'", sensor_cmd, grep_pattern, awk_field)
    local _, result, _ = wezterm.run_child_process({ 'sh', '-c', extract_cmd })

    local temp = tonumber(result:match('%d+%.?%d*')) or 0
    local icon = (temp >= 70 and TEMP_ICON_HIGH) or (temp >= 50 and TEMP_ICON_MED) or TEMP_ICON_LOW
    return string.format('%s %.1f°C', icon, temp)
  end

  local cpu_temp = get_temp('sensors coretemp-isa-0000', 'Package id 0', 4)

  --> Get CPU usage
  local cpuv = { total = 0, idle = 0, pct = 1 }
  local _, cpuout, _ = wezterm.run_child_process({ 'head', '-n1', '/proc/stat' })
  local vtotal, vidle, k = 0, 0, 1

  for v in cpuout:gmatch('%d+') do
    vtotal = vtotal + tonumber(v)
    if k == 4 then
      vidle = tonumber(v) or 0
    end
    k = k + 1
  end

  local dtotal, didle = vtotal - cpuv.total, vidle - cpuv.idle
  if dtotal == 0 then
    dtotal = 1
  end

  cpuv.pct = math.floor(0.5 + 100 * (dtotal - didle) / dtotal)
  cpuv.total, cpuv.idle = vtotal, vidle

  --> CPU string with dynamic colors based on usage
  local cpu_idx = (cpuv.pct < 30 and 1) or (cpuv.pct < 60 and 2) or (cpuv.pct < 80 and 3) or 4
  local cpu_warning = (cpuv.pct >= 80) and WARNING_ICON or ''
  local cpu_str = string.format('%s %d%% %s', CPU_ICON, cpuv.pct, cpu_warning)

  --> Get RAM usage
  local memmb = { Total = 0, Available = 0 }
  local _, mmout, _ = wezterm.run_child_process({ 'head', '-n3', '/proc/meminfo' })

  local function update_memory_status(info, item)
    local numstr = info:match('Mem' .. item .. ':%s+(%S+)')
    if numstr then
      memmb[item] = tonumber(numstr) / 1000
    end
  end

  if memmb.Total == 0 then
    update_memory_status(mmout, 'Total')
  end
  update_memory_status(mmout, 'Available')

  local mem_usage_pct = 100 * (1 - (memmb.Available / memmb.Total))

  --> RAM % color based on usage
  local ram_idx = (mem_usage_pct < 30 and 1) or (mem_usage_pct < 60 and 2) or (mem_usage_pct < 80 and 3) or 4
  local ram_icon = (mem_usage_pct >= 60 and RAM_ICON_HIGH) or (mem_usage_pct >= 30 and RAM_ICON_MED) or RAM_ICON_LOW
  local ram_warning = (mem_usage_pct >= 80) and WARNING_ICON or ''
  local ram_str = string.format('%s %.1f%% %s', ram_icon, mem_usage_pct, ram_warning)

  window:set_right_status(wezterm.format({
    --> Divider w Sys Icon
    { Background = { Color = divider_color } },
    { Foreground = { Color = fg_color } },
    { Text = ' ' .. DEV_LINUX .. ' ' },

    --> CPU Section
    { Background = { Color = bg_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = header_color } },
    { Text = ' CPU' },
    { Foreground = { Color = cpu_colors[cpu_idx] } },
    { Text = ' ' .. cpu_str },

    --> Divider CPU usage & temp
    { Foreground = { Color = fg_color } },
    { Text = '&' },

    { Foreground = { Color = cpu_colors[cpu_idx] } },
    { Text = ' ' .. cpu_temp .. ' ' },

    --> Small Section Divider
    { Background = { Color = divider_color } },
    { Foreground = { Color = fg_color } },
    { Text = ' ' },

    --> RAM Section
    { Background = { Color = bg_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = header_color } },
    { Text = ' RAM ' },
    { Foreground = { Color = ram_colors[ram_idx] } },
    { Text = ' ' .. ram_str .. ' ' },
  }))
end)

return config
