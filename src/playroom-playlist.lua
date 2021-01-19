--[[--
 @package   PlayRoom
 @filename  playroom-playlist.lua
 @version   1.0
 @autor     The Moonsteal Team
 @date      18.01.2021 20:05:49 -04
]]

function scandir(directory)
	local pfile = assert(io.popen(("find '%s' -mindepth 1 -maxdepth 1 -printf '%%f\\0'"):format(directory), 'r'))
	local list = pfile:read('*a')
	pfile:close()

	local folders = {}

	for filename in string.gmatch(list, '[^%z]+') do
		table.insert(folders, filename)
	end

	return folders
end

function list_view()
	if ( ui.entry_directory.text ~= "" ) then
		ui.playlist:clear()
		for i, item in pairs(scandir(ui.entry_directory.text)) do
			ui.playlist:append({
				i,
				item,
				'[WIP]'
			})
		end
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

