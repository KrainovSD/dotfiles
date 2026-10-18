-- https://wiki.hypr.land/configuring/

-- https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@120", position = "0x0",    scale = 1.25 })
-- hl.monitor({ output = "HDMI-A-2", mode = "2560x1440@120", position = "2048x0", scale = 1.25 })

local terminal = "kitty"
local menu = "wofi --show drun"
-- https://wiki.hypr.land/configuring/core/autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("hyprctl setcursor Future-cyan 30")
	hl.exec_cmd("uwsm app -- awww-daemon")
	hl.exec_cmd("uwsm app -- dunst $HOME/.config/dunst/dunstrc")
end)
-- https://wiki.hypr.land/configuring/core/environment-variables/
hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_SIZE", "30")
-- https://wiki.hypr.land/configuring/core/config-options/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		-- https://wiki.hypr.land/configuring/extra/tearing/
		allow_tearing = false,
		layout = "master",
	},
})
-- https://wiki.hypr.land/configuring/layouts/dwindle-layout/
hl.config({
	dwindle = {
		preserve_split = true,
	},
})
-- https://wiki.hypr.land/configuring/layouts/master-layout/
hl.config({
	master = {
		mfact = 0.65,
		special_scale_factor = 0.95,
		allow_small_split = true,
	},
})
-- https://wiki.hypr.land/configuring/core/config-options/#decoration
hl.config({
	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		dim_inactive = true,
		dim_strength = 0.2,
		dim_around = 0.2,
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
})
hl.config({
	animations = {
		enabled = true,
	},
})
-- https://wiki.hypr.land/configuring/core/animations/
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
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
-- https://wiki.hypr.land/configuring/core/rules/workspace-rules/
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 5, gaps_in = 5 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 5, gaps_in = 5 })
-- https://wiki.hypr.land/configuring/core/rules/window-rules/
hl.window_rule({
	name = "center-power-menu",
	match = { class = "power-menu" },
	float = true,
	center = true,
	pin = true,
	size = { 500, 200 },
	dim_around = true,
})
hl.window_rule({
	name = "float",
	match = { class = "float" },
	float = true,
	center = true,
	pin = true,
	size = { 1000, 600 },
	dim_around = true,
})
hl.window_rule({
	name = "satty",
	match = { class = "com.gabm.satty" },
	float = true,
	center = true,
	pin = true,
	-- size = { 1000, 600 },
	dim_around = true,
})
hl.window_rule({
	name = "bluetooth",
	match = { class = "bluetooth" },
	float = true,
	center = true,
	pin = true,
	size = { 1000, 600 },
	dim_around = true,
})
hl.window_rule({
	name = "network",
	match = { class = "network" },
	float = true,
	center = true,
	pin = true,
	size = { 1000, 600 },
	dim_around = true,
})
-- https://github.com/hyprwm/Hyprland/discussions/16404
hl.window_rule({
	name = "kitty-no-maximize",
	match = { class = "^(kitty|float)$" },
	suppress_event = "maximize",
})
hl.config({
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},
})
-- https://wiki.hypr.land/configuring/core/config-options/#input
hl.config({
	input = {
		kb_layout = "us,ru",
		kb_variant = "",
		kb_model = "",
		kb_options = "grp:win_space_toggle",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
})
-- https://wiki.hypr.land/configuring/core/gestures/
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
-- https://wiki.hypr.land/configuring/core/devices/
-- hl.device({
-- 	name = "epic-mouse-v1",
-- 	sensitivity = -0.5,
-- })
-- https://wiki.hypr.land/configuring/core/binds/
local mainMod = "SUPER"
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("uwsm app -- hyprlock"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("uwsm app -- " .. terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("uwsm app -- " .. terminal .. " --class=float"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("uwsm app -- " .. menu))
hl.bind(mainMod .. " + Y", hl.dsp.layout("orientationnext"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + O", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + N", hl.dsp.layout("swapwithmaster"))
hl.bind(
	"Print",
	hl.dsp.exec_cmd(
		[[uwsm app -- grim -g "$(slurp)" - | satty -f - --copy-command wl-copy -o ~/screen/screen_$(date +'%Y%m%d_%H%M%S').png]]
	)
)
hl.bind(
	"SHIFT + Print",
	hl.dsp.exec_cmd(
		[[uwsm app -- grim - | satty -f - --copy-command wl-copy -o ~/screen/screen_$(date +'%Y%m%d_%H%M%S').png]]
	)
)
hl.bind(
	mainMod .. " + Print",
	-- hl.dsp.exec_cmd([[uwsm app -- wf-recorder -g "$(slurp)" -f ~/screen/record_$(date +'%Y%m%d_%H%M%S').mp4]])
	hl.dsp.exec_cmd([[uwsm app -- wf-recorder - -f ~/screen/record_$(date +'%Y%m%d_%H%M%S').mp4]])
)
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("killall -INT wf-recorder"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

local wsKeys = {
	[1] = "Q",
	[2] = "W",
	[3] = "E",
	[4] = "A",
	[5] = "S",
	[6] = "D",
	[7] = "1",
	[8] = "2",
	[9] = "3",
	[10] = "0",
}
for i = 1, 10 do
	local key = wsKeys[i]
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("uwsm app -- hyprlock"), { locked = true }) -- при закрытии крышки — блокировка
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
