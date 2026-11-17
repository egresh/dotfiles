-- User override of default/lib/menu-button.luau (apple-menu and app-menu
-- buttons). The default caps the icon at 24px; here sizes come from lib/look.luau
-- (following the bar height): an app icon (app-menu) is "icon"-sized like the
-- workspace icons, a symbol (the Apple logo) "symbol"-sized like the omniwm logo
-- and status glyphs.

local look = require("./look")

local button = {}

function button.render(ctx: Context, props)
    local style = ctx.data.bar.style
    local size = look.px(ctx, "slot") -- the workspace icon cell, so spacing matches
    local icon = look.px(ctx, if props.symbol then "symbol" else "icon")
    local capsule = style.transparent and style.backgrounds
    local foreground = style.solidBlack and "#FFFFFF" or "foreground"
    local image = if props.symbol then ui.symbol{ name = props.symbol, size = icon, w = icon, h = icon, color = foreground }
        else ui.icon{ app = props.app, pid = props.pid, w = icon, h = icon, placeholder = "app.dashed" }
    return ui.stack{ w = size, h = size, onClick = props.action, help = props.help,
        radius = if capsule then size / 2 else 4, hover = if style.solidBlack then "#FFFFFF1F" else "foreground/0.12",
        image }
end

return button
