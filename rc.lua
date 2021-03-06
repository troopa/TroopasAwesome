--@TODO rightclick context menu to close a window/client

-------------------------------------------------------
--- author  : Daniel Foehn aka Don Troopa
--- version : 1.0
--- e-mail  : --
--- description: a personal configuration of my
--- 	awesome tiling manager. I configured myself some
---		vicious widgets and key shortcuts. I also changed
---		the menu structure to my needs.
---
---
--- NOTE:
--- feel free to use this configuration. for individual
--- changes you should change the menu part starting
--- on line 66.
--- for individual key combination start changing on
--- line 268.
--- also line 44 with the terminal variable.
-------------------------------------------------------

-- {{ libraries
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget handling library
local wibox = require("wibox")
-- theme library
local beautiful = require("beautiful")
local gears = require("gears")
-- extra libraries
local naughty = require("naughty")
local vicious = require("vicious")
-- }}

-- {{ variable definitions
local altkey = "Mod1"
local superkey = "Mod4"
local control = "Control_L"

local home = os.getenv("HOME")
local terminal = "urxvt"
-- theme
beautiful.init("/usr/share/awesome/themes/igotblues/theme.lua")
for s=1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
end

-- layouts
layouts = {
    awful.layout.suit.tile,         -- 1
    awful.layout.suit.tile.bottom,  -- 2
    awful.layout.suit.max,          -- 3
    awful.layout.suit.floating      -- 4
}
-- }}

-- {{ tags
tags = { name = {"1","2","3","4","5"},
		 layout = {layouts[1],layouts[1],layouts[1],layouts[1],layouts[1]}
	   }
for s = 1, screen.count() do
    tags[s]  = awful.tag(tags.name, s, tags.layout)
end
-- }}

-- {{ Menu
-- { launcher for power off etc
awesomemenu = {
	{ "restart", awesome.restart},
	{ "quit", awesome.quit}
}

powermenu = awful.menu({ items = {	{ "power off", "shutdown -h now" },
									{ "reboot", "shutdown -r now" },
									{ "awesome", awesomemenu }
								 }
					   })
powerlauncher = awful.widget.launcher({ image = beautiful.powerlauncher,
										menu = powermenu })
-- }

-- { menu launcher 
-- menu for all programs which are not categorized
workbench = {
    { "SailfishOS IDE", "" },
    { "VirtualBox", "virtualbox" },
    { "Wireshark", "wireshark" },
    { "Kinetis", "kinetis"},
    { "UML", "umlet"}
}
-- menu for internet applications
office = {
    { "LibreOffice", "libreoffice" },
	{ "GEdit", "gedit" },
	{ "PDF", "evince" },
	{ "Torrent", "transmission-qt" },
	{ "Email", "geary" },
    { "Tex", "texmaker" },
    { "FTP", "filezilla" },
    { "Chromium", "chromium" }
}
-- menu for mathematical programs
mathematics = {
    { "R", "rstudio-bin"},
    { "octave", terminal .. " -e octave --no-gui"},
    { "calc", terminal .. " -e python"}
}
-- menu for applications with them i can chat/talk to another people
chat = {
	{ "Skype", "skype" },
	{ "IRC", terminal .. " -e irssi" },
	{ "Mumble", "mumble" }
}
-- menu for ALL applications from multimedia (video,audio,image)
mmf = {
	{ "MPlayer", "smplayer"},
	{ "GIMP", "gimp" },
    { "Paint", "mypaint"}
}

mainmenu = awful.menu({ items = { 
								  { "Workbench", workbench },
								  { "Office", office },
								  { "Chat", chat },
                                  { "Mathematics", mathematics },
                                  { "MultiMedia", mmf }
								}
					 })

menulauncher = awful.widget.launcher({ image = beautiful.menulauncher,
									   menu = mainmenu
									})

-- }

--{ context menu, rightclick on the tasklist
--contextmenu = awful.menu({ items = { { "close", function (c) c:kill() end }
--								   }
--						})
-- }
-- }}

-- {{ widgets
-- create textclock widget
w_textclock = awful.widget.textclock()

-- { separator
separator = wibox.widget.imagebox()--widget({ type = "imagebox" })
separator:set_image(beautiful.separator)
-- }
---- { cpu usage and temperature
cpuicon = wibox.widget.imagebox() --widget({ type = "imagebox" })
cpuicon:set_image(beautiful.cpu)
---- initialize
cpu = wibox.widget.textbox()--widget({ type = "textbox" })
--temperature = wibox.widget.textbox()--widget({ type = "textbox" })
---- register
vicious.register(cpu, vicious.widgets.cpu, "$1%")
--vicious.register(temperature, vicious.widgets.thermal, "$1C ", 42, {"atk0110", "core"})
---- }

---- { memory usage
memicon = wibox.widget.imagebox() --widget({ type = "imagebox" })
memicon:set_image(beautiful.memory)
---- initialize
memory = wibox.widget.textbox()--widget({ type = "textbox" })
---- register
vicious.register(memory, vicious.widgets.mem, "$1%", 13)
---- }

---- { upload/download rate
downicon = wibox.widget.imagebox() --widget({ type = "imagebox" })
upicon = wibox.widget.imagebox() --widget({ type = "imagebox" })
downicon:set_image(beautiful.download)
upicon:set_image(beautiful.upload)
---- initialize
netwidget = wibox.widget.textbox()--widget({ type = "imagebox" })
---- register
vicious.register(netwidget, vicious.widgets.net, '<span color="' .. beautiful.foreground_color .. '">${enp4s0 down_kb} | </span><span color="' .. beautiful.foreground_color .. '">${enp4s0 up_kb}</span>', 3)
---- }

-- initialize a wibox for each screen
w_wibox = {}
w_promptbox = {}
-- box that contains icons to change the layout
w_layoutbox = {}
-- element in the wibox that contains the tag numbers (1,2,3,...)
w_taglist = {}
-- and its functionality
w_taglist.buttons = awful.util.table.join(
						-- create button with --> awful.button({special key }, key, function)
						awful.button({ }, 1, awful.tag.viewonly),
						awful.button({ }, 3, awful.tag.viewtoggle),
						awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
						awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
					)

-- element that contains the opened programs
w_tasklist = {}
w_tasklist.buttons = awful.util.table.join(
						awful.button({ }, 1, function(c)
							if c == client.focus then
								c.minimized = true
							else
								c.minimized = false
								if not c:isvisible() then
									awful.tag.viewonly(c:tags()[1])
								end
								client.focus = c
								c:raise()
							end
						end),
						awful.button({ }, 3, function ()
							if instance then
								instance:hide()
								instance = nil
							else
								instance = awful.menu.clients({ width=250 })
							end
						end),
						awful.button({ }, 4, function ()
							awful.client.focus.byidx(1)
							if client.focus then client.focus:raise() end
						end),
						awful.button({ }, 5, function ()
							awful.client.focus.byidx(-1)
							if client.focus then client.focus:raise() end
						end)					
					) 

-- add everything  to the wibox and the wibox to the screen
for s = 1, screen.count() do
    w_promptbox[s] = awful.widget.prompt()
	w_layoutbox[s] = awful.widget.layoutbox(s)
	w_layoutbox[s]:buttons(awful.util.table.join(
								awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
								awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
								awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
								awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
							)
	)
	-- creates the taglist widget
	w_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, w_taglist.buttons)

	-- creates the tasklist widget
	w_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, w_tasklist.buttons)

	-- adds the wibox to the screen in position top
	w_wibox[s] = awful.wibox({ position = "top", screen = s })

	-- variable for leftside content of wibox
	local leftside = wibox.layout.fixed.horizontal()
	leftside:add(menulauncher)
	leftside:add(powerlauncher)
	leftside:add(w_taglist[s])
	leftside:add(w_promptbox[s])

	-- variable for rightside content of wibox
	local rightside = wibox.layout.fixed.horizontal()
	--add vicious widget to the wibox
	--add cpu and icon from vicious
	rightside:add(cpuicon)
	rightside:add(cpu)
	rightside:add(separator)
	--add memory and icon from vicious
	rightside:add(memicon)
	rightside:add(memory)
	rightside:add(separator)
	--add down- and upload rate
	rightside:add(downicon)
	rightside:add(netwidget)
	rightside:add(upicon)
	rightside:add(separator)

	--basic widget
	if s == 1 then rightside:add(wibox.widget.systray()) end --systray
	rightside:add(w_textclock)--clock
	rightside:add(w_layoutbox[s])

	-- adding left, middle and rightside to wibox	
	local layout = wibox.layout.align.horizontal()
	layout:set_left(leftside)
	layout:set_middle(w_tasklist[s])
	layout:set_right(rightside)

	w_wibox[s]:set_widget(layout)
end
--}}

--{{ mouse bindings
root.buttons(awful.util.table.join(
	awful.button({}, 3, function () mainmenu:toggle() end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
--}}

--{{ Key bindings
--globalkeys are the key combination that work on the display manager itself
globalkeys = awful.util.table.join(
	awful.key({ superkey, }, "t", function() awful.util.spawn(terminal)end),
	awful.key({ superkey, }, "s", function () awful.util.spawn("skype")end),
	awful.key({ superkey, }, "p", function () awful.util.spawn("evince") end),
	awful.key({ superkey, }, "u", function () awful.util.spawn("umlet") end),
	awful.key({ superkey, }, "b", function () awful.util.spawn("chromium")end),
    awful.key({ superkey, }, "g", function () awful.util.spawn("gedit") end),
    awful.key({ superkey, }, "i", function () awful.util.spawn(terminal .. " -e irssi") end),
    awful.key({ superkey, }, "l", function () awful.util.spawn("xtrlock") end),
    awful.key({ superkey, "Shift" }, "g", function () awful.util.spawn("gimp") end),
    awful.key({ superkey, "Shift" }, "m", function () awful.util.spawn("mypaint") end),
    awful.key({ superkey, "Shift" }, "l", function () awful.util.spawn("texmaker") end),
    awful.key({ superkey, "Shift" }, "b", function () awful.util.spawn("blender") end),
	--key bindings for easy access to the layouts
	awful.key({ superkey, }, "space", function () awful.layout.inc(layouts, 1) end),
	awful.key({ superkey, "Shift"}, "space", function () awful.layout.inc(layouts, -1) end),

    --key bindings for command prompt
    awful.key({ superkey, }, "r", function () w_promptbox[mouse.screen]:run() end)
)

--placeholder for clientkeys. key combination for specific window usage
clientkeys = awful.util.table.join(
	awful.key({ superkey, altkey }, "c", function (c) c:kill() end),
	awful.key({ superkey, }, "f", function (c) c.fullscreen = not c.fullscreen end),
	awful.key({ superkey, }, "n", function (c) c.minimized = true end),
	awful.key({ superkey, }, "m", 
		function (c) 
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical = not c.maximized_vertical
		end
	)
)

--implement superkey + numbkey change functionn
for i = 1, 9 do
	globalkeys = awful.util.table.join(
		globalkeys,
		--function to change the tag with superkey + number
		awful.key({ superkey }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end),
		--function to toggle 1..* tags on 1 screen
		awful.key({ superkey, "Control" }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end)
		)
end

--implement move and resize of windows
--also called clientbuttons. (mouse) buttons for specific window usage
clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ superkey }, 1, awful.mouse.client.move),
	awful.button({ superkey }, 3, awful.mouse.client.resize)
)

--set the keys to the manager
root.keys(globalkeys)
--}}

--{{ rule definition (how does certain thing react with the awesome)
awful.rules.rules = {
	-- client rules (client = window=)
	{ rule = { },
	  properties = { border_width = nil,
					 border_color = nil,
					 focus = awful.client.focus.filter,
					 keys = clientkeys,
					 buttons = clientbuttons}
	}
}
