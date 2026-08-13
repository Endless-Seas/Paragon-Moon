//Martial classes, divided into three, as with elsewhere.
//Champion, which is a universal weapon skill fighter. Only adventurer with expert in a mainline skill.
//Barbarian, which, mind, I'm sure you can imagine. Unarmed or axe. Losers use an axe.
//Stalker. Which gets a TON of non-combat utility. Doesn't bleed into Missionary overlap, however.
/datum/advclass/sfighter
	name = "Champion"
	tutorial = "You're an exceptionally skilled fighter. Regardless of where you hail from, few of this land can best you. \
	Save, perhaps, for the inhabitant's own garrison."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/sfighter
	cmode_music = 'sound/music/combat_routier.ogg'
	subclass_social_rank = SOCIAL_RANK_DIRT
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_MEDIUMARMOR)
	class_select_category = CLASS_CAT_WARRIOR
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT, CTAG_LICKER_WRETCH)
	subclass_stats = list(//Spread of seven. +2 from STR.
		STATKEY_STR = 2,
		STATKEY_WIL = 1,
		STATKEY_CON = 1,
		STATKEY_PER = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/shields = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)
	extra_context = "This subclass has a wide spread of middling weapon skills. \
	Once chosen, you may select EXPT Polearms, EXPT Swords & JMAN Shields, EXPT Whips & Flails."


/datum/outfit/job/roguetown/adventurer/sfighter/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/warrior()
	H.set_blindness(0)
	if(H.mind)
		var/weapons = list("Flail", "Sword & Board", "Spear")
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("Flail")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_EXPERT, TRUE)
				beltr = /obj/item/rogueweapon/flail
			if("Sword & Board")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_JOURNEYMAN, TRUE)
				backr = /obj/item/rogueweapon/shield/iron
				beltr = /obj/item/rogueweapon/scabbard/sword
				r_hand = /obj/item/rogueweapon/sword/iron
			if("Spear")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				r_hand = /obj/item/rogueweapon/spear
		var/armors = list("Maille","Breastplate","Gambeson")
		var/armor_choice = input(H, "Choose your armor.", "TAKE UP ARMOR") as anything in armors
		switch(armor_choice)
			if("Maille")
				armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
				neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
				pants = /obj/item/clothing/under/roguetown/chainlegs/iron
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			if("Breastplate")
				armor = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
				neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
				pants = /obj/item/clothing/under/roguetown/splintlegs/iron
				gloves = /obj/item/clothing/gloves/roguetown/angle
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			if("Gambeson")
				armor = /obj/item/clothing/suit/roguetown/armor/gambeson
				neck = /obj/item/clothing/neck/roguetown/coif/padded
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
				pants = /obj/item/clothing/under/roguetown/trou/leather
				gloves = /obj/item/clothing/gloves/roguetown/angle
				wrists = /obj/item/clothing/wrists/roguetown/splintarms/iron
	belt = /obj/item/storage/belt/rogue/leather
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
		)

/datum/advclass/sfighter/barbarian
	name = "Barbarian"
	tutorial = "You are a brutal warrior, who has foregone armor in favor of pure strength. Crush your enemies, see them driven before you, and hear the lamentations of their women!"
	outfit = /datum/outfit/job/roguetown/adventurer/barbarian
	cmode_music = 'sound/music/combat_blackstar.ogg'
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(//Spread of five. +4 from STR. -2INT because of CR and NP, which brings it to five.
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 1,
		STATKEY_INT = -2,
	)
	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
	)
	extra_context = "This subclass allows, after spawn, the choice between JMAN axe skills, or EXPT unarmed and CivBarb."

/datum/outfit/job/roguetown/adventurer/barbarian/pre_equip(mob/living/carbon/human/H, visualsOnly)
	..()
	H.set_blindness(0)

	if(H.mind)
		var/weapons = list("Axe", "Unarmed")
		var/weapon_choice = input(H, "Choose your WEAPON.", "TAKE UP ARMS.") as anything in weapons
		switch(weapon_choice)
			if("Axe")
				H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
				head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
				r_hand = /obj/item/rogueweapon/stoneaxe/woodcut/bronze
				gloves = /obj/item/clothing/gloves/roguetown/bandages
			if ("Unarmed")
				H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
				ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
				head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
				gloves = /obj/item/clothing/gloves/roguetown/bandages/weighted

		belt = /obj/item/storage/belt/rogue/leather/battleskirt/barbarian
		pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/bronzeskirt
		shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather

	if(should_wear_masc_clothes(H))
		H.dna.species.soundpack_m = new /datum/voicepack/male/warrior()
		backl = /obj/item/storage/backpack/rogue/satchel
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/bikini
		backl = /obj/item/storage/backpack/rogue/satchel

	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife/bronze = 1,
		)

/datum/advclass/sfighter/stalker
	name = "Stalker"
	tutorial = "You serve a cause as righteous as any other. Poaching. Theft. Perhaps a little of both. Or, perhaps, neither? \
	It doesn't matter. You've your weapon. Some spare lockpicks. The skill to walk the woods of the isle. You'll fit in perfectly."
	outfit = /datum/outfit/job/roguetown/adventurer/stalker
	cmode_music = 'sound/music/combat_poacher.ogg'
	traits_applied = list(TRAIT_OUTDOORSMAN, TRAIT_DODGEEXPERT)
	subclass_stats = list(//Five, until the additional +2 is applied below.
		STATKEY_PER = 3,
		STATKEY_WIL = 1,
		STATKEY_CON = 1,
	)
	subclass_skills = list(//It looks like a lot, because it is.
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/crossbows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/bows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/slings = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/fishing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_APPRENTICE,
	)
	extra_context = "This subclass adds an additional point of SPEED or STRENGTH, depending on weapon selection. \
	Longbow and crossbow provide STRENGTH. Recurve and Sling provide SPEED."

/datum/outfit/job/roguetown/adventurer/stalker/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	belt = /obj/item/storage/belt/rogue/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/hide
	cloak = /obj/item/clothing/cloak/raincloak/green
	backl = /obj/item/storage/backpack/rogue/satchel
	beltr = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/bait = 1,
		/obj/item/rogueweapon/huntingknife/combat = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/lockpickring/mundane = 1,
		)
	if(H.mind)
		var/weapons = list("Recurve Bow", "Longbow", "Crossbow", "Sling")
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		H.set_blindness(0)
		switch(weapon_choice)
			if("Recurve Bow")
				H.adjust_skillrank_up_to(/datum/skill/combat/bows, SKILL_LEVEL_EXPERT, TRUE)
				backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
				beltl = /obj/item/quiver/arrows
				H.change_stat(STATKEY_SPD, 1)
			if("Longbow")
				H.adjust_skillrank_up_to(/datum/skill/combat/bows, SKILL_LEVEL_EXPERT, TRUE)
				backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
				beltl = /obj/item/quiver/arrows
				H.change_stat(STATKEY_STR, 1)
			if("Crossbow")
				H.adjust_skillrank_up_to(/datum/skill/combat/crossbows, SKILL_LEVEL_EXPERT, TRUE)
				backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
				beltl = /obj/item/quiver/bolts
				H.change_stat(STATKEY_STR, 1)
			if("Sling")
				H.adjust_skillrank_up_to(/datum/skill/combat/slings, SKILL_LEVEL_EXPERT, TRUE)
				beltl = /obj/item/quiver/sling/iron
				r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/sling
				H.change_stat(STATKEY_SPD, 1)
