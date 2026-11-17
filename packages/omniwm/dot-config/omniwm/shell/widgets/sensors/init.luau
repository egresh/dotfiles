-- CPU and GPU temperatures in °F, ported from sketchybar's widgets/sensors.lua,
-- coloured by the hotter of the two; popout has a history graph of both.
-- (No fans or power rails: OmniShell doesn't provide them.) Shared pieces in
-- lib/metrics.luau.

interval = 2

local metrics = require("../lib/metrics")

local TOP = 110 -- graph scale, °C

local function histories(ctx)
    local thermal = ctx.data.thermal or {}
    return metrics.sample(ctx, { cpu = thermal.cpu, gpu = thermal.gpu })
end

function render(ctx)
    histories(ctx)
    local thermal = ctx.data.thermal or {}
    local color = metrics.heat(math.max(thermal.cpu or 0, thermal.gpu or 0))
    return metrics.bar(ctx, "thermometer.medium", {
        { symbol = "cpu" },
        { text = metrics.fahrenheit(thermal.cpu), color = color, reserve = "199" },
        { symbol = "cube" },
        { text = metrics.fahrenheit(thermal.gpu), color = color, reserve = "199" },
    }, "CPU / GPU temperature")
end

function popout(ctx)
    local thermal = ctx.data.thermal or {}
    local h = histories(ctx)
    return metrics.popout("Temperatures", {
        metrics.graph(h.cpu, TOP, metrics.heat(thermal.cpu), nil, 40),
        metrics.graph(h.gpu, TOP, metrics.heat(thermal.gpu), nil, 40),
        metrics.row("CPU", metrics.fahrenheit(thermal.cpu) .. " °F", metrics.heat(thermal.cpu)),
        metrics.row(thermal.gpuName or "GPU", metrics.fahrenheit(thermal.gpu) .. " °F", metrics.heat(thermal.gpu)),
    })
end
