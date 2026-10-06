/*
THE CHROME PYRAMID
A towering lostech construct. Slow, but every 10 seconds while it has a target,
it marks patches of ground around itself and detonates them shortly after.
It is immune to its own detonations.
On death it shakes itself apart over 10 seconds, then vanishes and leaves loot behind.
*/

#define CHROME_PYRAMID_BARRAGE_COOLDOWN (10 SECONDS)
#define CHROME_PYRAMID_DETONATION_DELAY (5 SECONDS)
#define CHROME_PYRAMID_COLLAPSE_TIME (10 SECONDS)

/mob/living/simple_animal/hostile/boss/chrome_pyramid
	name = "PYRAMID"
	desc = "The vision fills with ancient spacetime that has come to kill you. The Mother Superior said that Angels were good and brought joy, but this one has staticized the World to bring it Hell."
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
	deathmessage = "groans as a thousand sun-weights collapse its chrome skin!"
	del_on_death = TRUE
	//The collapsing husk does the vibrating, the collapse sound, and drops the real loot when it finishes.
	loot = list(/obj/effect/temp_visual/chrome_pyramid_collapse)
	/// world.time at which the ambient hum may next play
	var/next_ambience = 0
	/// world.time at which the next mark-and-detonate barrage may fire
	var/next_barrage = 0
	/// How far from the pyramid barrage areas may be placed
	var/barrage_range = 7
	/// How many 3x3 areas to mark per barrage (one extra is always placed on the target)
	var/barrage_areas = 5
	/// Damage dealt to each living thing caught in a detonation
	var/barrage_damage = 50

/mob/living/simple_animal/hostile/boss/chrome_pyramid/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOFIRE, "[type]")
	ADD_TRAIT(src, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)

/mob/living/simple_animal/hostile/boss/chrome_pyramid/simple_add_wound(datum/wound/wound, silent = FALSE, crit_message = FALSE) //it's a solid block of metal
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

/// Picks several 3x3 areas around the pyramid (plus one on the target), telegraphs them, and schedules the detonation.
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
	playsound(origin, 'modular_paragon/sound_library/pyramidlaser_charge.wav', 100, TRUE, 6)
	addtimer(CALLBACK(src, PROC_REF(detonate_barrage), marked_turfs), CHROME_PYRAMID_DETONATION_DELAY)

/// Blows up every marked turf. The pyramid itself is never harmed.
/mob/living/simple_animal/hostile/boss/chrome_pyramid/proc/detonate_barrage(list/marked_turfs)
	if(QDELETED(src) || stat == DEAD)
		return
	playsound(get_turf(src), 'modular_paragon/sound_library/pyramidlaser_fire.wav', 100, TRUE, 8)
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

/// Telegraph marker for the pyramid's detonations. Lasts exactly as long as the fuse.
/obj/effect/temp_visual/trap/chrome_pyramid
	icon_state = "trapdouble"
	light_outer_range = 0 // a barrage marks dozens of tiles, don't spam SSlighting
	duration = CHROME_PYRAMID_DETONATION_DELAY
	color = "#9fd3ff"

/// The pyramid's death throes. Shakes violently while the collapse sound plays, then vanishes and leaves loot.
/obj/effect/temp_visual/chrome_pyramid_collapse
	name = "PYRAMID"
	desc = "It is coming apart."
	icon = 'modular_paragon/lostech/icons/vault_entrance.dmi'
	icon_state = "cube" //codersprite
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	randomdir = FALSE
	duration = CHROME_PYRAMID_COLLAPSE_TIME
	/// What actually drops once the collapse finishes
	var/list/collapse_loot = list(
		/obj/item/roguegem/diamond,
		/obj/item/roguecoin/gold/pile,
		/obj/item/roguecoin/gold/pile,
		/obj/item/reagent_containers/stimpen,
		/obj/item/reagent_containers/stimpen,
		/obj/item/lightsphere,
	)
	/// Number of extra random gems on top of collapse_loot
	var/bonus_gems = 2

/obj/effect/temp_visual/chrome_pyramid_collapse/Initialize(mapload)
	. = ..()
	playsound(src, 'modular_paragon/sound_library/pyramidcollapse.ogg', 100, FALSE, 10)
	//Chain a handful of random jitters and loop them for the whole collapse.
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
		for(var/i in 1 to bonus_gems)
			var/gem_type = pick(/obj/item/roguegem/green, /obj/item/roguegem/blue, /obj/item/roguegem/yellow, /obj/item/roguegem/violet, /obj/item/roguegem/ruby)
			new gem_type(T)
	return ..()

#undef CHROME_PYRAMID_BARRAGE_COOLDOWN
#undef CHROME_PYRAMID_DETONATION_DELAY
#undef CHROME_PYRAMID_COLLAPSE_TIME
