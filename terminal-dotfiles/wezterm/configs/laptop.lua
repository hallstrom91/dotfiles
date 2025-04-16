local wezterm = require("wezterm")
local config = {}

--| custom config files |---
local keymaps = require("keymaps")
local sysstatus = require("status")
local gui_startup = require("gui_startup")
local gui_tabs = require("gui_tabs")
local gui_theme = require("gui_theme")

---------------------
---- Keymaps config
---------------------
config.disable_default_key_bindings = true
config.keys = keymaps.keys
config.key_tables = keymaps.key_tables

---------------------
---- Core settings
---------------------
local font_size = 10.5

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

config.font = wezterm.font_with_fallback({
  "CaskaydiaCove NF", -- Nerd Font
  "JetBrainsMono Nerd Font", -- fallback
})
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
---- Modifiers
---------------------

----| automated script loading and navigation |-----
wezterm.on("gui-startup", gui_startup.bootloader)

----| dynamic theme (if SSH) |----
wezterm.on("update-status", gui_theme.switcher)

----| format tab title function |----
wezterm.on("format-tab-title", gui_tabs.title_and_icon)

----| show cpu and ram usage/temp |----
wezterm.on("update-right-status", sysstatus.usage_and_temp)

return config
