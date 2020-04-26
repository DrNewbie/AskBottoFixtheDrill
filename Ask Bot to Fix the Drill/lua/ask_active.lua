if Network:is_client() then
	return
end

_G.CustomWaypoints = _G.CustomWaypoints or {}

_G.Keepers = _G.Keepers or {}

function PlayerStandard:_start_action_intimidate_alt(t, unit)
	if not Keepers or not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t then
		local skip_alert = managers.groupai:state():whisper_mode()
		local voice_type, plural, prime_target = 'kpr_boost', false, {unit = unit}
		if prime_target and prime_target.unit and prime_target.unit.base and (prime_target.unit:base().unintimidateable or prime_target.unit:anim_data() and prime_target.unit:anim_data().unintimidateable) then
			return
		end
		local interact_type, sound_name = nil
		local sound_suffix = plural and "plu" or "sin"
		interact_type = "cmd_gogo"
		local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)
		if static_data then
			local character_code = static_data.ssuffix
			sound_name = "f21" .. character_code .. "_sin"
		else
			sound_name = "f38_any"
		end
		Keepers:SendState(prime_target.unit, Keepers:GetLuaNetworkingText(peer_id, prime_target.unit, 1), true)
		Keepers:ShowCovers(prime_target.unit)
		self:_do_action_intimidate(t, interact_type, sound_name, skip_alert)
	end
end