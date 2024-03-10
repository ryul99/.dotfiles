-- Pull in the wezterm API
local wezterm = require 'wezterm'
local keymaps = {}

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- color
color_scheme = 'dimidium'

-- font
config.font = wezterm.font('CaskaydiaMono Nerd Font Mono')
config.font_size = 16

-- keymaps Copy & Paste
table.insert( keymaps, { key = 'C', mods = 'SHIFT|CTRL', action =
wezterm.action.CopyTo 'ClipboardAndPrimarySelection', })

table.insert( keymaps, { key = 'V', mods = 'SHIFT|CTRL', action =
wezterm.action.PasteFrom 'Clipboard', })

table.insert( keymaps, { key = 'V', mods = 'SHIFT|CTRL', action =
wezterm.action.PasteFrom 'PrimarySelection', })

-- and finally, return the configuration to wezterm
return config
