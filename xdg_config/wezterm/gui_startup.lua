local wezterm = require("wezterm")
local mux = wezterm.mux

local startup = {}

function startup.bootloader()
  local script_path = wezterm.home_dir .. "/.bin/mountwsx_and_navigate.sh"
  local newtab_dotfiles = wezterm.home_dir .. "/Documents/dotfiles"

  local tab, _, window = mux.spawn_window({
    workspace = "Main",
    cwd = wezterm.home_dir,
    args = { script_path },
  })

  window:spawn_tab({ cwd = newtab_dotfiles })

  wezterm.time.call_after(0.3, function()
    tab:activate()
  end)
end

return startup
