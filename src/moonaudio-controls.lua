--[[--
 @package   MoonAudio
 @filename  moonaudio-controls.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      18.01.2021 22:30:02 -04
]]

ui.volume_control:set_value(conf.general.volume)

function ui.volume_control:on_value_changed()
	local value = (math.floor(ui.volume_control:get_value())/100)
	ui.volume_control:set_range(0, 100 )
	if  (value == 1) then
		conf.general.volume = 100
	else
		conf.general.volume = value
	end
	play.volume = conf.general.volume
	print( value )
	inifile:save(('%s/moonaudio.ini'):format(dir), conf)
end


function ui.btn_stop:on_clicked()
	stop_media()
end

function ui.btn_play:on_clicked()
	stop_media()
	local id_music, title_music, duration_music = get_music()
	local ext = title_music:match('%w+$')
	if ext == 'mp4' then
		ui.media_stack:set_visible_child_name('videos_view')
		ui.btn_back.sensitive = true
		ui.btn_forward.sensitive = false
	end
	play.uri = ('file://%s/%s'):format(conf.general.playlist,title_music)
	play_media()
end

function ui.btn_back:on_clicked()
	ui.media_stack:set_visible_child_name('treeview')
	ui.btn_forward.sensitive = true
	self.sensitive = false
end

function ui.btn_forward:on_clicked()
	ui.media_stack:set_visible_child_name('videos_view')
	ui.btn_back.sensitive = true
	self.sensitive = false
end

function ui.videos:on_realize()
	print(self.window:get_xid())
	play:set_window_handle(self.window:get_xid())
end

-- paint the background
function ui.videos:on_draw(cr)
	cr:paint()
end
