local icons = require("icons")
local colors = require("settings").gruvbox
local font = require("settings").font
local popup_hover = require("items.widgets.popup_hover")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = {
      family = font.family,
      size = font.size
    }
  },
  label = { font = { family = font.family, size = font.size }, padding_left = 6 },
  update_freq = 180,
  popup = { align = "center", height = 30 }
})

local remaining_time = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = {
    string = "Remaining:",
    width = 110,
    align = "left"
  },
  label = {
    string = "??:??h",
    width = 170,
    align = "right"
  },
})


-- Battery details (filled from AppleSmartBattery when the popup opens).
local function detail_row(title)
  return sbar.add("item", {
    position = "popup." .. battery.name,
    icon = { string = title, width = 110, align = "left" },
    label = { string = "--", width = 170, align = "right" },
  })
end

local health_row = detail_row("Health:")
local cycles_row = detail_row("Cycles:")
local voltage_row = detail_row("Voltage:")
local adapter_row = detail_row("Adapter:")
local state_row = detail_row("State:")

local BATT_CMD = [[ioreg -rn AppleSmartBattery -w0 | grep -o -E '"(CycleCount|DesignCycleCount9C|Voltage|NominalChargeCapacity|DesignCapacity|ExternalConnected|IsCharging|Watts)"[ =]+[A-Za-z0-9]+']]

local function fill_battery_details(out)
  local v = {}
  for key, val in tostring(out):gmatch('"(%w+)"[ =]+(%w+)') do
    if v[key] == nil then v[key] = val end -- first (top-level) occurrence wins
  end
  local nominal, design = tonumber(v.NominalChargeCapacity), tonumber(v.DesignCapacity)
  local cycles, design_cycles = tonumber(v.CycleCount), tonumber(v.DesignCycleCount9C)
  local mv, watts = tonumber(v.Voltage), tonumber(v.Watts)

  health_row:set({ label = (nominal and design and design > 0) and string.format("%.0f%%", nominal / design * 100) or "--" })
  cycles_row:set({ label = cycles and (design_cycles and string.format("%d / %d", cycles, design_cycles) or tostring(cycles)) or "--" })
  voltage_row:set({ label = mv and string.format("%.1f V", mv / 1000) or "--" })
  adapter_row:set({ label = (v.ExternalConnected == "Yes" and watts) and string.format("%d W", watts) or "--" })
  local state = "On battery"
  if v.IsCharging == "Yes" then
    state = "Charging"
  elseif v.ExternalConnected == "Yes" then
    state = "AC, not charging"
  end
  state_row:set({ label = state })
end

-- Nerd Font (Material Design) glyphs, indexed by charge rounded down to 10s.
local LEVEL = {
  [10] = "\u{F007A}", [20] = "\u{F007B}", [30] = "\u{F007C}", [40] = "\u{F007D}", [50] = "\u{F007E}",
  [60] = "\u{F007F}", [70] = "\u{F0080}", [80] = "\u{F0081}", [90] = "\u{F0082}", [100] = "\u{F0079}",
}
local CHARGING = {
  [10] = "\u{F089C}", [20] = "\u{F0086}", [30] = "\u{F0087}", [40] = "\u{F0088}", [50] = "\u{F089D}",
  [60] = "\u{F0089}", [70] = "\u{F089E}", [80] = "\u{F008A}", [90] = "\u{F008B}", [100] = "\u{F0085}",
}
local PLUG = "\u{F06A5}"  -- on AC, not charging
local ALERT = "\u{F0083}" -- unknown / critically low

battery:subscribe({"routine", "power_source_change", "system_woke"}, function()
  sbar.exec("pmset -g batt", function(batt_info)
    local found, _, charge = batt_info:find("(%d+)%%")
    charge = found and tonumber(charge) or nil

    -- pmset: "...; charging; ..." / "; finishing charge;" / "; AC attached; not
    -- charging" / "; charged;" / "; discharging;". Match the charging states
    -- explicitly because "discharging" contains "charging".
    local on_ac = batt_info:find("AC Power") ~= nil
    local charging = batt_info:find("; charging;") or batt_info:find("; finishing charge;")

    local step = charge and math.max(10, math.min(100, math.floor(charge / 10) * 10)) or nil
    local icon, color = ALERT, colors.bright_red

    if charging then
      icon, color = step and CHARGING[step] or ALERT, colors.bright_purple
    elseif on_ac then
      icon, color = PLUG, colors.bright_purple
    elseif charge then
      icon = LEVEL[step]
      if charge <= 20 then
        color = colors.bright_red
      elseif charge <= 40 then
        color = colors.bright_orange
      else
        color = colors.bright_purple
      end
    end

    local lead = (charge and charge < 10) and "0" or ""
    battery:set({
      icon = { string = icon, color = color },
      label = { string = lead .. (charge and (charge .. "%") or "?") },
    })
  end)
end)

battery:subscribe("mouse.clicked", function(env)
  local drawing = battery:query().popup.drawing
  battery:set( { popup = { drawing = "toggle" } })

  if drawing == "off" then
    sbar.exec(BATT_CMD, fill_battery_details)
    sbar.exec("pmset -g batt", function(batt_info)
      local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
      local label = found and remaining .. "h" or "No estimate"
      remaining_time:set( { label = label })
    end)
  end
end)

popup_hover.attach(battery, { remaining_time, health_row, cycles_row, voltage_row, adapter_row, state_row }, function()
  battery:set({ popup = { drawing = false } })
end)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
  background = { color = colors.dark0 }
})

sbar.add("item", "widgets.battery.padding", {
  position = "right",
  width = 30,
})
