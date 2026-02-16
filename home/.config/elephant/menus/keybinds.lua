local json = dofile(os.getenv("HOME") .. "/.config/elephant/utils/json.lua")

Name = "keybinds"
NamePretty = "Keybinds"
Icon = "preferences-desktop-keyboard-shortcuts"
Cache = false
Action = "hyprctl dispatch %VALUE%"

local function get_mods(modmask)
	local mods = {}
	if (modmask / 64) % 2 >= 1 then
		table.insert(mods, "󰘳")
	end -- Super
	if (modmask / 8) % 2 >= 1 then
		table.insert(mods, "󰘵")
	end -- Alt
	if (modmask / 4) % 2 >= 1 then
		table.insert(mods, "󰘴")
	end -- Ctrl
	if (modmask / 1) % 2 >= 1 then
		table.insert(mods, "󰘶")
	end -- Shift
	return mods
end

function GetEntries()
	local handle = io.popen("hyprctl binds -j")
	local output = handle:read("*a")
	handle:close()

	if not output or output == "" then
		return {}
	end

	local status, data = pcall(json.decode, output)
	if not status then
		return { { Text = "JSON Error", Subtext = tostring(data) } }
	end

	local entries = {}
	for _, bind in ipairs(data) do
		if bind.description and bind.description ~= "" then
			local mods = get_mods(bind.modmask)
			local key_icons = table.concat(mods, " ")
			local key_name = bind.key or ""

			local display_keys = key_icons
			if #mods > 0 then
				display_keys = key_icons .. " + " .. key_name
			else
				display_keys = key_name
			end

			table.insert(entries, {
				-- Main text: Description (Icons + Key)
				Text = bind.description .. " (" .. display_keys .. ")",
				-- Subtext: Repeated for extra clarity
				Subtext = "Shortcut: " .. display_keys,
				Value = (bind.dispatcher or "") .. " " .. (bind.arg or ""),
				Icon = "preferences-desktop-keyboard-shortcuts",
			})
		end
	end

	if #entries == 0 then
		table.insert(entries, {
			Text = "No labeled binds found",
			Subtext = "Add descriptions to binds in hyprland.conf using 'bindd'",
			Value = "exec notify-send 'Hint' 'Use bindd in your config!'",
		})
	end

	return entries
end
