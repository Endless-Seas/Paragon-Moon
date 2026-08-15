//We divide holy into three.
//Cleric, which is the typical shield and mace guy. Mid-point between Missionary and Paladin.
//Missionary, which is all miracle no anything else. Full support. Also gets some towner skills.
//Paladin, which drops a lot of the utility for being a bruiser.
/datum/advclass/cleric
	name = "Cleric"
	tutorial = "Robe wearing warriors, holding a shield in one hand and a mace in the other. \
	You are the archetypal cleric. Wield miracle and club in an effort to stave off an inevitable end."
	class_select_category = CLASS_CAT_CLERIC
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT)
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	vampcompat = FALSE

	subclass_social_rank = SOCIAL_RANK_DIRT
	outfit = /datum/outfit/job/roguetown/adventurer/cleric
	cmode_music = 'sound/music/templarofpsydonia.ogg'
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_MEDIUMARMOR)
	subclass_stats = list(//Spread of seven. +2 from STR.
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = 1,
		STATKEY_STR = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
	)
	subclass_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy
	)

/datum/outfit/job/roguetown/adventurer/cleric/pre_equip(mob/living/carbon/human/H)
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/reagent_containers/glass/bottle/rogue/healthpot
	beltr = /obj/item/rogueweapon/mace/spiked
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/leather
	cloak = /obj/item/clothing/cloak/cape/crusader/cleric
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	head = /obj/item/clothing/head/roguetown/roguehood/reinforced
	gloves = /obj/item/clothing/gloves/roguetown/angle
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/metal = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/manapot = 1,
		)

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)

	if(istype(H.patron, /datum/patron/divine))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast)
	if(istype(H.patron, /datum/patron/inhumen))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast/unholyblast)

	H.set_blindness(0)
	switch(H.patron?.type)
		if(/datum/patron/old_god)
			wrists = /obj/item/clothing/neck/roguetown/psicross
		if(/datum/patron/divine/astrata)
			wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
			H.cmode_music = 'sound/music/combat_holy.ogg'
		if(/datum/patron/divine/noc)
			wrists = /obj/item/clothing/neck/roguetown/psicross/noc
		if(/datum/patron/divine/abyssor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
		if(/datum/patron/divine/dendor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
			H.cmode_music = 'sound/music/combat_citywatch.ogg'
		if(/datum/patron/divine/necra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/necra
			H.cmode_music = 'sound/music/combat_ancient.ogg'
		if(/datum/patron/divine/pestra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/pestra
		if(/datum/patron/divine/ravox)
			wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
		if(/datum/patron/divine/malum)
			wrists = /obj/item/clothing/neck/roguetown/psicross/malum
		if(/datum/patron/divine/eora)
			wrists = /obj/item/clothing/neck/roguetown/psicross/eora
			H.cmode_music = 'sound/music/combat_martyrsafe.ogg'
		if(/datum/patron/divine/xylix)
			wrists = /obj/item/clothing/neck/roguetown/psicross/xylix
			H.cmode_music = 'sound/music/combat_jester.ogg'

		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_cult.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen] = 1
		if(/datum/patron/inhumen/matthios)
			H.cmode_music = 'sound/music/unholy.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/matthios] = 1
		if(/datum/patron/inhumen/graggar)
			H.cmode_music = 'sound/music/combat_graggar_new.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/graggar] = 1
		if(/datum/patron/inhumen/baotha)
			H.cmode_music = 'sound/music/combat_starsugar.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/baotha] = 1

/obj/item/clothing/cloak/cape/crusader/cleric
	name = "clerical cloak"
	desc = "A heavy, thick cloak. Meant for the wandering fool of these lands, who believes they may yet bring hope."
	color = CLOTHING_BROWN

/datum/advclass/cleric/paladin
	name = "Paladin"
	tutorial = "Holy knights, charged with defending the weak and keeping their allies aloft by way of miracle. \
	You, of all people, will stand tall in the darkness to come. Brandish blade and slay the reviled undead of the land."
	outfit = /datum/outfit/job/roguetown/adventurer/paladin
	cmode_music = 'sound/music/templarofpsydonia.ogg'
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_HEAVYARMOR)
	subclass_stats = list(//Spread of seven. +4 from STR.
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/shields = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_APPRENTICE,
	)

	extra_context = "With exception to Noc and Pestra's domain, each Pantheon member is provided a curated miracle of T2 strength."

/datum/outfit/job/roguetown/adventurer/paladin/pre_equip(mob/living/carbon/human/H)
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/flashlight/flare/torch/lantern
	beltl = /obj/item/reagent_containers/glass/bottle/rogue/healthpot
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	cloak = /obj/item/clothing/cloak/cape/crusader/cleric
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

	var/helmets = list("Volfskulle","Buckethelm", "Knightly", "Kettle & Wildguard")
	var/helmet_choice = input(H, "Choose your HELMET.", "WALK IN THE LIGHT.") as anything in helmets
	switch(helmet_choice)
		if("Volfskulle")//Kind of the objective best but it FUCKS
			head = /obj/item/clothing/head/roguetown/helmet/heavy/volfplate/iron
		if("Buckethelm")
			head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/iron
		if("Knightly")
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/iron
		if("Kettle & Wildguard")
			head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
			mask = /obj/item/clothing/mask/rogue/wildguard

	var/weapons = list("Greatsword", "Polehammer", "Shield & Spear")
	var/weapon_choice = input(H, "Choose your WEAPON.", "TAKE UP YOUR MIGHT.") as anything in weapons
	switch(weapon_choice)
		if("Greatsword")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
			r_hand = /obj/item/rogueweapon/greatsword/warbrand
			backr = /obj/item/rogueweapon/scabbard/gwstrap
		if("Polehammer")
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne
			backr = /obj/item/rogueweapon/scabbard/gwstrap
		if("Shield & Spear")//Nomads, where ye at?
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_JOURNEYMAN, TRUE)
			l_hand = /obj/item/rogueweapon/spear/nomad/paladin
			r_hand = /obj/item/rogueweapon/shield/heater
			backr = /obj/item/rogueweapon/scabbard/gwstrap

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()

	if(istype(H.patron, /datum/patron/divine))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast)
	if(istype(H.patron, /datum/patron/inhumen))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast/unholyblast)

	H.set_blindness(0)
	switch(H.patron?.type)
		if(/datum/patron/old_god)
			wrists = /obj/item/clothing/neck/roguetown/psicross
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/self/psydonrespite)//Less than T2 is important for others. These guys? Not so much.
		if(/datum/patron/divine/astrata)
			wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
			H.cmode_music = 'sound/music/combat_holy.ogg'
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/self/astratan_spear)//YEAH!!!!!
		if(/datum/patron/divine/noc)
			wrists = /obj/item/clothing/neck/roguetown/psicross/noc//Gotta make something for them.
		if(/datum/patron/divine/abyssor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/abyssheal)//We'll need to make something better, but it works, for now
		if(/datum/patron/divine/dendor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
			H.cmode_music = 'sound/music/combat_citywatch.ogg'
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/targeted/beasttame)//Actual nothingburger, but in theme.
		if(/datum/patron/divine/necra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/necra
			H.cmode_music = 'sound/music/combat_ancient.ogg'
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/targeted/abrogation)//This is also soulful. We just don't want Undertow, blinding, pest-blade, etc.
		if(/datum/patron/divine/pestra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/pestra//Same issue as Noc.
		if(/datum/patron/divine/ravox)
			wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/self/call_to_arms)//Soulful.
		if(/datum/patron/divine/malum)
			wrists = /obj/item/clothing/neck/roguetown/psicross/malum
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/malum_earth_step)//This is better than heat metal. I'd think. Maybe? :(
		if(/datum/patron/divine/eora)
			wrists = /obj/item/clothing/neck/roguetown/psicross/eora
			H.cmode_music = 'sound/music/combat_martyrsafe.ogg'
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/heartweave)//Not just sexpests.
		if(/datum/patron/divine/xylix)
			wrists = /obj/item/clothing/neck/roguetown/psicross/xylix
			H.cmode_music = 'sound/music/combat_jester.ogg'
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/mastersillusion)//I'll beat you to death with hammers if you give them slick trick.

		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_cult.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen] = 1
		if(/datum/patron/inhumen/matthios)
			H.cmode_music = 'sound/music/unholy.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/matthios] = 1
		if(/datum/patron/inhumen/graggar)
			H.cmode_music = 'sound/music/combat_graggar_new.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/graggar] = 1
		if(/datum/patron/inhumen/baotha)
			H.cmode_music = 'sound/music/combat_starsugar.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/baotha] = 1

/datum/advclass/cleric/missionary
	name = "Missionary"
	tutorial = "You're a missionary of some nature. Whether that be of ill intent or genuine care. \
	Equipped with what little you've left in lyfe, you have made your way towards the isle. Perhaps an adventuring party could make use of your skills..."
	outfit = /datum/outfit/job/roguetown/adventurer/missionary
	cmode_music = 'sound/music/templarofpsydonia.ogg'
	traits_applied = list(TRAIT_EMPATH)
	subclass_stats = list(//Spread of seven.
		STATKEY_INT = 2,
		STATKEY_PER = 2,
		STATKEY_WIL = 2,
		STATKEY_LCK = 1,
	)
	subclass_skills = list(
		/datum/skill/magic/holy = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
	)
	subclass_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy
	)

/datum/outfit/job/roguetown/adventurer/missionary/pre_equip(mob/living/carbon/human/H)
	if(H.mind?.current)
		H.mind.current.faction += "[H.name]_faction"
	var/datum/inspiration/I = new /datum/inspiration(H)
	I.grant_inspiration(H, bard_tier = BARD_T2)
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/storage/belt/rogue/surgery_bag/full
	beltl = /obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/metal = 1,
		)

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_MAJOR, devotion_limit = CLERIC_REQ_3)

	if(istype(H.patron, /datum/patron/divine))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast)
	if(istype(H.patron, /datum/patron/inhumen))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast/unholyblast)

	H.set_blindness(0)
	switch(H.patron?.type)
		if(/datum/patron/old_god)
			wrists = /obj/item/clothing/neck/roguetown/psicross
		if(/datum/patron/divine/astrata)
			wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
			H.cmode_music = 'sound/music/combat_holy.ogg'
		if(/datum/patron/divine/noc)
			wrists = /obj/item/clothing/neck/roguetown/psicross/noc
		if(/datum/patron/divine/abyssor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
		if(/datum/patron/divine/dendor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
			H.cmode_music = 'sound/music/combat_citywatch.ogg'
		if(/datum/patron/divine/necra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/necra
			H.cmode_music = 'sound/music/combat_ancient.ogg'
		if(/datum/patron/divine/pestra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/pestra
		if(/datum/patron/divine/ravox)
			wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
		if(/datum/patron/divine/malum)
			wrists = /obj/item/clothing/neck/roguetown/psicross/malum
		if(/datum/patron/divine/eora)
			wrists = /obj/item/clothing/neck/roguetown/psicross/eora
			H.cmode_music = 'sound/music/combat_martyrsafe.ogg'
			backpack_contents[/obj/item/reagent_containers/eoran_seed] = 1
			ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
		if(/datum/patron/divine/xylix)
			wrists = /obj/item/clothing/neck/roguetown/psicross/xylix
			H.cmode_music = 'sound/music/combat_jester.ogg'

		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_cult.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen] = 1
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/minion_order)
			H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/gravemark)
		if(/datum/patron/inhumen/matthios)
			H.cmode_music = 'sound/music/unholy.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/matthios] = 1
		if(/datum/patron/inhumen/graggar)
			H.cmode_music = 'sound/music/combat_graggar_new.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/graggar] = 1
		if(/datum/patron/inhumen/baotha)
			H.cmode_music = 'sound/music/combat_starsugar.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
			backpack_contents[/obj/item/clothing/neck/roguetown/psicross/inhumen/baotha] = 1
