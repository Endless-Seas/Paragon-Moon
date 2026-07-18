/// DREADWOOD FOREST

/area/rogue/outdoors/dread
	icon = 'modular_helmsguard/icons/turf/dreadareas.dmi'

/area/rogue/indoors/dread
	icon = 'modular_helmsguard/icons/turf/dreadareas.dmi'

/area/rogue/outdoors/dread/dreadwoods
	name = "Dreadwood Forest"
	discover_sound = 'sound/misc/area_4.ogg'
	icon_state = "dreadwood"
	ambush_types = list(
				/turf/open/floor/rogue/dirt,
				/turf/open/floor/rogue/grass,
				/turf/open/water)
	ambush_mobs = list(
				/mob/living/carbon/human/species/skeleton/npc/ambush = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 60,
				/mob/living/simple_animal/hostile/retaliate/rogue/trollbog = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/spider = 40,
				/mob/living/carbon/human/species/skeleton/npc/bogguard = 20,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 30)
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	spookysounds = SPOOKY_FROG
	spookynight = SPOOKY_GEN
	location_name = "Dreadwood Forest"
	first_time_text = "Dreadwood Forest"
	ambush_times = list("night","dawn","dusk","day")
	converted_type = /area/rogue/indoors/dread/shelter/dreadwoods

/area/rogue/indoors/dread/shelter/dreadwoods
	icon_state = "dreadwood"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "Somewhere in Dreadwood"

/area/rogue/indoors/dread/church
	name = "Old Church"
	first_time_text = "Old Church"
	icon_state = "dreadchurch"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "Dreadwood Church"

/area/rogue/indoors/dread/toll
	name = "Toll House"
	first_time_text = "Toll House"
	icon_state = "tollhouse"
	droning_sound = null
	droning_sound_dusk = null
	droning_sound_night = null
	location_name = "Dreadwood Toll House"

/area/rogue/outdoors/dread/merc_spawn
	name = "mercenary spawn"
	icon_state = "mercenary_spawn"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "Mercenary Camp"


//NIGHTKEEP

/area/rogue/indoors/dread/nightkeep
	name = "nebelwacht"
	icon_state = "nightkeep"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "somewhere near Nebelwacht Castle"

/area/rogue/outdoors/dread/nightkeep
	name = "nebelwacht_outside"
	first_time_text = "Nebelwacht Castle"
	discover_sound = 'sound/misc/area_2.ogg'
	icon_state = "nightkeep_outside"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "somewhere from inside Nebelwacht Castle"


///GOBLIN OUTPOST

/area/rogue/indoors/dread/gobcamp
	name = "gobcamp"
	icon_state = "gobcamp"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "deep inside of the Goblin Outpost"

/area/rogue/outdoors/dread/gobcamp_outside
	name = "gobcamp_outside"
	first_time_text = "Goblin Outpost"
	discover_sound = 'sound/misc/area_3.ogg'
	icon_state = "nightkeep_outside"
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "Goblin Outpost"

/area/rogue/indoors/dread/forgottenkeep
	name = "forgotten keep"
	icon_state = "forgottenkeep"
	first_time_text = "Forgotten Keep"
	discover_sound = 'sound/misc/area_2.ogg'
	droning_sound = 'sound/music/area/dreadwood.ogg'
	droning_sound_dusk = 'sound/music/area/dreadwood.ogg'
	droning_sound_night = 'sound/music/area/dreadwood_night.ogg'
	location_name = "deep within the Forgotten Keep"

// UNDERBOROUGH
/area/rogue/under/cavewet/dreadcave
	name = "Underway"
	first_time_text = "The Underway"
	location_name = "somewhere in the Underway"
	spookysounds = SPOOKY_FROG
	spookynight = SPOOKY_GEN
