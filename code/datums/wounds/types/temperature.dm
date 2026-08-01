/*
We've moved temp stuff to its own folder.
Why was this in special? I've no idea.
It's not as if it's applied by 99% of things. Just the temp system
And mages, I guess. For some reason. Whatever.
*/
/datum/wound/heatexhaustion
	name = "heat exhaustion"
	check_name = span_warning("HEATEXHAUSTION")
	severity = 0
	crit_message = ""
	whp = null
	woundpain = 0
	mob_overlay = "cut"
	can_sew = FALSE
	can_cauterize = FALSE
	critical = FALSE
	sleep_healing = 0
	bleed_rate = 0
	clotting_threshold = 0
	clotting_rate = 0
	bypass_bloody_wound_check = TRUE

	var/start_time
	var/duration = 2 MINUTES

/datum/wound/heatexhaustion/on_mob_gain(mob/living/affected)
	. = ..()
	start_time = world.time
	if(!owner.stat)
		to_chat(owner, span_warning("A wave of heat washes over me... I feel faint."))
	owner.overlay_fullscreen("heatexhaust", /atom/movable/screen/fullscreen/heatexhaust)

/datum/wound/heatexhaustion/on_life()
	. = ..()

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/C = owner

	// If cooled off, remove heat exhaustion
	if(C.bodytemperature <= BODYTEMP_NORMAL_MAX)
		to_chat(C, span_notice("Cool air steadies me. The worst of the heat passes."))
		C.clear_fullscreen("heatexhaust")
		qdel(src)
		return

	// Occasional discomfort message
	if(!C.stat && prob(5))
		to_chat(C, span_warning("My vision swims from the heat..."))

	// After 2 minute, convert to heatstroke
	if(world.time >= start_time + duration)
		var/obj/item/bodypart/BP = bodypart_owner
		if(BP)
			to_chat(C, span_userdanger("The heat overwhelms me!"))
			BP.add_wound(/datum/wound/heatstroke)
		C.clear_fullscreen("heatexhaust")
		qdel(src)

/datum/wound/heatstroke
	name = "heatstroke"
	check_name = span_warning("HEATSTROKE")
	severity = 0
	crit_message = ""
	whp = null
	woundpain = 0
	mob_overlay = "cut"
	can_sew = FALSE
	can_cauterize = FALSE
	critical = FALSE
	sleep_healing = 0
	bleed_rate = 0
	clotting_threshold = 0
	clotting_rate = 0
	bypass_bloody_wound_check = TRUE
	var/cure_timer

/datum/wound/heatstroke/on_mob_gain(mob/living/affected)
	. = ..()
	cure_timer = null
	owner.overlay_fullscreen("heatstroke", /atom/movable/screen/fullscreen/heatstroke)

/datum/wound/heatstroke/on_life()
	. = ..()

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/C = owner

	if(!C.stat && prob(5))
		if(prob(5))
			C.vomit(1, blood = FALSE, stun = TRUE)
		to_chat(owner, span_warning("The world is spinning!"))
		C.Dizzy(10)

	// If temperature is normal, start cure timer
	if(C.bodytemperature <= BODYTEMP_NORMAL_MAX)
		if(!cure_timer)
			to_chat(C, span_notice("The heat begins to slowly fade from my body..."))
			cure_timer = addtimer(CALLBACK(src, PROC_REF(cure_heatstroke)), 2 MINUTES)

	// If overheating again, cancel cure timer
	else
		if(cure_timer)
			deltimer(cure_timer)
			cure_timer = null

/datum/wound/heatstroke/on_mob_loss()
	. = ..()
	if(cure_timer)
		deltimer(cure_timer)
		cure_timer = null

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/C = owner
	to_chat(owner, span_warning("The world has stopped spinning."))
	C.set_dizziness(0)

/datum/wound/heatstroke/proc/cure_heatstroke()
	if(!owner)
		return

	var/mob/living/carbon/human/H = owner

	to_chat(H, span_notice("The world finally stops spinning as the heat leaves me."))
	H.clear_fullscreen("heatstroke")
	qdel(src)

/datum/wound/frostbite
	name = "frostbite"
	check_name = span_blue("FROSTBITE")
	severity = 0
	crit_message = ""
	whp = null
	woundpain = 0
	mob_overlay = "cut"
	can_sew = FALSE
	can_cauterize = FALSE
	critical = FALSE
	sleep_healing = 0
	bleed_rate = 0
	clotting_threshold = 0
	clotting_rate = 0
	bypass_bloody_wound_check = TRUE
	var/stage = 1
	var/last_stage_tick
	var/stage_interval = 2 MINUTES

/datum/wound/frostbite/on_mob_gain(mob/living/affected)
	. = ..()
	last_stage_tick = world.time
	update_stage_name()
	owner.overlay_fullscreen("frostbite", /atom/movable/screen/fullscreen/frostbite)

/datum/wound/frostbite/on_life()
	. = ..()

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/C = owner
	var/obj/item/bodypart/BP = bodypart_owner

	// Warmth degrades frostbite
	if(C.bodytemperature >= BODYTEMP_NORMAL_MIN)
		if(world.time >= last_stage_tick + (1 MINUTES))
			stage--
			last_stage_tick = world.time

			if(stage >= 1)
				to_chat(C, span_notice("The feeling slowly returns to my [BP]..."))
				disabling = FALSE
				update_stage_name()
			else
				stage = 1

	// Stage progression
	if(stage < 3 && world.time >= last_stage_tick + stage_interval && C.bodytemperature < BODYTEMP_NORMAL_MIN)
		stage++
		last_stage_tick = world.time
		update_stage_name()

		switch(stage)
			if(2)
				to_chat(C, span_userdanger("My [BP] is completely numb..."))
			if(3)
				to_chat(C, span_userdanger("My [BP] feels dead and brittle!"))
				disabling = TRUE

	// Damage scaling per stage
	if(!C.stat && prob(30))
		var/damage = 0
		switch(stage)
			if(1)
				damage = 2
			if(2)
				damage = 5
			if(3)
				damage = 10
		if(BP.bandage)
			damage = damage *0.25

		C.apply_damage(damage, BURN)

/datum/wound/frostbite/proc/update_stage_name()
	var/stage_text

	switch(stage)
		if(1)
			stage_text = "I"
		if(2)
			stage_text = "II"
		if(3)
			stage_text = "III"

	check_name = span_blue("FROSTBITE ([stage_text])")


/datum/wound/hypothermia
	name = "hypothermia"
	check_name = span_blue("HYPOTHERMIA")
	severity = 0
	crit_message = ""
	whp = 40
	woundpain = 0
	mob_overlay = null
	can_sew = FALSE
	can_cauterize = FALSE
	critical = FALSE
	sleep_healing = 0
	bleed_rate = 0
	clotting_threshold = 0
	clotting_rate = 0
	bypass_bloody_wound_check = TRUE

	var/start_time
	var/duration = 2 MINUTES

/datum/wound/hypothermia/on_mob_gain(mob/living/affected)
	. = ..()
	start_time = world.time
	owner.overlay_fullscreen("hypothermia", /atom/movable/screen/fullscreen/hypothermia)

/datum/wound/hypothermia/on_life()
	. = ..()

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/C = owner

	// If warmed up, remove hypothermia
	if(C.bodytemperature >= BODYTEMP_NORMAL_MIN)
		to_chat(C, span_notice("Feeling returns to my body as I warm up."))
		C.clear_fullscreen("hypothermia")
		qdel(src)
		return

	// Occasional discomfort message
	if(!C.stat && prob(5))
		to_chat(C, span_warning("I can't stop shivering..."))

	// After 2 minutes, convert to frostbite
	if(world.time >= start_time + duration)
		var/obj/item/bodypart/BP = bodypart_owner
		if(BP)
			to_chat(C, span_userdanger("I feel pins and needles in [BP]!"))
			BP.add_wound(/datum/wound/frostbite)
			C.clear_fullscreen("hypothermia")
		qdel(src)
