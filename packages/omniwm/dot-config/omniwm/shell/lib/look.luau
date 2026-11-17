-- User override of default/lib/look.luau: same skin, but icon sizes follow the bar.
-- Icon sizes come from the bar thickness OmniWM reports (`height` in
-- shell.toml's [workspaceBar]), so that one setting sizes every icon: workspace,
-- scratchpad and center app icons, the omniwm logo, the fullscreen marker
-- (widgets/fullscreen), the apple/app-menu buttons (lib/menu-button.luau asks for
-- the "icon" size), and the status widgets' glyphs: the "symbol" role (ported
-- metric widgets, system-stats, clock), the *Bar hooks below (volume, media,
-- control-center, wifi, battery) and the notification bell (lib/notification-style.luau).
-- Text and padding keep the look they had at a 45pt bar. Popout (dropdown) text
-- is enlarged by POPOUT_SCALE (see look.text below) and panels widened to match.
-- Required modules are read-only, so everything goes in through skin()'s
-- options rather than being patched afterwards.

local ICON_INSET = 8 -- the most an icon can take: bar height - 8 (48 -> 40px)
local SLOT_PAD = 4 -- icon cell = icon + 4: a little air round each workspace icon
local REFERENCE_HEIGHT = 45 -- sizes other than icons stay as they were at this height
-- Both scales apply to that size. ICON_SCALE: app icons ("icon": workspace,
-- scratchpad, center and app-menu icons, the fullscreen marker). SYMBOL_SCALE:
-- everything else ("symbol"/"glyph": status widget glyphs, the battery, the
-- omniwm logo), drawn smaller so they sit back from the app icons.
local ICON_SCALE = 1.0
local SYMBOL_SCALE = 0.7
-- Popout (dropdown) text size and panel width. There's no OmniShell setting for
-- it: widgets hardcode popout sizes as whole numbers (13, 11, ...), while bar
-- text is always a multiple of look.scale (18.28, ...), so look.text scales the
-- whole-number sizes. Monospaced text is left alone: the bar's count badges
-- (workspaces, scratchpads) use whole-number mono sizes too.
local POPOUT_SCALE = 1.2

local look = { capsules = true, popoutScale = POPOUT_SCALE, width = math.round(320 * POPOUT_SCALE) }

look.text = function(props)
    local size = props.size
    if size and size == math.floor(size) and props.style ~= "mono" then
        props.size = size * POPOUT_SCALE
    end
    -- the stock skin's look.text (which this replaces)
    if props.color == nil and props.role == "secondary" then
        props.color = "secondaryForeground"
    end
    props.role = nil
    return ui.text(props)
end

local function barHeight(ctx)
    local style = ctx.data.bar and ctx.data.bar.style
    return (style and style.height) or REFERENCE_HEIGHT
end

look.scale = function(ctx)
    return REFERENCE_HEIGHT / look.base
end

look.px = function(ctx, role)
    local full = barHeight(ctx) - ICON_INSET
    if role == "icon" then
        return math.max(14, math.round(full * ICON_SCALE))
    elseif role == "symbol" or role == "glyph" then -- glyph: the omniwm logo (its only user)
        return math.max(14, math.round(full * SYMBOL_SCALE))
    elseif role == "slot" then
        return math.max(16, math.round(full * ICON_SCALE) + SLOT_PAD)
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

-- OmniWM's own status widgets (volume, media, control-center, wifi, battery,
-- system-stats): these hooks rebuild each bar button in the style of the ported
-- metric widgets (lib/metrics.luau's M.bar): a "symbol"-sized glyph in the
-- metrics accent colour, values in its mono/medium value style. Each widget
-- adds its click/scroll/help behaviour to what the hook returns. On a vertical
-- bar they return nil and the widget draws its stock layout.
--
-- metrics, wifi and battery require this module, so they're loaded on first
-- use (once this module has finished loading), not at the top.
local function horizontal(ctx)
    return not ctx.data.bar.style.vertical
end

local function accent(): string
    return require("./metrics").ACCENT
end

local function glyph(ctx, name: string)
    return look.glyph{ name = name, size = look.px(ctx, "symbol"), color = accent() }
end

-- A reading as the metric widgets draw one; the colour is their lowest load step.
local function value(ctx, props)
    props.size = 13 * look.scale(ctx)
    props.weight = "medium"
    props.style = "mono"
    props.color = require("./metrics").ramp(0)
    return look.text(props)
end

local function bar(ctx, props)
    props.gap = 6 * look.scale(ctx) -- metrics.bar's spacing
    return look.bar(ctx, props)
end

look.volumeBar = function(ctx, m)
    if not horizontal(ctx) then return nil end
    local props = { glyph(ctx, m.symbol) }
    if m.volume then
        props[2] = value(ctx, { text = m.percent, reserve = ctx.format.percent(1) })
    end
    return bar(ctx, props)
end

look.mediaBar = function(ctx, m)
    if not horizontal(ctx) then return nil end
    return bar(ctx, { glyph(ctx, m.symbol), value(ctx, { text = m.title, maxWidth = 160 * look.scale(ctx) }) })
end

look.controlCenterBar = function(ctx, state)
    if not horizontal(ctx) then return nil end
    return bar(ctx, { glyph(ctx, state.symbol) })
end

look.systemStatsButton = function(ctx, g)
    if not horizontal(ctx) then return nil end
    g.color = accent() -- the widget puts the glyph in the frame returned here
    local size = look.px(ctx, "slot")
    return { w = size, h = size, radius = look.radius(6 * look.scale(ctx)), hover = look.hover }
end

look.wifiBar = function(ctx, state)
    if not horizontal(ctx) then return nil end
    local size = look.px(ctx, "symbol")
    local icon = if state.power
        then require("./wifi").fan(state.level, size, accent(), accent() .. "/0.25")
        else look.glyph{ name = "wifi.slash", size = size, color = accent() .. "/0.5" }
    return bar(ctx, { icon })
end

look.batteryDetailsBar = function(ctx, state)
    if not horizontal(ctx) then return nil end
    local battery, icon = require("./battery"), look.px(ctx, "symbol")
    -- the level fill in the accent colour; low battery keeps its warning tint
    local s = table.clone(state)
    if not s.low then
        s.tint = accent()
    end
    if s.mode == "inside" then
        return bar(ctx, { battery.cell(s, icon, icon / 2, s.text) })
    end
    local props = { battery.cell(s, icon * 23 / 30, icon * 12 / 30) } -- the stock 23x12 : 30x15 ratio
    if s.mode == "beside" then
        props[2] = value(ctx, { text = s.percent, reserve = s.reserve })
    end
    return bar(ctx, props)
end

-- Date and time as readings (the stock clock draws them white / grey). The
-- widget adds its click behaviour; the time reserves its width so the bar
-- doesn't shift as the minutes change.
look.clockBar = function(ctx, m)
    if not horizontal(ctx) then return nil end
    local props = {}
    if m.showIcon then
        props[#props + 1] = glyph(ctx, "calendar")
    end
    if m.showDate then
        props[#props + 1] = value(ctx, { text = m.date })
    end
    props[#props + 1] = value(ctx, { text = m.time, reserve = "00:00 PM" })
    return bar(ctx, props)
end

return require("./skin")(look)
