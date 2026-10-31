local colors = require("settings").gruvbox
local font = require("settings").font
local alias_bracket_config = require("settings").alias_bracket

local hostname = sbar.add("item", "hostname", {
	label = {
		font = { family = font.family, size = font.size },
		color = colors.bright_green,
		string = "??",
	},
	-- Matches the iStat pill's ~12px visual inset (measured from a screenshot,
	-- not sketchybar's reported frame: the iStat icons are native menu-extra
	-- bitmaps with transparent margin baked in, so their declared frame is
	-- flush with the bracket even though the visible glyphs aren't).
	padding_left = 12,
	padding_right = 12,
})

-- No background on the item itself, same as apple: the border comes only
-- from the bracket (dark0 fill, bright_red border) so this reads as another
-- section, not a stray label.
sbar.add("bracket", { hostname.name }, alias_bracket_config())

sbar.exec("hostname -s", function(result)
	local host = (result or ""):gsub("%s+$", "")
	hostname:set({ label = host })
end)
