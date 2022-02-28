#!/usr/bin/env lua

--[[--
 @package   PlayRoom
 @filename  playroom.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      18.01.2021 19:09:28 -04
]]

require 'libraries.middleclass'
utils     = require 'libraries.utils'
inifile   = require 'libraries.inifile'

lgi       = require 'lgi'
GLib	  = lgi.GLib
GObject   = lgi.GObject
Gtk       = lgi.require('Gtk', '3.0')
Gst       = lgi.require("Gst", "1.0")
GdkX11    = lgi.GdkX11
if tonumber(Gst._version) >= 1.0 then
	GstVideo = lgi.GstVideo
end

builder   = Gtk.Builder()
app		  = Gtk.Application()

builder:add_from_file('Playroom.ui')
ui = builder.objects

utils:create_config('playroom','playroom.ini')
dir 				= ('%s/playroom'):format(GLib.get_user_config_dir())
conf				= inifile:load(('%s/playroom.ini'):format(dir))

require('src.playroom-playlist')
require('src.playroom-app')
require('src.playroom-controls')
require('src.playroom-tray')

function ui.btn_about:on_clicked()
	ui.about_window:run()
	ui.about_window:hide()
end

function quit()
	Gtk.main_quit()
	main_loop:quit()
	os.exit(0)
end 

function ui.btn_quit:on_clicked()
	quit()
end

function ui.main_window:on_destroy()
	quit()
end

function app:on_activate()
	ui.btn_back.sensitive = false
	ui.entry_directory.text = conf.general.playlist
	ui.main_window:present()
	self:add_window(ui.main_window)
  list_view()
end

app:run()
