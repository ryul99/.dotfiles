-- Pull in the wezterm API
local wezterm = require 'wezterm'
local keymaps = {}

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- color
color_scheme = 'dimidium'

-- visual
config.font = wezterm.font('CaskaydiaMono Nerd Font')
config.font_size = 18
config.term = "wezterm"

config.window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0cell',
    bottom = '0cell',
}

-- keymaps Copy & Paste
table.insert( keymaps, { key = 'C', mods = 'SHIFT|CTRL', action =
wezterm.action.CopyTo 'ClipboardAndPrimarySelection', })

table.insert( keymaps, { key = 'V', mods = 'SHIFT|CTRL', action =
wezterm.action.PasteFrom 'Clipboard', })

table.insert( keymaps, { key = 'V', mods = 'SHIFT|CTRL', action =
wezterm.action.PasteFrom 'PrimarySelection', })

config.keys = {
    {
        key = 'Enter',
        mods = 'ALT',
        action = wezterm.action.DisableDefaultAssignment,
    },
}

-- and finally, return the configuration to wezterm
return config
