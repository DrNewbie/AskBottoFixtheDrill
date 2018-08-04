if Network:is_client() then
	return
end

_G.CustomWaypoints = _G.CustomWaypoints or {}

_G.Keepers = _G.Keepers or {}

BotFixDrill_Runner = BotFixDrill_Runner or {}

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
	--Could it be fixed??
	if not tim._botfix or not tim._unit then
		return
	end
	if not tim._jammed then
		if tim._botfix_t then
			tim._botfix_t = nil
			CustomWaypoints:RemoveMyWaypoint()
		end
		return
	end
	--Stealth?? Keepers??
	if managers.groupai:state():whisper_mode() or not CustomWaypoints or not Keepers then
		return
	end
	--Ply alive??
	local PlyStandard = managers.player and managers.player:player_unit() and managers.player:player_unit():movement() and managers.player:player_unit():movement()._states.standard or nil
	if not PlyStandard or managers.player:player_unit():character_damage():need_revive() then
		return
	end
	--Fixing??
	if tim._botfix_t then
		tim._botfix_t = tim._botfix_t - dt
		if tim._botfix_t < 0 then
			tim._botfix_t = nil
		end
		return
	end
	
	local itname = tostring(tim._unit:interaction().tweak_data)
	local _AIs = managers.groupai:state():all_AI_criminals() or {}
	for _, data in pairs(_AIs) do
		if data.unit and alive(data.unit) and data.unit:brain()._current_logic_name ~= "disabled" then
			local fixer = data.unit
			local fixer_key = tostring(fixer:key())
			if BotFixDrill_Runner[fixer_key] then
				if BotFixDrill_Runner[fixer_key] <= t then
					BotFixDrill_Runner[fixer_key] = nil
				end
			end
			if not BotFixDrill_Runner[fixer_key] then				
				tim._botfix_t = 1 + (tweak_data.interaction[itname].timer or 25) + math.round(mvector3.distance(tim._unit:position(), fixer:position())/100) + 5
				BotFixDrill_Runner[fixer_key] = t + tim._botfix_t + 5
				CustomWaypoints:RemoveMyWaypoint()
				CustomWaypoints:PlaceMyWaypoint(tim._unit:position())
				DelayedCalls:Add("F_"..Idstring("BotFixDrill_Run"..tostring(tim._unit:key())):key(), 7, function()
					PlyStandard:_start_action_intimidate_alt(t, fixer)
				end)
				DelayedCalls:Add("F_"..Idstring("BotFixDrill_Del_WP"..tostring(tim._unit:key())):key(), tim._botfix_t - 0.5, function()
					CustomWaypoints:RemoveMyWaypoint()
				end)
				break
			end
		end
	end	
end)