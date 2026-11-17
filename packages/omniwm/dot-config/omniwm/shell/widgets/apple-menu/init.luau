-- User override of default/widgets/apple-menu: the stock widget only shows while
-- the bar hides the macOS menu bar (style.hidesMenuBar); this one always shows,
-- so the Apple menu stays a click away with the bar below the menu bar too.

local button = require("../lib/menu-button")

function render(ctx: Context)
    return button.render(ctx, { symbol = "applelogo", action = "menu apple", help = omniwm.l10n("Apple Menu") })
end
