-- User override of default/lib/notification-style.luau: the same presentation,
-- but the notifications widget's bar item matches the other status widgets
-- (see lib/look.luau): the bell is "symbol"-sized in the metric widgets' accent
-- colour, and the unread count is a reading (mono, medium, value colour).
--
-- The presentation functions get no ctx and are shared with the popout, so this
-- follows the bar render's call order (widgets/notifications render()):
--   scale(ctx) -> icon(...) -> [text{count} if there are unread items] -> bar(ctx, rows)
-- scale() notes the symbol size for icon(); icon() is only called for the bar,
-- so it marks the next text as the count; bar() clears the mark. Popout text
-- never follows an icon() and keeps the stock style.

local look = require("./look")
local metrics = require("./metrics")

local barIcon: number? = nil
local countNext = false

return require("./notification-presentation")({
    scale = function(ctx)
        barIcon = look.px(ctx, "symbol")
        return look.scale(ctx)
    end,
    icon = function(issue, size)
        countNext = true
        return ui.symbol{ name = if issue then "bell.badge" else "bell", size = barIcon or size,
            color = metrics.ACCENT }
    end,
    text = function(props)
        if countNext then
            countNext = false
            props.style = "mono"
            props.weight = "medium"
            props.color = metrics.ramp(0)
        elseif props.size and props.size == math.floor(props.size) then
            props.size = props.size * look.popoutScale -- popout text, as look.text does
        end
        return ui.text(props) -- the stock presentation's text (it isn't given look.text)
    end,
    bar = function(ctx, props)
        countNext = false
        return look.bar(ctx, props)
    end,
    hover = look.hover,
    buttonRadius = 7,
    group = look.group,
    panel = look.panel,
})
