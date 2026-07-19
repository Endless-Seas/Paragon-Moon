/*
Pulled from, as of some time ago, something original to Foundation.
As far as I'm aware, anyhow. If that's not the case anymore, or I'm mistaken, do let me know.
We've repurposed this for our use, with modifications where necessary. - Carl
- - -
Current icons:
small - small circle
default - full size circle
boom - jagged circle
*/
#define SFX_ICON_SMALL "small"
#define SFX_ICON_FULL "default"
#define SFX_ICON_JAGGED "boom"

/proc/show_sound_effect(turf/T, mob/source, soundicon = SFX_ICON_FULL)
	var/list/clients_to_show = list()
	var/mob/living/M

	for(M in view(7, T))
		var/client/C = M.client
		if(HAS_TRAIT(M, TRAIT_DEAF) || !C)
			continue
		clients_to_show += C

	if(!length(clients_to_show))
		return

	if(source)
		clients_to_show -= source.client

	var/image/I = image('modular_paragon/icons/mob/effects.dmi', loc = T, icon_state = soundicon)
	I.plane = WALL_PLANE
	I.layer = CHAT_LAYER

	flick_overlay(I, clients_to_show, 6)

/*
General ping for grabbing and dropping items.
This is an example of what we can do with the above.
It doesn't look great, but it WORKS.
*/

// Dropping.
/obj/item/dropped()
	if(w_class >= WEIGHT_CLASS_BULKY)
		show_sound_effect(src, soundicon = SFX_ICON_JAGGED)
	else
		show_sound_effect(src, soundicon = SFX_ICON_FULL)

// Grabbing.
/obj/item/pickup()
	show_sound_effect(src, soundicon = SFX_ICON_SMALL)
