if ModCore then
	ModCore:new(ModPath .. "Config.xml", false, true):init_modules()
end

if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

BotFixDrill.Fix_Distance = 300

BotFixDrill.target_drill_table = BotFixDrill.target_drill_table or {}

function BotFixDrill:Animal_Do_Fixing(ai_unit, booloh, drill_unit)
	local check_is_unit_okay = function(check_unit)
		if not check_unit or not alive(check_unit) or not check_unit.position or not check_unit.movement or not check_unit:movement().nav_tracker or not check_unit:movement():nav_tracker().nav_segment then
			return false
		end
		return true
	end
	if not drill_unit or not alive(drill_unit) or not drill_unit.position then
		return
	end
	if not check_is_unit_okay(ai_unit) then
		return
	end
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
		follow_unit = ai_unit,
		called = true,
		destroy_clbk_key = false,
		nav_seg = ai_unit:movement():nav_tracker():nav_segment(),
		pos = drill_unit:position(),
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
	BotFixDrill.target_drill_table[ai_unit:name():key()] = {drill = drill_unit, fixer = ai_unit, start_time = math.round(TimerManager:game():time())+15, should_stay = ai_unit:movement()._should_stay}
	ai_unit:movement():set_should_stay(false)
	BotFixDrill:Animal_Do_Fixing(ai_unit, _, drill_unit)
end

function BotFixDrill:Get_All_Drill_Unit_In_Sphere(pos, area)
	local _unit = nil
	local _Unit_In_Sphere = World:find_units("sphere", pos, area, managers.slot:get_mask("all")) or {}
	for _, data in pairs(_Unit_In_Sphere) do
		if data then
			if data.base and data:base() and data:base().is_drill then
				if data:base()._jammed then
					if data.interaction and data:interaction() then
						local _name = tostring(data:interaction().tweak_data)
						local _nonfix = {
							huge_lance = true,
							huge_lance_jammed = true,
							cas_fix_bfd_drill = true
						}
						if not _nonfix[_name] then
							_unit = data
							break
						end
					end
				end
			end
		end
	end  
	return _unit
end