local settings = require("settings")
local colors = settings.colors
local font = settings.font
local popup_hover = require("items.widgets.popup_hover")
local macmon = require("items.widgets.macmon")

local popup_width = 250
local IDLE_PERIOD = 5 -- seconds between samples while the popup is closed
local OPEN_PERIOD = 2

-- Glyphs that tag each temperature in the bar label (same card glyph as the
-- GPU widget).
local CHIP = "\u{F061A}" -- nf-md-chip
local CARD = "\u{F08AE}" -- nf-md-expansion_card

-- Bar: thermometer + "CPU GPU" temperatures in F (from macmon). Popup: thermal
-- state, fans and power rails. Battery details live in widgets/battery.lua.
local sensors = sbar.add("item", "widgets.sensors", {
  position = "right",
  icon = {
    string = "\u{F050F}", -- nf-md-thermometer
    font = { family = font.family, size = font.size },
    color = colors.magenta, -- icon stays accent; the value uses the ramp
  },
  label = {
    string = CHIP .. " -- " .. CARD .. " --",
    font = { family = font.family, size = font.size },
    -- Fixed width (fits "<chip> 100 <card> 100") so the widget doesn't resize as
    -- temps cross 100F; left-aligned so the numbers sit next to the icon.
    width = 150,
    align = "left",
    padding_left = 8, -- gap between the thermometer and the first glyph
    color = colors.blue,
  },
  padding_right = settings.paddings + 6,
  popup = { align = "center", height = 30 },
})

local function stat_row(title, title_width)
  title_width = title_width or popup_width / 2
  return sbar.add("item", {
    position = "popup." .. sensors.name,
    icon = { align = "left", string = title, width = title_width },
    label = { string = "--", width = popup_width - title_width, align = "right" },
  })
end

local cpu_temp_row = stat_row("CPU temp:", 120)
local gpu_temp_row = stat_row("GPU temp:", 120)
local thermal_row = stat_row("Thermal:")
local fan1_row = stat_row("Fan 1:")
local fan2_row = stat_row("Fan 2:")
local cpu_power_row = stat_row("CPU power:", 120)
local gpu_power_row = stat_row("GPU power:", 120)
local ane_power_row = stat_row("ANE power:", 120)
local ram_power_row = stat_row("RAM power:", 120)
local sys_power_row = stat_row("System:", 120)

local function f_of(c)
  return c * 9 / 5 + 32
end

local function watts(v)
  return v and string.format("%.1f W", v) or "--"
end

local function fan_label(fan)
  if not fan then return "--" end
  local rpm = fan.rpm or 0
  local pct = fan.max_rpm and fan.max_rpm > 0 and (rpm / fan.max_rpm * 100) or 0
  return string.format("%.0f rpm · %.0f%%", rpm, pct)
end

-- macmon intermittently reports a bogus ~1.6C GPU temp; keep showing the last
-- plausible reading instead of a gap.
local last_gpu_c

local function show(m)
  local t = m.temp or {}
  local cpu_c = t.cpu_temp_avg
  local gpu_c = t.gpu_temp_avg
  if gpu_c and gpu_c >= 10 then
    last_gpu_c = gpu_c
  else
    gpu_c = last_gpu_c
  end

  local hottest = math.max(cpu_c or 0, gpu_c or 0)
  local color = colors.blue
  if hottest >= 90 then
    color = colors.red
  elseif hottest >= 75 then
    color = colors.orange
  elseif hottest >= 60 then
    color = colors.yellow
  end

  sensors:set({
    label = {
      string = string.format("%s %s %s %s",
        CHIP, cpu_c and string.format("%.0f", f_of(cpu_c)) or "--",
        CARD, gpu_c and string.format("%.0f", f_of(gpu_c)) or "--"),
      color = color,
    },
  })

  cpu_temp_row:set({ label = cpu_c and string.format("%.0f °F", f_of(cpu_c)) or "--" })
  gpu_temp_row:set({ label = gpu_c and string.format("%.0f °F", f_of(gpu_c)) or "--" })

  local fans = m.fans or {}
  fan1_row:set({ label = fan_label(fans[1]) })
  fan2_row:set({ label = fan_label(fans[2]) })
  cpu_power_row:set({ label = watts(m.cpu_power) })
  gpu_power_row:set({ label = watts(m.gpu_power) })
  ane_power_row:set({ label = watts(m.ane_power) })
  ram_power_row:set({ label = watts(m.ram_power) })
  sys_power_row:set({ label = watts(m.sys_power) })
end

-- Always sampling (slowly) so the bar temperatures stay current.
macmon.watch("sensors", show, IDLE_PERIOD)

local function hide_popup()
  sensors:set({ popup = { drawing = false } })
  macmon.watch("sensors", show, IDLE_PERIOD)
end

sensors:subscribe("mouse.clicked", function()
  local should_draw = sensors:query().popup.drawing == "off"
  if not should_draw then
    hide_popup()
    return
  end
  sensors:set({ popup = { drawing = true } })
  macmon.watch("sensors", show, OPEN_PERIOD)
  sbar.exec("/opt/homebrew/bin/hs -c 'print(hs.host.thermalState())' 2>/dev/null | grep -v '^-- '", function(r)
    r = tostring(r):gsub("%s+$", "")
    thermal_row:set({ label = r ~= "" and r or "--" })
  end)
end)

popup_hover.attach(sensors, {
  cpu_temp_row, gpu_temp_row, thermal_row, fan1_row, fan2_row,
  cpu_power_row, gpu_power_row, ane_power_row, ram_power_row, sys_power_row,
}, hide_popup)

sbar.add("bracket", "widgets.sensors.bracket", { sensors.name }, {
  background = { color = settings.gruvbox.dark1 }
})

sbar.add("item", "widgets.sensors.padding", {
  position = "right",
  width = settings.group_paddings
})
