-- OmniWM backend loader. Registers the focus/workspace events, starts watchers
-- that fire them (killing any prior watcher so reloads don't stack), and loads
-- the title and workspace items. Loaded by wm/init.lua when OmniWM is active.
sbar.add("event", "omniwm_focus_change")
sbar.add("event", "omniwm_workspace_change")
sbar.add("event", "omniwm_layout_change")
sbar.add("event", "omniwm_windows_change")

-- Each watcher holds an IPC connection to OmniWM, so it dies whenever OmniWM
-- restarts ("Connection reset by peer") — and since it was previously spawned
-- once at config load, nothing revived it and the bar froze until the next
-- sketchybar reload. Run them under supervising loops instead so they
-- reconnect. The 2s backoff keeps them from spinning while OmniWM is down (e.g.
-- at login, when sketchybar's launchd job starts before OmniWM is up). Each
-- reconnect sends an initial event, which re-syncs. The pkill also reaps the
-- old supervisors, since their argv contains the watch command too.
local function supervise(channel, trigger)
	sbar.exec("pkill -f 'omniwmctl watch " .. channel .. "' >/dev/null 2>&1; "
		.. "nohup sh -c 'while :; do /opt/homebrew/bin/omniwmctl watch " .. channel .. " "
		.. "--exec /opt/homebrew/bin/sketchybar --trigger " .. trigger .. "; "
		.. "sleep 2; done' >/dev/null 2>&1 &")
end

supervise("focus", "omniwm_focus_change")
supervise("workspace-bar", "omniwm_workspace_change")
-- Fires when a workspace's tiling layout flips (niri <-> dwindle), e.g. via the
-- `toggle-workspace-layout` leader key. Drives the per-workspace layout tag in
-- wm/omniwm/workspaces.lua.
supervise("layout-changed", "omniwm_layout_change")
-- Fires when windows are added/removed/retiled (e.g. toggle-float). Drives the
-- standalone floating-windows section in wm/omniwm/workspaces.lua.
supervise("windows-changed", "omniwm_windows_change")

require("wm.omniwm.title")
require("wm.omniwm.workspaces")
