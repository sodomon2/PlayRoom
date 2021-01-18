#!/usr/bin/env lua

require 'libraries.middleclass'
utils     = require 'libraries.utils'
inifile   = require 'libraries.inifile'

lgi       = require 'lgi'
GLib	  = lgi.GLib
GObject   = lgi.GObject
Gtk       = lgi.require('Gtk', '3.0')
Gst       = lgi.require("Gst", "1.0")

builder   = Gtk.Builder()
app		  = Gtk.Application()

builder:add_from_file('MoonAudio.ui')
ui = builder.objects

utils:create_config('MoonAudio','moonaudio.ini')
dir 				= ('%s/MoonAudio'):format(GLib.get_user_config_dir())
conf				= inifile:load(('%s/moonaudio.ini'):format(dir))

function quit()
	Gtk.main_quit()
	os.exit(0)
end 

function ui.main_window:on_destroy()
	quit()
end

function app:on_activate()
	ui.main_window:present()
	self:add_window(ui.main_window)
end

app:run()
