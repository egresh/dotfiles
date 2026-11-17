-- GPU utilisation, ported from sketchybar's widgets/gpu.lua: percentage
-- coloured by load; popout has a 2-minute history graph, GPU name and
-- temperature. Shared pieces in lib/metrics.luau.

interval = 2

local metrics = require("../lib/metrics")

local function history(ctx)
    return metrics.sample(ctx, { gpu = ctx.data.gpu }).gpu
end

function render(ctx)
    history(ctx)
    local gpu = ctx.data.gpu
    local text = if gpu then string.format("%d%%", math.min(math.round(gpu), 99)) else "--%"
    return metrics.bar(ctx, "cube", { { text = text, color = metrics.ramp(gpu and gpu / 100), reserve = "99%" } },
        "GPU utilisation")
end

function popout(ctx)
    local gpu = ctx.data.gpu
    local thermal = ctx.data.thermal
    local temp = thermal and thermal.gpu
    local color = metrics.ramp(gpu and gpu / 100)
    local graph = metrics.graph(history(ctx), 100, color)
    graph.onClick = metrics.openActivityMonitor
    graph.help = "Open Activity Monitor"
    return metrics.popout((thermal and thermal.gpuName) or "GPU", {
        graph,
        metrics.row("Utilisation", if gpu then string.format("%d%%", math.round(gpu)) else "--", color),
        metrics.row("Temperature", metrics.fahrenheit(temp) .. " °F", metrics.heat(temp)),
    })
end
