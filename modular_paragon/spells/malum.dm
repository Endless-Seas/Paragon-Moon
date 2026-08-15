//Listen up, bucko.
//This file? This here is special.
//It's where I make Malumites CRACKED.
//Starting? Slow. Ending? HOT.

//Miracle to temporarily bypass crafting skill reqs.
/obj/effect/proc_holder/spell/invoked/malum_bypass
	name = "Divine Inspiration"
	desc = "Strikes the target with a fey mood, granting them sight beyond sight. \
	During this duration, they may bypass any and all skill restrictions on crafting."
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "inspiration"
	range = 7
	no_early_release = TRUE
	charging_slowdown = 1
	chargetime = 6 SECONDS
	sound = 'sound/items/bsmithfail.ogg'
	invocations = list("By creation, by fire, one must be inspired!!")
	invocation_type = "shout"
	recharge_time = 15 MINUTES//Legendary EVERYTHING BYPASS is WILD. This might need to go up, even. A lot.
	miracle = TRUE
	devotion_cost = 200

/obj/effect/proc_holder/spell/invoked/malum_bypass/cast(list/targets, mob/living/user)
	. = ..()
	var/mob/living/carbon/human/target = targets[1]
	target.apply_status_effect(/datum/status_effect/buff/malum_bypass)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/malum_bypass
	name = "Fey Mood"
	desc = "I HAVE BEEN STRUCK BY DIVINE INSIGHT. I MUST PUT MY HANDS TO WORK. I DO NOT CARE FOR SKILL REQUIREMENTS IN CRAFTING. REJOICE."

/datum/status_effect/buff/malum_bypass
	alert_type = /atom/movable/screen/alert/status_effect/buff/malum_bypass
	examine_text = "SUBJECTPRONOUN has been struck with divine inspiration!"
	id = "malum_bypass"
	duration = 2 MINUTES

/datum/status_effect/buff/malum_bypass/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_FEY_MOOD, TRAIT_MIRACLE)
	to_chat(owner, span_warning("I'm struck with divine inspiration! My hands must move!"))

/datum/status_effect/buff/malum_bypass/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_FEY_MOOD, TRAIT_MIRACLE)
	to_chat(owner, span_warning("I can no longer... feel the spark..."))

//Mass AOE repair of walls and structures. Full stop. That's all it is.
//This is absurd and STUPID and should NOT exist. But I'm me, so it must.
//Anti-siege Malumites are integral to my RP, I swear.
/*
/obj/effect/proc_holder/spell/invoked/malum_aura
	name = "Malumite Aura"
	desc = "I simply wave my hand, assuring all is well with the surrounding area. \
	The Shaper shall see to it that any imperfection is tended."
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "inspiration"
	releasedrain = 60
	recharge_time = 30 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocations = list(span_danger("shimmers, projecting a violent, albeit short lyved, aura of structural mending."))
	invocation_type = "emote"
	miracle = TRUE
	devotion_cost = 90
*/
//Lava walking and burn stack immunity. YEAH!! FUCK YOU MAGES!!
//LAVA? FUCK YOU, TOO!! THINK YOU'RE SAFE? THINK AGAIN!!
/obj/effect/proc_holder/spell/invoked/malum_earth_step
	name = "Earthbound Steps"
	desc = "Lava and open flame hazard shall be rendered harmless. \
	For fire will no longer hold sway over my target's frame."
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "steps"
	range = 7
	no_early_release = TRUE
	charging_slowdown = 1
	chargetime = 2 SECONDS
	sound = 'sound/items/bsmithfail.ogg'
	invocations = list(span_danger("appears afire, for but a brief moment. Flesh boiling from frame, and settling, in an instant."))
	invocation_type = "emote"
	recharge_time = 4 MINUTES//As below. Can constantly refresh, within the one minute window.
	miracle = TRUE
	devotion_cost = 120

/obj/effect/proc_holder/spell/invoked/malum_earth_step/cast(list/targets, mob/living/user)
	. = ..()
	var/mob/living/carbon/human/target = targets[1]
	target.apply_status_effect(/datum/status_effect/buff/malum_earth_step)
	return TRUE

#define EARTH_STEP_FILTER "earth_step_glow"

/atom/movable/screen/alert/status_effect/buff/malum_earth_step
	name = "Earthbound Steps"
	desc = "I go where I wish, for I can no longer catch alight. Lava? A trivial thing."

/datum/status_effect/buff/malum_earth_step
	alert_type = /atom/movable/screen/alert/status_effect/buff/malum_earth_step
	examine_text = "<font color='red'>SUBJECTPRONOUN appears to be boiling alive, frame simmering!</font>"
	id = "malum_earth_step"
	duration = 5 MINUTES//Can keep this up forever, basically. 1min window between.
	var/outline_colour = "#F29D1F"

/datum/status_effect/buff/malum_earth_step/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOFIRE, TRAIT_MIRACLE)
	ADD_TRAIT(owner, TRAIT_EARTH_STEP, TRAIT_MIRACLE)
	to_chat(owner, span_warning("My steps are guided, for sure as Malum wishes me to explore, lava shan't cause me harm!"))
	var/filter = owner.get_filter(EARTH_STEP_FILTER)
	if (!filter)
		owner.add_filter(EARTH_STEP_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 60, "size" = 1))

/datum/status_effect/buff/malum_earth_step/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOFIRE, TRAIT_MIRACLE)
	REMOVE_TRAIT(owner, TRAIT_EARTH_STEP, TRAIT_MIRACLE)
	to_chat(owner, span_warning("I feel the aspect of the Earth's grasp fall from my frame..."))
	owner.remove_filter(EARTH_STEP_FILTER)
