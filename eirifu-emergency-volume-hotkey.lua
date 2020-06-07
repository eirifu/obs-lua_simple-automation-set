-- Emergency Volume Mod Hotkey
-- by Eiri Sanada, 2020
-- @eirifu eiri.sanada at gmail dot com
-- License: GPLv3

--[[
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>
]]

obs           = obslua

-- Loops
count = 1

-- User settings
source_name   = ""
hotkey_id     = obs.OBS_INVALID_HOTKEY_ID

volume1 = 0
volume2 = 0

-- Derived values
volume1f = 0.0
volume2f = 0.0

----------- Main Functions -----------

function volswitch(pressed)
	if not pressed then
		return
	end

	local source = obs.obs_get_source_by_name(source_name)
	if count == 1 then
		obs.obs_source_set_volume(source, volume1f)
		count = 2
	else
		obs.obs_source_set_volume(source, volume2f)
		count = 1
	end
	

-- OBS' mixer range: -96 dB to +26 dB

-- Decibel to Float formula: float = 10^(dB/20)
-- inverse: 20 log(float) = dB
	
end

function volswitch_button_clicked(props, p)
	volswitch(true)
	return false
end


----------- Triggers -----------



----------- User Settings in the OBS script menu -----------

function script_description()
	return "Emergency Volume Mod Hotkey\nSwitch a source between two volume levels,\nin the event that OBS is only accessible through hotkeys.\n\n\nby Eiri Sanada @eirifu eiri.sanada at gmail dot com\nLicense: GPLv3"
end

function script_properties()
	local props = obs.obs_properties_create()

	local p = obs.obs_properties_add_list(props, "source", "Volume Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_id(source)
			if source_id == "wasapi_output_capture" then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
			end
		end
	end
	obs.source_list_release(sources)
	
	obs.obs_properties_add_int(props, "volume1", "Volume A", -96, 26, 1)
	obs.obs_properties_add_int(props, "volume2", "Volume B", -96, 26, 1)

	obs.obs_properties_add_button(props, "volswitch_button", "Switch Volume", volswitch_button_clicked)

	return props
end

function script_update(settings)

	source_name = obs.obs_data_get_string(settings, "source")
	
	volume1f = 10 ^ (obs.obs_data_get_int(settings, "volume1") / 20)
	volume2f = 10 ^ (obs.obs_data_get_int(settings, "volume2") / 20)

	count = 1
	volswitch(true)
end

function script_defaults(settings)

	obs.obs_data_set_default_int(settings, "volume1", -9)
	obs.obs_data_set_default_int(settings, "volume2", -18)

end

function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "volswitch_hotkey", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)

end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)

	hotkey_id = obs.obs_hotkey_register_frontend("volume_switcher", "Switch Volume", volswitch)
	local hotkey_save_array = obs.obs_data_get_array(settings, "volswitch_hotkey")
	obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
	
end
