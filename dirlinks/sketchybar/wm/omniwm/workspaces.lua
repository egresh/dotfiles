-- OmniWM workspace bar for sketchybar.
--
-- Reproduces (and replaces) OmniWM's native workspace bar: one bracket per
-- workspace, butted together with overlapping side borders so the run reads as
-- one strip with dividers. Each workspace is a number chip followed by an
-- app-icon glyph for each distinct app with a window there. Each glyph is tinted to its
-- app's real icon color (helpers/app_color.sh); glyphs on background
-- workspaces are dimmed, and the focused app gets a filled pill.
--
-- Trailing the workspaces are two standalone pills: the tiling-mode pill (the
-- focused workspace's niri/dwindle layout) and the scratchpad pill (an app
-- glyph per assigned scratchpad window; shown-scratchpad glyphs get the filled
-- pill, hidden ones are dimmed). Both hide when they have nothing to show.
--
-- Data source: `omniwmctl query workspace-bar --format json` (SbarLua's
-- sbar.exec auto-decodes the JSON into a Lua table). Refreshed on the
-- `omniwm_workspace_change` event (fired by the `omniwmctl watch workspace-bar`
-- supervisor in wm/omniwm/init.lua) and on `omniwm_focus_change` so the
-- active-app highlight tracks focus promptly.
--
-- Loaded by wm/omniwm/init.lua.

local cmd = require("wm.omniwm.commands")
local icon_map = require("icon_map")
local colors = require("settings").gruvbox
local with_alpha = require("settings").colors.with_alpha

local omniwmctl = cmd.omniwmctl

-- Fixed pool of pre-created item slots. Workspaces/apps beyond these caps are
-- not shown (OmniWM is niri-style: rarely more than a handful of either).
local MAX_WS = 10
local MAX_APPS = 12
local MAX_SCR = 8 -- app glyphs shown in the scratchpad pill
local MAX_FLT = 8 -- app glyphs shown in the floating-windows pill

-- ---- styling (kept here, not settings.lua, so the bar is tweakable in one
-- ---- file while iterating) ----
-- Sizes mirror the apple / iStat / title sections (settings.lua: height 45,
-- border 2, corner 5, font ~20) so the workspace block matches the rest of the
-- bar rather than sitting shorter.
local style = {
	bar_height = 45,
	corner_radius = 5,
	border_width = 2,
	-- Per-workspace brackets, butted together (ws_gap 0) with square corners and
	-- a border-width negative left inset (ws_overlap) so each bracket's left
	-- border lands on the previous one's right border: the run reads as one
	-- strip with a single divider line between workspaces. The focused workspace
	-- gets the accent border (same colour as the mode pill); the rest are muted.
	ws_focused_border = colors.bright_yellow,
	ws_border = colors.dark3,
	ws_focused_bg = colors.transparent, -- unused (fill stays transparent)
	ws_bg = colors.transparent,
	ws_corner_radius = 0, -- square, so the internal dividers are straight
	ws_overlap = -2, -- = -border_width; collapses adjacent side borders into one
	num_focused = colors.bright_yellow,
	num_idle = colors.light4,
	-- Each workspace number sits in its own outlined chip, nested inside the
	-- bracket that groups the number with its app glyphs.
	num_box_border = colors.dark4,
	num_box_focused_border = colors.bright_yellow,
	num_box_bg = colors.transparent,
	num_box_focused_bg = colors.transparent,
	-- Gap between the number box and the first app. It's a standalone spacer
	-- (not glyph padding) so the focused app's pill — which fills the glyph
	-- item's box — starts clear of the number box instead of hard against it.
	num_app_gap = 9,
	-- First app glyph keeps the same left pad as the rest now that num_app_gap
	-- provides the separation.
	first_app_pad_left = 4,
	app_font = "sketchybar-app-font:Regular:22.0",
	num_font = "ShureTechMono Nerd Font:Bold:20.0",
	-- Standalone tiling-mode section: one pill sitting between the iStat menus
	-- and workspace 1, showing the *focused* workspace's layout as a single
	-- Nerd Font glyph — fa-columns (U+F0DB) for niri (scrollable columns),
	-- fa-th-large (U+F009) for dwindle (binary split) — tinted per mode. Click
	-- toggles the layout.
	mode_font = "ShureTechMono Nerd Font:Regular:26.0", -- family:style:size (style required or size falls back to 10)
	mode_gap = 0, -- mode pill butts directly against workspace 1
	mode_border = colors.bright_yellow, -- matches the active workspace border (ws_focused_border)
	-- Fixed icon cell so the pill doesn't resize when the glyph changes on
	-- toggle. layout_pad_left nudges the (center-aligned) glyph right off the
	-- cell's left edge; bump per-glyph if one looks off.
	mode_icon_width = 26,
	mode_pad_left = 6, -- inner pad, left of the glyph
	mode_pad_right = 6, -- inner pad, right of the glyph (kept +2 vs left so the
	-- fixed-width pill is unchanged and the glyph just sits 2px further left)
	layout_tags = {
		niri = "\u{f0db}",
		dwindle = "\u{f009}",
	},
	layout_y_offset = {
		niri = 0,
		dwindle = 0,
	},
	layout_pad_left = { -- extra left padding inside the icon cell, per glyph
		niri = 1,
		dwindle = 1,
	},
	layout_colors = {
		niri = colors.bright_blue,
		dwindle = colors.bright_purple,
	},
	fallback_glyph = icon_map["Default"] or ":default:",
	-- App-name -> glyph fixups for apps missing from the vendored icon_map.lua
	-- (kept here so a font/icon_map update won't clobber them).
	glyph_override = {
		ovim = ":neovim:", -- Neovim GUI; icon_map only knows "Neovim"/"nvim"
	},
	-- Glyphs are tinted to their app's real icon color (helpers/app_color.sh);
	-- apps whose icon has no vivid color fall back to this.
	app_fallback_color = colors.light1,
	-- Empty space between the iStat section and the tiling-mode pill. Kept equal
	-- to aliases.lua's istat_spacer (apple -> iStat) so bar spacing is uniform.
	lead_gap = 18,
	-- Fullscreen marker: a filled yellow box in the lead gap, shown while the
	-- focused window is fullscreen. Preview icons with bin/fs-icon-preview.
	fs_icon = "\u{f0293}", -- nf-md-fullscreen
	fs_font = "ShureTechMono Nerd Font:Regular:24.0", -- Regular: no Bold face is installed
	fs_pad_left = 6, -- air between the iStat items and the box
	fs_width = 30, -- box width; the glyph is centred in it
	-- Follows tinty. base09 (bright_orange) rather than base0A (bright_yellow):
	-- the box is the only amber element, and in schemes like base16-isotope
	-- base0A is pink while base09 is amber — the closest slot to yellow there.
	fs_color = colors.bright_orange,
	fs_fg = colors.dark0, -- base00: contrast glyph on the fill
	-- Gap between adjacent workspace brackets. 0 so they butt together; the
	-- overlap that fuses their borders is ws_overlap above.
	ws_gap = 0,
	-- Glyph brightness tiers (0..1 blend toward white; sampled icon colors run
	-- dark). Background/hidden < active-workspace non-focused < focused.
	-- Non-focused glyphs on the *active* workspace.
	app_active_brighten = 0.32,
	-- Background (non-active) workspace glyphs, and hidden scratchpad glyphs:
	-- lifted a little and only mildly see-through, so they still read clearly —
	-- but kept below the active workspace's brightness / full alpha.
	app_bg_brighten = 0.30,
	app_bg_alpha = 0.62,
	-- Focused app: brighten its glyph further and wrap it in a thin outlined pill.
	app_focus_brighten = 0.75, -- 0..1 blend toward white; kept well above app_active_brighten so the focused glyph pops
	app_pill_alpha = 0.42, -- fill behind the focused app's glyph
	app_pill_border_alpha = 1.0, -- outline of that pill (already maxed at 1.0)
	app_pill_border_width = 2, -- focused-app pill outline thickness
	app_edge_pad = 5, -- breathing room inside the bracket, right of the last glyph
	-- Standalone scratchpad section: one pill after the mode pill listing every
	-- assigned scratchpad window as an app-icon glyph (tinted to the app's real
	-- colour, like the workspace glyphs). A scratchpad that's currently shown
	-- (isVisible) gets the bright glyph + filled pill; a hidden one is dimmed.
	-- Click toggles that scratchpad. The whole section hides when none exist.
	-- Leading gap before the scratchpad pill. 0 so it butts directly against the
	-- last workspace, like the workspaces do with each other.
	scr_gap = 0,
	scr_end_gap = 18, -- gap after the scratchpad pill, before the window-title section; matches the 18px gap unit used between other left-side sections
	scr_border = colors.dark3, -- same muted outline as an inactive workspace
	-- Leading marker so the pill reads as "stashed apps" rather than more
	-- workspace glyphs. nf-fa-bars (U+F0C9) — three equal bars — from the same
	-- ShureTechMono Nerd Font as the numbers, so no extra font is needed.
	scr_marker = "\u{f0c9}",
	scr_marker_font = "ShureTechMono Nerd Font:Regular:20.0", -- Regular: no Bold weight installed
	scr_marker_y_offset = 0,
	-- Standalone floating-windows section: same shape as the scratchpad pill, one
	-- app glyph per floating (non-tiled) window across all workspaces. Marker is
	-- nf-fa-window-restore (also used by title.lua to flag a floating window).
	flt_border = colors.dark3, -- muted, like an inactive workspace / scratchpad
	flt_marker = "\u{f2d2}",
	flt_marker_font = "ShureTechMono Nerd Font:Regular:20.0",
	flt_marker_y_offset = 0,
	flt_gap = 0, -- butts against the scratchpad pill (or last workspace)
}

-- ---- deterministic item names ----
local function num_name(n)
	return "omni.ws." .. n
end
local function app_name(n, i)
	return "omni.ws." .. n .. ".app." .. i
end
local function bracket_name(n)
	return "omni.ws." .. n .. ".br"
end
local function spacer_name(n)
	return "omni.ws." .. n .. ".sp"
end
local function tail_name(n)
	return "omni.ws." .. n .. ".tail"
end
-- Spacer between the number box and the first app glyph.
local function numpad_name(n)
	return "omni.ws." .. n .. ".numpad"
end
-- Empty spacer that sits between the iStat section and workspace 1.
local LEAD_NAME = "omni.ws.lead"
-- Standalone tiling-mode section (after the last workspace, before the title).
local MODE_GAP = "omni.mode.gap"
local MODE_LPAD = "omni.mode.lpad"
local MODE_ICON = "omni.mode.icon"
local MODE_RPAD = "omni.mode.rpad"
local MODE_BR = "omni.mode.br"
-- Standalone scratchpad section (after the mode pill, before the title).
local SCR_GAP = "omni.scr.gap"
local SCR_MARK = "omni.scr.mark"
local SCR_TAIL = "omni.scr.tail"
local SCR_BR = "omni.scr.br"
-- Spacer after the scratchpad pill (outside SCR_BR), before the window title.
local SCR_END = "omni.scr.end"
-- Spacer between the marker chip and the first scratchpad glyph (mirrors
-- numpad_name(n) in a workspace).
local SCR_MARKPAD = "omni.scr.markpad"
local function scr_app_name(i)
	return "omni.scr.app." .. i
end

-- Standalone floating-windows section (after the scratchpad pill, before the
-- title). SCR_END is the always-on gap between the workspaces and the title.
local FLT_GAP = "omni.flt.gap"
local FLT_MARK = "omni.flt.mark"
local FLT_MARKPAD = "omni.flt.markpad"
local FLT_TAIL = "omni.flt.tail"
local FLT_BR = "omni.flt.br"
local function flt_app_name(i)
	return "omni.flt.app." .. i
end

-- ---- one-time slot creation (during config load, for stable left-to-right
-- ---- ordering) ----
local function create_slots()
	-- The lead gap doubles as the fullscreen marker: a fixed-width item whose
	-- label is the fullscreen icon while the focused window is fullscreen, so
	-- nothing shifts.
	sbar.add("item", LEAD_NAME, {
		position = "left",
		width = style.fs_width,
		icon = { drawing = false },
		label = {
			string = "",
			font = style.fs_font,
			color = style.fs_fg,
			-- label.width = box width, else align = "center" has no span to centre in
			width = style.fs_width,
			align = "center",
			padding_left = 0,
			padding_right = 0,
		},
		-- Box around the F, drawn only while fullscreen (see refresh_fullscreen).
		-- padding_left separates it from the iStat items; the negative
		-- padding_right fuses its right border with the mode pill's left border.
		padding_left = style.fs_pad_left,
		padding_right = style.ws_overlap,
		background = {
			drawing = false,
			color = style.fs_color,
			border_color = style.fs_color,
			border_width = style.border_width,
			height = style.bar_height,
			corner_radius = style.ws_corner_radius,
		},
	})

	for n = 1, MAX_WS do
		local members = {}

		sbar.add("item", num_name(n), {
			position = "left",
			drawing = false,
			icon = { drawing = false },
			label = {
				string = tostring(n),
				font = style.num_font,
				color = style.num_idle,
				padding_left = 7,
				padding_right = 7,
			},
			background = {
				drawing = true,
				color = style.num_box_bg,
				border_color = style.num_box_border,
				border_width = 1,
				corner_radius = style.corner_radius,
				height = style.bar_height - 14,
			},
			click_script = omniwmctl .. " command switch-workspace " .. n,
		})
		members[#members + 1] = num_name(n)

		sbar.add("item", numpad_name(n), {
			position = "left",
			drawing = false,
			width = style.num_app_gap,
			background = { drawing = false },
		})
		members[#members + 1] = numpad_name(n)

		for i = 1, MAX_APPS do
			sbar.add("item", app_name(n, i), {
				position = "left",
				drawing = false,
				icon = {
					string = style.fallback_glyph,
					font = style.app_font,
					color = style.app_fallback_color,
					padding_left = (i == 1) and style.first_app_pad_left or 4,
					padding_right = 4,
					y_offset = -1,
				},
				label = { drawing = false },
				background = { drawing = false },
			})
			members[#members + 1] = app_name(n, i)
		end

		sbar.add("item", tail_name(n), {
			position = "left",
			drawing = false,
			width = style.app_edge_pad,
			background = { drawing = false },
		})
		members[#members + 1] = tail_name(n)

		-- One bracket per workspace. Square corners + a negative left inset so
		-- consecutive brackets' side borders coincide into a single divider,
		-- making the run read as one strip. render_workspace() sets the border
		-- colour per focus (accent for the active workspace, muted otherwise).
		sbar.add("bracket", bracket_name(n), members, {
			drawing = false,
			background = {
				color = style.ws_bg,
				border_color = style.ws_border,
				border_width = style.border_width,
				height = style.bar_height,
				corner_radius = style.ws_corner_radius,
				padding_left = style.ws_overlap,
			},
		})

		sbar.add("item", spacer_name(n), {
			position = "left",
			drawing = false,
			width = style.ws_gap,
			background = { drawing = false },
		})
	end

	-- ---- standalone tiling-mode pill ----
	sbar.add("item", MODE_GAP, {
		position = "left",
		width = style.mode_gap,
		background = { drawing = false },
	})
	sbar.add("item", MODE_LPAD, {
		position = "left",
		drawing = false,
		width = style.mode_pad_left,
		background = { drawing = false },
	})
	sbar.add("item", MODE_ICON, {
		position = "left",
		drawing = false,
		width = style.mode_icon_width,
		icon = { drawing = false },
		label = {
			string = style.layout_tags.niri,
			font = style.mode_font,
			color = style.num_idle,
			align = "center",
			padding_left = style.layout_pad_left.niri,
			padding_right = 0,
			y_offset = style.layout_y_offset.niri,
		},
		background = { drawing = false },
		click_script = omniwmctl .. " command toggle-workspace-layout",
	})
	sbar.add("item", MODE_RPAD, {
		position = "left",
		drawing = false,
		width = style.mode_pad_right,
		background = { drawing = false },
	})
	-- Square corners + full height so it fuses with the workspace strip's left
	-- edge (workspace 1's negative inset overlaps this bracket's right border).
	sbar.add("bracket", MODE_BR, { MODE_LPAD, MODE_ICON, MODE_RPAD }, {
		drawing = false,
		background = {
			color = style.ws_bg,
			border_color = style.mode_border,
			border_width = style.border_width,
			height = style.bar_height,
			corner_radius = style.ws_corner_radius,
		},
	})

	-- ---- standalone scratchpad pill ----
	sbar.add("item", SCR_GAP, {
		position = "left",
		drawing = false,
		width = style.scr_gap,
		background = { drawing = false },
	})
	local scr_members = {}
	-- Same outlined chip as a workspace number, so the scratchpad marker reads
	-- as a peer of the workspace chips.
	sbar.add("item", SCR_MARK, {
		position = "left",
		drawing = false,
		icon = { drawing = false },
		label = {
			string = style.scr_marker,
			font = style.scr_marker_font,
			color = style.num_idle,
			padding_left = 7,
			padding_right = 7,
			y_offset = style.scr_marker_y_offset,
		},
		background = {
			drawing = true,
			color = style.num_box_bg,
			border_color = style.num_box_border,
			border_width = 1,
			corner_radius = style.corner_radius,
			height = style.bar_height - 14,
		},
	})
	scr_members[#scr_members + 1] = SCR_MARK

	sbar.add("item", SCR_MARKPAD, {
		position = "left",
		drawing = false,
		width = style.num_app_gap,
		background = { drawing = false },
	})
	scr_members[#scr_members + 1] = SCR_MARKPAD

	for i = 1, MAX_SCR do
		sbar.add("item", scr_app_name(i), {
			position = "left",
			drawing = false,
			icon = {
				string = style.fallback_glyph,
				font = style.app_font,
				color = style.app_fallback_color,
				padding_left = 4,
				padding_right = 4,
				y_offset = -1,
			},
			label = { drawing = false },
			background = { drawing = false },
		})
		scr_members[#scr_members + 1] = scr_app_name(i)
	end

	sbar.add("item", SCR_TAIL, {
		position = "left",
		drawing = false,
		width = style.app_edge_pad,
		background = { drawing = false },
	})
	scr_members[#scr_members + 1] = SCR_TAIL

	-- Square corners + a negative left inset so it fuses with the last
	-- workspace's right border, matching the inter-workspace dividers.
	sbar.add("bracket", SCR_BR, scr_members, {
		drawing = false,
		background = {
			color = style.ws_bg,
			border_color = style.scr_border,
			border_width = style.border_width,
			height = style.bar_height,
			corner_radius = style.ws_corner_radius,
			padding_left = style.ws_overlap,
		},
	})

	-- ---- standalone floating-windows pill (same shape as the scratchpad) ----
	sbar.add("item", FLT_GAP, {
		position = "left",
		drawing = false,
		width = style.flt_gap,
		background = { drawing = false },
	})
	local flt_members = {}
	sbar.add("item", FLT_MARK, {
		position = "left",
		drawing = false,
		icon = { drawing = false },
		label = {
			string = style.flt_marker,
			font = style.flt_marker_font,
			color = style.num_idle,
			padding_left = 7,
			padding_right = 7,
			y_offset = style.flt_marker_y_offset,
		},
		background = {
			drawing = true,
			color = style.num_box_bg,
			border_color = style.num_box_border,
			border_width = 1,
			corner_radius = style.corner_radius,
			height = style.bar_height - 14,
		},
	})
	flt_members[#flt_members + 1] = FLT_MARK

	sbar.add("item", FLT_MARKPAD, {
		position = "left",
		drawing = false,
		width = style.num_app_gap,
		background = { drawing = false },
	})
	flt_members[#flt_members + 1] = FLT_MARKPAD

	for i = 1, MAX_FLT do
		sbar.add("item", flt_app_name(i), {
			position = "left",
			drawing = false,
			icon = {
				string = style.fallback_glyph,
				font = style.app_font,
				color = style.app_fallback_color,
				padding_left = 4,
				padding_right = 4,
				y_offset = -1,
			},
			label = { drawing = false },
			background = { drawing = false },
		})
		flt_members[#flt_members + 1] = flt_app_name(i)
	end

	sbar.add("item", FLT_TAIL, {
		position = "left",
		drawing = false,
		width = style.app_edge_pad,
		background = { drawing = false },
	})
	flt_members[#flt_members + 1] = FLT_TAIL

	sbar.add("bracket", FLT_BR, flt_members, {
		drawing = false,
		background = {
			color = style.ws_bg,
			border_color = style.flt_border,
			border_width = style.border_width,
			height = style.bar_height,
			corner_radius = style.ws_corner_radius,
			padding_left = style.ws_overlap,
		},
	})

	-- Trailing gap before the title. Always drawn so the title is separated from
	-- the workspaces even when neither the scratchpad nor floating pill shows.
	sbar.add("item", SCR_END, {
		position = "left",
		width = style.scr_end_gap,
		background = { drawing = false },
	})
end

-- ---- per-app icon color ----
-- brand[bundleId] : color number once sampled, or false if the icon had no
--   vivid color. requested[bundleId] : a lookup has been fired (once ever).
-- helpers/app_color.sh does the sampling and caches to disk; here we just
-- memoise per process and re-render when an answer arrives.
local brand, requested = {}, {}
local refresh -- forward declaration (defined below, after render)

-- ---- focused workspace's tiling layout ("niri" / "dwindle") ----
-- The workspace-bar payload has no layout field, so it's fetched separately
-- (cmd.list_workspace_layouts). Only the focused workspace's layout is kept —
-- it drives the standalone mode pill. Refilled on the layout-change, focus and
-- workspace events.
local focused_layout = nil

local function render_mode()
	local tag = style.layout_tags[focused_layout]
	local show = tag ~= nil
	sbar.set(MODE_BR, { drawing = show })
	sbar.set(MODE_LPAD, { drawing = show })
	sbar.set(MODE_RPAD, { drawing = show })
	if not show then
		sbar.set(MODE_ICON, { drawing = false })
		return
	end
	sbar.set(MODE_ICON, {
		drawing = true,
		label = {
			string = tag,
			color = style.layout_colors[focused_layout] or style.num_idle,
			y_offset = style.layout_y_offset[focused_layout] or 0,
			padding_left = style.layout_pad_left[focused_layout] or 0,
		},
	})
end

-- Show the fullscreen box in the lead gap while the focused window is fullscreen.
local function refresh_fullscreen()
	sbar.exec(cmd.list_focused_fullscreen(), function(out)
		local wins = type(out) == "table"
			and out.result
			and out.result.payload
			and out.result.payload.windows
		if type(wins) == "table" then
			local fs = wins[1] and wins[1].isFullscreen == true
			sbar.set(LEAD_NAME, {
				label = { string = fs and style.fs_icon or "" },
				background = { drawing = fs },
			})
		end
	end)
end

local function refresh_layouts(done)
	refresh_fullscreen()
	sbar.exec(cmd.list_workspace_layouts(), function(out)
		local wss = type(out) == "table"
			and out.result
			and out.result.payload
			and out.result.payload.workspaces
		if type(wss) == "table" then
			focused_layout = nil
			for _, ws in ipairs(wss) do
				if ws.isFocused == true then
					focused_layout = ws.layout
				end
			end
			render_mode()
		end
		if done then
			done()
		end
	end)
end

local function want_color(bundle_id, name)
	if not bundle_id or requested[bundle_id] then
		return
	end
	requested[bundle_id] = true
	local cmd_str = string.format(
		"$CONFIG_DIR/helpers/app_color.sh '%s' '%s'",
		bundle_id:gsub("'", ""),
		tostring(name or ""):gsub("'", "")
	)
	sbar.exec(cmd_str, function(out)
		brand[bundle_id] = tonumber((tostring(out)):match("0[xX]%x+")) or false
		refresh()
	end)
end

local function app_base_color(rec)
	local c = rec.bundle_id and brand[rec.bundle_id]
	return type(c) == "number" and c or style.app_fallback_color
end

-- Blend a 0xAARRGGBB color toward white by t (0..1), keeping its alpha.
local function brighten(c, t)
	local a = (c >> 24) & 0xff
	if a == 0 then
		a = 0xff
	end
	local r = (c >> 16) & 0xff
	local g = (c >> 8) & 0xff
	local b = c & 0xff
	r = math.floor(r + (255 - r) * t)
	g = math.floor(g + (255 - g) * t)
	b = math.floor(b + (255 - b) * t)
	return (a << 24) | (r << 16) | (g << 8) | b
end

-- ---- render one decoded workspace-bar payload ----

-- Collapse a workspace's windows[] to an ordered list of distinct apps,
-- remembering whether any of that app's windows is focused (and which id to
-- focus on click).
local function distinct_apps(ws)
	local order, seen = {}, {}
	for _, w in ipairs(ws.windows or {}) do
		local key = w.appName or "?"
		local rec = seen[key]
		if not rec then
			rec = { name = key, bundle_id = w.bundleId, id = w.id, focused = false }
			seen[key] = rec
			order[#order + 1] = rec
		end
		if w.isFocused == true then
			rec.focused = true
			rec.id = w.id
		end
	end
	return order
end

local function hide_workspace(n)
	sbar.set(bracket_name(n), { drawing = false })
	sbar.set(num_name(n), { drawing = false })
	sbar.set(numpad_name(n), { drawing = false })
	sbar.set(tail_name(n), { drawing = false })
	sbar.set(spacer_name(n), { drawing = false })
	for i = 1, MAX_APPS do
		sbar.set(app_name(n, i), { drawing = false })
	end
end

local function render_workspace(ws)
	local n = ws.number
	if type(n) ~= "number" or n < 1 or n > MAX_WS then
		return
	end
	local focused_ws = ws.isFocused == true

	sbar.set(bracket_name(n), {
		drawing = true,
		background = {
			border_color = focused_ws and style.ws_focused_border or style.ws_border,
		},
	})
	sbar.set(num_name(n), {
		drawing = true,
		label = { color = focused_ws and style.num_focused or style.num_idle },
		background = {
			border_color = focused_ws and style.num_box_focused_border or style.num_box_border,
			color = focused_ws and style.num_box_focused_bg or style.num_box_bg,
		},
	})
	sbar.set(numpad_name(n), { drawing = true })
	sbar.set(tail_name(n), { drawing = true })
	sbar.set(spacer_name(n), { drawing = true })

	local apps = distinct_apps(ws)
	for i = 1, MAX_APPS do
		local rec = apps[i]
		if not rec then
			sbar.set(app_name(n, i), { drawing = false })
		else
			want_color(rec.bundle_id, rec.name)

			-- Tint the glyph to the app's real icon color. Dim it on
			-- background workspaces; the focused app gets a brighter glyph
			-- and a thin outlined pill in its own color.
			local base = app_base_color(rec)
			local glyph_color, pill
			if not focused_ws then
				glyph_color = with_alpha(brighten(base, style.app_bg_brighten), style.app_bg_alpha)
				pill = { drawing = false, border_width = 0 }
			elseif rec.focused then
				glyph_color = brighten(base, style.app_focus_brighten)
				pill = {
					drawing = true,
					color = with_alpha(base, style.app_pill_alpha),
					border_color = with_alpha(base, style.app_pill_border_alpha),
					border_width = style.app_pill_border_width,
					corner_radius = style.corner_radius,
					height = style.bar_height - 14,
				}
			else
				glyph_color = brighten(base, style.app_active_brighten)
				pill = { drawing = false, border_width = 0 }
			end

			sbar.set(app_name(n, i), {
				drawing = true,
				icon = {
					string = style.glyph_override[rec.name] or icon_map[rec.name] or style.fallback_glyph,
					color = glyph_color,
				},
				background = pill,
				click_script = rec.id and (omniwmctl .. " window focus " .. rec.id) or "",
			})
		end
	end
end

-- ---- scratchpad pill ----

-- Flatten mon.scratchpads[] (each { index, isVisible, windows[] }) to an ordered
-- list of one record per scratchpad window, capped at MAX_SCR.
local function flatten_scratchpads(mon)
	local out = {}
	for _, sp in ipairs(mon.scratchpads or {}) do
		for _, w in ipairs(sp.windows or {}) do
			out[#out + 1] = {
				name = w.appName or "?",
				bundle_id = w.bundleId,
				id = w.id,
				index = sp.index,
				visible = sp.isVisible == true,
			}
			if #out >= MAX_SCR then
				return out
			end
		end
	end
	return out
end

local function render_scratchpads(mon)
	local list = flatten_scratchpads(mon)
	local show = #list > 0
	sbar.set(SCR_GAP, { drawing = show })
	sbar.set(SCR_MARKPAD, { drawing = show })
	sbar.set(SCR_BR, { drawing = show })
	sbar.set(SCR_MARK, { drawing = show })
	sbar.set(SCR_TAIL, { drawing = show })

	for i = 1, MAX_SCR do
		local rec = list[i]
		if not rec then
			sbar.set(scr_app_name(i), { drawing = false })
		else
			want_color(rec.bundle_id, rec.name)

			-- Same tinting as the workspace glyphs: a shown scratchpad reads
			-- like the focused app (bright glyph + filled pill); a hidden one is
			-- dimmed.
			local base = app_base_color(rec)
			local glyph_color, pill
			if rec.visible then
				glyph_color = brighten(base, style.app_focus_brighten)
				pill = {
					drawing = true,
					color = with_alpha(base, style.app_pill_alpha),
					border_color = with_alpha(base, style.app_pill_border_alpha),
					border_width = style.app_pill_border_width,
					corner_radius = style.corner_radius,
					height = style.bar_height - 14,
				}
			else
				-- Hidden scratchpad = same treatment as a background workspace glyph.
				glyph_color = with_alpha(brighten(base, style.app_bg_brighten), style.app_bg_alpha)
				pill = { drawing = false, border_width = 0 }
			end

			sbar.set(scr_app_name(i), {
				drawing = true,
				icon = {
					string = style.glyph_override[rec.name] or icon_map[rec.name] or style.fallback_glyph,
					color = glyph_color,
				},
				background = pill,
				click_script = rec.index and (omniwmctl .. " command scratchpad toggle " .. rec.index) or "",
			})
		end
	end
end

-- ---- floating-windows pill ----
-- Unlike the scratchpad/workspace data, floating windows aren't in the
-- workspace-bar payload, so this section is driven by its own query
-- (cmd.list_floating_windows) via refresh_floating() below.
local function render_floating(wins)
	local show = #wins > 0
	sbar.set(FLT_GAP, { drawing = show })
	sbar.set(FLT_MARK, { drawing = show })
	sbar.set(FLT_MARKPAD, { drawing = show })
	sbar.set(FLT_TAIL, { drawing = show })
	sbar.set(FLT_BR, { drawing = show })

	for i = 1, MAX_FLT do
		local rec = wins[i]
		if not rec then
			sbar.set(flt_app_name(i), { drawing = false })
		else
			want_color(rec.bundle_id, rec.name)

			local base = app_base_color(rec)
			local glyph_color, pill
			if rec.focused then
				glyph_color = brighten(base, style.app_focus_brighten)
				pill = {
					drawing = true,
					color = with_alpha(base, style.app_pill_alpha),
					border_color = with_alpha(base, style.app_pill_border_alpha),
					border_width = style.app_pill_border_width,
					corner_radius = style.corner_radius,
					height = style.bar_height - 14,
				}
			else
				glyph_color = brighten(base, style.app_active_brighten)
				pill = { drawing = false, border_width = 0 }
			end

			sbar.set(flt_app_name(i), {
				drawing = true,
				icon = {
					string = style.glyph_override[rec.name] or icon_map[rec.name] or style.fallback_glyph,
					color = glyph_color,
				},
				background = pill,
				click_script = rec.id and (omniwmctl .. " window focus " .. rec.id) or "",
			})
		end
	end
end

local function refresh_floating()
	sbar.exec(cmd.list_floating_windows(), function(out)
		local wins = type(out) == "table"
			and out.result
			and out.result.payload
			and out.result.payload.windows
		local list = {}
		if type(wins) == "table" then
			for _, w in ipairs(wins) do
				list[#list + 1] = {
					name = (w.app and w.app.name) or "?",
					bundle_id = w.app and w.app.bundleId,
					id = w.id,
					focused = w.isFocused == true,
				}
				if #list >= MAX_FLT then
					break
				end
			end
		end
		render_floating(list)
	end)
end

local function render(payload)
	local monitors = payload and payload.monitors
	if type(monitors) ~= "table" or not monitors[1] then
		return
	end

	-- The bar sits on one display (bar.lua), but workspaces live on every
	-- monitor, so show them all. isFocused is per monitor (each has its own
	-- active workspace); only the one on the monitor being interacted with is
	-- the real focus.
	local active_id = payload.interactionMonitorId
	local active_mon = monitors[1]
	local present = {}
	for _, mon in ipairs(monitors) do
		local is_active = (active_id == nil) or (mon.id == active_id)
		if is_active then
			active_mon = mon
		end
		for _, ws in ipairs(mon.workspaces or {}) do
			if type(ws.number) == "number" and not present[ws.number] then
				present[ws.number] = true
				if not is_active then
					ws.isFocused = false
				end
				render_workspace(ws)
			end
		end
	end
	for n = 1, MAX_WS do
		if not present[n] then
			hide_workspace(n)
		end
	end

	-- Scratchpads are global; each monitor reports the same list.
	render_scratchpads(active_mon)
end

-- ---- placement: slot the whole block in right after the iStat section ----
-- aliases.lua force-orders  apple -> istat_spacer -> istat.cpu ... -> .sensors
-- with chained `sketchybar --move` (left-side add order is a race between async
-- callbacks). Do the same to park the workspace items immediately after the
-- last iStat alias. The alias name depends on the macOS release, matching
-- aliases.lua's own branch. Runs once, after the first render, by which point
-- aliases.lua's (faster) uname callback has added the anchors.
local placed = false
local function place_after_istat()
	if placed then
		return
	end
	placed = true
	sbar.exec("uname -r", function(release)
		local prefix = tostring(release):match("24%.6%.0") and "iStat Menus Menubar" or "Control Center"
		local anchor = prefix .. ",com.bjango.istatmenus.sensors"

		local moves, prev = {}, anchor
		moves[#moves + 1] = string.format(" --move '%s' after '%s'", LEAD_NAME, prev)
		prev = LEAD_NAME
		-- Tiling-mode section sits between the iStat menus and workspace 1.
		-- MODE_GAP trails it as separation before the first workspace.
		for _, name in ipairs({ MODE_LPAD, MODE_ICON, MODE_RPAD, MODE_GAP }) do
			moves[#moves + 1] = string.format(" --move '%s' after '%s'", name, prev)
			prev = name
		end
		for n = 1, MAX_WS do
			local block = { num_name(n), numpad_name(n) }
			for i = 1, MAX_APPS do
				block[#block + 1] = app_name(n, i)
			end
			block[#block + 1] = tail_name(n)
			block[#block + 1] = spacer_name(n)
			for _, name in ipairs(block) do
				moves[#moves + 1] = string.format(" --move '%s' after '%s'", name, prev)
				prev = name
			end
		end
		-- Scratchpad pill, then the floating-windows pill, trail the last
		-- workspace (title/front-app sit further right, outside this move chain,
		-- so they stay to the right of both).
		local trailing = { SCR_GAP, SCR_MARK, SCR_MARKPAD }
		for i = 1, MAX_SCR do
			trailing[#trailing + 1] = scr_app_name(i)
		end
		trailing[#trailing + 1] = SCR_TAIL
		trailing[#trailing + 1] = FLT_GAP
		trailing[#trailing + 1] = FLT_MARK
		trailing[#trailing + 1] = FLT_MARKPAD
		for i = 1, MAX_FLT do
			trailing[#trailing + 1] = flt_app_name(i)
		end
		trailing[#trailing + 1] = FLT_TAIL
		trailing[#trailing + 1] = SCR_END
		for _, name in ipairs(trailing) do
			moves[#moves + 1] = string.format(" --move '%s' after '%s'", name, prev)
			prev = name
		end
		sbar.exec("sketchybar" .. table.concat(moves))
	end)
end

-- ---- fetch -> render ----
-- SbarLua's sbar.exec auto-decodes JSON stdout into a Lua table, so `out` is
-- the parsed response. A malformed/truncated response arrives as a string
-- (or nil) and is skipped; the next event refreshes.
-- assigns the forward-declared `refresh` (want_color's callback calls it)
refresh = function()
	sbar.exec(cmd.list_workspace_bar(), function(out)
		local payload = type(out) == "table" and out.result and out.result.payload
		if type(payload) == "table" then
			render(payload)
			place_after_istat()
		end
	end)
	-- Floating windows come from a separate query; refresh them alongside.
	refresh_floating()
end

-- ---- wire up ----
create_slots()

local driver = sbar.add("item", "omni.ws.driver", { drawing = false, updates = true, update_freq = 1 })
-- OmniWM emits no watch event for toggle-fullscreen, so poll the (cheap) focused
-- window query. ponytail: up to 1s lag; instead have karabiner's `f` bindings
-- run `sketchybar --trigger omniwm_windows_change` if that matters.
driver:subscribe("routine", refresh_fullscreen)
-- layout-change flips the focused workspace's mode; focus/workspace changes can
-- move focus to a workspace in a different mode. All three re-fetch the focused
-- layout (cheap query) and re-render the bar.
driver:subscribe("omniwm_workspace_change", function()
	refresh_layouts(refresh)
end)
driver:subscribe("omniwm_layout_change", function()
	refresh_layouts(refresh)
end)
driver:subscribe("omniwm_focus_change", function()
	refresh_layouts(refresh)
end)
-- Windows added/removed or toggled float <-> tile.
driver:subscribe("omniwm_windows_change", function()
	refresh_layouts(refresh)
end)

refresh_layouts(refresh)
