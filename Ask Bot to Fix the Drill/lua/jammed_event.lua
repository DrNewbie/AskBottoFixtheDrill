if Network:is_client() then
	return
end

local _delay_t = 0

_G.CustomWaypoints = _G.CustomWaypoints or {}

_G.Keepers = _G.Keepers or {}

AskBot2Stealth_Runner = AskBot2Stealth_Runner or nil

Hooks:PostHook(TimerGui, "init", "F_"..Idstring("BotFixDrill_TimerGui_init"):key(), function(tim)
	if tim._unit and tim._unit.interaction and tim._unit:interaction() then
		local _nonfix = {
			huge_lance = true,
			huge_lance_jammed = true,
			cas_fix_bfd_drill = true
		}
		local itname = tostring(tim._unit:interaction().tweak_data)
		if _nonfix[itname] then
			tim._botfix = false
		else
			tim._botfix = true
			tim._botfix_t = 0
		end
	end
end)

Hooks:PreHook(TimerGui, "update", "F_"..Idstring("BotFixDrill_TimerGui_update"):key(), function(tim, unit, t, dt)
	if not tim._botfix or _delay_t > t then
		return
	end
	_delay_t = t + 1
	if managers.groupai:state():whisper_mode() or not CustomWaypoints or not Keepers then
		return
	end
	if not tim._jammed and tim._botfix_t > 0 then
		tim._botfix_t = 0
	end
	if tim._botfix_t > t then
		return
	end
	local PlyStandard = managers.player and managers.player:player_unit() and managers.player:player_unit():movement() and managers.player:player_unit():movement()._states.standard or nil
	if not PlyStandard or managers.player:player_unit():character_damage():need_revive() then
		return
	end
	local itname = tostring(tim._unit:interaction().tweak_data)
	if tim._jammed and tim._unit and tweak_data.interaction[itname] then
		local _AIs = managers.groupai:state():all_AI_criminals() or {}
		if _AIs then
			for _, data in pairs(_AIs) do
				if data.unit and alive(data.unit) and data.unit:brain()._current_logic_name ~= "disabled" then
					tim._botfix_t = t + (tweak_data.interaction[itname].timer or 25) + math.round(mvector3.distance(tim._unit:position(), data.unit:position())/100) + 5
					CustomWaypoints:PlaceMyWaypoint(tim._unit:position())
					AskBot2Stealth_Runner = data.unit
					DelayedCalls:Add("F_"..Idstring("BotFixDrill_Run"..tostring(tim._unit:key())):key(), 0.5, function()
						PlyStandard:_start_action_intimidate_alt(t, true)
					end)
				end
			end
		end
	end
end)