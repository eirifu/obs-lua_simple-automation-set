obs           = obslua
source_name   = ""
total_seconds = 0

cur_seconds   = 0


-- Function to set the time text
function set_time_text()
	local seconds       = math.floor(cur_seconds % 60)
	local total_minutes = math.floor(cur_seconds / 60)
	local minutes       = math.floor(total_minutes % 60)
	local text          = string.format("%02d:%02d", minutes, seconds)


-- Making negative time work

	if cur_seconds < 0 then
		local min_display
		local sec_display
		
		sec_display = 60 - seconds
		if sec_display == 60 then
			sec_display = 0
			min_display = total_minutes
		else
			min_display = total_minutes + 1
		end
		
		if min_display == 0 then
			text = string.format("-%d:%02d", min_display, sec_display)
		else
			text = string.format("%02d:%02d", min_display, sec_display)
		end
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

function timer_callback()
	cur_seconds = cur_seconds + 1

	set_time_text()
end

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

----------------------------------------------------------

function script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_int(props, "duration", "Starting Minute", -9999, 9999, 1)

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

	return props
end


function script_description()
	return "It's the countdown timer, except it goes up. For tracking screen durations.\n\nModified by Eiri"
end


function script_update(settings)
	activate(false)

	total_seconds = obs.obs_data_get_int(settings, "duration") * 60
	source_name = obs.obs_data_get_string(settings, "source")

	reset(true)
end


function script_defaults(settings)
	obs.obs_data_set_default_int(settings, "duration", 0)
end


function script_save(settings)

end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)

end
