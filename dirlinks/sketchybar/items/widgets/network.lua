local settings = require("settings")
local colors = settings.colors
local font = settings.font
local popup_hover = require("items.widgets.popup_hover")

local popup_width = 250

local ARROW_DOWN = "\u{F0045}" -- nf-md-arrow_down
local ARROW_UP = "\u{F005D}"   -- nf-md-arrow_up

-- Network throughput from the network_load C helper (fires "network_update"
-- every 2s with upload/download like "012KBps"). The interface is the current
-- default route at load time (falls back to en0).
local iface = "en0"

-- Right-side items stack right-to-left in add order, so add up, down, then net
-- (the leftmost, and the one that owns the popup). Each value sits in its own
-- fixed-width, right-aligned field, so arrows and digits never move when the
-- number changes length or unit.
local VALUE_WIDTH = 54 -- fits "999K" at the bar font size

local function value_item(name, arrow, padding_right)
  return sbar.add("item", name, {
    position = "right",
    icon = {
      string = arrow,
      font = { family = font.family, size = font.size },
      color = colors.magenta,
    },
    label = {
      string = "--",
      font = { family = font.family, size = font.size },
      width = VALUE_WIDTH,
      align = "right",
      color = colors.blue,
    },
    padding_left = 0,
    padding_right = padding_right,
  })
end

local up = value_item("widgets.network.up", ARROW_UP, settings.paddings + 6)
local down = value_item("widgets.network.down", ARROW_DOWN, 12) -- gap before the up arrow

local net = sbar.add("item", "widgets.network", {
  position = "right",
  icon = {
    string = "\u{F0200}", -- nf-md-ethernet
    font = { family = font.family, size = font.size },
    color = colors.magenta,
  },
  label = { drawing = false },
  padding_right = 8, -- gap before the down arrow
  popup = { align = "center", height = 30 },
})

local function graph_item(name, color)
  return sbar.add("graph", name, popup_width, {
    position = "popup." .. net.name,
    width = popup_width,
    graph = { color = color, fill_color = color % 0x1000000 + 0x99000000, line_width = 2 },
    icon = { drawing = false },
    label = { drawing = false },
    background = {
      height = 40,
      color = settings.gruvbox.dark0,
      border_color = settings.gruvbox.dark4,
      border_width = 1,
      corner_radius = 4,
      drawing = true,
    },
  })
end

local down_graph = graph_item("widgets.network.down_graph", colors.blue)
local up_graph = graph_item("widgets.network.up_graph", colors.orange)

local function stat_row(title)
  return sbar.add("item", {
    position = "popup." .. net.name,
    icon = { align = "left", string = title, width = popup_width / 2 },
    label = { string = "--", width = popup_width / 2, align = "right" },
  })
end

local down_row = stat_row("Download:")
local up_row = stat_row("Upload:")
local iface_row = stat_row("Interface:")
local ip_row = stat_row("IP:")
local rx_row = stat_row("Received:")
local tx_row = stat_row("Sent:")

-- "012KBps" / "003MBps" / "045 Bps" -> bytes per second, compact label ("12K").
local function parse(s)
  local n, u = tostring(s):match("(%d+)%s*([KM]?)Bps")
  n = tonumber(n) or 0
  local mult = (u == "K" and 1024) or (u == "M" and 1048576) or 1
  return n * mult, n .. (u == "" and "B" or u)
end

local function human_rate(bps)
  if bps < 1024 then
    return string.format("%d B/s", bps)
  elseif bps < 1048576 then
    return string.format("%.1f KB/s", bps / 1024)
  end
  return string.format("%.1f MB/s", bps / 1048576)
end

local function human_bytes(b)
  b = tonumber(b)
  if not b then return "--" end
  if b < 1048576 then return string.format("%.0f KB", b / 1024) end
  if b < 1073741824 then return string.format("%.1f MB", b / 1048576) end
  return string.format("%.2f GB", b / 1073741824)
end

-- Graphs scale to a slowly decaying peak so quiet links still show shape.
local MIN_PEAK = 50 * 1024
local down_peak, up_peak = MIN_PEAK, MIN_PEAK

local function push(graph, value, peak)
  local p = math.min(value / peak, 1)
  graph:push({ p, p, p, p }) -- 4px per sample
end

net:subscribe("network_update", function(env)
  -- bytes/s and the compact label for each direction (don't shadow the `down` /
  -- `up` bar items)
  local down_bps, down_s = parse(env.download)
  local up_bps, up_s = parse(env.upload)

  down_peak = math.max(down_peak * 0.98, down_bps, MIN_PEAK)
  up_peak = math.max(up_peak * 0.98, up_bps, MIN_PEAK)
  push(down_graph, down_bps, down_peak)
  push(up_graph, up_bps, up_peak)

  down:set({ label = down_s })
  up:set({ label = up_s })
  down_row:set({ label = human_rate(down_bps) })
  up_row:set({ label = human_rate(up_bps) })
end)

local function hide_popup()
  net:set({ popup = { drawing = false } })
end

local function toggle_popup()
  local should_draw = net:query().popup.drawing == "off"
  net:set({ popup = { drawing = should_draw } })
  if not should_draw then return end

  iface_row:set({ label = iface })
  sbar.exec("ipconfig getifaddr " .. iface, function(r)
    r = tostring(r):gsub("%s+$", "")
    ip_row:set({ label = r ~= "" and r or "--" })
  end)
  sbar.exec("netstat -ib -I " .. iface .. " | awk 'NR==2{print $7, $10}'", function(r)
    local rx, tx = tostring(r):match("(%d+)%s+(%d+)")
    rx_row:set({ label = human_bytes(rx) })
    tx_row:set({ label = human_bytes(tx) })
  end)
end

net:subscribe("mouse.clicked", toggle_popup)
down:subscribe("mouse.clicked", toggle_popup)
up:subscribe("mouse.clicked", toggle_popup)

popup_hover.attach(net, { down_graph, up_graph, down_row, up_row, iface_row, ip_row, rx_row, tx_row }, hide_popup, { down, up })

down_graph:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open -a 'Activity Monitor'")
end)

sbar.add("bracket", "widgets.network.bracket", { net.name, down.name, up.name }, {
  background = { color = settings.gruvbox.dark1 }
})

sbar.add("item", "widgets.network.padding", {
  position = "right",
  width = settings.group_paddings
})

-- Start the helper on the default-route interface.
sbar.exec("route -n get default 2>/dev/null | awk '/interface:/{print $2}'", function(r)
  r = tostring(r):gsub("%s+$", "")
  if r ~= "" then iface = r end
  sbar.exec("killall network_load >/dev/null 2>&1; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load "
    .. iface .. " network_update 2.0")
end)
