local wezterm = require("wezterm")

local theme = {}

function theme.switcher(window, pane)
  local overrides = window:get_config_overrides() or {}
  local process_name = pane:get_foreground_process_name()
  local dimmer = { brightness = 0.05 }

  if process_name and process_name:match("ssh") then
    overrides.color_scheme = "Fideloper"
    overrides.background = {
      {
        source = {
          File = wezterm.home_dir .. "/.config/wezterm/backdrops/cloudy-quasar.png",
        },
        hsb = dimmer,
      },
    }
  else
    overrides.color_scheme = "farmhouse-dark"
    overrides.background = {
      {
        source = {
          -- File = wezterm.home_dir .. "/.config/wezterm/backdrops/cloudy-quasar.png",
          --  File = wezterm.home_dir .. "/.config/wezterm/backdrops/brain.png",
          -- File = wezterm.home_dir .. "/.config/wezterm/backdrops/cubes.png",
          -- File = wezterm.home_dir .. "/.config/wezterm/backdrops/cyberpunk.png",
          File = wezterm.home_dir .. "/.config/wezterm/backdrops/earth.png",
        },
        hsb = dimmer,
      },
    }
  end

  window:set_config_overrides(overrides)
end

return theme
