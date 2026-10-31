local settings = require("settings")
local colors = settings.colors
local font = settings.font
local popup_hover = require("items.widgets.popup_hover")
local macmon = require("items.widgets.macmon")

local popup_width = 250

-- No event-provider binary for the GPU: poll IOKit's IOAccelerator stats via
-- ioreg (no sudo). Prints lines like `"Device Utilization %"=3`.
local CMD = [[ioreg -r -d 1 -c IOAccelerator -w0 | grep -o '"[A-Za-z]* Utilization %"=[0-9]*']]

-- Bar item: graphics-card glyph + big percentage, mirroring widgets/cpu.lua. History graph
-- and renderer/tiler split live in the popup, shown on click.
local gpu = sbar.add("item", "widgets.gpu", {
  position = "right",
  update_freq = 2,
  icon = {
    string = "󰢮", -- nf-md-expansion_card
    font = { family = font.family, size = 28 },
    color = colors.magenta, -- icon stays accent; the value uses the ramp
  },
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

local history = sbar.add("graph", "widgets.gpu.history", popup_width, {
  position = "popup." .. gpu.name,
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
    position = "popup." .. gpu.name,
    icon = { align = "left", string = title, width = title_width },
    label = { string = "--", width = popup_width - title_width, align = "right" },
  })
end

local renderer_row = stat_row("Renderer:")
local tiler_row = stat_row("Tiler:")
-- macmon rows (only refreshed while the popup is open)
local freq_row = stat_row("Frequency:", 110)
local power_row = stat_row("Power:")
local temp_row = stat_row("Temp:")

gpu:subscribe({ "routine", "forced" }, function()
  sbar.exec(CMD, function(out)
    local load = tonumber(out:match('"Device Utilization %%"=(%d+)'))
    if not load then return end

    -- 4 identical points per sample = 4px per sample, so the 250px panel fills in
    -- ~2 minutes instead of ~8.
    local v = load / 100.
    history:push({ v, v, v, v })

    -- same ramp as the cpu widget
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

    gpu:set({
      label = { string = math.min(load, 99) .. "%", color = color }, -- capped to fit the fixed width
    })
    -- translucent fill: keep the rgb, force alpha to 0x99
    history:set({ graph = { color = color, fill_color = color % 0x1000000 + 0x99000000 } })
    renderer_row:set({ label = (out:match('"Renderer Utilization %%"=(%d+)') or "?") .. "%" })
    tiler_row:set({ label = (out:match('"Tiler Utilization %%"=(%d+)') or "?") .. "%" })
  end)
end)

local function show_macmon(m)
  local t = m.temp or {}
  freq_row:set({ label = m.gpu_freq_mhz and string.format("%.0f MHz", m.gpu_freq_mhz) or "--" })
  power_row:set({ label = m.gpu_power and string.format("%.2f W", m.gpu_power) or "--" })
  temp_row:set({ label = t.gpu_temp_avg and string.format("%.0f °F", t.gpu_temp_avg * 9 / 5 + 32) or "--" })
end

local function hide_popup()
  gpu:set({ popup = { drawing = false } })
  macmon.unwatch("gpu")
end

gpu:subscribe("mouse.clicked", function()
  local should_draw = gpu:query().popup.drawing == "off"
  gpu:set({ popup = { drawing = should_draw } })
  if should_draw then
    macmon.watch("gpu", show_macmon)
  else
    macmon.unwatch("gpu")
  end
end)
popup_hover.attach(gpu, { history, renderer_row, tiler_row, freq_row, power_row, temp_row }, hide_popup)

history:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the gpu item
sbar.add("bracket", "widgets.gpu.bracket", { gpu.name }, {
  background = { color = settings.gruvbox.dark1 }
})

-- Spacing after the gpu item
sbar.add("item", "widgets.gpu.padding", {
  position = "right",
  width = settings.group_paddings
})
