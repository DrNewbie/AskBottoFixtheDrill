if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

if not BotFixDrill then
	return
end

local _delay_t = 0

Hooks:PreHook(TimerGui, "update", "BotFixDrill_TimerGui_update", function(tim, unit, t, dt)
	if tim._jammed and t > _delay_t then
		_delay_t = t + 0.25
		local _AIs = managers.groupai:state():all_AI_criminals() or {}
		if _AIs then
			for _, data in pairs(_AIs) do
				if data.unit and alive(data.unit) and data.unit:brain()._current_logic_name ~= "disabled" and not BotFixDrill.shout2cancel[data.unit:name():key()] then
					local drill = BotFixDrill:Get_All_Drill_Unit_In_Sphere(data.unit:position(), BotFixDrill.Fix_Distance)
					local _dd = BotFixDrill.target_drill_table[data.unit:name():key()]
					if drill and (not _dd or #_dd <= 0 or not _dd.start_time) then
						BotFixDrill:Bot_Fix_This_Drill(data.unit, drill)
						break
					end
				end
			end
		end
	end
	if not tim._jammed then
		for k, v in pairs(BotFixDrill.target_drill_table) do
			if tim._unit and v and v.drill and v.drill == tim._unit then
				BotFixDrill:Animal_End_Fixing(v.fixer)
				BotFixDrill.target_drill_table[k] = {}
				if v.fixer and alive(v.fixer) and v.should_stay then
					v.fixer:movement():set_should_stay(v.should_stay)
				end
			end
		end
	end
end)