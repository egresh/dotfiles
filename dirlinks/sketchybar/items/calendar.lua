local colors = require("settings").gruvbox
local font = require("settings").font

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = 5})

local cal = sbar.add("item", {
  icon = {
    color = colors.bright_green,
    padding_left = 8,
    font = {
      family = font.family,
      size = font.size,
    },
  },
  label = {
    color = colors.bright_green,
    padding_right = 8,
    width = 60,
    align = "right",
    font = {
      family = font.family,
      size = font.size,
    },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.dark0,
    border_color = colors.bright_red,
    border_width = 1,
    corner_radius = 5,
  },
  click_script = "open -a 'Calendar'"
})

-- Double border for calendar using a single item bracket. Height / corner /
-- border match the section-pill spec (apple / iStat / workspace pills);
-- `colors.grey` doesn't exist in the palette (rendered as no border), so use a
-- real grey.
sbar.add("bracket", { cal.name }, {
  background = {
    color = colors.transparent,
    height = 45,
    corner_radius = 5,
    border_width = 2,
    border_color = colors.gray_245,
  }
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = 30})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M") })
end)
