--[[--
 @package   MoonAudio
 @filename  moonaudio-app.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      18.01.2021 20:09:32 -04
]]

pipeline    = Gst.Pipeline.new('pipeline')
play        = Gst.ElementFactory.make('playbin', 'play')
main_loop   = GLib.MainLoop()

function ns_to_str (ns)
	if (not ns) then return nil end
	seconds = ns / Gst.SECOND
	minutes = math.floor(seconds / 60)
	seconds = math.floor(seconds - (minutes * 60))
	str = minutes .. ':' .. seconds
	return str
end

function get_duration()
	duration_ns = pipeline:query_duration(Gst.Format.TIME)
	duration 	= duration_ns and ns_to_str(duration_ns) or '0:00'
	return duration
end

function get_duration_position()
	position_ns = pipeline:query_position(Gst.Format.TIME)
	position 	= position_ns and ns_to_str(position_ns) or '0:00'
	duration_ns = pipeline:query_duration(Gst.Format.TIME)
	duration 	= duration_ns and ns_to_str(duration_ns) or '0:00'
	return position .. ' / ' .. duration
end

local btn_play_trigger = true
function play_media()
	ui.img_media_state.icon_name = 'media-playback-pause'

	GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1,function()
		local duration = pipeline:query_duration(Gst.Format.TIME)
		if duration then
			ui.playlist_slider:set_range(0, math.floor(duration/Gst.SECOND) )
		end
		local current = pipeline:query_position(Gst.Format.TIME)
		if current then
			btn_play_trigger = false
			ui.playlist_slider:set_value( math.floor(current / Gst.SECOND) )
			btn_play_trigger = true
		end
		ui.playlist_duration.label = get_duration_position()
		return true
	end)
	pipeline.state = 'PLAYING'
	main_loop:run()
	pipeline.state = 'READY'
end

local function bus_callback(bus, message)
	if message.type.ERROR then
		print('Error:', message:parse_error().message)
		pipeline.state = 'READY'
	elseif message.type.EOS then
		print 'end of stream'
	end

	return true
end

--function get_music_id()
	--local selection = ui.playlist_view:get_selection()
	--selection.mode = 'SINGLE'
	--local model, iter = selection:get_selected()
	--if model and iter then
		--id_music = model:get_value(iter, 0):get_int()
		--return id_music
	--end
--end


pipeline:add_many(play)
pipeline.bus:add_watch(GLib.PRIORITY_DEFAULT, bus_callback)

function ui.playlist_slider:on_value_changed(id)
	if btn_play_trigger then
		local value = ui.playlist_slider:get_value()
		pipeline:seek_simple(
			Gst.Format.TIME,
			{Gst.SeekFlags.FLUSH, Gst.SeekFlags.KEY_UNIT},
			value * Gst.SECOND
		)
	end
end

