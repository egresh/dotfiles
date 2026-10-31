local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar(settings.bar)

-- Equivalent to the --default domain: every item added afterwards inherits this
-- popup background, so all the click-through dropdowns (cpu / weather / wifi /
-- battery / …) get a solid, readable panel behind their text.
sbar.default({
	popup = settings.popup,
})

-- Hide the bar on the built-in display while an external monitor is also active.
-- Alone (or in clamshell), the built-in/only display keeps the bar.
local current
local INTERNAL_ID = [[system_profiler SPDisplaysDataType -json 2>/dev/null | grep -B10 spdisplays_internal | grep displayID | grep -o '[0-9]\+' | tail -1]]

local function update_displays()
	sbar.exec(INTERNAL_ID, function(out)
		local internal = tonumber(out)
		sbar.exec("sketchybar --query displays", function(displays)
			local external = {}
			for _, d in ipairs(type(displays) == "table" and displays or {}) do
				if d.DirectDisplayID ~= internal then
					external[#external + 1] = d["arrangement-id"]
				end
			end
			-- Only the built-in left (or detection failed) -> show everywhere.
			if not internal or #external == #displays then external = {} end
			local want = #external > 0 and table.concat(external, ",") or "all"
			-- Setting the bar's display fires display_change again; only act on a change.
			if want ~= current then
				current = want
				sbar.bar({ display = want })
			end
		end)
	end)
end

update_displays()
sbar.add("item", "display_watcher", { drawing = false })
	:subscribe({ "display_change", "display_added", "display_removed", "system_woke" }, update_displays)
