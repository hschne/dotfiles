-- Hyprland config - migrated from hyprlang to lua (Hyprland 0.55+)
-- https://wiki.hypr.land/Configuring/

------------------
---- MONITORS ----
------------------

-- Let kanshi manage monitor layout/profile switching. Minimal fallbacks here.

-- Internal laptop display defaults
hl.monitor({ output = "eDP-1", mode = "2880x1920@60", position = "auto", scale = 1.5 })

-- Generic fallback for anything else
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "walker"
local browser = "firefox"
local editor = "nvim"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm-app -- kanshi")
	hl.exec_cmd("uwsm-app -- mako")
	hl.exec_cmd("uwsm-app -- waybar")
	hl.exec_cmd("uwsm-app -- walker --gapplication-service")
	hl.exec_cmd("uwsm-app -- hypridle")
	hl.exec_cmd("uwsm-app -- hyprsunset")
	hl.exec_cmd("uwsm-app -- swayosd-server")
	hl.exec_cmd("uwsm-app -- voxtype daemon")
	hl.exec_cmd("uwsm-app -- easyeffects --gapplication-service")

	-- Wallpaper
	hl.exec_cmd("uwsm-app -- swaybg -i $(fd --full-path ~/Pictures/Backgrounds/ --type=file | shuf -n1) -m fill")

	-- Polkit agent for auth dialogs
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- Slow app launch fix -- set systemd vars
	hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.config({
	ecosystem = {
		no_update_news = true,
	},
})

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 1,

		-- Tokyo Night colors (matching i3 config)
		col = {
			active_border = "rgba(bb9af7ff)",
			inactive_border = "rgba(32344aff)",
		},

		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = true,
	},

	cursor = {
		enable_hyprcursor = false,
	},
})

-- Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_options = "caps:swapescape,compose:ralt",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
		},
	},
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Core bindings
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal), { description = "Terminal" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close(), { description = "Kill window" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu), { description = "App launcher" })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("~/.scripts/power-menu"), { description = "Power menu" })

-- Applications
hl.bind(
	mainMod .. " + X",
	hl.dsp.exec_cmd(terminal .. " " .. editor .. " ~/Documents/Wiki/todo.txt"),
	{ description = "Todo" }
)
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager), { description = "File Manager" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(terminal .. " -e nvim"), { description = "Neovim" })
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal .. " -e btop"), { description = "Top" })

-- Focus movement (vim-style, matching i3)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })

-- Move windows
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }), { description = "Move window left" })
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "down" }), { description = "Move window down" })
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "up" }), { description = "Move window up" })
hl.bind(
	mainMod .. " + SHIFT + Right",
	hl.dsp.window.move({ direction = "right" }),
	{ description = "Move window right" }
)

-- Workspace prev/next on output
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ workspace = "m-1" }), { description = "Previous workspace" })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ workspace = "m+1" }), { description = "Next workspace" })

-- Move workspace to monitor
hl.bind(
	mainMod .. " + CTRL + SHIFT + Left",
	hl.dsp.workspace.move({ monitor = "l" }),
	{ description = "Move workspace to left monitor" }
)
hl.bind(
	mainMod .. " + CTRL + SHIFT + Right",
	hl.dsp.workspace.move({ monitor = "r" }),
	{ description = "Move workspace to right monitor" }
)

-- Split orientation (dwindle)
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
hl.bind(mainMod .. " + V", hl.dsp.layout("preselect d"), { description = "Preselect down" })

-- Fullscreen
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Fullscreen" })

-- Floating
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(
	mainMod .. " + Space",
	hl.dsp.window.cycle_next({ floating = true }),
	{ description = "Cycle floating windows" }
)

-- Config management
hl.bind(
	mainMod .. " + SHIFT + W",
	hl.dsp.exec_cmd("pkill waybar; uwsm-app -- waybar"),
	{ description = "Restart Waybar" }
)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })

-- Lock screen
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })

-- Screenshot (with satty for annotation)
hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | satty -f -]]), { description = "Screenshot region" })
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim - | satty -f -"), { description = "Screenshot full" })
hl.bind(
	mainMod .. " + SHIFT + Print",
	hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]),
	{ description = "Screenshot region to clipboard" }
)

-- Screen recording
hl.bind(
	mainMod .. " + R",
	hl.dsp.exec_cmd("~/.scripts/screen-record --silent"),
	{ description = "Toggle screen recording (silent)" }
)

-- Voice recording (push-to-talk: hold to record, release to transcribe)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("voxtype record start"), { description = "Voxtype start recording" })
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd("voxtype record stop"),
	{ release = true, description = "Voxtype stop recording" }
)

-- Color picker
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color picker" })

-- Switch workspaces / move window to workspace
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Workspace " .. i })
	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i }),
		{ description = "Move to workspace " .. i }
	)
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace (scroll)" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace (scroll)" })

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window (mouse)" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window (mouse)" })

-- Media keys (using swayosd for visual feedback)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ repeating = true, locked = true, description = "Volume up" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ repeating = true, locked = true, description = "Volume down" }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ repeating = true, locked = true, description = "Toggle mute" }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
	{ repeating = true, locked = true, description = "Toggle mic mute" }
)

-- Brightness (using swayosd for visual feedback)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ repeating = true, locked = true, description = "Brightness up" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
	{ repeating = true, locked = true, description = "Brightness down" }
)

-- Media player controls
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/Pause" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/Pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous track" })

-- Notifications
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("makoctl dismiss"), { description = "Dismiss last notification" })
hl.bind(
	mainMod .. " + SHIFT + comma",
	hl.dsp.exec_cmd("makoctl dismiss --all"),
	{ description = "Dismiss all notifications" }
)
hl.bind(
	mainMod .. " + CTRL + comma",
	hl.dsp.exec_cmd(
		[[makoctl mode -t do-not-disturb && makoctl mode | grep -q 'do-not-disturb' && notify-send "Silenced notifications" || notify-send "Enabled notifications"]]
	),
	{ description = "Toggle silencing notifications" }
)
hl.bind(mainMod .. " + ALT + comma", hl.dsp.exec_cmd("makoctl invoke"), { description = "Invoke last notification" })
hl.bind(
	mainMod .. " + SHIFT + ALT + comma",
	hl.dsp.exec_cmd("makoctl restore"),
	{ description = "Restore last notification" }
)

-- OBS zoom / recording (sends shortcut directly to OBS window)
hl.bind(
	"SHIFT + ALT + period",
	hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }),
	{ description = "OBS Zoom Toggle" }
)
hl.bind(
	"SHIFT + ALT + s",
	hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }),
	{ description = "OBS Start Recording" }
)
hl.bind(
	"SHIFT + ALT + o",
	hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }),
	{ description = "OBS Stop Recording" }
)

----------------------------------
---- SUBMAPS (like i3 modes) ----
----------------------------------

-- Exit mode (like i3's "Exit (L)ogout, (R)eboot, (P)oweroff")
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.submap("exit"), { description = "Exit mode" })
hl.define_submap("exit", function()
	hl.bind(mainMod .. " + L", hl.dsp.exit(), { description = "Logout" })
	hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("systemctl reboot"), { description = "Reboot" })
	hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("systemctl poweroff"), { description = "Poweroff" })
	hl.bind("Return", hl.dsp.submap("reset"))
	hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Resize mode
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"), { description = "Resize mode" })
hl.define_submap("resize", function()
	hl.bind(
		"H",
		hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
		{ repeating = true, description = "Resize left" }
	)
	hl.bind(
		"J",
		hl.dsp.window.resize({ x = 0, y = 20, relative = true }),
		{ repeating = true, description = "Resize down" }
	)
	hl.bind(
		"K",
		hl.dsp.window.resize({ x = 0, y = -20, relative = true }),
		{ repeating = true, description = "Resize up" }
	)
	hl.bind(
		"L",
		hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
		{ repeating = true, description = "Resize right" }
	)
	hl.bind(
		"Left",
		hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
		{ repeating = true, description = "Resize left" }
	)
	hl.bind(
		"Down",
		hl.dsp.window.resize({ x = 0, y = 20, relative = true }),
		{ repeating = true, description = "Resize down" }
	)
	hl.bind(
		"Up",
		hl.dsp.window.resize({ x = 0, y = -20, relative = true }),
		{ repeating = true, description = "Resize up" }
	)
	hl.bind(
		"Right",
		hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
		{ repeating = true, description = "Resize right" }
	)
	hl.bind("Return", hl.dsp.submap("reset"))
	hl.bind("Escape", hl.dsp.submap("reset"))
	hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

------------------------
---- WINDOW RULES -----
------------------------

-- Ignore maximize requests from all apps
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
hl.window_rule({
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

-- Workspace assignments
hl.window_rule({ match = { class = "^([Ff]irefox.*)$" }, workspace = "2" })
hl.window_rule({ match = { title = "^(Spotify.*)$" }, workspace = "5" })
hl.window_rule({ match = { class = "^([Ss]lack.*)$" }, workspace = "6" })
hl.window_rule({ match = { class = "^([Ss]ignal.*)$" }, workspace = "6" })
hl.window_rule({ match = { class = "^([Dd]iscord.*)$" }, workspace = "6" })

-- Float certain windows
hl.window_rule({ match = { class = "^(org.speedcrunch.speedcrunch)$" }, float = true })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { class = "^(com.gabm.satty)$" }, float = true })
