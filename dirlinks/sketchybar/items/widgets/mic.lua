local icons = require("icons")
local settings = require("settings")
local colors = settings.gruvbox
local font = settings.font

-- Mute toggle for the default audio input device. Green mic = live, red
-- slashed mic = muted. Click to flip. macOS fires no "input volume changed"
-- event, so poll on a timer to catch changes made elsewhere (Control Center,
-- a headset button, swapping input devices).
local MIC = "$CONFIG_DIR/helpers/mic.sh"

local mic = sbar.add("item", "widgets.mic", {
  position = "right",
  update_freq = 5,
  -- Leave icon.font.family unset so it inherits sketchybar's default icon font
  -- (the same one cpu/weather/wifi glyphs use); an explicit family that isn't
  -- installed under that exact name renders as tofu.
  icon = {
    string = icons.mic.on,
    color = colors.bright_purple,
    font = { size = 20.0 },
    padding_left = 6,
    padding_right = 6,
  },
  label = {
    string = "OFF AIR",
    color = colors.bright_red,
    font = { family = font.family, style = font.style_map["Bold"], size = 20.0 },
    padding_left = 2,
    padding_right = 6,
  },
})

-- Fired by Hammerspoon's mic module (talk()/mute()) so the widget flips
-- immediately instead of waiting up to update_freq seconds for the poll.
sbar.add("event", "mic_updated")

local function render(state)
  if state == "muted" then
    mic:set({
      icon = { string = icons.mic.off, color = colors.bright_red },
      label = { string = "OFF AIR", color = colors.bright_red },
    })
  elseif state == "active" then
    mic:set({
      icon = { string = icons.mic.on, color = colors.bright_purple },
      label = { string = "ON AIR", color = colors.bright_green },
    })
  else
    -- no input device available
    mic:set({
      icon = { string = icons.mic.off, color = colors.dark4 },
      label = { string = "NO MIC", color = colors.dark4 },
    })
  end
end

local function refresh()
  sbar.exec(MIC, function(out)
    render((out or ""):gsub("%s+", ""))
  end)
end

mic:subscribe({ "routine", "forced", "system_woke" }, refresh)

-- Hammerspoon passes the new state directly for an instant flip; a bare
-- trigger with no state falls back to re-querying mic.sh.
mic:subscribe("mic_updated", function(env)
  if env.state == "active" or env.state == "muted" then
    render(env.state)
  else
    refresh()
  end
end)

mic:subscribe("mouse.clicked", function()
  sbar.exec(MIC .. " toggle", function(out)
    render((out or ""):gsub("%s+", ""))
  end)
end)

refresh()

-- Background + trailing padding, matching the other widgets.
sbar.add("bracket", "widgets.mic.bracket", { mic.name }, {
  background = { color = colors.dark1 },
})

sbar.add("item", "widgets.mic.padding", {
  position = "right",
  width = settings.group_paddings,
})
