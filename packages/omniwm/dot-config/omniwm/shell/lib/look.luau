-- User override of default/lib/look.luau: same skin, but app icons fill the bar.
-- Icon sizes come from the bar thickness OmniWM reports (`height` in
-- shell.toml's [workspaceBar]), so that one setting sizes every icon: workspace
-- and center app icons, the omniwm logo, the fullscreen marker (widgets/fullscreen),
-- and the apple/app-menu buttons (lib/menu-button.luau uses the same rule).
-- Text, symbols and padding keep the look they had at a 45pt bar.
-- Required modules are read-only, so everything goes in through skin()'s
-- options rather than being patched afterwards.

local ICON_INSET = 8 -- icon = bar height - 8 (58 -> 50px)
local SLOT_INSET = 4 -- icon cell = bar height - 4 (58 -> 54px): a little air round the icon
local REFERENCE_HEIGHT = 45 -- sizes other than icons stay as they were at this height

local look = { capsules = true }

local function barHeight(ctx)
    local style = ctx.data.bar and ctx.data.bar.style
    return (style and style.height) or REFERENCE_HEIGHT
end

look.scale = function(ctx)
    return REFERENCE_HEIGHT / look.base
end

look.px = function(ctx, role)
    if role == "icon" or role == "glyph" then -- glyph: the omniwm widget's logo (its only user)
        return math.max(14, barHeight(ctx) - ICON_INSET)
    elseif role == "slot" then
        return math.max(16, barHeight(ctx) - SLOT_INSET)
    end
    return look.size[role] * look.scale(ctx)
end

-- Center widget (default/widgets/active-window) hardcodes 18 * scale for its
-- app icon; this hook replaces its button so the icon matches.
look.activeWindowBar = function(ctx, m)
    local props = {}
    if m.showIcon then
        local icon = look.px(ctx, "icon")
        props[#props + 1] = ui.icon{ app = m.bundle, w = icon, h = icon, placeholder = "app.dashed" }
    end
    if m.showText then
        props[#props + 1] = look.text{ text = m.title, size = 13 * look.scale(ctx), weight = "medium", maxWidth = m.maxWidth }
    end
    return look.bar(ctx, props)
end

return require("./skin")(look)
