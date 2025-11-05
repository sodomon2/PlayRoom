--[[--
 @package   PlayRoom
 @filename  playroom-playlist.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      18.01.2021 20:05:49 -04
]]
 local content = {}
 local playlist = {}
 local discoverer = GstPbutils.Discoverer()

local function get_file_duration(uri)
	-- TODO: Implement discoverer:discover_uri_async, discoverer:discover_uri is blocking
	local info = discoverer:discover_uri(uri, 5 * Gst.SECOND) 
	if info then
		local duration_ns = info:get_duration()
		return ns_to_str(duration_ns)
	else
		return "N/A"
	end
end

-- thank https://gist.github.com/Miqueas/6b75b25731f9a785678951cfcef8c002
local function scandir(Path, Tab)
  local file = Gio.File.new_for_path(Path)
  local enum = file:enumerate_children("standard::name", Gio.FileQueryInfoFlags.NONE)
  local path = file:get_path() .. "/"

  local info = enum:next_file()
  local count = 1

	while info do
		local name = info:get_name()
		local file_type = info:get_file_type()
		local full_path = path .. name

		if file_type == "DIRECTORY" then
			Tab[count] = {
				Path = full_path,
				Files = {}
			}
			scandir(full_path, Tab[count].Files)
		else
			Tab[count] = {
				Path = full_path,
				Name = name
			}
		end

		info = enum:next_file()
		count = count + 1
		if file_type == 'DIRECTORY' then
    else
      local file_gio = Gio.File.new_for_path(full_path)
      local uri = file_gio:get_uri()
      local duration = get_file_duration(uri)
      table.insert(playlist, {
        full_path = full_path,
        name = name,
        duration = duration
      })
    end
	end
end

function list_view()
	if ( ui.entry_directory.text ~= "" ) then
		scandir(ui.entry_directory.text, content)
		ui.playlist:clear()
		for i, song in pairs(playlist) do
			local iter = ui.playlist:append()
			ui.playlist:set(iter,
				{ i, song.name, song.duration }
			)
		end
	end
end

function get_music()
	local id, title = get_data()
	local ext = title:match('%w+$')
	if ext == 'mp4' then
		ui.media_stack:set_visible_child_name('videos_view')
		ui.btn_back.sensitive = true
		ui.btn_forward.sensitive = false
	else
		ui.btn_back.sensitive = false
		ui.btn_forward.sensitive = false
		play.uri = ('file://%s'):format(playlist[id].full_path)
	end
end

function ui.btn_settings:on_clicked()
	ui.dialog_settings:run()
	ui.dialog_settings:hide()
end

function ui.btn_dialog_settings_ok:on_clicked()
	list_view()
	conf.general.playlist = ui.entry_directory.text
	inifile:save(('%s/playroom.ini'):format(dir), conf)
	ui.dialog_settings:hide()
end

function ui.btn_dialog_settings_cancel:on_clicked()
	ui.dialog_settings:hide()
end

