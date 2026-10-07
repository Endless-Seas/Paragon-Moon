//War is such a silly game we play!~
//Boss mob.

#define CHROME_PYRAMID_BARRAGE_COOLDOWN (10 SECONDS)
#define CHROME_PYRAMID_DETONATION_DELAY (5 SECONDS)
#define CHROME_PYRAMID_COLLAPSE_TIME (10 SECONDS)

/mob/living/simple_animal/hostile/boss/chrome_pyramid
	name = "PYRAMID"
	desc = "My vision fills with ancient, malignant spacetime that has come to kill me. The Mother Superior said that Angels were good and brought joy, but this one has staticized the World to bring it Hell. /n /n When God realized what the Eaters have done to His creation, He was full of grief; and so He did weep."
	mob_biotypes = NONE
	gender = NEUTER
	faction = list("abberant")
	//searching for a sprite that doesn't exist. at the .dmi, don't turn left
	icon = 'modular_paragon/lostech/icons/vault_entrance.dmi'
	icon_state = "cube" //codersprite
	icon_living = "cube"//codersprite
	icon_dead = "cube"//codersprite
	pixel_x = 0 //idk
	base_pixel_x = 0 //idk
	wander = 0
	vision_range = 9
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_WALLS
	obj_damage = 300
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	minimum_distance = 1
	retreat_distance = 0
	move_to_delay = 8
	base_intents = list(/datum/intent/simple/bite)
	attack_verb_continuous = "crushes"
	attack_verb_simple = "crush"
	attack_sound = 'sound/misc/explode/bomb.ogg' //im a placeholder im a placeholder im a fat fucking placeholder
	melee_damage_lower = 40
	melee_damage_upper = 60
	health = 5000
	maxHealth = 5000
	STASTR = 20
	STAPER = 15
	STACON = 20
	STAWIL = 20
	STASPD = 6
	footstep_type = FOOTSTEP_MOB_HEAVY
	light_outer_range = 6
	light_power = 2
	light_color = LIGHT_COLOR_PURPLE
	deathmessage = "groans as a thousand sun-weights collapse its chrome skin!"
	del_on_death = TRUE
	loot = list(/obj/effect/temp_visual/chrome_pyramid_collapse) //hgouhguh this is so fucking janky but whatever
	/// world.time at which the ambient hum may next play and when the next barrage will happen
	var/next_ambience = 0
	var/next_barrage = 0

	// How far from the pyramid barrage areas can be placed up to (pretty sure it's +1 this but whatever), followed by area amt and dmg
	var/barrage_range = 7
	var/barrage_areas = 5
	var/barrage_damage = 50

/mob/living/simple_animal/hostile/boss/chrome_pyramid/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOFIRE, "[type]")
	ADD_TRAIT(src, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)

/mob/living/simple_animal/hostile/boss/chrome_pyramid/simple_add_wound(datum/wound/wound, silent = FALSE, crit_message = FALSE)
	return

/mob/living/simple_animal/hostile/boss/chrome_pyramid/Life()
	. = ..()
	if(stat == DEAD || world.time < next_ambience)
		return
	next_ambience = world.time + rand(30 SECONDS, 60 SECONDS)
	playsound(src, 'modular_paragon/sound_library/pyramidambience.ogg', 70, FALSE, 8)

/mob/living/simple_animal/hostile/boss/chrome_pyramid/handle_automated_action()
	. = ..()
	if(stat == DEAD || !target || world.time < next_barrage)
		return
	next_barrage = world.time + CHROME_PYRAMID_BARRAGE_COOLDOWN
	mark_barrage()

//this code is so abysmally dogshit. someone needs to optimize this at some point
/mob/living/simple_animal/hostile/boss/chrome_pyramid/proc/mark_barrage()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	var/list/candidate_centers = list()
	for(var/turf/T in RANGE_TURFS(barrage_range, origin))
		if(!T.density)
			candidate_centers += T
	if(!length(candidate_centers))
		return

	var/list/centers = list()
	if(target)
		var/turf/target_turf = get_turf(target)
		if(target_turf && target_turf.z == origin.z)
			centers += target_turf
	for(var/i in 1 to barrage_areas)
		if(!length(candidate_centers))
			break
		centers += pick_n_take(candidate_centers)

	var/list/marked_turfs = list()
	for(var/turf/center as anything in centers)
		for(var/turf/T in RANGE_TURFS(1, center))
			if(T.density)
				continue
			marked_turfs |= T
	if(!length(marked_turfs))
		return

	for(var/turf/T as anything in marked_turfs)
		new /obj/effect/temp_visual/trap/chrome_pyramid(T)
	visible_message(span_danger("[src] hums, and the ground around it begins to glow!"))
	play_barrage_sound('modular_paragon/sound_library/pyramidlaser_charge.wav', marked_turfs)
	addtimer(CALLBACK(src, PROC_REF(detonate_barrage), marked_turfs), CHROME_PYRAMID_DETONATION_DELAY)

/// Plays a sound once to each nearby player, coming from whichever marked turf is closest to them.
/// Playing it from every marked turf would stack dozens of copies.
/mob/living/simple_animal/hostile/boss/chrome_pyramid/proc/play_barrage_sound(soundfile, list/marked_turfs)
	var/turf/origin = get_turf(src)
	if(!origin || !length(marked_turfs))
		return
	var/channel = SSsounds.random_available_channel()
	for(var/mob/listener as anything in get_hearers_in_range(world.view + barrage_range, origin, RECURSIVE_CONTENTS_CLIENT_MOBS))
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf)
			continue
		var/turf/closest
		var/closest_dist = INFINITY
		for(var/turf/T as anything in marked_turfs)
			var/dist = get_dist(listener_turf, T)
			if(dist < closest_dist)
				closest = T
				closest_dist = dist
		//vary is off: it forces ~44.1kHz playback, which slows down these 48kHz wavs
		listener.playsound_local(closest, soundfile, 100, FALSE, channel = channel)

/mob/living/simple_animal/hostile/boss/chrome_pyramid/proc/detonate_barrage(list/marked_turfs)
	if(QDELETED(src) || stat == DEAD)
		return
	play_barrage_sound('modular_paragon/sound_library/pyramidlaser_fire.wav', marked_turfs)
	var/list/already_hit = list()
	for(var/turf/T as anything in marked_turfs)
		new /obj/effect/temp_visual/explosion/fast(T)
		for(var/mob/living/victim in T)
			if(victim == src || (victim in already_hit))
				continue
			already_hit += victim
			victim.apply_damage(barrage_damage, BRUTE)
			shake_camera(victim, 3, 2)
			to_chat(victim, span_userdanger("CRUSHED."))

//DON'T SPAM LIGHTING!! HEY!!
/obj/effect/temp_visual/trap/chrome_pyramid
	icon_state = "trapdouble"
	light_outer_range = 0
	duration = CHROME_PYRAMID_DETONATION_DELAY
	color = "#9fd3ff"

//so fucking jank
/obj/effect/temp_visual/chrome_pyramid_collapse
	name = "PYRAMID"
	desc = "Spacetime is unhewing. These things weigh heavy on the heart."
	icon = 'modular_paragon/lostech/icons/vault_entrance.dmi'
	icon_state = "cube" //codersprite
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	randomdir = FALSE
	duration = CHROME_PYRAMID_COLLAPSE_TIME
	// LOOT. do this at your leisure
	var/list/collapse_loot = list(
		/obj/item/roguegem/diamond,
		/obj/item/roguegem/diamond
	)

/obj/effect/temp_visual/chrome_pyramid_collapse/Initialize(mapload) //pipe shit directly to ppl in view, shake, delete
	. = ..()
	var/channel = SSsounds.random_available_channel()
	for(var/mob/listener as anything in get_hearers_in_view(world.view, src, RECURSIVE_CONTENTS_CLIENT_MOBS))
		listener.playsound_local(null, 'modular_paragon/sound_library/pyramidcollapse.ogg', 100, FALSE, channel = channel)
	animate(src, pixel_x = rand(-4, 4), pixel_y = rand(-4, 4), time = 0.5, loop = -1)
	for(var/i in 1 to 7)
		animate(pixel_x = rand(-4, 4), pixel_y = rand(-4, 4), time = 0.5)
	for(var/mob/M in range(7, src))
		shake_camera(M, 10, 1)

/obj/effect/temp_visual/chrome_pyramid_collapse/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		visible_message(span_boldannounce("[src] folds in on itself and is gone."))
		for(var/loot_type in collapse_loot)
			new loot_type(T)
	return ..()

#undef CHROME_PYRAMID_BARRAGE_COOLDOWN
#undef CHROME_PYRAMID_DETONATION_DELAY
#undef CHROME_PYRAMID_COLLAPSE_TIME
