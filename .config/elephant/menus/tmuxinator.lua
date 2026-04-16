Name = "tmuxinator"
NamePretty = "Tmuxinator"
Icon = "utilities-terminal"
Terminal = true
Cache = false

Action = "tmuxinator start '%VALUE%'"

function GetEntries()
	local entries = {}

	local handle = io.popen("/home/hschne/.local/share/mise/installs/ruby/4.0.0/bin/tmuxinator list")
	local output = handle:read("*a")
	handle:close()

	local first_line = true
	for line in output:gmatch("[^\r\n]+") do
		if first_line then
			first_line = false
		else
			for project in line:gmatch("%S+") do
				table.insert(entries, {
					Text = project,
					Subtext = "Tmuxinator Session",
					Value = project,
					Icon = "utilities-terminal",
				})
			end
		end
	end

	return entries
end
