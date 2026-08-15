//Special stamina and energy regen.
//This is WILD and locked to their ritual for a reason.
//Equivalent to a full reset for energy and stamina on 99% of characters. Full stop.
//Frag on, my little fragchamp.
/obj/effect/proc_holder/spell/self/justiciar_might
	name = "Justiciar's Might"
	desc = "Grants an immediate boost to stamina and energy, so you may continue to fight on! \
	Once used, this power will vanish from your frame."
	overlay_icon = 'icons/mob/actions/ravoxmiracles.dmi'
	action_icon = 'icons/mob/actions/ravoxmiracles.dmi'
	overlay_state = "ravox_might"//I'm so tired I didn't even bother.
	sound = 'sound/magic/necra_sight.ogg'
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	invocations = list("RAAAGH!!")//RAAAGH!! KILL!! You can't even see this, though. But it's funny.
	invocation_type = "shout"
	miracle = TRUE
	var/stam_recovery = 200//Oh, yeah!!!! WELCOME TO FRAG TOWN, BABY!!!
	var/blue_recovery = 1650//WHO'S KING OF FRAG TOWN? I AM!!!!

/obj/effect/proc_holder/spell/self/justiciar_might/cast(mob/living/carbon/human/user)
	user.stamina_add(-stam_recovery)
	user.energy_add(blue_recovery)
	to_chat(user, span_monkeyhive("FIGHT WELL!"))
	user.mind?.RemoveSpell(/obj/effect/proc_holder/spell/self/justiciar_might)
