local settings = require("settings")

local icons = {
  sf_symbols = {
    plus = "􀅼",
    loading = "􀖇",
    apple = "􀣺",
    gear = "􀍟",
    cpu = "􀫥",
    clipboard = "􀉄",

    switch = {
      on = "􁏮",
      off = "􁏯",
    },
    mic = {
      on = "􀊰",
      off = "􀊲",
    },
    volume = {
      _100="􀊩",
      _66="􀊧",
      _33="􀊥",
      _10="􀊡",
      _0="􀊣",
    },
    battery = {
      _100 = "􀛨",
      _75 = "􀺸",
      _50 = "􀺶",
      _25 = "􀛩",
      _0 = "􀛪",
      charging = "􀢋"
    },
    wifi = {
      upload = "􀄨",
      download = "􀄩",
      connected = "􀙇",
      disconnected = "􀙈",
      router = "􁓤",
    },
    weather = {
      sun = "􀆭",
      moon = "􀆹",
      partly_cloudy_day = "􀇕",
      partly_cloudy_night = "􀇖",
      cloudy = "􀇂",
      fog = "􀇍",
      drizzle = "􀇃",
      rain = "􀇄",
      sleet = "􀇆",
      snow = "􀇈",
      thunder = "􀇞",
      wind = "􀇔",
      thermometer = "􀇪",
      humidity = "􀇦",
      drop = "􀇮",
      umbrella = "􀇁",
    },
    media = {
      back = "􀊊",
      forward = "􀊌",
      play_pause = "􀊈",
    },
  },

  -- Alternative NerdFont icons
  nerdfont = {
    plus = "",
    loading = "",
    apple = "",
    gear = "",
    cpu = "",
    clipboard = "Missing Icon",
    mic = {
      on = "\u{f130}",
      off = "\u{f131}",
    },

    switch = {
      on = "󱨥",
      off = "󱨦",
    },
    volume = {
      _100="",
      _66="",
      _33="",
      _10="",
      _0="",
    },
    battery = {
      _100 = "",
      _75 = "",
      _50 = "",
      _25 = "",
      _0 = "",
      charging = "󰂈"
    },
    wifi = {
      upload = "",
      download = "",
      connected = "󰖩",
      disconnected = "󰖪",
      router = "Missing Icon"
    },
    weather = {
      sun = "󰖙",
      moon = "󰖔",
      partly_cloudy_day = "󰖕",
      partly_cloudy_night = "󰖕",
      cloudy = "󰖐",
      fog = "󰖑",
      drizzle = "󰖗",
      rain = "󰖖",
      sleet = "󰙾",
      snow = "󰖘",
      thunder = "󰖒",
      wind = "󰖝",
      thermometer = "󰔄",
      humidity = "󰓅",
      drop = "󰖌",
      umbrella = "󰖍",
    },
    media = {
      back = "",
      forward = "",
      play_pause = "",
    },
  },
}

-- if not (settings.icons == "NerdFont") then
--   return icons.sf_symbols
-- else
--   return icons.nerdfont
-- end

return icons.nerdfont
