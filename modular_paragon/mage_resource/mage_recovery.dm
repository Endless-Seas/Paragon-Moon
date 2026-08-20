/*
The spell used to 'meditate'.
Used if you don't have mana pots.
*/
/obj/effect/proc_holder/spell/self/arc_rejuv
	name = "Arcyne Rejuvenation"
	desc = "Focus inwards for a short rest, recovering your arcyne energy."
	school = "transmutation"
	charge_type = "recharge"
	recharge_time = 2 MINUTES
	clothes_req = FALSE
	cost = 3
	spell_tier = 0
	cooldown_min = 2 MINUTES
	associated_skill = /datum/skill/magic/arcane
	xp_gain = TRUE
	invocations = list("Ad nexum corrigendum.")
	invocation_type = "whisper"
	action_icon_state = "spell0"

	var/recovery_delay = 15 SECONDS
	spark_immune = TRUE

/obj/effect/proc_holder/spell/self/arc_rejuv/cast(mob/user = usr)
	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = user

	H.visible_message(span_warning("[H] closes [H.p_their()] eyes, focusing inwards."))
	H.apply_status_effect(/datum/status_effect/buff/arc_rejuv)
	if(do_after(H, recovery_delay, target = H, progress = TRUE))
		var/recovery_audio = pick('modular_paragon/mage_resource/sound/recovery_one.ogg',
		'modular_paragon/mage_resource/sound/recovery_two.ogg')
		playsound(H, recovery_audio, 100, TRUE)

		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(1, loc)
		smoke.start()

		if(H.spark <= SPARK_LEVEL_FADED && !HAS_TRAIT(H, TRAIT_ARCYNE_T4))
			to_chat(H, span_warning("No matter how hard you try, it just isn't possible!"))
			H.remove_status_effect(/datum/status_effect/buff/arc_rejuv)
			start_recharge()
			revert_cast()
			return

		if(H.spark >= SPARK_LEVEL_FULL)
			to_chat(H, span_warning("You've fully recovered your arcyne strength."))
		else
			to_chat(H, span_warning("You've recovered some of your strength to cast the arcyne..."))

		H.adjust_spark(100)
		H.remove_status_effect(/datum/status_effect/buff/arc_rejuv)

		start_recharge()
	else
		H.remove_status_effect(/datum/status_effect/buff/arc_rejuv)
		to_chat(H, span_warning("Your concentration was broken!"))
		start_recharge()
		revert_cast()

/atom/movable/screen/alert/status_effect/buff/arc_rejuv
	name = "Recovering"
	desc = "I'm in the middle of casting Arcyne Rejuvenation. I need to stand still!"
	icon_state = "buff"
	color = "#77557A"

/datum/status_effect/buff/arc_rejuv
	id = "arc_recovering"
	alert_type = /atom/movable/screen/alert/status_effect/buff/arc_rejuv
	var/effect_color
	var/datum/stressevent/stress_to_apply
	var/pulse = 0
	var/ticks_to_apply = 5

/datum/status_effect/buff/arc_rejuv/tick()
	var/obj/effect/temp_visual/recovery_smoke/M = new /obj/effect/temp_visual/recovery_smoke(get_turf(owner))
	M.color = effect_color
	pulse += 1

/obj/effect/temp_visual/recovery_smoke
	name = "recovery smoke"
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = "steam_cloud_1"
	duration = 20
	plane = GAME_PLANE_UPPER
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/recovery_smoke/Initialize(mapload, set_color)
	if(set_color)
		add_atom_colour(set_color, FIXED_COLOUR_PRIORITY)
	. = ..()
	alpha = 180
	pixel_x = rand(-15, 15)
	pixel_y = rand(-15, 15)
