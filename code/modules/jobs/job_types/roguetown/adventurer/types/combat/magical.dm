//We divide Magical into two, unlike Martial and Holy.
//Firstly, Sorcerer. We frontload them with spellpoints and give them some toys.
//Secondly, Conjurer. We reduce spellpoints from Sorcerer and drop to T2, but give them goodies they'd normally otherwise not have.
//No spellblade or anything of the sort, here.
/datum/advclass/mage
	name = "Sorcerer"
	tutorial = "You're a Sorcerer of some manner. Why you've come to this dreadful place, however, is a mystery to all but you. \
	Be cautious, friend, for this place has a way of sapping the lyfe from those who abuse the Arcyne."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/mage
	cmode_music = 'sound/music/combat_highgrain.ogg'
	class_select_category = CLASS_CAT_MAGE
	subclass_social_rank = SOCIAL_RANK_DIRT
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT)
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T3)
	subclass_stats = list(//Spread of seven. +2 from SPD.
		STATKEY_INT = 3,
		STATKEY_WIL = 2,
		STATKEY_SPD = 1,
	)
	subclass_spellpoints = 21
	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/mage/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/roguehood/mage
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	pants = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/rogueweapon/huntingknife
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/spellbook_unfinished/pre_arcyne = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/recipe_book/magic = 1,
		/obj/item/chalk = 1
		)
	H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	if(H.age == AGE_OLD)
		H.mind?.adjust_spellpoints(6)
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_cult.ogg'

/datum/advclass/mage/conjurer
	name = "Conjurer"
	tutorial = "Sorcerer? No. You're a Conjurer. Very different! Gods, damn the fools who'd say otherwise... \
	In any case, you've come prepared. With dust and, admittedly, weaker spells, you may yet serve a greater purpose."
	outfit = /datum/outfit/job/roguetown/adventurer/conjurer
	cmode_music = 'sound/music/combat_poacher.ogg'
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2)
	subclass_stats = list(//Spread of seven.
		STATKEY_INT = 3,
		STATKEY_WIL = 2,
		STATKEY_CON = 2,
	)
	subclass_spellpoints = 15
	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/conjurer/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/roguehood/mage
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	pants = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/rogueweapon/huntingknife/copper
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/amethyst
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1,
	/obj/item/alch/waterdust = 2,
	/obj/item/alch/airdust = 2,
	/obj/item/alch/firedust = 2)
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_cult.ogg'
	H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	if(H.age == AGE_OLD)
		H.mind?.adjust_spellpoints(6)
	if(H.mind)//9 Spellpoints here worth of spells. +3 over sorcerer, but gets less ideal spells.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/conjure_primordial)//Costs +4.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/conjure_weapon)//Costs +2.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/findfamiliar)//Useless but funny. Costs +2.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonweapon)//Not a soul otherwise gets this. +1.
