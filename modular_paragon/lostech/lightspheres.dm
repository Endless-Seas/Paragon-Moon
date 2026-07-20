/*
Gravity grenades.
Seriously.
That's... it.
More-or-less.
Except they're also flashbangs.
SURPRISE!!!!
*/
/obj/item/lightsphere
	name = "lightsphere"
	desc = "Some matter of divine object! It looks fragile..."
	dropshrink = 0.6
	icon_state = "lightsphere"//Temp sprite.
	icon = 'modular_paragon/lostech/icons/items/misc.dmi'
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 1
	grid_width = 32
	grid_height = 32
	dropshrink = 0.75

/obj/item/lightsphere/Initialize(mapload)
	. = ..()

/obj/item/lightsphere/proc/explodes()
	for(var/mob/living/carbon/human/H in view(4, src))
		if(!considered_alive(H.mind))
			continue
		H.adjustBruteLoss(40)
		H.adjustFireLoss(40)
		H.blur_eyes(10)
		H.Knockdown(5)
		H.blind_eyes(5)
		to_chat(H, "<span class='userdanger'>BY PSYDON, MY EYES!</span>")
	playsound(src, 'modular_paragon/lostech/sound/sphere.ogg', 100, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	qdel(src)

/obj/item/lightsphere/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	sleep(1)
	explodes()
