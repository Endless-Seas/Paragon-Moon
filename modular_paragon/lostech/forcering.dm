//force ring, creates a battle-ward esque ward. if it breaks uhh sucks to be you buddy lmao


#define FORCE_RING_FILTER "force_ring_field"
#define FORCE_RING_COLOUR "#00FFFF"
#define FORCE_RING_DURATION 20 SECONDS
#define FORCE_RING_COOLDOWN 2 MINUTES
#define FORCE_RING_ARMOR list("blunt" = 100, "slash" = 100, "stab" = 100, "piercing" = 100, "fire" = 0, "acid" = 0)

/obj/item/clothing/ring/force_ring
	name = "force ring"
	desc = "The gem is deep and colorful 'til the pixelcut reaches its unseen photon potential; and then, electric-auger force erupts one of its many vertices into brilliant light.<br>\
	<small>It seems the hexagonal gem turns to the <b>right</b>.</small>"
	icon = 'modular_paragon/icons/clothing/misc.dmi'
	icon_state = "forcering"
	mob_overlay_icon = 'modular_paragon/icons/clothing/onmob.dmi'
	max_integrity = 300 //field's health, not the ring's (i mean, both, i guess)
	integrity_failure = 0
	anvilrepair = null
	armor_class = ARMOR_CLASS_NONE
	blocksound = PLATEHIT
	sellprice = 2000 //idk lmfao

//very self explanatory
	var/active = FALSE
	var/next_use = 0
	var/mob/living/carbon/human/shielded
	var/fade_timer
	var/glowduration = 20 SECONDS

/obj/item/clothing/ring/force_ring/Destroy()
	deactivate()
	return ..()

/obj/item/clothing/ring/force_ring/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("[round(obj_integrity / max_integrity * 100)]% INTEGRITY REMAINING.")
	else if(world.time < next_use)
		. += span_warning("The hexagonal display is dark.")

/obj/item/clothing/ring/force_ring/attack_right(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.wear_ring != src)
		to_chat(H, span_warning("I must wear [src] to use it."))
		return
	if(active)
		return
	if(world.time < next_use)
		to_chat(H, span_warning("The [src] clicks before humming and going dark."))
		return
	activate(H)

/obj/item/clothing/ring/force_ring/proc/activate(mob/living/carbon/human/H)
	active = TRUE
	shielded = H
	next_use = world.time + FORCE_RING_COOLDOWN

	armor = getArmor(arglist(FORCE_RING_ARMOR)) //kinda cheating, we're using forcering stuff for this but whatever :3
	body_parts_covered = COVERAGE_FULL | COVERAGE_HEAD_NOSE | NECK | HANDS | FEET
	body_parts_covered_dynamic = body_parts_covered
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_STAB, BCLASS_PIERCE, BCLASS_PICK, BCLASS_BLUNT)
	obj_broken = FALSE
	obj_integrity = max_integrity

	H.apply_status_effect(/datum/status_effect/buff/force_field)
	H.visible_message(span_warning("[H] twists [src], and a force bubble pops into being around [H.p_them()]!")) //literal qud dialogue. are we on the nose? yeah, probably
	playsound(H, "modular_paragon/lostech/sound/shields/shield_pass_[rand(1,2)].ogg", 100, FALSE)
	H.mob_light(FORCE_RING_COLOUR, 3, 3, glowduration)

	var/atom/movable/distortion_effect/ripple = new(get_turf(H))
	ripple.pulse(1 SECONDS, 0.1, 0.3) //weaker than the collapse ripple
	QDEL_IN(ripple, 1 SECONDS)

	fade_timer = addtimer(CALLBACK(src, PROC_REF(fade)), FORCE_RING_DURATION, TIMER_STOPPABLE)

//safe and harmful dispersion, in order
/obj/item/clothing/ring/force_ring/proc/fade()
	if(!active)
		return
	shielded?.visible_message(span_notice("The [src] snaps off."))
	deactivate()

//uh oh!
/obj/item/clothing/ring/force_ring/proc/collapse()
	var/mob/living/carbon/human/H = shielded
	deactivate()
	if(QDELETED(H))
		return
	H.visible_message(span_danger("[H]'s force bubble pops violently!"), \
		span_userdanger("A sharp pain grips my heart!"))
	playsound(H, 'sound/foley/breaksound.ogg', 100, TRUE)
	H.emote("painscream", forced = TRUE)
	H.Immobilize(0.5 SECONDS)
	H.apply_status_effect(/datum/status_effect/debuff/force_feedback)

	var/atom/movable/distortion_effect/ripple = new(get_turf(H))
	ripple.pulse(1.5 SECONDS, 0.1, 0.6)
	QDEL_IN(ripple, 1.5 SECONDS)

// deletes filter and strips the armor off again
/obj/item/clothing/ring/force_ring/proc/deactivate()
	if(!active)
		return
	active = FALSE
	deltimer(fade_timer)
	fade_timer = null

	armor = getArmor()
	body_parts_covered = NONE
	body_parts_covered_dynamic = NONE
	prevent_crits = null
	obj_integrity = max_integrity

	shielded?.remove_status_effect(/datum/status_effect/buff/force_field)
	shielded = null

/obj/item/clothing/ring/force_ring/dropped(mob/user)
	. = ..()
	deactivate()


/obj/item/clothing/ring/force_ring/obj_destruction(damage_flag)
	if(active)
		collapse()
		return
	return ..()

/datum/status_effect/buff/force_field
	id = "force_field"
	alert_type = /atom/movable/screen/alert/status_effect/buff/force_field
	duration = -1
	examine_text = "<font color='#00FFFF'>SUBJECTPRONOUN is wrapped in hexagonal nx-glass.</font>"

/atom/movable/screen/alert/status_effect/buff/force_field
	name = "Force Field"
	desc = "Potential is polarized into a cyanic hex mesh and keyed to its arranger." //QUD!!

/datum/status_effect/buff/force_field/on_apply()
	. = ..()
	if(!owner.get_filter(FORCE_RING_FILTER))
		owner.add_filter(FORCE_RING_FILTER, 2, list("type" = "outline", "color" = FORCE_RING_COLOUR, "alpha" = 220, "size" = 1))

/datum/status_effect/buff/force_field/on_remove()
	. = ..()
	owner.remove_filter(FORCE_RING_FILTER)

/datum/status_effect/debuff/force_feedback
	id = "force_feedback"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/force_feedback
	effectedstats = list(STATKEY_STR = -3, STATKEY_CON = -3, STATKEY_SPD = -3, STATKEY_PER = -2)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/debuff/force_feedback
	name = "Force Feedback"
	desc = "Hexagonal prismarine shards form myocardinal agony. Euhedral discs spin in my eyes."

#undef FORCE_RING_FILTER
#undef FORCE_RING_COLOUR
#undef FORCE_RING_DURATION
#undef FORCE_RING_COOLDOWN
#undef FORCE_RING_ARMOR
