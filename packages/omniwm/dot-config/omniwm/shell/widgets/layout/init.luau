-- Layout mode of the current workspace (niri / dwindle), as sketchybar's mode
-- pill showed it: columns for niri, a 2x2 grid for dwindle. Click toggles the
-- workspace's layout. While the focused window floats, a float marker sits to
-- its left (click re-tiles the window). OmniShell gives bar widgets no layout
-- or window-mode data, so push.sh (next to this file) pushes both in via
-- `omniwmctl shell trigger layout layout <niri|dwindle>` and `... floating
-- <true|false>`, run by the LaunchAgent local.omnishell.layout on focus,
-- window, layout and active-workspace events.

local look = require("../lib/look")

local MODES = {
    niri = { symbol = "rectangle.split.3x1", color = "blue", help = "Layout: niri (scrolling columns). Click for dwindle." },
    dwindle = { symbol = "square.grid.2x2", color = "purple", help = "Layout: dwindle (tiling). Click for niri." },
}

function trigger(ctx, event)
    if event.name == "layout" then
        ctx.state.layout = event.value
    elseif event.name == "floating" then
        ctx.state.floating = (event.value == "true")
    end
end

local function button(ctx, symbol, color, onClick, help)
    local slot = look.px(ctx, "slot")
    return ui.stack{
        w = slot, h = slot, radius = 6, hover = look.hover,
        onClick = onClick, help = help,
        look.glyph{ name = symbol, size = look.px(ctx, "symbol"), color = color },
    }
end

function render(ctx)
    local mode = MODES[ctx.state.layout or ""]
    if not mode then
        return ui.box{ w = 0, h = 0 }
    end
    local layout = button(ctx, mode.symbol, mode.color, "toggle-workspace-layout", mode.help)
    if not ctx.state.floating then
        return layout
    end
    return ui.row{
        gap = 0,
        button(ctx, "macwindow.on.rectangle", "teal", "toggle-focused-window-floating",
            "Focused window is floating. Click to tile it."),
        layout,
    }
end
