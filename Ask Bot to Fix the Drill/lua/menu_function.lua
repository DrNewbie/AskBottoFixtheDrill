if Network:is_client() then
	return
end

_G.BotFixDrill = _G.BotFixDrill or {}

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