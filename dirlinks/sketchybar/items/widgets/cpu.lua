local icons = require("icons")
local settings = require("settings")
local colors = settings.colors
local font = settings.font
local popup_hover = require("items.widgets.popup_hover")
local macmon = require("items.widgets.macmon")

local popup_width = 250

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

-- Bar item: icon + big percentage (same size as battery). The history graph and
-- user/sys split live in the popup, shown on click.
local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  icon = { string = icons.cpu, color = colors.magenta, font = { size = font.size } }, -- icon stays accent; the number uses the load ramp
  label = {
    string = "??%",
    font = { family = font.family, size = font.size },
    -- Fixed width (fits "99%") so the widget doesn't resize as digits change.
    width = 40,
    align = "right",
    color = colors.blue,
  },
  padding_right = settings.paddings + 6,
  popup = { align = "center", height = 30 },
})

local history = sbar.add("graph", "widgets.cpu.history", popup_width, {
  position = "popup." .. cpu.name,
  width = popup_width,
  graph = { color = colors.blue, line_width = 2 },
  icon = { drawing = false },
  label = { drawing = false },
  -- Solid inset panel (tinty base00 / base03) so the trace stands out from the
  -- popup fill.
  background = {
    height = 50,
    color = settings.gruvbox.dark0,
    border_color = settings.gruvbox.dark4,
    border_width = 1,
    corner_radius = 4,
    drawing = true,
  },
})

local function stat_row(title, title_width)
  title_width = title_width or popup_width / 2
  return sbar.add("item", {
    position = "popup." .. cpu.name,
    icon = { align = "left", string = title, width = title_width },
    label = { string = "--", width = popup_width - title_width, align = "right" },
  })
end

local user_row = stat_row("User:")
local sys_row = stat_row("System:")
-- macmon rows (only refreshed while the popup is open)
local ecores_row = stat_row("E-cores:", 90)
local pcores_row = stat_row("P-cores:", 90)
local strip_row = stat_row("Cores:", 60)
local power_row = stat_row("Power:")
local temp_row = stat_row("Temp:")
local fans_row = stat_row("Fans:")
local sys_power_row = stat_row("Sys power:", 110)

cpu:subscribe("cpu_update", function(env)
  local load = tonumber(env.total_load)
  -- 4 identical points per sample = 4px per sample, so the 250px panel fills in
  -- ~2 minutes instead of ~8.
  local v = load / 100.
  history:push({ v, v, v, v })

  local color = colors.blue
  if load > 30 then
    if load < 60 then
      color = colors.yellow
    elseif load < 80 then
      color = colors.orange
    else
      color = colors.red
    end
  end

  cpu:set({
    label = { string = math.min(load, 99) .. "%", color = color }, -- capped to fit the fixed width
  })
  -- translucent fill: keep the rgb, force alpha to 0x99
  history:set({ graph = { color = color, fill_color = color % 0x1000000 + 0x99000000 } })
  user_row:set({ label = tonumber(env.user_load) .. "%" })
  sys_row:set({ label = tonumber(env.sys_load) .. "%" })
end)

local function fmt(v, f)
  return v and string.format(f, v) or "--"
end

local function show_macmon(m)
  local t = m.temp or {}
  local fans = {}
  for _, fan in ipairs(m.fans or {}) do
    fans[#fans + 1] = string.format("%.0f", fan.rpm or 0)
  end
  ecores_row:set({ label = string.format("%.0f MHz · %.0f%%", m.ecpu_freq_mhz or 0, (m.ecpu_active_ratio or 0) * 100) })
  pcores_row:set({ label = string.format("%.0f MHz · %.0f%%", m.pcpu_freq_mhz or 0, (m.pcpu_active_ratio or 0) * 100) })
  strip_row:set({ label = macmon.core_strip(m) })
  power_row:set({ label = fmt(m.cpu_power, "%.1f W") })
  temp_row:set({ label = t.cpu_temp_avg and string.format("%.0f °F", t.cpu_temp_avg * 9 / 5 + 32) or "--" })
  fans_row:set({ label = #fans > 0 and (table.concat(fans, " / ") .. " rpm") or "--" })
  sys_power_row:set({ label = fmt(m.sys_power, "%.1f W") })
end

local function hide_popup()
  cpu:set({ popup = { drawing = false } })
  macmon.unwatch("cpu")
end

cpu:subscribe("mouse.clicked", function()
  local should_draw = cpu:query().popup.drawing == "off"
  cpu:set({ popup = { drawing = should_draw } })
  if should_draw then
    macmon.watch("cpu", show_macmon)
  else
    macmon.unwatch("cpu")
  end
end)
popup_hover.attach(cpu, {
  history, user_row, sys_row,
  ecores_row, pcores_row, strip_row, power_row, temp_row, fans_row, sys_power_row,
}, hide_popup)
-- The block glyphs are wide (~15px each at 16pt); shrink the strip so 15 cores
-- fit its slot. Set after attach(), which applies the shared row font size.
strip_row:set({ label = { font = { family = font.family, size = 12 } } })

history:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { color = settings.gruvbox.dark1 }
})

-- Spacing after the cpu item
sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})
