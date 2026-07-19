//Spaghetti-bit's combat indicator, tweaked(kind of) for our use. Cheers!
//This wasn't very popular when first introduced, mind, but our host wants it.
//We'll see if we can't make it worse. - Carl
/mob/living
	/// An overlay image that displays the mob's intent, doesn't apply to NPCs.
	var/static/mutable_appearance/combat_indicator

/mob/living/proc/toggle_combat_indicator()
	if(!combat_indicator)
		combat_indicator = mutable_appearance('modular_paragon/icons/mob/combat_hud.dmi', "combat_indicator", FLY_LAYER)
		combat_indicator.alpha = 175
	if(!cmode)
		cut_overlay(combat_indicator)
		update_vision_cone()
	else
		add_overlay(combat_indicator)
		update_vision_cone()
	return cmode

/mob/living/toggle_cmode()
	..()
	log_message("[src] has " + (cmode ? "enabled" : "disabled") + " combat mode.", LOG_ATTACK)
	toggle_combat_indicator()
