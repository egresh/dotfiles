-- Shared pieces for the metric widgets (widgets/cpu, gpu, network, sensors),
-- ported from sketchybar (dirlinks/sketchybar/items/widgets). Bar item: accent
-- glyph + value coloured by load; click opens a popout with a history graph and
-- detail rows. Data comes from OmniShell (ctx.data), so there is no load average
-- and none of sketchybar's macmon detail (per-core, fans, power).

local look = require("./look")

local M = {}

M.ACCENT = "purple" -- glyph colour (sketchybar's magenta)
M.PERIOD = 2 -- seconds between history samples
M.SAMPLES = 60 -- 2 minutes of history at PERIOD
M.WIDTH = 250 -- popout content width
M.GRAPH = 50 -- popout graph height

-- Load ramp: fraction 0..1 -> colour (same thresholds as sketchybar).
function M.ramp(fraction: number?): string
    if not fraction or fraction <= 0.3 then
        return "blue"
    elseif fraction < 0.6 then
        return "yellow"
    elseif fraction < 0.8 then
        return "orange"
    end
    return "red"
end

-- Temperature ramp in °C (sensors widget thresholds).
function M.heat(celsius: number?): string
    if not celsius or celsius < 60 then
        return "blue"
    elseif celsius < 75 then
        return "yellow"
    elseif celsius < 90 then
        return "orange"
    end
    return "red"
end

function M.fahrenheit(celsius: number?): string
    return if celsius then string.format("%.0f", celsius * 9 / 5 + 32) else "--"
end

-- Bytes/s, at most 4 characters: "999B", "12K", "1.5M".
function M.rate(bps: number?): string
    bps = math.max(0, bps or 0)
    if bps < 1000 then
        return string.format("%dB", math.floor(bps))
    elseif bps < 1024 * 1000 then
        return string.format("%dK", math.floor(bps / 1024))
    end
    local mb = bps / 1048576
    return if mb < 10 then string.format("%.1fM", mb) else string.format("%dM", math.floor(mb))
end

-- Append the current values to ctx.state histories, at most once per PERIOD
-- (render also runs on hover, clicks and data changes). `values` maps a
-- history name to a number or nil (nil is skipped).
function M.sample(ctx, values: { [string]: number? })
    local state = ctx.state
    local now = math.floor(ctx.data.seconds or 0)
    state.histories = state.histories or {}
    if state.sampledAt and now - state.sampledAt < M.PERIOD then
        return state.histories
    end
    state.sampledAt = now
    for name, value in values do
        local list = state.histories[name] or {}
        state.histories[name] = list
        list[#list + 1] = value
        if #list > M.SAMPLES then
            table.remove(list, 1)
        end
    end
    return state.histories
end

-- Area graph of `values` scaled to `top`, on an inset panel. Fixed window of
-- SAMPLES points so it fills from the right like sketchybar's.
function M.graph(values: { number }?, top: number, color: string, w: number?, h: number?)
    w = w or M.WIDTH
    h = h or M.GRAPH
    local panel = { w = w, h = h, radius = 4, fill = "background", border = "border", borderWidth = 1 }
    values = values or {}
    if #values >= 2 then
        local span = M.SAMPLES - 1
        local first = span - (#values - 1)
        local line = table.create(#values)
        for index, value in values do
            local y = 100 - math.clamp(value / top, 0, 1) * 100
            line[index] = string.format("%s%d %.1f", if index == 1 then "M" else "L", first + index - 1, y)
        end
        local stroke = table.concat(line, " ")
        local box = { 0, -4, span, 108 }
        panel[1] = ui.path{ w = w, h = h, viewBox = box, fill = color .. "/0.6",
            d = stroke .. string.format(" L%d 104 L%d 104 Z", span, first) }
        panel[2] = ui.path{ w = w, h = h, viewBox = box, d = stroke, border = color, borderWidth = 2 }
    end
    return ui.stack(panel)
end

-- "Label        value" row for the popout.
function M.row(label: string, value: string, color: string?)
    return ui.row{ w = M.WIDTH, gap = 8,
        look.text{ text = label, size = 13, grow = 1, role = "secondary" },
        look.text{ text = value, size = 13, weight = "medium", color = color } }
end

-- Popout wrapper: heading, then the given children.
function M.popout(title: string, children: { any })
    local props = { w = M.WIDTH + 32, pad = 16, gap = 10, center = false, look.heading(title, M.WIDTH) }
    for _, child in children do
        props[#props + 1] = child
    end
    return ui.column(props)
end

-- Bar item: accent glyph, then reading(s) as { text, color, reserve } tables.
function M.bar(ctx, symbol: string, readings: { any }, help: string)
    local scale = look.scale(ctx)
    local props = { gap = 6 * scale, onClick = ui.popout, help = help,
        look.glyph{ name = symbol, size = look.px(ctx, "symbol"), color = M.ACCENT } }
    for _, r in readings do
        if r.symbol then
            props[#props + 1] = look.glyph{ name = r.symbol, size = 11 * scale, color = M.ACCENT }
        else
            props[#props + 1] = look.text{ text = r.text, size = 13 * scale, weight = "medium", style = "mono",
                color = r.color, reserve = r.reserve }
        end
    end
    return look.bar(ctx, props)
end

function M.openActivityMonitor()
    omniwm.run("open -a 'Activity Monitor'")
end

return M
