/*
Pens, intended to disintegrate on use.
They confer various bonuses, but mainly just give you the power of a leper gnome.
It's just redone hypos.
I really should clean this up, but for now it's mostly the old garbage from OldRW. - Carl
*/
/obj/item/reagent_containers/stimpen
	name = "stimpen"
	desc = "An incredibly ancient device of some divine nature. <br>\
	<small><span class='bloody'>It calls to you. Can you feel it?</span></small> <br>\
	<span class='bloody'>USE IT</span>"
	icon = 'modular_paragon/lostech/icons/items/medical.dmi'
	item_state = "stimpen_nanite"//It's just an F13 medx sprite. The good one, mind. But I've chopped it up. Woe...
	icon_state = "stimpen_nanite"
	volume = 30
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list()
	resistance_flags = ACID_PROOF
	reagent_flags = OPENCONTAINER//Ideally, you'd take the fluid out. But, y'know...
	slot_flags = ITEM_SLOT_BELT
	list_reagents = list(/datum/reagent/medicine/stimpen_health = 30)

/obj/item/reagent_containers/stimpen/functional/inject(mob/living/M, mob/user)
	return ..(M, user, src)  // Call parent with normal injection behavior

/obj/item/reagent_containers/stimpen/attack(mob/living/M, mob/user)
	inject(M, user)
	..()
	src.visible_message(span_warning("The [src] all but evaporates in [user]'s grasp!"), vision_distance = COMBAT_MESSAGE_RANGE)
	to_chat(user, span_warning("[src] evaporates in your hands!"))
	qdel(src)

/obj/item/reagent_containers/stimpen/proc/inject(mob/living/M, mob/user, obj/item/reagent_containers/stimpen/this, drinking = FALSE)
	if(!this.reagents.total_volume)
		to_chat(user, span_warning("[this] is empty!"))
		return FALSE
	if(!iscarbon(M))
		to_chat(user, span_warning("You can't use that on this!"))
		return FALSE
	if(!M)
		return FALSE
	var/list/injected = list()
	for(var/datum/reagent/R in this.reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)

	log_combat(user, M, "attempted to [drinking ? "force-feed" : "inject"]", this, "([contained])")
	log_admin(user, M, "attempted to [drinking ? "force-feed" : "inject"]", this, "([contained])")

	if(!do_after(user, 2 SECONDS, M))  // Can be interrupted if user moves, gets stunned, etc.
		to_chat(user, span_warning("Your [drinking ? "feeding" : "injection"] attempt was interrupted!"))
		return FALSE

	if(this.reagents.total_volume && (!M.stat || M.can_inject(user, 1)))
		to_chat(M, span_warning("I feel a [drinking ? "bit of liquid forced into my mouth" : "tiny prick"]!"))
		to_chat(user, span_notice("You [drinking ? "force [M] to drink" : "inject[M] with"]  [this]."))

		var/fraction = min(this.amount_per_transfer_from_this / this.reagents.total_volume, 1)
		this.reagents.reaction(M, INJECT, fraction)

		if(M.reagents)
			var/trans = 0
			trans = this.reagents.trans_to(M, this.amount_per_transfer_from_this, transfered_by = user)

			to_chat(user, span_notice("[trans] unit\s [drinking ? "swallowed" : "injected"]. [this.reagents.total_volume] unit\s remaining in [this]."))

			log_combat(user, M, "[drinking ? "force-fed" : "successfully injected"]", this, "([contained])")
			log_admin(user, M, "[drinking ? "force-fed" : "successfully injected"]", this, "([contained])")

		playsound(src, 'modular_paragon/lostech/sound/stim_use.ogg', 100, TRUE)

		return TRUE
	return FALSE
