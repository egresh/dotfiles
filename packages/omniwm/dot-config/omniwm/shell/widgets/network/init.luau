-- Network throughput, ported from sketchybar's widgets/network.lua: down and up
-- rates in fixed-width fields; popout has download/upload graphs (OmniShell's
-- own networkHistory) and totals. Shared pieces in lib/metrics.luau.

interval = 2

local metrics = require("../lib/metrics")

local MIN_PEAK = 50 * 1024 -- graph scale floor, as in sketchybar

local function peak(values: { number }?): number
    local top = MIN_PEAK
    for _, v in values or {} do
        top = math.max(top, v)
    end
    return top
end

local function bytes(ctx, n: number?): string
    return if n then ctx.format.bytes(n, "file") else "--"
end

function render(ctx)
    local net = ctx.data.network
    return metrics.bar(ctx, "network", {
        { symbol = "arrow.down" },
        { text = metrics.rate(net and net.down), color = "blue", reserve = "999K" },
        { symbol = "arrow.up" },
        { text = metrics.rate(net and net.up), color = "orange", reserve = "999K" },
    }, "Network throughput")
end

function popout(ctx)
    local net = ctx.data.network
    local history = ctx.data.networkHistory
    local down = history and history.down
    local up = history and history.up
    return metrics.popout("Network", {
        metrics.graph(down, peak(down), "blue", nil, 40),
        metrics.graph(up, peak(up), "orange", nil, 40),
        metrics.row("Download", bytes(ctx, net and net.down) .. "/s", "blue"),
        metrics.row("Upload", bytes(ctx, net and net.up) .. "/s", "orange"),
        metrics.row("Received", bytes(ctx, history and history.received)),
        metrics.row("Sent", bytes(ctx, history and history.sent)),
    })
end
