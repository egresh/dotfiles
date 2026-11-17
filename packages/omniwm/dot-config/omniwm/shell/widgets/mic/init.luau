-- Microphone on/off-air toggle, ported from sketchybar's widgets.mic. OmniShell
-- feeds the default input device live (ctx.data.microphone: volume 0-100 and,
-- when the device has one, a hardware mute), so there's no polling or push.
--
-- "Off air" is volume 0 or muted, the same model as Hammerspoon's mic.lua
-- (Karabiner m-mode t / s), so either side can flip it. Muting stashes the
-- level and zeroes it (plus the hardware mute); unmuting clears the mute and
-- restores the stashed level.

local look = require("../lib/look")
local metrics = require("../lib/metrics")

local STORE_KEY = "mic.level"
local RESTORE_DEFAULT = 75

local function model(ctx)
    local mic = ctx.data.microphone
    if not mic or not mic.volume then
        return nil
    end
    return { volume = mic.volume, muted = mic.muted, live = mic.volume > 0 and mic.muted ~= true }
end

local function toggle(ctx)
    local m = model(ctx)
    if not m then
        return
    end
    if m.live then
        omniwm.store.set(STORE_KEY, m.volume)
        omniwm.run("microphone set 0")
        if m.muted == false then
            omniwm.run("microphone mute") -- a toggle, like `volume mute`
        end
    else
        if m.muted then
            omniwm.run("microphone mute")
        end
        local level = if m.volume > 0 then m.volume else tonumber(omniwm.store.get(STORE_KEY))
        if not level or level <= 0 then
            level = RESTORE_DEFAULT
        end
        omniwm.run(string.format("microphone set %d", level))
    end
end

function render(ctx)
    local m = model(ctx)
    local scale = look.scale(ctx)
    local symbol, tint, label, labelColor
    if not m then
        symbol, tint, label, labelColor = "mic.slash", "secondaryForeground", "NO MIC", "secondaryForeground"
    elseif m.live then
        symbol, tint, label, labelColor = "mic.fill", metrics.ACCENT, "ON AIR", "green"
    else
        symbol, tint, label, labelColor = "mic.slash.fill", "red", "OFF AIR", "red"
    end
    return look.bar(ctx, {
        gap = 6 * scale, onClick = toggle,
        help = if m then (if m.live then "Microphone live. Click to mute." else "Microphone muted. Click to talk.")
            else "No input device",
        look.glyph{ name = symbol, size = look.px(ctx, "symbol"), color = tint },
        look.text{ text = label, size = 13 * scale, weight = "bold", style = "mono", color = labelColor,
            reserve = "OFF AIR" },
    })
end
