if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

if not BotFixDrill then
	return
end

BotFixDrill.target_drill_table = BotFixDrill.target_drill_table or {}

local _BotFixDrill_PlayerStandard_get_intimidation_action = PlayerStandard._get_intimidation_action

function PlayerStandard:_get_intimidation_action(prime_target, ...)
	local voice_type, plural, prime_target = _BotFixDrill_PlayerStandard_get_intimidation_action(self, prime_target, ...)
	if (voice_type == "come" or voice_type == "boost") and prime_target and prime_target.unit and prime_target.unit_type == 2 then
		local _key = prime_target.unit:name():key()
		if not BotFixDrill.target_drill_table[_key] then
			local drill = Get_All_Drill_Unit_In_Sphere(prime_target.unit:position(), 200)
			if drill and prime_target.unit:brain()._current_logic_name ~= "disabled" then
				prime_target.unit:movement():set_rotation(drill:rotation())
				BotFixDrill.target_drill_table[_key] = {drill = drill, fixer = prime_target.unit, start_time = math.floor(TimerManager:game():time())+10}
				BotFixDrill:Animal_Do_Fixing(prime_target.unit)
			else
				drill = Get_All_Drill_Unit_In_Sphere(self._unit:position(), 200)
				if drill then
					BotFixDrill:Animal_Do_Fixing(prime_target.unit, true)
				end
			end
		end
	end
	return voice_type, plural, prime_target
end

function Get_All_Drill_Unit_In_Sphere(pos, area)
	local _unit = nil
	local _Unit_In_Sphere = World:find_units("sphere", pos, area) or {}
	for _, data in pairs(_Unit_In_Sphere) do
		if data and alive(data) and data:base() and data:base()._jammed then
			_unit = data
			break
		end
	end  
	return _unit
end