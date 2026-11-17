-- CPU load, ported from sketchybar's widgets/cpu.lua: percentage coloured by
-- load; popout has a 2-minute history graph and temperature. Click the graph for
-- Activity Monitor. Shared pieces in lib/metrics.luau.

interval = 2

local metrics = require("../lib/metrics")

local function history(ctx)
    return metrics.sample(ctx, { cpu = ctx.data.cpu }).cpu
end

function render(ctx)
    history(ctx)
    local cpu = ctx.data.cpu
    local text = if cpu then string.format("%d%%", math.min(math.round(cpu), 99)) else "--%"
    return metrics.bar(ctx, "cpu", { { text = text, color = metrics.ramp(cpu and cpu / 100), reserve = "99%" } },
        "CPU load")
end

function popout(ctx)
    local cpu = ctx.data.cpu
    local thermal = ctx.data.thermal
    local temp = thermal and thermal.cpu
    local color = metrics.ramp(cpu and cpu / 100)
    local graph = metrics.graph(history(ctx), 100, color)
    graph.onClick = metrics.openActivityMonitor
    graph.help = "Open Activity Monitor"
    return metrics.popout("CPU", {
        graph,
        metrics.row("Load", if cpu then string.format("%d%%", math.round(cpu)) else "--", color),
        metrics.row("Temperature", metrics.fahrenheit(temp) .. " °F", metrics.heat(temp)),
    })
end
