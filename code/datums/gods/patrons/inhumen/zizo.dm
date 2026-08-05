/datum/patron/inhumen/zizo
	name = "Zizo"
	titles = "The Timekeeper. The Eternal. The Puppeteer."
	domain = "Secrets, Undeath, Time"
	desc = "The Patron of those who seek success at any cost. \
	Followers of this domain seek to gain an upper hand, be it by asking to bend time in their favour, \
	to gain power through trickery and sinister ploys or to even will the dead to serve once more. Their worship is regarded as vile and dangerous."
	worshippers = "Seekers of Life Eternal, Necromancers, Spies, Schemers"
	virtues = "Chaos, Lust for Power, Clever Ploys, Sowing Disorder"
	sins = "Brute Force, Talentless Hacks, Needless Theatrics "
	mob_traits = list(TRAIT_CABAL, TRAIT_ZIZOSIGHT)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/zizo_snuff						= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/profane/miracle 	= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/raise_undead_formation/miracle= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/tame_undead/miracle			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/rituos/miracle 				= CLERIC_T3,
					/obj/effect/proc_holder/spell/targeted/touch/lacrima				= CLERIC_T3,
	)
	confess_lines = list(
		"PRAISE ZIZO THE IMMORTAL!",
		"LONG LIVE ZIZO THE IMMORTAL!",
		"ZIZO IS THE QUEEN ETERNAL!",
	)
	storyteller = /datum/storyteller/zizo

/datum/patron/inhumen/zizo/post_equip(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/human = pious
		var/datum/devotion/pious_devotion = human.devotion
		if(pious_devotion?.level >= CLERIC_T2)
			pious.grant_language(/datum/language/undead)

// When the sun is blotted out, zchurch, bad-cross, or ritual chalk
/datum/patron/inhumen/zizo/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the Zzzzzzzurch(!)
	if(istype(get_area(follower), /area/rogue/indoors/shelter/mountains))
		return TRUE
	// Allows prayer near EEEVIL psycross
	for(var/obj/structure/fluff/psycross/zizocross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer near a grave.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer during the sun being blotted from the sky.
	if(hasomen(OMEN_SUNSTEAL))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/zizo in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Zizo to hear my prayers I must either be in the church of the abandoned, near an inverted psycross, atop a drawn Zizite symbol, or while the sun is blotted from the sky!"))
	return FALSE

/datum/patron/inhumen/zizo/on_lesser_heal(
	mob/living/user,
	mob/living/target,
	message_out,
	message_self,
	conditional_buff,
	situational_bonus,
	is_inhumen
)
	*is_inhumen = TRUE
	*message_out = span_info("Vital energies are sapped towards [target]!")
	*message_self = span_notice("The life around me pales as I am restored!")

	var/bonus = 0

	for(var/obj/item/natural/bone/bone in oview(5, user))
		bonus += 0.5

	for(var/obj/item/natural/bundle/bone/bone in oview(5, user))
		bonus += (bone.amount * 0.5)

	if(!bonus)
		return

	*conditional_buff = TRUE
	*situational_bonus = min(bonus, 5)
