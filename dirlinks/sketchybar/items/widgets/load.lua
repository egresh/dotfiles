local settings = require("settings")
local colors = settings.colors
local font = settings.font
local popup_hover = require("items.widgets.popup_hover")

local popup_width = 250

-- Load average (1 / 5 / 15 min) from `sysctl vm.loadavg`, colour-coded against
-- the logical core count. The kernel only refreshes it every 5s, so poll at that
-- rate. Same layout as widgets/cpu.lua: big number on the bar, history graph and
-- the three averages in the popup.
local ncpu = 14 -- replaced by hw.logicalcpu below
sbar.exec("sysctl -n hw.logicalcpu", function(n)
  ncpu = tonumber(n) or ncpu
end)

local load = sbar.add("item", "widgets.load", {
  position = "right",
  update_freq = 5,
  icon = {
    string = "\u{F04C5}", -- nf-md-speedometer
    font = { family = font.family, size = font.size },
    color = colors.magenta, -- icon stays accent; the value uses the ramp
  },
  label = {
    string = "?.?",
    font = { family = font.family, size = font.size },
    -- Fixed width (fits "1.8" and "14") so the widget doesn't resize and the
    -- number sits right next to the icon.
    width = 30,
    align = "right",
    color = colors.blue,
  },
  padding_right = settings.paddings + 6,
  popup = { align = "center", height = 30 },
})

local history = sbar.add("graph", "widgets.load.history", popup_width, {
  position = "popup." .. load.name,
  width = popup_width,
  graph = { color = colors.blue, line_width = 2 },
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    height = 50,
    color = settings.gruvbox.dark0,
    border_color = settings.gruvbox.dark4,
    border_width = 1,
    corner_radius = 4,
    drawing = true,
  },
})

local function stat_row(title)
  return sbar.add("item", {
    position = "popup." .. load.name,
    icon = { align = "left", string = title, width = popup_width / 2 },
    label = { string = "--", width = popup_width / 2, align = "right" },
  })
end

local row1 = stat_row("1 min:")
local row5 = stat_row("5 min:")
local row15 = stat_row("15 min:")
local cores_row = stat_row("Cores:")

local function fmt(v)
  return v < 100 and string.format("%.1f", v) or string.format("%.0f", v)
end

-- Bar label is at most 3 chars: one decimal under 10, whole number up to 99.
local function bar_fmt(v)
  if v >= 100 then return "99+" end
  return v < 10 and string.format("%.1f", v) or string.format("%.0f", v)
end

local function refresh()
  sbar.exec("sysctl -n vm.loadavg", function(out)
    local v = {}
    for n in tostring(out):gmatch("[%d%.]+") do
      v[#v + 1] = tonumber(n)
    end
    if #v < 3 then return end

    -- graph: 1-min load as a fraction of core count (clamped at 1.0)
    local frac = v[1] / ncpu
    local p = math.min(frac, 1)
    history:push({ p, p, p, p }) -- 4px per sample

    local color = colors.blue
    if frac > 0.3 then
      if frac < 0.6 then
        color = colors.yellow
      elseif frac < 0.8 then
        color = colors.orange
      else
        color = colors.red
      end
    end

    load:set({
      label = { string = bar_fmt(v[1]), color = color },
    })
    history:set({ graph = { color = color, fill_color = color % 0x1000000 + 0x99000000 } })
    row1:set({ label = fmt(v[1]) })
    row5:set({ label = fmt(v[2]) })
    row15:set({ label = fmt(v[3]) })
    cores_row:set({ label = tostring(ncpu) })
  end)
end

load:subscribe({ "routine", "forced" }, refresh)

local function hide_popup()
  load:set({ popup = { drawing = false } })
end

load:subscribe("mouse.clicked", function()
  local should_draw = load:query().popup.drawing == "off"
  load:set({ popup = { drawing = should_draw } })
end)
popup_hover.attach(load, { history, row1, row5, row15, cores_row }, hide_popup)

history:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open -a 'Activity Monitor'")
end)

sbar.add("bracket", "widgets.load.bracket", { load.name }, {
  background = { color = settings.gruvbox.dark1 }
})

sbar.add("item", "widgets.load.padding", {
  position = "right",
  width = settings.group_paddings
})
