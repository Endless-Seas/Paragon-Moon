/*
The death screen, after Casualties: Unknown's. Replaces the old "You have perished" splash.

CU shows you your own body as it died - lying still, in a pool of blood, or blurred and blue if you drowned - over the
cause and a handful of stats about the run. This does the same with the player's actual character: their sprite, lying
dead and scaled up, treated to match how they went, with the cause as the headline and their stats underneath.

Client side like the rest of the decline: built from screen objects on the dead player's client only.
It fades out on its own after DEATH_SCREEN_TIME, or straight away on a click.
*/

#define DEATH_SCREEN_TIME (20 SECONDS)
#define DEATH_SCREEN_FADE (2 SECONDS)
#define DEATH_SCREEN_HEADLINE(text, colour) {"<span style='text-align:center; vertical-align:top; color:[colour]; font-size:300%; font-family:"Blackmoor LET", "Pterra"; text-shadow:0 0 6px #000, 0 0 2px #000;'>[text]</span>"}
#define DEATH_SCREEN_SMALL(text, colour) {"<span style='text-align:center; vertical-align:top; color:[colour]; font-family:"Pterra"; line-height:1.4;'>[text]</span>"}

#define DEATH_CAUSE_BEHEADED "beheaded"
#define DEATH_CAUSE_DROWNED "drowned"
#define DEATH_CAUSE_BLED "bled"
#define DEATH_CAUSE_BURNED "burned"
#define DEATH_CAUSE_SICK "sick"
#define DEATH_CAUSE_STARVED "starved"
#define DEATH_CAUSE_THIRST "thirst"
#define DEATH_CAUSE_SUFFOCATED "suffocated"
#define DEATH_CAUSE_WOUNDS "wounds"

/// Deaths per ckey this round, for the "death #" line.
GLOBAL_LIST_EMPTY(death_screen_counts)

/mob/living
	/// world.time a player first took this body, for the "survived" line.
	var/first_inhabited = 0

/mob/living/Login()
	. = ..()
	if(!first_inhabited)
		first_inhabited = world.time

/// What killed us, as one of the DEATH_CAUSE_ defines. Worked out from what's left at the moment we're looked at.
/mob/living/proc/get_death_cause()
	var/brute = getBruteLoss()
	var/burn = getFireLoss()
	var/tox = getToxLoss()
	var/oxy = getOxyLoss()
	var/worst = max(brute, burn, tox, oxy)
	if(worst <= 0 || worst == brute)
		return DEATH_CAUSE_WOUNDS
	if(worst == burn)
		return DEATH_CAUSE_BURNED
	if(worst == tox)
		return DEATH_CAUSE_SICK
	return DEATH_CAUSE_SUFFOCATED

/mob/living/carbon/get_death_cause()
	if(!get_bodypart(BODY_ZONE_HEAD))
		return DEATH_CAUSE_BEHEADED
	var/oxy = getOxyLoss()
	if(istype(get_turf(src), /turf/open/water) && oxy >= max(getBruteLoss(), getFireLoss(), getToxLoss()))
		return DEATH_CAUSE_DROWNED
	if(blood_volume < BLOOD_VOLUME_SURVIVE && !HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE) && !(dna?.species && (NOBLOOD in dna.species.species_traits)))
		return DEATH_CAUSE_BLED
	// Wasting away only counts if nothing more violent got there first.
	if(getBruteLoss() + getFireLoss() < 50)
		if(hydration <= 0)
			return DEATH_CAUSE_THIRST
		if(nutrition <= 0)
			return DEATH_CAUSE_STARVED
	return ..()

/// The death screen itself. Owns its screen objects and cleans them up.
/datum/death_screen
	var/client/viewer
	var/list/parts = list()
	var/dismissed = FALSE

/datum/death_screen/New(mob/living/dead)
	viewer = dead.client
	if(!viewer)
		qdel(src)
		return
	var/cause = dead.get_death_cause()
	var/accent = death_screen_accent(cause)

	var/atom/movable/screen/death_screen/backdrop/backdrop = new()
	backdrop.owner = src
	add_part(backdrop, 0, 1 SECONDS)

	if(cause == DEATH_CAUSE_BLED || cause == DEATH_CAUSE_WOUNDS || cause == DEATH_CAUSE_BEHEADED)
		var/atom/movable/screen/death_screen/pool = new()
		pool.icon = 'icons/effects/blood.dmi'
		pool.icon_state = "floor[rand(1, 6)]"
		pool.color = "#5a0606"
		pool.transform = matrix(6, 0, 0, 0, 3, -14)
		pool.layer = SPLASHSCREEN_LAYER + 0.2
		pool.screen_loc = "CENTER,CENTER+2"
		add_part(pool, 0.5 SECONDS, 2.5 SECONDS)

	add_part(make_portrait(dead, cause), 0.5 SECONDS, 2.5 SECONDS)

	add_part(make_text(DEATH_SCREEN_HEADLINE(death_screen_headline(cause), accent), 196, 64), 1.5 SECONDS, 1.5 SECONDS)
	add_part(make_text(DEATH_SCREEN_SMALL(dead.real_name, "#8c8c8c"), 172, 24), 2 SECONDS, 1.5 SECONDS)
	add_part(make_text(DEATH_SCREEN_SMALL(death_screen_stats(dead), "#b4b4b4"), 40, 128), 2.5 SECONDS, 2 SECONDS)
	add_part(make_text(DEATH_SCREEN_SMALL("Click to look away.", "#505050"), 8, 20), 4 SECONDS, 2 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(dismiss)), DEATH_SCREEN_TIME, TIMER_CLIENT_TIME)

/datum/death_screen/Destroy()
	if(viewer)
		viewer.screen -= parts
	QDEL_LIST(parts)
	viewer = null
	return ..()

/// Adds a piece to the screen, fading it in after a delay.
/datum/death_screen/proc/add_part(atom/movable/screen/death_screen/part, delay, fade)
	parts += part
	part.alpha = 0
	viewer.screen += part
	animate(part, alpha = 0, time = delay)
	animate(alpha = 255, time = fade, easing = SINE_EASING)

/datum/death_screen/proc/dismiss()
	if(dismissed || QDELETED(src))
		return
	dismissed = TRUE
	for(var/atom/movable/screen/part as anything in parts)
		animate(part, alpha = 0, time = DEATH_SCREEN_FADE, easing = SINE_EASING)
	QDEL_IN(src, DEATH_SCREEN_FADE)

/// Their own body, lying as it fell, scaled up and treated to match how they died.
/datum/death_screen/proc/make_portrait(mob/living/dead, cause)
	var/atom/movable/screen/death_screen/portrait = new()
	var/mutable_appearance/body = new(dead)
	body.plane = SPLASHSCREEN_PLANE
	body.layer = SPLASHSCREEN_LAYER + 0.3
	body.appearance_flags |= KEEP_TOGETHER | PIXEL_SCALE | NO_CLIENT_COLOR
	body.alpha = 255
	body.pixel_x = 0
	body.pixel_y = 0
	body.dir = SOUTH
	var/matrix/lying = matrix()
	lying.Turn(90)
	lying.Scale(4)
	body.transform = lying
	body.color = null
	body.maptext = null
	switch(cause)
		if(DEATH_CAUSE_DROWNED)
			body.color = list(0.3,0.35,0.5, 0.3,0.4,0.55, 0.1,0.15,0.35, 0,0,0.05)
		if(DEATH_CAUSE_BURNED)
			body.color = list(0.35,0.22,0.15, 0.3,0.18,0.12, 0.1,0.06,0.04, 0,0,0)
		if(DEATH_CAUSE_SICK, DEATH_CAUSE_STARVED, DEATH_CAUSE_THIRST, DEATH_CAUSE_SUFFOCATED)
			body.color = list(0.3,0.3,0.28, 0.45,0.45,0.42, 0.1,0.1,0.1, 0,0,0)
	portrait.appearance = body
	portrait.screen_loc = "CENTER,CENTER+2"
	portrait.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(cause == DEATH_CAUSE_DROWNED)
		portrait.filters += filter(type = "blur", size = 1.5)
	return portrait

/datum/death_screen/proc/make_text(text, y, height)
	var/atom/movable/screen/death_screen/line = new()
	line.screen_loc = "CENTER-7,CENTER-7"
	line.maptext_width = 480
	line.maptext_height = height
	line.maptext_y = y
	line.maptext = text
	line.layer = SPLASHSCREEN_LAYER + 0.4
	return line

/proc/death_screen_headline(cause)
	switch(cause)
		if(DEATH_CAUSE_BEHEADED)
			return "Your head was taken."
		if(DEATH_CAUSE_DROWNED)
			return "You drowned."
		if(DEATH_CAUSE_BLED)
			return "You bled out."
		if(DEATH_CAUSE_BURNED)
			return "You burned."
		if(DEATH_CAUSE_SICK)
			return "The sickness took you."
		if(DEATH_CAUSE_STARVED)
			return "You starved."
		if(DEATH_CAUSE_THIRST)
			return "You died of thirst."
		if(DEATH_CAUSE_SUFFOCATED)
			return "You suffocated."
	return "Your wounds were too many."

/proc/death_screen_accent(cause)
	switch(cause)
		if(DEATH_CAUSE_DROWNED)
			return "#6f8fb4"
		if(DEATH_CAUSE_BURNED)
			return "#c0703a"
		if(DEATH_CAUSE_SICK)
			return "#8a9a5a"
		if(DEATH_CAUSE_STARVED, DEATH_CAUSE_THIRST, DEATH_CAUSE_SUFFOCATED)
			return "#a0a0a0"
	return "#9a1a1a"

/// The run, in a few lines - CU shows depth, how long you lasted, your mood and how many times you've died.
/proc/death_screen_stats(mob/living/dead)
	var/list/lines = list()
	var/alive_for = dead.first_inhabited ? world.time - dead.first_inhabited : 0
	lines += "Survived: [death_screen_duration(alive_for)]"
	var/area/where = get_area(dead)
	if(where)
		lines += "Fell in: [where.name]"
	if(iscarbon(dead))
		var/mob/living/carbon/C = dead
		lines += "Blood left: [round(100 * clamp(C.blood_volume / BLOOD_VOLUME_NORMAL, 0, 1))]%"
	lines += "Wounds: [length(dead.get_wounds())]"
	lines += "In the end: [death_screen_mood(dead.get_stress_amount())]"
	var/key = dead.ckey || "unknown"
	GLOB.death_screen_counts[key] = (GLOB.death_screen_counts[key] || 0) + 1
	lines += "Death #[GLOB.death_screen_counts[key]] this round"
	return lines.Join("<br>")

/proc/death_screen_duration(time)
	var/minutes = round(time / (1 MINUTES))
	if(minutes < 1)
		return "less than a minute"
	if(minutes < 60)
		return "[minutes] minute[minutes == 1 ? "" : "s"]"
	return "[round(minutes / 60)]h [minutes % 60]m"

/proc/death_screen_mood(stress)
	if(stress < 0)
		return "At peace"
	if(stress < 1)
		return "Steady"
	if(stress < 10)
		return "Uneasy"
	if(stress < 20)
		return "Distressed"
	if(stress < 30)
		return "Despairing"
	return "Broken"

/atom/movable/screen/death_screen
	icon = null
	plane = SPLASHSCREEN_PLANE
	layer = SPLASHSCREEN_LAYER + 0.1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI | NO_CLIENT_COLOR | PIXEL_SCALE

/// Solid black across the whole screen, map and HUD alike. Click it to look away.
/atom/movable/screen/death_screen/backdrop
	icon = 'icons/gameover.dmi'
	icon_state = "blank"
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/death_screen/owner

/atom/movable/screen/death_screen/backdrop/New()
	. = ..()
	transform = matrix(4, 0, 0, 0, 4, 0) // 640x480 scaled up from the middle covers any view size

/atom/movable/screen/death_screen/backdrop/Click()
	owner?.dismiss()

/atom/movable/screen/death_screen/backdrop/Destroy()
	owner = null
	return ..()

#undef DEATH_SCREEN_HEADLINE
#undef DEATH_SCREEN_SMALL
#undef DEATH_SCREEN_TIME
#undef DEATH_SCREEN_FADE
#undef DEATH_CAUSE_BEHEADED
#undef DEATH_CAUSE_DROWNED
#undef DEATH_CAUSE_BLED
#undef DEATH_CAUSE_BURNED
#undef DEATH_CAUSE_SICK
#undef DEATH_CAUSE_STARVED
#undef DEATH_CAUSE_THIRST
#undef DEATH_CAUSE_SUFFOCATED
#undef DEATH_CAUSE_WOUNDS
