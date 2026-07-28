//Exclusive to the mystic, as per the file name's suggestion.
//Don't hand this out. Seriously. It's integral to their character.
/obj/effect/proc_holder/spell/targeted/shapeshift/mystic
	name = "Curseshift"
	desc = "As per the nature of your curse, you may temporarily allow it to... take over, as it were."
	invocations = list("ARGH!!")
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

	to_chat(user, span_info("<small>I feel my bones pop... <br>\
	<b>Something is wrong!</small></b>"))
	H.Jitter(15)
	if(do_after(user, 5 SECONDS))
		to_chat(user, span_danger("Gods above! Agony!"))//Funny tags don't work with typical spans like this.
		H.emote("agony", forced = TRUE)
		H.Jitter(15)

		if(do_after(user, 5 SECONDS))
			if(istype(H, /mob/living/carbon/human/species/wildshape/mystic))
				to_chat(user,"<span class='bloody'><b>You need to feast! To scratch and bite!</span></b> <br>\
				<span class='his_grace'>Except... you don't? Always an unpleasant experience...</span>")
				H.wildshape_untransform()
				return TRUE

			to_chat(user,"<span class='his_grace'><b>An eerie calm overtakes your mind. It's peaceful, for but a brief period.</span></b> <br>\
			<span class='bloody'>It won't be long before the gnawing subsumes your thoughts. Temper this ferocity, lest it consume you, in both body and soul.</span>")
			H.wildshape_transformation(/mob/living/carbon/human/species/wildshape/mystic)
			return TRUE

	else
		revert_cast()

