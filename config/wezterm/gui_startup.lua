local wezterm = require("wezterm")
local mux = wezterm.mux

local startup = {}

function startup.bootloader()
	local wsx = wezterm.home_dir .. "/.bin/wsx.sh"

	local tab, pane, window = mux.spawn_window({
		workspace = "Main",
		cwd = wezterm.home_dir,
		args = { wsx, "enter", "--exec-shell" },
	})

	window:spawn_tab({ cwd = wezterm.home_dir .. "/Documents/dotfiles" })

	local split_one = pane:split({
		direction = "Right",
		size = 0.50,
	})

	-- local split_two = split_one:split({
	-- 	direction = "Bottom",
	-- 	size = 0.50,
	-- })

	split_one:send_text("btop\n")
	-- split_two:send_text("Hello Mr")

	wezterm.time.call_after(0.3, function()
		tab:activate()
	end)
end

return startup
