local wezterm = require("wezterm")
local mux = wezterm.mux

local startup = {}

local signal_file = "/tmp/mount_success.signal"
local max_attempts = 20
local attempt = 0
local mount_path = "/media/veracrypt2"

local function poll_mount_signal(pane)
  attempt = attempt + 1
  local f = io.open(signal_file, "r")

  if f then
    f:close()
    os.remove(signal_file)
    local split = pane:split({
      direction = "Right",
      size = 0.5,
      cwd = mount_path,
    })
    split:send_text("lazydocker\n")
  elseif attempt < max_attempts then
    wezterm.time.call_after(1.0, function()
      poll_mount_signal(pane)
    end)
  else
    pane:send_text(" Mount failed or took too long.\n")
  end
end

function startup.bootloader()
  local script_path = wezterm.home_dir .. "/.bin/mountwsx_and_navigate.sh"

  local tab, pane, window = mux.spawn_window({
    workspace = "Main",
    cwd = wezterm.home_dir,
    args = { script_path },
  })

  wezterm.time.call_after(5.0, function()
    poll_mount_signal(pane)
  end)

  window:spawn_tab({ cwd = wezterm.home_dir .. "/Documents/dotfiles" })

  wezterm.time.call_after(0.3, function()
    tab:activate()
  end)
end

return startup
