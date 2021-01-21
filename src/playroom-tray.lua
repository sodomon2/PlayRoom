--[[--
 @package   PlayRoom
 @filename  playroom-tray.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      20.01.2021 22:37:58 -04
]]

function statusicon()
	visible = not visible
	if visible then
		ui.main_window:show_all()
	else
		ui.main_window:hide()
	end
end

function ui.tray:on_activate()
	statusicon()
end

function create_menu(event_button, event_time)
	menu = Gtk.Menu {
		Gtk.ImageMenuItem {
		label = "Preferences",
		image = Gtk.Image {
		stock = "gtk-preferences"
		},
		on_activate = function()
			ui.dialog_settings:run()
		end
        },
		Gtk.SeparatorMenuItem {},
		Gtk.ImageMenuItem {
			label = "About",
			image = Gtk.Image {
				stock = "gtk-about"
			},
			on_activate = function()
				ui.about_window:run()
				ui.about_window:hide()
			end
		},
		Gtk.SeparatorMenuItem {},
		Gtk.ImageMenuItem {
			label = "Quit",
			image = Gtk.Image {
				stock = "gtk-quit"
			},
			on_activate = function()
				quit()
			end
		}
	}
	menu:show_all()
	menu:popup(nil, nil, nil, event_button, event_time)
end

function ui.tray:on_popup_menu(ev, time)
	create_menu(ev, time)
end

