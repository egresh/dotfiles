-- OmniWM backend commands.
local omniwmctl = "/opt/homebrew/bin/omniwmctl"

return {
	-- Focused window as TSV: a header row followed by one data row.
	-- wm/omniwm/title.lua parses it by column name.
	list_focused_window = function()
		return omniwmctl .. " query windows --focused --format tsv"
	end,
	-- Full workspace bar model as JSON: monitors[].workspaces[].windows[]
	-- (windows pre-grouped per app, each with appName/bundleId/isFocused).
	-- Consumed by wm/omniwm/workspaces.lua (SbarLua auto-decodes the JSON).
	list_workspace_bar = function()
		return omniwmctl .. " query workspace-bar --format json"
	end,
	-- Per-workspace tiling layout ("niri" / "dwindle"), which the workspace-bar
	-- payload doesn't carry. wm/omniwm/workspaces.lua picks the focused row to
	-- drive the standalone tiling-mode pill.
	list_workspace_layouts = function()
		return omniwmctl .. " query workspaces --fields number,layout,is-focused --format json"
	end,
	-- Focused window's fullscreen flag (the `space -> f` toggle-fullscreen state).
	-- Drives the "F" marker in wm/omniwm/workspaces.lua.
	list_focused_fullscreen = function()
		return omniwmctl .. " query windows --focused --fields is-fullscreen --format json"
	end,
	-- Floating (non-tiled) windows across all workspaces. Not carried by the
	-- workspace-bar payload, so wm/omniwm/workspaces.lua fetches it separately
	-- for the standalone floating-windows section.
	list_floating_windows = function()
		return omniwmctl .. " query windows --floating --fields app,id,is-focused --format json"
	end,
	omniwmctl = omniwmctl,
	-- tmux helpers are WM-agnostic (copied verbatim from commands.lua).
	tmux_current_session = "tmux display-message -p '#{client_session}'",
	tmux_list_active_window = function(session)
		-- Session names can contain spaces (e.g. "sesh config"), so single-quote
		-- the value and escape any embedded quotes.
		session = session:gsub("\n$", ""):gsub("'", [['\'']])
		return "tmux list-windows -t '" .. session .. "' -F '#{?window_active,#{window_name},}'"
	end,
}
