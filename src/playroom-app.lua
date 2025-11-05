--[[--
 @package   PlayRoom
 @filename  playroom-app.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      18.01.2021 20:09:32 -04
]]

pipeline    = Gst.Pipeline.new('pipeline')
play        = Gst.ElementFactory.make('playbin', 'play')
main_loop   = GLib.MainLoop()

function ns_to_str (ns)
  if (not ns) or (ns <= 0) then
    return "00:00:00"
  end

  local total_seconds = math.floor(ns / Gst.SECOND)
  local hours = math.floor(total_seconds / 3600)
  local minutes = math.floor((total_seconds % 3600) / 60)
  local seconds = math.floor(total_seconds % 60)

  return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function get_duration_position()
  local position_ns = pipeline:query_position(Gst.Format.TIME)
  local duration_ns = pipeline:query_duration(Gst.Format.TIME)

  local position = ns_to_str(position_ns)
  local duration = ns_to_str(duration_ns)

  return position .. ' / ' .. duration
end

local btn_play_trigger = true
function play_media()
	ui.playlist_slider.sensitive = true
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

function stop_media()
	pipeline.state = 'NULL'
	main_loop:quit()
	ui.playlist_slider:set_value(0)
	ui.img_media_state.icon_name = 'media-playback-start'
	ui.playlist_duration.label = '00:00:00 / 00:00:00'
	ui.media_stack:set_visible_child_name('treeview')
	ui.btn_forward.sensitive = true
	ui.btn_back.sensitive = false
	ui.playlist_slider.sensitive = false
	ui.player_reveal:set_reveal_child(false)
end

local function bus_callback(bus, message)
	if message.type.ERROR then
		print('Error:', message:parse_error().message)
		pipeline.state = 'READY'
	elseif message.type.EOS then
		print 'end of stream'
		ui.player_reveal:set_reveal_child(false)
		stop_media()
	end

	return true
end

function ui.playlist_view:on_row_activated()
	stop_media()
	get_music()
	play_media()
end

function get_data()
	local selection = ui.playlist_view:get_selection()
	selection.mode = 'SINGLE'
	local model, iter = selection:get_selected()
	if model and iter then
		local id = model:get_value(iter, 0):get_int()
		local title = model:get_value(iter, 1):get_string()
		local duration = model:get_value(iter, 2):get_string()
		return id, title, duration
	end
end

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

