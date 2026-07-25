//Exclusive to the mystic, as per the file name's suggestion.
//Don't hand this out. Seriously. It's integral to their character.
/obj/effect/proc_holder/spell/targeted/shapeshift/mystic
	name = "Curseshift"
	desc = "As per the nature of your curse, you may temporarily allow it to... take over, as it were."
	invocations = list("The curse shall feast while I rest!")
	invocation_type = "shout"
	overlay_state = "tamebeast"
	human_req = FALSE
	range = -1
	include_user = TRUE
	recharge_time = 5 MINUTES // RAAAAAAA
	cooldown_min = 50
	action_icon_state = "shapeshift"
	associated_skill = /datum/skill/magic/blood
	chargetime = 5 SECONDS
	devotion_cost = 200

/obj/effect/proc_holder/spell/targeted/shapeshift/mystic/cast(list/targets, mob/user = usr)
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		return

	if(istype(H, /mob/living/carbon/human/species/wildshape/mystic))
		H.wildshape_untransform()
		return TRUE

	H.wildshape_transformation(/mob/living/carbon/human/species/wildshape/mystic)
	return TRUE
