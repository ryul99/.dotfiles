-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- color
color_scheme = 'dimidium'

-- font
config.font = wezterm.font('CaskaydiaMono Nerd Font Mono')
config.font_size = 16

-- and finally, return the configuration to wezterm
return config
