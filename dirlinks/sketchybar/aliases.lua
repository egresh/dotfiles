local alias_bracket_config = require("settings").alias_bracket

-- iStat aliases render blank on macOS 27 (SketchyBar issue #849). Hide them but
-- keep the items: workspaces.lua anchors the workspace strip after the sensors
-- alias. Set to false once upstream fixes it.
local hide_istat = true

sbar.exec("uname -r", function(release)
  local istat_items
	if string.match(release, "24.6.0") then
		istat_items = {
			"iStat Menus Menubar,com.bjango.istatmenus.memory",
			"iStat Menus Menubar,com.bjango.istatmenus.cpu",
			"iStat Menus Menubar,com.bjango.istatmenus.disks",
			"iStat Menus Menubar,com.bjango.istatmenus.network",
			"iStat Menus Menubar,com.bjango.istatmenus.sensors",
		}
	else
		istat_items = {
			"Control Center,com.bjango.istatmenus.cpu",
			"Control Center,com.bjango.istatmenus.memory",
			"Control Center,com.bjango.istatmenus.disks",
			"Control Center,com.bjango.istatmenus.network",
			"Control Center,com.bjango.istatmenus.sensors",
		}
	end

	local bracket_names = {}

	for i, v in ipairs(istat_items) do
		sbar.add("alias", v, {
			position = "left",
			drawing = not hide_istat,
			alias = {
				scale = 1.3,
			},
		})

		table.insert(bracket_names, v)
	end

	local bracket_config = alias_bracket_config()
	bracket_config.drawing = not hide_istat
	sbar.add("bracket", "istat_items", bracket_names, bracket_config)

	-- Pin the stats block right after the hostname pill (which itself sits right
	-- after apple), so the section order is apple -> hostname -> stats. These
	-- aliases are added from this async `uname -r` callback, and other items are
	-- added from separate async callbacks, so left-side order is otherwise a race.
	-- Chain each move after the previous item so the final order (apple ->
	-- hostname -> spacer -> cpu -> memory -> ...) is deterministic.
	sbar.add("item", "istat_spacer", { position = "left", width = 18 })

	local move_cmd = "sketchybar --move istat_spacer after hostname"
	local prev = "istat_spacer"
	for _, v in ipairs(istat_items) do
		move_cmd = move_cmd .. string.format(" --move '%s' after '%s'", v, prev)
		prev = v
	end
	sbar.exec(move_cmd)
end)
