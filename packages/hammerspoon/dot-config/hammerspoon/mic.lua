-- mic.lua — talk / mute control for the default audio input device.
--
-- macOS exposes no scriptable "input muted" flag (only output has one), so mute
-- is modelled as input volume 0 with the pre-mute level stashed for restore.
-- This mirrors sketchybar's helpers/mic.sh, which reads `input volume` on its
-- 5s poll, so the two stay in agreement no matter which one made the change.
--
-- Driven from Karabiner's m-mode via shell_command:
--   mt -> /opt/homebrew/bin/hs -c 'mic.toggle()'
--   ms -> /opt/homebrew/bin/hs -c 'mic.mute()'
-- (`mic` is exposed as a global below.)

local M = {}

local SKETCHYBAR = "/opt/homebrew/bin/sketchybar"
local RESTORE_DEFAULT = 75

-- Last known good (non-zero) input level, restored on talk().
local prevLevel = RESTORE_DEFAULT

local function device()
  return hs.audiodevice.defaultInputDevice()
end

-- Nudge the sketchybar widget so it flips instantly instead of waiting for the
-- next poll. A bare `--trigger mic_updated` also works (widget re-queries).
local function notifyBar(onAir)
  hs.execute(SKETCHYBAR .. " --trigger mic_updated state="
    .. (onAir and "active" or "muted"), false)
end

-- Bring the mic live: restore the stashed level (or a sane default).
-- Internal only for now -- reached via M.toggle(), not exposed as mic.talk().
local function talk()
  local dev = device()
  if not dev then return end
  local cur = dev:inputVolume()
  if cur and cur > 0 then prevLevel = cur end
  pcall(function() dev:setInputMuted(false) end)
  dev:setInputVolume((prevLevel and prevLevel > 0) and prevLevel or RESTORE_DEFAULT)
  notifyBar(true)
end

-- Mute: stash the current level, then zero the input.
function M.mute()
  local dev = device()
  if not dev then return end
  local cur = dev:inputVolume()
  if cur and cur > 0 then prevLevel = cur end
  pcall(function() dev:setInputMuted(true) end)
  dev:setInputVolume(0)
  notifyBar(false)
end

function M.toggle()
  local dev = device()
  if not dev then return end
  if (dev:inputVolume() or 0) > 0 then M.mute() else talk() end
end

-- Seed from the current level so the first talk() after a config reload
-- restores what you actually had, not just the default.
do
  local dev = device()
  local v = dev and dev:inputVolume()
  if v and v > 0 then prevLevel = v end
end

-- Global so `hs -c 'mic.talk()'` works from a Karabiner shell_command.
mic = M
return M
