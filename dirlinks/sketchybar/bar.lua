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

-- OmniWM's global top outer gap ([gaps.outer] top) leaves room for the bar. The
-- built-in display has its own [[monitorGapOverrides]] entry (matched by
-- monitorDisplayUUID); keep its outerGapTop at the global value while the bar is
-- shown there and shrink it when the bar is hidden, so windows take that space.
-- OmniWM live-reloads settings.toml. Write in place (io.open follows the stow
-- symlink) and only when the value changes.
local OMNIWM_SETTINGS = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))
	.. "/omniwm/settings.toml"
local INTERNAL_OVERRIDE_ID = "B1F7A0C2-5D3E-4C8B-9A61-7E2D4F0B3C11"
local NO_BAR_TOP_GAP = 5.0

local function set_internal_top_gap(bar_on_internal)
	local f = io.open(OMNIWM_SETTINGS, "r")
	if not f then
		return
	end
	local text = f:read("a")
	f:close()

	local global_top = tonumber(text:match("%[gaps%.outer%][^%[]-\ntop = ([%d%.]+)"))
	local want = bar_on_internal and global_top or NO_BAR_TOP_GAP
	if not want then
		return
	end

	-- The override block: from its id line up to the next table header.
	local s = text:find('id = "' .. INTERNAL_OVERRIDE_ID .. '"', 1, true)
	if not s then
		return
	end
	local e = (text:find("\n%[", s) or (#text + 1)) - 1
	local block = text:sub(s, e)
	local current = tonumber(block:match("\nouterGapTop = ([%d%.]+)"))
	if current == want then
		return
	end
	local patched = block:gsub("\nouterGapTop = [%d%.]+", string.format("\nouterGapTop = %.1f", want), 1)
	f = io.open(OMNIWM_SETTINGS, "w")
	if f then
		f:write(text:sub(1, s - 1) .. patched .. text:sub(e + 1))
		f:close()
	end
end

local function update_displays()
	sbar.exec(INTERNAL_ID, function(out)
		local internal = tonumber(out)
		sbar.exec("sketchybar --query displays", function(displays)
			-- The query comes back empty while sketchybar is still loading this
			-- config (i.e. on the first run after a start or reload). Treating that
			-- as "no external display" would show the bar everywhere, so retry.
			if type(displays) ~= "table" or #displays == 0 then
				sbar.delay(1, update_displays)
				return
			end
			local external = {}
			for _, d in ipairs(displays) do
				if d.DirectDisplayID ~= internal then
					external[#external + 1] = d["arrangement-id"]
				end
			end
			-- Only the built-in left (or detection failed) -> show everywhere.
			if not internal or #external == #displays then external = {} end
			local want = #external > 0 and table.concat(external, ",") or "all"
			set_internal_top_gap(want == "all")
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
