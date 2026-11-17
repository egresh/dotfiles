-- Network throughput, ported from sketchybar's widgets/network.lua: down and up
-- rates in fixed-width fields, both blue as in sketchybar; popout has
-- download/upload graphs (2 minutes, sampled here like the other metric widgets:
-- OmniShell's networkHistory isn't filled in for this widget) and, when OmniShell
-- provides them, totals. Shared pieces in lib/metrics.luau.

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

local function histories(ctx)
    local net = ctx.data.network
    return metrics.sample(ctx, { down = net and net.down, up = net and net.up })
end

function render(ctx)
    histories(ctx)
    local net = ctx.data.network
    return metrics.bar(ctx, "network", {
        { symbol = "arrow.down" },
        { text = metrics.rate(net and net.down), color = "blue", reserve = "999K" },
        { symbol = "arrow.up" },
        { text = metrics.rate(net and net.up), color = "blue", reserve = "999K" },
    }, "Network throughput")
end

function popout(ctx)
    local net = ctx.data.network
    local h = histories(ctx)
    local rows = {
        metrics.graph(h.down, peak(h.down), "blue", nil, 40),
        metrics.graph(h.up, peak(h.up), "orange", nil, 40),
        metrics.row("Download", bytes(ctx, net and net.down) .. "/s", "blue"),
        metrics.row("Upload", bytes(ctx, net and net.up) .. "/s", "orange"),
    }
    local totals = ctx.data.networkHistory
    if totals then
        rows[#rows + 1] = metrics.row("Received", bytes(ctx, totals.received))
        rows[#rows + 1] = metrics.row("Sent", bytes(ctx, totals.sent))
    end
    return metrics.popout("Network", rows)
end
