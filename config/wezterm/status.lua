local wezterm = require("wezterm")
local icons = require("icons")

local sysstatus = {}

function sysstatus.usage_and_temp(window)
  local bg_color = "#2d2d2d"
  local fg_color = "#b7babd"
  local divider_color = "#3f537d"
  local header_color = "#619cff"
  local cpu_colors = { "#4CAF50", "#BAC140", "#FF9149", "#B71C1C" }
  local ram_colors = { "#4CAF50", "#BAC140", "#FF9149", "#B71C1C" }

  --> Get CPU Temp
  local function get_temp(sensor_cmd, grep_pattern, awk_field)
    local success, temp_out, _ = pcall(wezterm.run_child_process, { "sh", "-c", sensor_cmd })
    if not success or not temp_out then
      return "N/A"
    end

    local extract_cmd = string.format("%s | grep '%s' | awk '{print $%d}'", sensor_cmd, grep_pattern, awk_field)
    local _, result, _ = wezterm.run_child_process({ "sh", "-c", extract_cmd })

    local temp = tonumber(result:match("%d+%.?%d*")) or 0
    local icon = (temp >= 70 and icons.system.TEMP_ICON_HIGH)
      or (temp >= 50 and icons.system.TEMP_ICON_MED)
      or icons.system.TEMP_ICON_LOW
    return string.format("%s %.1f°C", icon, temp)
  end

  local cpu_temp = get_temp("sensors coretemp-isa-0000", "Package id 0", 4)

  --> Get CPU usage
  local cpuv = { total = 0, idle = 0, pct = 1 }
  local _, cpuout, _ = wezterm.run_child_process({ "head", "-n1", "/proc/stat" })
  local vtotal, vidle, k = 0, 0, 1

  for v in cpuout:gmatch("%d+") do
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
  local cpu_warning = (cpuv.pct >= 80) and icons.system.WARNING_ICON or ""
  local cpu_str = string.format("%s %d%% %s", icons.system.CPU_ICON, cpuv.pct, cpu_warning)

  --> Get RAM usage
  local memmb = { Total = 0, Available = 0 }
  local _, mmout, _ = wezterm.run_child_process({ "head", "-n3", "/proc/meminfo" })

  local function update_memory_status(info, item)
    local numstr = info:match("Mem" .. item .. ":%s+(%S+)")
    if numstr then
      memmb[item] = tonumber(numstr) / 1000
    end
  end

  if memmb.Total == 0 then
    update_memory_status(mmout, "Total")
  end
  update_memory_status(mmout, "Available")

  local mem_usage_pct = 100 * (1 - (memmb.Available / memmb.Total))

  --> RAM % color based on usage
  local ram_idx = (mem_usage_pct < 30 and 1) or (mem_usage_pct < 60 and 2) or (mem_usage_pct < 80 and 3) or 4
  local ram_icon = (mem_usage_pct >= 60 and icons.system.RAM_ICON_HIGH)
    or (mem_usage_pct >= 30 and icons.system.RAM_ICON_MED)
    or icons.system.RAM_ICON_LOW
  local ram_warning = (mem_usage_pct >= 80) and icons.system.WARNING_ICON or ""
  local ram_str = string.format("%s %.1f%% %s", ram_icon, mem_usage_pct, ram_warning)

  window:set_right_status(wezterm.format({
    --> Divider w Sys Icon
    { Background = { Color = divider_color } },
    { Foreground = { Color = fg_color } },
    { Text = " " .. icons.system.DEV_LINUX .. " " },

    --> CPU Section
    { Background = { Color = bg_color } },
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = header_color } },
    { Text = " CPU" },
    { Foreground = { Color = cpu_colors[cpu_idx] } },
    { Text = " " .. cpu_str },

    --> Divider CPU usage & temp
    { Foreground = { Color = fg_color } },
    { Text = "&" },

    { Foreground = { Color = cpu_colors[cpu_idx] } },
    { Text = " " .. cpu_temp .. " " },

    --> Small Section Divider
    { Background = { Color = divider_color } },
    { Foreground = { Color = fg_color } },
    { Text = " " },

    --> RAM Section
    { Background = { Color = bg_color } },
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = header_color } },
    { Text = " RAM " },
    { Foreground = { Color = ram_colors[ram_idx] } },
    { Text = " " .. ram_str .. " " },
  }))
end

return sysstatus
