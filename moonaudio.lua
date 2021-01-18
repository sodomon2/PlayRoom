#!/usr/bin/env lua

lgi       = require 'lgi'             -- La libreria que me permitira usar GTK
GObject   = lgi.GObject               -- Parte de lgi
Gtk       = lgi.require('Gtk', '3.0') -- El objeto GTK
Gst       = lgi.require("Gst", "1.0")

builder   = Gtk.Builder()
app		  = Gtk.Application()

builder:add_from_file('MoonAudio.ui')
ui = builder.objects

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
