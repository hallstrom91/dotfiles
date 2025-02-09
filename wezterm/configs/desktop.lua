local wezterm = require('wezterm')
local config = {}
local mux = wezterm.mux

---------------------
---- Reusable settings
---------------------
local dimmer = { brightness = 0.1 }

config.window_padding = {
  top = 2,
  right = 3,
  bottom = 2,
  left = 2,
}

---------------------
---- Theme
---------------------
config.color_scheme = 'farmhouse-dark'

---------------------
---- Fonts
---------------------
config.font = wezterm.font({ family = 'CaskaydiaCove NFM', stretch = 'Expanded', weight = 'Regular' })
config.font_size = 10.0

---------------------
---- Scrollbar
---------------------
config.enable_scroll_bar = true
config.colors = {
  scrollbar_thumb = '#ffffff',
  visual_bell = '#777777', -- "bell" notifier color, instead of "beep" sound
}

---------------------
---- Performance
---------------------
config.animation_fps = 60
config.max_fps = 144
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
config.background = {
  {
    source = {
      File = '/home/simon/.config/wezterm/backgrounds/anonbgdark1920x1080.png',
    },
    hsb = dimmer,
  },
}

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
}

local function get_process_icon(process_name)
  local clean_name = process_name:match('([^/]+)$') or process_name
  local icon = process_icons[clean_name] or wezterm.nerdfonts.seti_checkbox_unchecked
  return icon .. ' ' .. clean_name
end

local SOLID_LEFT_ARROW = wezterm.nerdfonts.cod_arrow_swap
local CPU_ICON = wezterm.nerdfonts.md_cpu_64_bit
local RAM_ICON_LOW = wezterm.nerdfonts.md_speedometer_slow
local RAM_ICON_MED = wezterm.nerdfonts.md_speedometer_medium
local RAM_ICON_HIGH = wezterm.nerdfonts.md_speedometer
local TEMP_ICON_LOW = wezterm.nerdfonts.fae_thermometer_low
local TEMP_ICON_MED = wezterm.nerdfonts.fae_thermometer
local TEMP_ICON_HIGH = wezterm.nerdfonts.fae_thermometer_high
local DEV_LINUX = wezterm.nerdfonts.dev_linux
local DEBUG_DASH = wezterm.nerdfonts.cod_debug_pause

---------------------
---- Format Tabs
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

  -- icon + process
  local process_display = get_process_icon(process_name)

  -- folder-icon + latest dir (cwd)
  local filepath_icon = wezterm.nerdfonts.oct_rel_file_path
  local folder_icon = wezterm.nerdfonts.cod_folder_opened
  local formatted_title = folder_icon .. ' ' .. filepath_icon .. get_last_folder_segment(active_tab.title)

  -- 🎨 Dark-mode färger
  local process_fg = '#B0BEC5'
  local separator_fg = '#546E7A'
  local folder_fg = '#6a7fb5'

  -- ✨ Skapa den formatterade fliken
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

---------------------
---- Format Panes
---------------------

wezterm.on('gui-startup', function(cmd)
  local args = {}
  if cmd then
    args = cmd.args
  end

  local tab1, pane1, window1 = mux.spawn_window({
    workspace = 'Main',
    cwd = wezterm.home_dir .. '/.config/wezterm',
    args = { wezterm.home_dir .. '/.bin/mountwsx_and_navigate.sh' },
  })

  ------ Split vertical
  local system_info = pane1:split({
    direction = 'Right',
    workspace = 'sysinfo',
    size = 0.5,
  })

  system_info:send_text('fastfetch\n')

  -- local tab2, pane2, window2 = mux.spawn_window({
  --   workspace = 'Coding',
  --   cwd = wezterm.home_dir,
  -- })
  --
  -- pane2:send_text('Testing')

  mux.set_active_workspace('Main')
end)

-------------------------
---- CPU & RAM USAGE
-------------------------

wezterm.on('update-right-status', function(window, _)
  local bg_color = '#2d2d2d'
  local fg_color = '#b7babd'
  -- local accent_color = '#175ea0'
  local divider_color = '#3f537d'
  local header_color = '#619cff'
  local ram_color = '#FFFFFF'
  local cpu_colors = { '#6B705C', '#CB997E', '#DD6E42', '#B56576', '#FF5E5B' }
  -- local ram_colors = { '#4CAF50', '#FFB74D', '#D32F2F' }

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

  local cpu_idx = math.min(math.ceil(cpuv.pct / 20), #cpu_colors)
  local cpu_str = string.format(' %s %d%%', CPU_ICON, cpuv.pct)

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
  local ram_icon = (mem_usage_pct >= 60 and RAM_ICON_HIGH) or (mem_usage_pct >= 25 and RAM_ICON_MED) or RAM_ICON_LOW
  local ram_str = string.format(' %s %.1f%%', ram_icon, mem_usage_pct)

  local divider = ' '

  window:set_right_status(wezterm.format({
    ----> Divider
    { Background = { Color = divider_color } },
    { Foreground = { Color = fg_color } },
    { Text = ' ' .. DEV_LINUX .. ' ' },

    ----> CPU
    { Background = { Color = bg_color } },

    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = header_color } },
    { Text = ' CPU' },
    { Foreground = { Color = cpu_colors[cpu_idx] } },
    { Text = cpu_str .. ' & ' .. cpu_temp .. ' ' },

    ---->  Divider
    { Background = { Color = divider_color } },
    { Foreground = { Color = fg_color } },
    { Text = ' ' .. divider .. ' ' },

    ---->  RAM
    { Background = { Color = bg_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = header_color } },
    { Text = ' RAM ' },

    { Foreground = { Color = ram_color } },
    { Text = ' ' .. ram_str .. ' ' },
  }))
end)

return config
