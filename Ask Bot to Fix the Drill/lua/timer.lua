if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

if not BotFixDrill then
	return
end

BotFixDrill.target_drill_table = BotFixDrill.target_drill_table or {}

local _t_delay = 0

Hooks:Add("GameSetupUpdate", "BotFixDrillGameSetupUpdate", function(t, dt)
	if Utils:IsInHeist() then
		if t > _t_delay then
			_t_delay = math.round(t) + 1
			for k, v in pairs(BotFixDrill.target_drill_table) do
				if type(v.start_time) == "number" and v.start_time < t or
					not v.drill or not v.drill:base() or not v.drill:base()._jammed or 
					(v.fixer and alive(v.fixer) and v.fixer:brain()._current_logic_name == "disabled") then
					if v.drill and v.drill:base() and v.drill:base()._jammed then
						v.drill:timer_gui():set_jammed(false)
						v.drill:interaction():set_active(false, true)
						v.drill:interaction():check_for_upgrade()
					end
					BotFixDrill:Animal_End_Fixing(v.fixer)
					BotFixDrill.target_drill_table[k] = {}
				end
			end
		end
	end
end)