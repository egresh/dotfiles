local icons = require("icons")
local popup_hover = require("items.widgets.popup_hover")
local settings = require("settings")
local colors = settings.gruvbox
local font = settings.font

-- Optional pinned location (US ZIP code or city name) for wttr.in. nil = the
-- default auto-detect via IP. Persisted to a file so it survives a reload.
local state_file = os.getenv("CONFIG_DIR") .. "/.weather_location"
local location = nil

local function load_location()
  local f = io.open(state_file, "r")
  if f then
    local v = f:read("*l")
    f:close()
    if v and v ~= "" then location = v end
  end
end

local function save_location(v)
  local f = io.open(state_file, "w")
  if f then
    f:write(v or "")
    f:close()
  end
end

load_location()

-- Fetch weather from wttr.in (no API key required); uses the JSON API so
-- conditions map cleanly to NerdFont icons.
local weather = sbar.add("item", "widgets.weather", {
  position = "right",
  icon = {
    string = icons.weather.sun,
    color = colors.bright_purple,
    font = {
      family = font.family,
      size = font.size,
    },
  },
  label = {
    string = "--°",
    color = colors.light0,
    padding_left = 6, -- gap between the weather icon and the temperature
    font = {
      family = font.family,
      size = font.size,
    },
  },
  popup = { align = "center" },
  update_freq = 600,
  padding_left = 1,
  padding_right = 1,
  background = { drawing = false },
})

local popup_width = 210

local condition_line = sbar.add("item", {
  position = "popup." .. weather.name,
  icon = { drawing = false },
  label = {
    string = "Updating…",
    align = "center",
    width = popup_width,
    font = {
      family = font.family,
      size = 14,
    },
  },
  background = {
    height = 26,
    color = colors.dark0,
    corner_radius = 6,
  },
})

local location_row = sbar.add("item", {
  position = "popup." .. weather.name,
  icon = {
    string = icons.weather.thermometer,
    color = colors.bright_blue,
    padding_right = 8,
    width = 20,
    align = "left",
    font = { family = font.family, size = 14 },
  },
  label = {
    string = "Set location (ZIP/city)",
    align = "right",
    width = popup_width - 30,
    font = { family = font.family, size = 14 },
  },
  background = {
    height = 1,
    color = colors.gray_245,
    y_offset = -10,
  },
})

local function format_location()
  if location then
    return "Location: " .. location
  end
  return "Location: auto"
end

location_row:subscribe("mouse.clicked", function()
  weather:set({ popup = { drawing = false } })
  -- Prompt for a ZIP or city via an async dialog; empty/auto input resets to
  -- IP auto-detect. A cancelled dialog (non-zero exit) leaves things unchanged.
  sbar.exec('osascript -e \'text returned of (display dialog "Enter a US ZIP code or city name (blank = auto-detect):" default answer "' .. (location or "") .. '" with title "Weather Location" buttons {"Cancel", "OK"} default button "OK")\'', function(result, exit_code)
    if exit_code ~= 0 then return end
    if result == "" or result == "auto" or result == nil then
      location = nil
      save_location("")
    else
      location = result
      save_location(result)
    end
    refresh()
  end)
end)

local function add_row(icon, label_id)
  return sbar.add("item", {
    position = "popup." .. weather.name,
    icon = {
      string = icon,
      color = colors.gray_245,
      padding_right = 8,
      width = 20,
      align = "left",
      font = { family = font.family, size = 14 },
    },
    label = {
      string = label_id,
      align = "right",
      width = popup_width - 30,
      max_chars = 28,
      font = { family = font.family, size = 14 },
    },
  })
end

local feels_like = add_row(icons.weather.thermometer, "--°")
local humidity = add_row(icons.weather.humidity, "--%")
local wind = add_row(icons.weather.wind, "-- mph")
local wind_gust = add_row(icons.weather.drop, "-- mph")
local uv = add_row(icons.weather.sun, "--")
local sunrise_item = add_row(icons.weather.sun, "--:--")
local sunset_item = add_row(icons.weather.moon, "--:--")

local function pick_icon(code, is_night)
  if code == "113" then return is_night and icons.weather.moon or icons.weather.sun end
  if code == "116" then return icons.weather.partly_cloudy_day end
  if code == "119" then return icons.weather.cloudy end
  if code == "122" then return icons.weather.cloudy end
  if code == "143" or code == "248" or code == "260" then return icons.weather.fog end
  if code == "176" or code == "263" or code == "266" or code == "293" or code == "296" then
    return icons.weather.drizzle
  end
  if code == "179" or code == "182" or code == "185" or code == "281" or code == "284"
    or code == "311" or code == "312" or code == "314" then
    return icons.weather.sleet
  end
  if code == "299" or code == "302" or code == "305" or code == "306"
    or code == "308" or code == "317" or code == "320" or code == "353"
    or code == "356" or code == "359" then
    return icons.weather.rain
  end
  if code == "323" or code == "326" or code == "329" or code == "332"
    or code == "335" or code == "338" or code == "350" or code == "362"
    or code == "365" or code == "368" or code == "371" or code == "374"
    or code == "377" or code == "392" or code == "395" then
    return icons.weather.snow
  end
  if code == "200" or code == "201" or code == "202" or code == "230"
    or code == "231" or code == "232" or code == "233" then
    return icons.weather.thunder
  end
  if code == "380" or code == "386" or code == "389" then return icons.weather.thunder end
  return icons.weather.sun
end

local function refresh()
  local url = "https://wttr.in/?format=j1"
  if location and location ~= "" then
    url = "https://wttr.in/" .. location .. "?format=j1"
  end

  sbar.exec('curl -s "' .. url .. '"', function(maybe_data)
    location_row:set({ label = format_location() })

    -- The JSON is auto-decoded into a table by SbarLua; a failed lookup for an
    -- unknown ZIP/city returns a non-JSON body, so guard on the type.
    local current = (type(maybe_data) == "table")
      and maybe_data.current_condition and maybe_data.current_condition[1]
    if not current then
      weather:set({ label = "??°" })
      return
    end

    local temp = tonumber(current.temp_F)
    local feels = tonumber(current.FeelsLikeF or "--")
    local hum = tonumber(current.humidity or "--")
    local wind_mph = tonumber(current.windspeedMiles or "--")
    -- current_condition has no gust; use the 3-hourly forecast slot covering now
    local hourly = maybe_data.weather and maybe_data.weather[1].hourly
    local slot = hourly and hourly[math.floor(os.date("*t").hour / 3) + 1]
    local gust_mph = slot and tonumber(slot.WindGustMiles)
    local uv_index = tonumber(current.uvIndex or "-1")

    local code = current.weatherCode
    local desc = current.weatherDesc[1].value
    -- wttr.in may omit `isday`; infer night from the observation time's AM/PM.
    local obs_time = current.observation_time or ""
    local is_night = (obs_time:match("PM") ~= nil)

    local current_icon = pick_icon(code, is_night)
    weather:set({
      icon = { string = current_icon, color = colors.bright_purple },
      label = string.format("%d°", temp),
    })
    condition_line:set({ label = desc or "Weather" })

    feels_like:set({ label = string.format("%d°", feels) })
    humidity:set({ label = string.format("%d%%", hum) })
    wind:set({ label = string.format("%d mph", wind_mph) })
    wind_gust:set({ label = gust_mph and string.format("%d mph", gust_mph) or "--" })
    uv:set({ label = uv_index >= 0 and tostring(uv_index) or "--" })

    local astro = maybe_data.weather and maybe_data.weather[1].astronomy[1]
    if astro then
      sunrise_item:set({ label = astro.sunrise })
      sunset_item:set({ label = astro.sunset })
    end
  end)
end

weather:subscribe({ "routine", "forced", "system_woke" }, refresh)

weather:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("open 'https://wttr.in/'")
    return
  end
  local drawing = weather:query().popup.drawing
  weather:set({ popup = { drawing = "toggle" } })
  if drawing == "off" then
    refresh()
  end
end)

popup_hover.attach(weather, {
  condition_line, location_row, feels_like, humidity, wind, wind_gust, uv, sunrise_item, sunset_item,
}, function()
  weather:set({ popup = { drawing = false } })
end)

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
  background = { drawing = false },
  popup = { align = "center", height = 30 },
})

sbar.add("item", "widgets.weather.padding", {
  position = "right",
  width = settings.group_paddings,
})
