local wezterm = require("wezterm")
local act = wezterm.action

return {
  keys = {

    { key = "A", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    {
      key = "S",
      mods = "CTRL|SHIFT",
      action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
      key = "T",
      mods = "CTRL|SHIFT",
      action = act.SpawnTab("CurrentPaneDomain"),
    },

    { key = "T", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "T", mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
    { key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) },
    { key = "PageUp", mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
    { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
    { key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "PageDown", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },
    { key = "LeftArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
    { key = "LeftArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "RightArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
    { key = "RightArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "UpArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
    { key = "UpArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "DownArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },
    { key = "DownArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "r", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },
    { key = "r", mods = "SUPER", action = act.ReloadConfiguration },
    { key = "Insert", mods = "SHIFT", action = act.PasteFrom("PrimarySelection") },
    { key = "Insert", mods = "CTRL", action = act.CopyTo("PrimarySelection") },
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    -- { key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
    -- { key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },
    -- Pane Navigation
    { key = "LeftArrow", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
    { key = "UpArrow", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "CTRL", action = act.ActivatePaneDirection("Down") },

    -- Pane Size Adjust
    { key = "LeftArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "RightArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "UpArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "DownArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Down", 1 }) },

    -- Tab Navigation
    { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  },
  key_tables = {},
}
