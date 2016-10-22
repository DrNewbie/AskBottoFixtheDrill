if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

if not BotFixDrill then
	return
end

local _t_delay = 0

Hooks:Add("GameSetupUpdate", "BotFixDrillGameSetupUpdate", function(t, dt)
	if Utils:IsInHeist() then
		if t > _t_delay then
			_t_delay = math.round(t) + 1
			local _now_t = math.round(TimerManager:game():time())
			for k, v in pairs(BotFixDrill.target_drill_table) do
				if type(v.start_time) ~= "number" then
					BotFixDrill:Animal_End_Fixing(v.fixer)
					BotFixDrill.target_drill_table[k] = {}
					BotFixDrill.target_drill_table[k] = nil
					if v.fixer and alive(v.fixer) and v.should_stay then
						v.fixer:movement():set_should_stay(v.should_stay)
					end
				end
				if (type(v.start_time) == "number" and v.start_time < _now_t) or
					(not v.drill or not v.drill:base() or not v.drill:base()._jammed) or 
					(v.fixer and alive(v.fixer) and v.fixer:brain() and v.fixer:brain()._current_logic_name == "disabled") then
					if v.drill and v.drill:base() and v.drill:base()._jammed and v.fixer and alive(v.fixer) and v.fixer:brain()._current_logic_name ~= "disabled" then
						if v.drill:timer_gui() then
							v.drill:timer_gui():set_jammed(false)
						end
						if v.drill:interaction() then
							v.drill:interaction():set_active(false, true)
						end
					end
					if v.fixer and alive(v.fixer) and v.should_stay then
						v.fixer:movement():set_should_stay(v.should_stay)
					end
					BotFixDrill:Animal_End_Fixing(v.fixer)
					BotFixDrill.target_drill_table[k] = {}
					BotFixDrill.target_drill_table[k] = nil
				end
			end
		end
	end
end)