if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

if not BotFixDrill then
	return
end

local _BotFixDrill_PlayerStandard_get_intimidation_action = PlayerStandard._get_intimidation_action

function PlayerStandard:_get_intimidation_action(prime_target, ...)
	local voice_type, plural, prime_target = _BotFixDrill_PlayerStandard_get_intimidation_action(self, prime_target, ...)
	if (voice_type == "come" or voice_type == "boost") and prime_target and prime_target.unit and prime_target.unit_type == 2 and
		prime_target.unit:brain() and prime_target.unit:brain()._current_logic_name ~= "disabled" and
		BotFixDrill:Check_Is_He_AI(prime_target.unit) then
		local _key = prime_target.unit:name():key()
		if not BotFixDrill.target_drill_table[_key] then
			local drill = BotFixDrill:Get_All_Drill_Unit_In_Sphere(prime_target.unit:position(), BotFixDrill.Fix_Distance)
			if drill then
				BotFixDrill:Bot_Fix_This_Drill(prime_target.unit, drill)
			else
				drill = BotFixDrill:Get_All_Drill_Unit_In_Sphere(self._unit:position(), BotFixDrill.Fix_Distance)
				if drill then
					BotFixDrill:Animal_Do_Fixing(prime_target.unit, true)
				end
			end
		else
			BotFixDrill:Animal_End_Fixing(prime_target.unit)
			BotFixDrill.target_drill_table[_key] = {}
		end
	end
	return voice_type, plural, prime_target
end