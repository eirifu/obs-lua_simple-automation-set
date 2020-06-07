-- Clock - Date and Four Timezones
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
last_text     = ""
activated     = false

-- User settings
source_name   = ""
main_offset    = 0

source_name1   = ""
offset1    = 0

source_name2   = ""
offset2    = 0

source_name3   = ""
offset3    = 0

source_date   = ""


----------- Main Functions -----------
function set_time_text()

	local utctime = os.date("!*t")
	local localtime = os.date("*t")
	
	local time_hour_zulu		= utctime.hour
	local time_minutes_zulu		= utctime.min

	local time_hour_target = localtime.hour
	local time_minutes_target = localtime.min
	
	--------------
	
	local time_text		= string.format(" %02d:%02d ", time_hour_target, time_minutes_target)	
	
	local sideclock1 = string.format(" %02d ", ((time_hour_zulu + offset1) % 24))
	local sideclock2 = string.format(" %02d ", ((time_hour_zulu + offset2) % 24))
	local sideclock3 = string.format(" %02d ", ((time_hour_zulu + offset3) % 24))
	
	local dateclock = string.format(" %d-%02d-%02d ",localtime.year, localtime.month, localtime.day)
	
	--------------
	



	if utctime ~= last_text then
		local source = obs.obs_get_source_by_name(source_name)
		if source ~= nil then
			local settings = obs.obs_data_create()
			obs.obs_data_set_string(settings, "text", time_text)
			obs.obs_source_update(source, settings)
			obs.obs_data_release(settings)
			obs.obs_source_release(source)
		end
		
		local source1 = obs.obs_get_source_by_name(source_name1)
		if source1 ~= nil then
			local settings1 = obs.obs_data_create()
			obs.obs_data_set_string(settings1, "text", sideclock1)
			obs.obs_source_update(source1, settings1)
			obs.obs_data_release(settings1)
			obs.obs_source_release(source1)
		end
		
		local source2 = obs.obs_get_source_by_name(source_name2)
		if source2 ~= nil then
			local settings2 = obs.obs_data_create()
			obs.obs_data_set_string(settings2, "text", sideclock2)
			obs.obs_source_update(source2, settings2)
			obs.obs_data_release(settings2)
			obs.obs_source_release(source2)
		end
		
		local source3 = obs.obs_get_source_by_name(source_name3)
		if source3 ~= nil then
			local settings3 = obs.obs_data_create()
			obs.obs_data_set_string(settings3, "text", sideclock3)
			obs.obs_source_update(source3, settings3)
			obs.obs_data_release(settings3)
			obs.obs_source_release(source3)
		end
		
		local source4 = obs.obs_get_source_by_name(source_date)
		if source4 ~= nil then
			local settings4 = obs.obs_data_create()
			obs.obs_data_set_string(settings4, "text", dateclock)
			obs.obs_source_update(source4, settings4)
			obs.obs_data_release(settings4)
			obs.obs_source_release(source4)
		end
		
		
	end

	last_text = utctime
end


----------- Triggers -----------

function activate(activating)
	if activated == activating then
		return
	end

	activated = activating

	if activating then
		obs.timer_add(set_time_text, 1000)
	else
		obs.timer_remove(set_time_text)
	end
end

function activate_signal(cd, activating)
	local source = obs.calldata_source(cd, "source")
	if source ~= nil then
		local name = obs.obs_source_get_name(source)
		if (name == source_name) then
			activate(activating)
		end
	end
end

function source_activated(cd)
	activate_signal(cd, true)
end

function source_deactivated(cd)
	activate_signal(cd, false)
end


----------- User Settings in the OBS script menu -----------

function script_description()
	return "Clock - Date and Four Timezones \nUTC hour adjustments only\n\nby Eiri Sanada @eirifu eiri.sanada at gmail dot com\nLicense: GPLv3"
end

function script_properties()
	local props = obs.obs_properties_create()

	local p = obs.obs_properties_add_list(props, "source", "Main Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" or source_id == "text_gdiplus_v2" then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	obs.obs_properties_add_int(props, "offset", "Main Offset", -12, 12, 1)

-----------------

	local y = obs.obs_properties_add_list(props, "source1", "Side Clock Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources2 = obs.obs_enum_sources()
	if sources2 ~= nil then
		for _, source in ipairs(sources2) do
			source_id = obs.obs_source_get_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" or source_id == "text_gdiplus_v2"  then
				local name1 = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(y, name1, name1)
			end
		end
	end
	obs.source_list_release(sources2)

	obs.obs_properties_add_int(props, "offset1", "Side Clock Offset", -12, 12, 1)
	
	local o = obs.obs_properties_add_list(props, "source2", "Side Clock Source 2", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources3 = obs.obs_enum_sources()
	if sources3 ~= nil then
		for _, source in ipairs(sources3) do
			source_id = obs.obs_source_get_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" or source_id == "text_gdiplus_v2"  then
				local name2 = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(o, name2, name2)
			end
		end
	end
	obs.source_list_release(sources3)

	obs.obs_properties_add_int(props, "offset2", "Side Clock Offset 2", -12, 12, 1)
	
	local i = obs.obs_properties_add_list(props, "source3", "Side Clock Source 3", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources4 = obs.obs_enum_sources()
	if sources4 ~= nil then
		for _, source in ipairs(sources4) do
			source_id = obs.obs_source_get_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" or source_id == "text_gdiplus_v2"  then
				local name3 = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(i, name3, name3)
			end
		end
	end
	obs.source_list_release(sources4)

	obs.obs_properties_add_int(props, "offset3", "Side Clock Offset 3", -12, 12, 1)
	
	local u = obs.obs_properties_add_list(props, "source4", "Date Clock Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources5 = obs.obs_enum_sources()
	if sources5 ~= nil then
		for _, source in ipairs(sources5) do
			source_id = obs.obs_source_get_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" or source_id == "text_gdiplus_v2"  then
				local name4 = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(u, name4, name4)
			end
		end
	end
	obs.source_list_release(sources5)


	return props
end


function script_update(settings)

	source_name = obs.obs_data_get_string(settings, "source")
	main_offset = obs.obs_data_get_int(settings, "offset")

	source_name1 = obs.obs_data_get_string(settings, "source1")
	offset1 = obs.obs_data_get_int(settings, "offset1")
	
	source_name2 = obs.obs_data_get_string(settings, "source2")
	offset2 = obs.obs_data_get_int(settings, "offset2")
	
	source_name3 = obs.obs_data_get_string(settings, "source3")
	offset3 = obs.obs_data_get_int(settings, "offset3")
	
	source_date = obs.obs_data_get_string(settings, "source4")


	activate(true) -- leave at bottom to immediately apply settings
	
end

function script_defaults(settings)
	obs.obs_data_set_default_int(settings, "offset", 0)
	obs.obs_data_set_default_int(settings, "offset1", 0)
	obs.obs_data_set_default_int(settings, "offset2", 0)
	obs.obs_data_set_default_int(settings, "offset3", 0)

end

function script_save(settings)

end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)


end
