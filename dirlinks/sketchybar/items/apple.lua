local colors = require("settings").gruvbox
local icons = require("icons")

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", "apple", {
	icon = {
		font = "ShureTechMono Nerd Font:Regular:20",
		string = icons.apple,
		padding_right = 8,
		padding_left = 8,
	},
	label = { drawing = false },
	background = {
		color = colors.bg2,
		border_color = colors.black,
		border_width = 1,
	},
	padding_left = 1,
	padding_right = 1,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

-- Double border for apple using a single item bracket
sbar.add("bracket", { apple.name }, {
	background = {
		color = colors.dark0,
		border_color = colors.bright_red,
		border_width = 2,
		height = 45,
		corner_radius = 5,
	},
})

-- Padding item required because of bracket. 18px matches the gap unit used
-- elsewhere between left-side sections (istat_spacer, omni.ws.lead).
sbar.add("item", { width = 18 })
