local wezterm = require("wezterm")
local mux = wezterm.mux

local function setup_gui_startup()
  local signal_file = "/tmp/mount_success.signal"
  local mount_path = "/media/veracrypt2"
  local script_path = wezterm.home_dir .. "/.bin/mountwsx_and_navigate.sh"

  local max_attempts = 60
  local attempt = 0

  local tab1, pane, window = mux.spawn_window({
    workspace = "Main",
    cwd = wezterm.home_dir,
    args = { script_path },
  })

  local function poll_mount_signal()
    attempt = attempt + 1
    local f = io.open(signal_file, "r")

    if f then
      f:close()
      wezterm.log_info("󰸞 Mount confirmed via signal file. Creating split with lazydocker.")
      os.remove(signal_file)
      local split = pane:split({
        direction = "Right",
        size = 0.5,
        cwd = mount_path,
      })
      split:send_text("lazydocker\n")
    elseif attempt < max_attempts then
      wezterm.time.call_after(1.0, poll_mount_signal)
    else
      wezterm.log_error("󱈸 Mount timeout: Signal file not found after waiting.")
      pane:send_text("echo ' Mount failed or took too long.'\n")
    end
  end

  wezterm.time.call_after(5.0, poll_mount_signal)

  window:spawn_tab({ cwd = wezterm.home_dir .. "/Documents/dotfiles" })

  wezterm.time.call_after(0.3, function()
    tab1:activate()
  end)
end

return setup_gui_startup
