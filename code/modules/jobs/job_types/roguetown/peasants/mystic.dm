//Our mystic. Now, listen up. What's the purpose of this class?
//Mostly RP. Like most of our additions on Paragon.
//That said, however? Long distance communication. Brain dances.
//The works. I hope this'll be ok for RP.
//It certainly feels fun writing stuff up for it, and the visions for that matter!
//Also this person becomes an actual creechur when that mechanic is finished. Beyond the grafted on transform.
//You know the one. One of our new antags.
//- Carl
/datum/job/roguetown/mystic
	title = "Mystic"
	f_title = "Mystic"
	flag = MYSTIC
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = ACCEPTED_RACES
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)

	tutorial = "You are cursed. Horribly so. For you see the ends that others are to meet, incapable of warning them, lest it come true. \
	The Bathmaster has seen fortune in such, however, having employed you into their service. \
	See to it that you yet do some good with the time you've left, yourself."

	outfit = /datum/outfit/job/roguetown/mystic
	advclass_cat_rolls = list(CTAG_MYSTIC = 20)
	display_order = JDO_MYSTIC
	give_bank_account = TRUE
	can_random = FALSE
	min_pq = 4
	max_pq = null
	round_contrib_points = 3
	advjob_examine = TRUE
	cmode_music = 'sound/music/combat_blackoak.ogg'
	social_rank = SOCIAL_RANK_PEASANT
	job_traits = list(TRAIT_EMPATH, TRAIT_MYSTIC)

	supervisors = "Bathmaster"
	roleplay_exclusive_notify = TRUE

	rp_enforce = "You are <FONT color='green'>expected</font> to: <br> \
				- Assure the good health of both patron and establishment. <br> \
				- Obey the Bathmaster's whim. <br> \
				- Provide services related to your curse."

	rp_forbid = "You are <FONT color='red'>discouraged</font> from: <br> \
				- Abusing patron, or the Bathmaster's good will, in allowing you to remain. <br> \
				- Abusing the nature of your curse, forcing an untimely end upon others."

/datum/outfit/job/roguetown/mystic
	name = "Mystic"
	// This is just a base outfit, the actual outfits are defined in the advclasses

/datum/advclass/mystic
	name = "Mystic"
	tutorial = "A cursed fool."
	outfit = /datum/outfit/job/roguetown/mystic/general
	category_tags = list(CTAG_MYSTIC)
	subclass_stats = list(
		STATKEY_LCK = 2,
		STATKEY_WIL = 2,
		STATKEY_CON = 1
	)
	subclass_skills = list(
		/datum/skill/magic/blood = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/stealing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/music = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/knives = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/mystic/general/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/collar/woolen
	beltl = /obj/item/roguekey/nightmaiden
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	backl = /obj/item/storage/backpack/rogue/satchel
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	armor = /obj/item/clothing/suit/roguetown/shirt/rags
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	pants = /obj/item/clothing/under/roguetown/tights/vagrant
	belt  = /obj/item/storage/belt/rogue/leather/rope

	backpack_contents = list(
		/obj/item/soap/bath = 1,
	)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/message)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mindlink)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/braindance)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/mystic)
