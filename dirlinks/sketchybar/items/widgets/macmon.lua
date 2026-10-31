-- Shared macmon sampler for the cpu/gpu popups (temps, fans, power, frequency,
-- per-core usage). `macmon pipe -s 1` prints one JSON sample and exits (no sudo);
-- sbar.exec decodes the JSON into a Lua table. It only runs while something is
-- watching (an open popup, or the always-on sensors widget).
local M = {}

local CMD = "/opt/homebrew/bin/macmon pipe -s 1 -i 1000 2>/dev/null"
local PERIOD = 2 -- default seconds between samples while watched

local subs = {}
local periods = {}
local busy = false

local poller = sbar.add("item", "macmon.poll", { drawing = false, updates = true, update_freq = 0 })

local function poll()
  if busy then return end
  busy = true
  sbar.exec(CMD, function(data)
    busy = false
    if type(data) ~= "table" then return end
    for _, fn in pairs(subs) do fn(data) end
  end)
end

poller:subscribe("routine", poll)

-- Poll at the fastest period any watcher asked for; stop when nobody watches.
local function retune()
  local best
  for _, p in pairs(periods) do
    best = best and math.min(best, p) or p
  end
  poller:set({ update_freq = best or 0 })
end

-- Start sampling for `owner`; fn(sample) is called with each decoded sample.
-- Calling again for the same owner replaces its fn/period.
function M.watch(owner, fn, period)
  subs[owner] = fn
  periods[owner] = period or PERIOD
  retune()
  poll()
end

-- Stop sampling for `owner`; polling stops once nobody is watching.
function M.unwatch(owner)
  subs[owner] = nil
  periods[owner] = nil
  retune()
end

local BLOCKS = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

-- Compact per-core strip: one block per core (height = active ratio), efficiency
-- cores first, then a gap, then performance cores.
function M.core_strip(sample)
  local function group(cores)
    local out = {}
    for _, c in ipairs(cores or {}) do
      local r = math.max(0, math.min(1, c.active_ratio or 0))
      out[#out + 1] = BLOCKS[math.floor(r * (#BLOCKS - 1) + 0.5) + 1]
    end
    return table.concat(out)
  end
  return group(sample.ecpu_cores) .. " " .. group(sample.pcpu_cores)
end

return M
