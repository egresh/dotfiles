-- Focused window title item. Reads TSV from wm/omniwm/commands.lua and updates
-- on omniwm_focus_change.
local colors = require("settings").gruvbox
local title_config = require("settings").title

local cmd = require("wm.omniwm.commands")

-- Terminals that may be hosting a tmux session. The window title can't be used
-- to detect tmux (WezTerm reports the cwd, e.g. "~", never "tmux..."), so ask
-- tmux directly for these apps and fall back to the app name when it says
-- nothing.
local terminal_apps = {
	WezTerm = true,
	kitty = true,
	iTerm2 = true,
	Terminal = true,
	Ghostty = true,
	Alacritty = true,
}

-- tmux_list_active_window emits one line per window, blank for inactive ones,
-- so the active name can land on any line.
local function first_nonempty_line(s)
	for line in (s or ""):gmatch("[^\n]+") do
		local trimmed = line:match("^%s*(.-)%s*$")
		if trimmed ~= "" then
			return trimmed
		end
	end
	return nil
end

local item = sbar.add("item", "title")
local generate_title

-- Parse omniwmctl "windows --focused --format tsv": a header row names the
-- columns, the data row holds the values. Look columns up by header name so
-- column order or field filtering can't break us. Returns app, title, mode
-- ("tiling" / "floating") — any of them nil if the row is missing.
local function parse_focused(tsv)
	local header, data = tsv:match("^([^\n]*)\n([^\n]+)")
	if not header or not data then
		return nil, nil, nil
	end
	local idx, dcols = {}, {}
	local i = 0
	for name in (header .. "\t"):gmatch("(.-)\t") do
		i = i + 1
		idx[name] = i
	end
	for value in (data .. "\t"):gmatch("(.-)\t") do
		dcols[#dcols + 1] = value
	end
	local app = idx.APP and dcols[idx.APP]
	local title = idx.TITLE and dcols[idx.TITLE]
	local mode = idx.MODE and dcols[idx.MODE]
	return app, title, mode
end

item:subscribe("omniwm_focus_change", function(val)
	generate_title()
end)

generate_title = function()
	sbar.exec(cmd.list_focused_window(), function(active_window)
		local app, title, mode = parse_focused(active_window)
		local floating = (mode == "floating")

		-- Floating windows aren't in the tiling column list (so `focus left/right`
		-- skip them); flag that here. Orange border + a leading marker glyph when
		-- floating; the normal green border and no glyph when tiled.
		sbar.set("title", {
			background = {
				color = title_config.background.color,
				border_color = floating and colors.bright_orange or title_config.background.border_color,
				border_width = 2,
				height = title_config.background.height,
				corner_radius = title_config.background.corner_radius,
			},
			label = {
				padding_left = 10,
				padding_right = 10,
				color = floating and colors.bright_orange or colors.bright_red,
				font = {
					family = title_config.label.family,
					size = title_config.label.size
				}
			},
		})

		local function set_label(str)
			sbar.set("title", {
				label = {
					-- \u{F2D2} = Nerd Font nf-fa-window_restore (offset "floating" windows)
				string = (floating and ("\u{F2D2}  " .. str)) or str,
				},
			})
		end

		if app and terminal_apps[app] then
			sbar.exec(cmd.tmux_current_session, function(session)
				session = first_nonempty_line(session)
				if not session then
					set_label(app)
					return
				end
				sbar.exec(cmd.tmux_list_active_window(session), function(tmux)
					local window = first_nonempty_line(tmux)
					set_label(window and (app .. " | " .. window) or app)
				end)
			end)
		else
			set_label(app or "")
		end
	end)
end

generate_title()
