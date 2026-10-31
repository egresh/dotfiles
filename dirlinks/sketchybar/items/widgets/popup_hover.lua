-- Keep a widget's popup open while the pointer is over the widget or any of its
-- popup rows, and close it shortly after the pointer leaves all of them.
-- Leaving the icon for the popup fires exited then entered within a few ms, so
-- the close is delayed and cancelled by any entered event (generation counter).
local font = require("settings").font

local M = {}

local GRACE = 0.25 -- seconds
local ROW_SIZE = 16

-- `extras` are more hover targets (e.g. sibling bar items) that keep the popup
-- open but are not restyled as popup rows.
function M.attach(parent, rows, hide, extras)
  local gen = 0

  local function entered()
    gen = gen + 1
  end

  local function exited()
    gen = gen + 1
    local mine = gen
    sbar.delay(GRACE, function()
      if mine == gen then hide() end
    end)
  end

  -- Popup rows inherit sketchybar's built-in default font (Hack 14); give them
  -- the bar's font family so dropdowns match the widgets.
  for _, row in ipairs(rows) do
    row:set({
      icon = { font = { family = font.family, size = ROW_SIZE } },
      label = { font = { family = font.family, size = ROW_SIZE } },
    })
  end

  local targets = { parent, table.unpack(rows) }
  for _, item in ipairs(extras or {}) do
    targets[#targets + 1] = item
  end

  for _, item in ipairs(targets) do
    item:subscribe("mouse.entered", entered)
    item:subscribe("mouse.exited", exited)
  end
end

return M
