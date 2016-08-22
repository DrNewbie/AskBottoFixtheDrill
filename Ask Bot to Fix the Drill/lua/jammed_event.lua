if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

if not BotFixDrill then
	return
end

local _delay_t = 0

local _BotFixDrill_TimerGui_update = TimerGui.update

function TimerGui:update(unit, t, dt)
	if self._jammed and t > _delay_t then
		_delay_t = t + 1
		local _AIs = managers.groupai:state():all_AI_criminals() or {}
		if _AIs then
			for _, data in pairs(_AIs) do
				if data.unit and alive(data.unit) and data.unit:brain()._current_logic_name ~= "disabled" then
					local drill = BotFixDrill:Get_All_Drill_Unit_In_Sphere(data.unit:position(), BotFixDrill.Fix_Distance)
					if drill and not BotFixDrill.target_drill_table[data.unit:name():key()] then
						BotFixDrill:Bot_Fix_This_Drill(data.unit, drill)
						break
					end
				end
			end
		end
	end
	_BotFixDrill_TimerGui_update(self, unit, t, dt)
end