if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

BotFixDrill.Fix_Distance = 300

BotFixDrill.target_drill_table = BotFixDrill.target_drill_table or {}

function BotFixDrill:Animal_Do_Fixing(ai_unit, booloh)
	if not ai_unit or not alive(ai_unit) or not ai_unit:brain() then
		return
	end
	local other_unit = managers.player:player_unit()
	local objective_type, objective_action
	objective_type = "revive"
	objective_action = "revive"
	local followup_objective = {
		type = "act",
		scan = true,
		action = {
			type = "act",
			body_part = 1,
			variant = "crouch",
			blocks = {
				action = -1,
				walk = -1,
				hurt = -1,
				heavy_hurt = -1,
				aim = -1
			}
		}
	}
	local objective = {
		type = "revive",
		follow_unit = other_unit,
		called = true,
		destroy_clbk_key = false,
		nav_seg = other_unit:movement():nav_tracker():nav_segment(),
		scan = true,
		action = {
			type = "act",
			variant = objective_action,
			body_part = 1,
			blocks = {
				action = -1,
				walk = -1,
				hurt = -1,
				light_hurt = -1,
				heavy_hurt = -1,
				aim = -1
			},
			align_sync = true
		},
		action_duration = tweak_data.interaction[objective_action == "untie" and "free" or objective_action].timer,
		followup_objective = followup_objective
	}
	ai_unit:brain():set_objective(objective)
	if not booloh then
		ai_unit:brain():action_request(objective.action)
	end
end

function BotFixDrill:Animal_End_Fixing(ai_unit)
	if not ai_unit or not alive(ai_unit) or not ai_unit:brain() then
		return
	end
	ai_unit:brain():set_objective({
		type = "act",
		action = {
			type = "act",
			body_part = 1,
			variant = "idle",
			blocks = {
				idle = -1,
				turn = -1,
				action = -1,
				walk = -1,
				light_hurt = -1,
				hurt = -1,
				heavy_hurt = -1,
				expl_hurt = -1,
				fire_hurt = -1
			}
		}
	})
end

function BotFixDrill:Check_Is_He_AI(unit)
	local _AIs = managers.groupai:state():all_AI_criminals() or {}
	if _AIs then
		for _, data in pairs(_AIs) do
			if data.unit and alive(data.unit) and data.unit == unit then
				return true
			end
		end
	end
	return false
end

function BotFixDrill:Bot_Fix_This_Drill(ai_unit, drill_unit)
	for k, v in pairs(BotFixDrill.target_drill_table) do
		if v.drill == drill_unit then
			return
		end
	end
	if not BotFixDrill:Check_Is_He_AI(ai_unit) then
		return
	end
	ai_unit:movement():set_rotation(Rotation:look_at(ai_unit:position(), drill_unit:position(),  math.UP))
	BotFixDrill.target_drill_table[ai_unit:name():key()] = {drill = drill_unit, fixer = ai_unit, start_time = math.floor(TimerManager:game():time())+15}
	BotFixDrill:Animal_Do_Fixing(ai_unit)
end

function BotFixDrill:Get_All_Drill_Unit_In_Sphere(pos, area)
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