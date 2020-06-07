-- Stream and Rec Indicators
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

source_name1   = ""

invertvis	= false

----------- Main Functions -----------
function set_item()



	if invertvis == false then

		local source = obs.obs_get_source_by_name(source_name)
		if source ~= nil then
			obs.obs_source_set_enabled(source, obs.obs_frontend_streaming_active())
		end
			
		local source1 = obs.obs_get_source_by_name(source_name1)
		if source1 ~= nil then
			obs.obs_source_set_enabled(source1, obs.obs_frontend_recording_active())
		end
		
	else
		local source = obs.obs_get_source_by_name(source_name)
		if source ~= nil then
			obs.obs_source_set_enabled(source, not obs.obs_frontend_streaming_active())
		end
			
		local source1 = obs.obs_get_source_by_name(source_name1)
		if source1 ~= nil then
			obs.obs_source_set_enabled(source1, not obs.obs_frontend_recording_active())
		end

	end

end


----------- Triggers -----------

function activate(activating)
	if activated == activating then
		return
	end

	activated = activating

	if activating then
		obs.timer_add(set_item, 1000)
	else
		obs.timer_remove(set_item)
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
	return "Stream and Rec Indicators \nMakes a source visible or invisible based on condition.\n\nby Eiri Sanada @eirifu eiri.sanada at gmail dot com\nLicense: GPLv3"
end

function script_properties()
	local props = obs.obs_properties_create()

	local p = obs.obs_properties_add_list(props, "source", "Stream Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_id(source)
			local name = obs.obs_source_get_name(source)
			obs.obs_property_list_add_string(p, name, name)

		end
	end
	obs.source_list_release(sources)


	local y = obs.obs_properties_add_list(props, "source1", "Recording Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources2 = obs.obs_enum_sources()
	if sources2 ~= nil then
		for _, source in ipairs(sources2) do
			source_id = obs.obs_source_get_id(source)
			local name1 = obs.obs_source_get_name(source)
			obs.obs_property_list_add_string(y, name1, name1)
		end
	end
	obs.source_list_release(sources2)

	obs.obs_properties_add_bool(props, "invert", "Invert Visibility")

	return props
end


function script_update(settings)

	source_name = obs.obs_data_get_string(settings, "source")

	source_name1 = obs.obs_data_get_string(settings, "source1")

	invertvis = obs.obs_data_get_bool(settings, "invert")

	activate(true) -- leave at bottom to immediately apply settings
	
end

function script_defaults(settings)


end

function script_save(settings)

end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)


end
