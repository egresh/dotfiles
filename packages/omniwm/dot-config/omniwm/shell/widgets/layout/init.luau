-- Layout mode of the current workspace (niri / dwindle), as sketchybar's mode
-- pill showed it: columns for niri, a 2x2 grid for dwindle. Click toggles the
-- workspace's layout. OmniShell gives bar widgets no layout data, so push.sh
-- (next to this file) pushes it in via `omniwmctl shell trigger layout layout
-- <niri|dwindle>`, run by the LaunchAgent local.omnishell.layout on
-- layout-changed and active-workspace events.

local look = require("../lib/look")

local MODES = {
    niri = { symbol = "rectangle.split.3x1", color = "blue", help = "Layout: niri (scrolling columns). Click for dwindle." },
    dwindle = { symbol = "square.grid.2x2", color = "purple", help = "Layout: dwindle (tiling). Click for niri." },
}

function trigger(ctx, event)
    if event.name == "layout" then
        ctx.state.layout = event.value
    end
end

function render(ctx)
    local mode = MODES[ctx.state.layout or ""]
    if not mode then
        return ui.box{ w = 0, h = 0 }
    end
    local slot = look.px(ctx, "slot")
    return ui.stack{
        w = slot, h = slot, radius = 6, hover = look.hover,
        onClick = "toggle-workspace-layout", help = mode.help,
        look.glyph{ name = mode.symbol, size = look.px(ctx, "symbol"), color = mode.color },
    }
end
