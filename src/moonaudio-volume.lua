--[[--
 @package   MoonAudio
 @filename  moonaudio-app.lua
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