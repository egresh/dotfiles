local icons = require("icons")
local settings = require("settings")
local colors = settings.gruvbox
local font = settings.font
local popup_hover = require("items.widgets.popup_hover")

local popup_width = 250

local wifi = sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  icon = { font = { size = font.size } },
  label = { drawing = false },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name,
}, {
  background = { color = colors.dark1 },
  popup = { align = "center", height = 30 }
})

local ssid = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    drawing = false,
    font = {
      style = settings.font.style_map["Bold"]
    },
    string = icons.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"]
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.gray_245,
    y_offset = -15
  }
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  }
})

local ip = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local mask = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local router = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

-- Radio details (filled from Hammerspoon's CoreWLAN wrapper when the popup opens).
local function detail_row(title, title_width)
  title_width = title_width or popup_width / 2
  return sbar.add("item", {
    position = "popup." .. wifi_bracket.name,
    icon = { align = "left", string = title, width = title_width },
    label = { string = "--", width = popup_width - title_width, align = "right" },
  })
end

local signal = detail_row("Signal:")
local snr = detail_row("SNR:")
local speed = detail_row("Link speed:")
local channel = detail_row("Channel:")
local chan_width = detail_row("Width:")
local txpower = detail_row("Tx power:")
local country = detail_row("Country:")
local mac = detail_row("MAC:", 60)
local mode = detail_row("Mode:")
local radio = detail_row("Radio:")
local detail_rows = { signal, snr, speed, channel, chan_width, txpower, country, mac, mode, radio }

-- One call returns every field joined by "|" (empty string when missing):
-- ssid|rssi|noise|rate|channel|band|width|txpower|country|mac|mode|power
local HS_WIFI = [[/opt/homebrew/bin/hs -c 'local d = hs.wifi.interfaceDetails() or {}; local c = d.wlanChannel or {}; print(table.concat({d.ssid or "", d.rssi or "", d.noise or "", d.transmitRate or "", c.number or "", c.band or "", c.width or "", d.transmitPower or "", d.countryCode or "", d.hardwareAddress or "", d.interfaceMode or "", tostring(d.power)}, "|"))' 2>/dev/null | grep -v '^-- ']]

local function fill_details(result)
  local f = {}
  for v in (tostring(result):gsub("%s+$", "") .. "|"):gmatch("([^|]*)|") do
    f[#f + 1] = v
  end
  local function val(i, fmt)
    return (f[i] and f[i] ~= "") and fmt(f[i]) or "--"
  end
  local rssi, noise, rate = tonumber(f[2]), tonumber(f[3]), tonumber(f[4])

  ssid:set({ label = (f[1] and f[1] ~= "") and f[1] or "Wi-Fi" })
  signal:set({ label = rssi and (rssi .. " dBm") or "--" })
  snr:set({ label = (rssi and noise) and ((rssi - noise) .. " dB") or "--" })
  speed:set({ label = rate and string.format("%d Mbps", rate) or "--" })
  channel:set({ label = (f[5] and f[5] ~= "") and (f[5] .. " (" .. (f[6] or "?") .. ")") or "--" })
  chan_width:set({ label = val(7, function(x) return x end) })
  txpower:set({ label = val(8, function(x) return x .. " mW" end) })
  country:set({ label = val(9, function(x) return x end) })
  mac:set({ label = val(10, function(x) return x end) })
  mode:set({ label = val(11, function(x) return x end) })
  radio:set({ label = f[12] == "true" and "On" or (f[12] == "false" and "Off" or "--") })
end

sbar.add("item", { position = "right", width = settings.group_paddings })

wifi:subscribe({"wifi_change", "system_woke"}, function(env)
  sbar.exec("ipconfig getifaddr en0", function(ip)
    local connected = not (ip == "")
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.bright_purple or colors.bright_red,
      },
    })
  end)
end)

local function hide_details()
  wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set({ popup = { drawing = true }})
    sbar.exec("networksetup -getcomputername", function(result)
      hostname:set({ label = result })
    end)
    sbar.exec("ipconfig getifaddr en0", function(result)
      ip:set({ label = result })
    end)
    -- macOS redacts the SSID for CLI tools (ipconfig/networksetup/system_profiler),
    -- so ask Hammerspoon, which has Location Services permission. `hs` also
    -- prints "-- Loading extension" lines; HS_WIFI strips them.
    sbar.exec(HS_WIFI, fill_details)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set({ label = result })
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set({ label = result })
    end)
  else
    hide_details()
  end
end

wifi:subscribe("mouse.clicked", toggle_details)
local popup_rows = { ssid, hostname, ip, mask, router }
for _, row in ipairs(detail_rows) do
  popup_rows[#popup_rows + 1] = row
end
popup_hover.attach(wifi, popup_rows, hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = icons.clipboard, align="center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

for _, row in ipairs(popup_rows) do
  row:subscribe("mouse.clicked", copy_label_to_clipboard)
end
