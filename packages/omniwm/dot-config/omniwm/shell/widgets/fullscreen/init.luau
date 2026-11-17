-- Fullscreen marker: an orange box while the focused window is fullscreen.
-- OmniShell gives bar widgets no fullscreen data, so push.sh (next to this file)
-- pushes it in via `omniwmctl shell trigger fullscreen fullscreen true|false`.
-- push.sh runs on focus/window changes (LaunchAgent local.omnishell.fullscreen)
-- and after each fullscreen toggle (Karabiner leader-f, :omnifs), since toggles
-- emit no OmniWM event.

local look = require("../lib/look")

function trigger(ctx, event)
    if event.name == "fullscreen" then
        ctx.state.fullscreen = (event.value == "true")
    end
end

function render(ctx)
    if not ctx.state.fullscreen then
        return ui.box{ w = 0, h = 0 }
    end
    -- Same footprint as an app icon: centred in the icon cell, and drawn at the
    -- size of an app icon's visible tile (macOS icons fill ~84% of their box,
    -- the rest is transparent margin), so it doesn't look bigger than its
    -- neighbours. Sizes come from look's "icon" / "slot" (lib/look.luau).
    local icon, slot = look.px(ctx, "icon"), look.px(ctx, "slot")
    local tile = math.round(icon * 0.84)
    return ui.stack{
        w = slot, h = slot,
        help = "Focused window is fullscreen",
        ui.stack{
            w = tile, h = tile, radius = tile * 0.22, fill = "orange",
            look.glyph{ name = "arrow.up.left.and.arrow.down.right", size = tile * 0.5, color = "background" },
        },
    }
end
