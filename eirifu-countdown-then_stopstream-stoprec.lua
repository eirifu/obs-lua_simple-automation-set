------------------------------------------------------------------------
-- Countdown To Action
-- Countdown Timer, except that it performs an action at -1 seconds.
-- 
--    by eirifu / eiri.sanada
-- License: GPLv3
------------------------------------------------------------------------
obs           = obslua

cur_seconds   = 0
last_text     = ""
activated     = false

-- Exposed Variables
source_name   = ""
total_seconds = 0
stop_text     = ""
debugmode     = false


------------------------------------------------------------------------
-- Main Actions
------------------------------------------------------------------------

-- Activated at -1 seconds
function count_trigger()
	if debugmode == false then
	
	obs.obs_frontend_streaming_stop()
	obs.obs_frontend_recording_stop()
	
	end

end

-- Function to set the time text
function set_time_text()
	local seconds       = math.floor(cur_seconds % 60)
	local total_minutes = math.floor(cur_seconds / 60)
	local minutes       = math.floor(total_minutes % 60)
	local hours         = math.floor(total_minutes / 60)
	local text          = string.format("%d:%02d", minutes, seconds)

	if cur_seconds < 0 then
		text = stop_text
	end

	if text ~= last_text then
		local source = obs.obs_get_source_by_name(source_name)
		if source ~= nil then
			local settings = obs.obs_data_create()
			obs.obs_data_set_string(settings, "text", text)
			obs.obs_source_update(source, settings)
			obs.obs_data_release(settings)
			obs.obs_source_release(source)
		end
	end

	last_text = text
end


-- Clock cycle
function timer_callback()
	cur_seconds = cur_seconds - 1
	
	if cur_seconds < 0 then
		obs.remove_current_callback()
	--	cur_seconds = 0
		count_trigger()
	end

	set_time_text()

end

function reset(pressed)
	if not pressed then
		return
	end

	activate(false)
	local source = obs.obs_get_source_by_name(source_name)
	if source ~= nil then
		local active = obs.obs_source_active(source)
		obs.obs_source_release(source)
		activate(active)
	end
end

function reset_button_clicked(props, p)
	reset(true)
	return false
end

------------------------------------------------------------------------
-- ACTIVATION CYCLE
------------------------------------------------------------------------

function activate(activating)
	if activated == activating then
		return
	end

	activated = activating

	if activating then
		cur_seconds = total_seconds
		set_time_text()
		obs.timer_add(timer_callback, 1000)
	else
		obs.timer_remove(timer_callback)
	end
end

-- Called when a source is activated/deactivated
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


------------------------------------------------------------------------
-- SAVE/LOAD AND SETTINGS CYCLE
------------------------------------------------------------------------

function script_description()
	return "Countdown Timer, except that it performs an action at -1 seconds.\nAction: Stop Recording and Streaming\n\nby eirifu / eiri.sanada"
end

-- Shows up in Script Menu
function script_properties()
	local props = obs.obs_properties_create()
	
	---- Setting a Source --------------------------------------------
	local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
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
	------------------------------------------------------------------
	
	obs.obs_properties_add_int(props, "duration", "Length (sec)", 1, 10000, 1)

	obs.obs_properties_add_text(props, "stop_text", "Text at 0", obs.OBS_TEXT_DEFAULT)
	
	obs.obs_properties_add_bool(props, "debugmode", "Disable Action (Debug)")



	return props
end

-- Runs when properties in the Script Menu are updated
-- Exposed variables are set here
function script_update(settings)
	activate(false)

	total_seconds = obs.obs_data_get_int(settings, "duration")
	source_name = obs.obs_data_get_string(settings, "source")
	stop_text = obs.obs_data_get_string(settings, "stop_text")

	reset(true)
end

function script_defaults(settings)
	obs.obs_data_set_default_int(settings, "duration", 60)
	obs.obs_data_set_default_string(settings, "stop_text", " ")
end

-- Settings set via the Script Menu properties are saved automatically.
function script_save(settings)

end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)

end
