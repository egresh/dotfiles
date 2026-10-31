local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme_dirs = { os.getenv("HOME") .. "/.local/share/tinted-theming/tinty" }
config.color_scheme = "tinted-wezterm-themes-wezterm-file"
config.enable_tab_bar = false
config.font = wezterm.font "ShureTechMono Nerd Font Mono"
config.font_size = 24.0
config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
config.window_decorations = "RESIZE"
config.audible_bell = "Disabled"
config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false

return config
