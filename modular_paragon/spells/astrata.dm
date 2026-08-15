//Dead? Nah, you aren't.
//Paladin auras? Stocked.
//Frags? Assured.
//God I love Astratans being scary.

//FROM THE ASHES MIRACLE. DEATH CANNOT HOLD YOU, MY FRAG CHAMPION.
//Intentional to have this provide neither glow nor 'tell'.
//If you crit someone and eat the flashbang, it'll be funny. Trust.
//We also handle this via effect, as opposed to trait. Cleaner. More expensive, however.
//Decaps also assure instadeath, but 99% of weapons don't have instant decap, so...
/obj/effect/proc_holder/spell/self/astratan_rebirth
	name = "Phoenix Bindings"
	desc = "Wreaths your frame in an ephemeral coil of ash. \
	When such dissipates, you shall be immune to the effects of death. Once. \
	For this power will vanish afterwards."
	overlay_icon = 'icons/mob/actions/astratamiracles.dmi'
	action_icon = 'icons/mob/actions/astratamiracles.dmi'
	overlay_state = "rebirth"
	no_early_release = TRUE
	charging_slowdown = 1
	chargetime = 12 SECONDS
	sound = 'sound/misc/adrenaline_rush.ogg'
	invocations = list(span_danger("waves a hand through the air, spreading ash at their fore."))
	invocation_type = "emote"
	recharge_time = 5 MINUTES//We remove this when they revive, so it's fine.
	miracle = TRUE
	devotion_cost = 200

/obj/effect/proc_holder/spell/self/astratan_rebirth/cast(mob/living/user)
	. = ..()
	user.apply_status_effect(/datum/status_effect/buff/astratan_rebirth)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/astratan_rebirth
	name = "Phoenix Bindings"
	desc = "Come rain or hellfire, I cannot be slain by traditional means. <b>Once</b>."
	color = "#ED7171"

/datum/status_effect/buff/astratan_rebirth
	alert_type = /atom/movable/screen/alert/status_effect/buff/astratan_rebirth
	id = "astratan_rebirth"
	effectedstats = list(STATKEY_CON = -1)

/datum/status_effect/buff/astratan_rebirth/on_apply()
	. = ..()
	to_chat(owner, span_warning("I'm now incapable of being slain. <b>Once!</b>"))

/datum/status_effect/buff/astratan_rebirth/on_remove()
	. = ..()

//This is EXPENSIVE and GROSS. But it's COOL.
//Which is why it's incredibly limited, too.
/datum/status_effect/buff/astratan_rebirth/tick()
	if(owner.InFullCritical())
		rebirth()

//No brute. Just blood, oxy and wounds.
/datum/status_effect/buff/astratan_rebirth/proc/rebirth()
	var/mob/living/carbon/human/M = owner
	M.restore_blood()
	M.setOxyLoss(0, 0)
	for(var/datum/wound/wound as anything in M.get_wounds())
		wound.heal_wound(wound.whp)
	M.remove_CC(TRUE)
	M.set_resting(FALSE, FALSE)
	//Copy from lightspheres, firstly. Kinda.
	for(var/mob/living/carbon/human/H in oview(4, M))//Don't worry about it.
		if(!considered_alive(H.mind))
			continue
		H.blur_eyes(15)
		H.blind_eyes(5)
		to_chat(H, "<span class='userdanger'>MY EYES!</span>")
		playsound(H, 'modular_paragon/lostech/sound/sphere.ogg', 100, TRUE)//MY EARS!!!!!
	playsound(M, 'sound/misc/adrenaline_rush.ogg', 100, TRUE)
	M.mind?.RemoveSpell(/obj/effect/proc_holder/spell/self/astratan_rebirth)
	M.remove_status_effect(/datum/status_effect/buff/astratan_rebirth)
