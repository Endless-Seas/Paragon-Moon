/mob/living/carbon/human/species/wildshape/mystic
	name = "Horror"
	race = /datum/species/shapemystic
	footstep_type = FOOTSTEP_MOB_CLAW
	ambushable = FALSE
	skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/mystic_skin
	wildshape_icon = 'modular_paragon/icons/mob/mystic.dmi'//Temp sprite.
	wildshape_icon_state = "mystic"//Double temp sprite. GOD WHY.

//BUCKLING
/mob/living/carbon/human/species/wildshape/mystic/buckle_mob(mob/living/target, force = TRUE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0)
	. = ..(target, force, check_loc, lying_buckle, hands_needed, target_hands_needed)

/mob/living/carbon/human/species/wildshape/mystic/gain_inherent_skills()
	. = ..()
	if(src.mind)
		src.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		src.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		src.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		src.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		src.adjust_skillrank(/datum/skill/misc/tracking, 6, TRUE)

		src.STASTR = 16//Kick open those doors, brother. I believe in you!!!
		src.STACON = 12
		src.STAPER = 8
		src.STASPD = 8

		AddSpell(new /obj/effect/proc_holder/spell/self/wolfclaws)
		if (src.client.prefs?.wildshape_name)
			real_name = "horror ([stored_mob.real_name])"
		else
			real_name = "horror"

/datum/species/shapemystic
	name = "horror"
	id = "shapehorror"
	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES)
	inherent_traits = list(
		TRAIT_KNEESTINGER_IMMUNITY,
		TRAIT_STRONGBITE,
		TRAIT_STEELHEARTED,
		TRAIT_BREADY,
		TRAIT_ORGAN_EATER,
		TRAIT_WILD_EATER,
		TRAIT_HARDDISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_LONGSTRIDER,
		TRAIT_PERFECT_TRACKER
	)
	inherent_biotypes = MOB_HUMANOID
	armor = 5
	no_equip = list(SLOT_SHIRT, SLOT_HEAD, SLOT_WEAR_MASK, SLOT_ARMOR, SLOT_GLOVES, SLOT_SHOES, SLOT_PANTS, SLOT_CLOAK, SLOT_BELT, SLOT_BACK_R, SLOT_BACK_L, SLOT_S_STORE)
	nojumpsuit = 1
	sexes = 1
	offset_features = list(OFFSET_HANDS = list(0,2), OFFSET_HANDS_F = list(0,2))
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/wild_tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		)

	languages = list(
		/datum/language/abyssal
	)

/datum/species/shapemystic/send_voice(mob/living/carbon/human/H)
	playsound(get_turf(H), pick('modular_paragon/mage_resource/sound/recovery_one.ogg','modular_paragon/mage_resource/sound/recovery_two.ogg'), 80, TRUE, -1)

/datum/species/shapemystic/regenerate_icons(mob/living/carbon/human/H)
	H.icon = 'modular_paragon/icons/mob/mystic.dmi'//SUPER TEMP.
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	H.icon_state = "mystic"//TEMP TEMP TEMP
	H.update_damage_overlays()
	return TRUE

/datum/species/shapemystic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/shapemystic/update_damage_overlays(mob/living/carbon/human/H)
	H.remove_overlay(DAMAGE_LAYER)
	return TRUE

// MYSTIC SPECIFIC ITEMS //
/obj/item/clothing/suit/roguetown/armor/skin_armor/mystic_skin
	slot_flags = null
	name = "horror's flesh"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	body_parts_inherent = FULL_BODY
	armor = ARMOR_LEATHER
	prevent_crits = list(BCLASS_CUT, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = FALSE
	max_integrity = 400
	item_flags = DROPDEL
