//RP role(s) for establishing external relations. Given funds, material and an 'honour guard'(later).
//Think IAA, except instead of for 'The Company', it's for whatever foreign interest you select.
//We have this to force engagement with the councillors and what have you. - Carl
/datum/job/roguetown/consul
	title = "Consul"
	flag = CONSUL
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_sexes = list(MALE, FEMALE)
	advclass_cat_rolls = list(CTAG_CONSUL = 20)
	tutorial = "You are the consul. A figure of vast power - outside of the Barony - that stands present to manipulate the Baron's court. \
	Make promises. Bribe. Force concessions. Speak on behalf of the power you represent. \
	Whatever you do, get into the court's good graces and establish a foothold by which the land may be claimed, one way or another. <br>\
	For the Baron has secrets. Secrets you've been charged with disturbing."

	outfit = /datum/outfit/job/roguetown/consul

	display_order = JDO_CONSUL
	give_bank_account = 60
	noble_income = 15
	min_pq = 2
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_noble.ogg'
	social_rank = SOCIAL_RANK_MINOR_NOBLE
	vice_restrictions = list(/datum/charflaw/mute)

	job_traits = list(TRAIT_NOBLE, TRAIT_OUTLANDER, TRAIT_ARCYNE_T1)

	leave_admin_shout = TRUE
	roleplay_exclusive_notify = TRUE

	rp_enforce = "You are <FONT color='green'>expected</font> to: <br> \
				- Force your way into the regent's good graces. <br> \
				- Assure your own nation's interests, in whatever form that may be."

	rp_forbid = "You are <FONT color='red'>discouraged</font> from: <br> \
				- Acting counter to your purpose of being present. <br> \
				- Exposing the plans you may have laid, prior to arrival, without reason. <br> \
				- Abandoning the court, and, thus, any work you may have accomplished."

/datum/outfit/job/roguetown/consul
	job_bitflag = BITFLAG_ROYALTY

/datum/outfit/job/roguetown/consul/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_femme_clothes(H))
		neck = /obj/item/roguekey/manor
		belt = /obj/item/storage/belt/rogue/leather/cloth/lady
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gown/wintergown
		beltl = /obj/item/flashlight/flare/torch/lantern
		shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
		backr = /obj/item/storage/backpack/rogue/satchel
		id = /obj/item/clothing/ring/signet
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
	else if(should_wear_masc_clothes(H))
		pants = /obj/item/clothing/under/roguetown/tights
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut
		shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
		belt = /obj/item/storage/belt/rogue/leather
		neck = /obj/item/roguekey/manor
		beltl = /obj/item/flashlight/flare/torch/lantern
		backr = /obj/item/storage/backpack/rogue/satchel
		id = /obj/item/clothing/ring/signet

/datum/advclass/consul/primary
	name = "Consul"
	tutorial = "The Consul. A prim and proper fool who will bring ruin to this horrid archipelago."
	outfit = /datum/outfit/job/roguetown/consul/primary
	category_tags = list(CTAG_CONSUL)
	traits_applied = list(TRAIT_SEEPRICES, TRAIT_NUTCRACKER, TRAIT_GOODLOVER, TRAIT_TOLERANT)
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 2,
		STATKEY_WIL = 1,
		STATKEY_LCK = 1
	)
	subclass_spellpoints = 6
	subclass_skills = list(
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
	)

/datum/outfit/job/roguetown/consul/primary/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)//Multiple of the same origin will be hilarious.
		var/origin = list("Colonial","Empire", "Confederacy", "Conclave", "Outland")//Repurpose merc medals.
		var/origin_choice = input(H, "Choose Thy Master", "THE LEASH TO BE WORN") as anything in origin
		switch(origin_choice)
			if("Colonial")//They'll get sailing when I'm done doing that. The skill, I mean. Teehee.
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/longstrider)//Remove when I give them sailing.
				H.adjust_skillrank_up_to(/datum/skill/misc/swimming, 4, TRUE)
				beltr = /obj/item/clothing/neck/roguetown/luckcharm/consul_badge/colonial
			if("Empire")//Trust that a Zizite Empire FREEK will be funny.
				H.adjust_skillrank_up_to(/datum/skill/magic/holy, 3, TRUE)
				var/datum/devotion/D = new /datum/devotion(H, H.patron)
				D.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_1)
				beltr = /obj/item/clothing/neck/roguetown/luckcharm/consul_badge/empire
			if("Confederacy")//Some combat skills, to show prior service.
				H.adjust_skillrank_up_to(/datum/skill/misc/athletics, 3, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, 2, TRUE)
				beltr = /obj/item/clothing/neck/roguetown/luckcharm/consul_badge/confed
			if("Conclave")//Stealth. For what good it'll do. Hide, you FOOL.
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/nondetection)
				H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, 3, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, 3, TRUE)
				beltr = /obj/item/clothing/neck/roguetown/luckcharm/consul_badge/conclave
			if("Outland")//Ballsy. Stupid. Poor combination. Give them a bone.
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mirror_transform)
				H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, 3, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/misc/medicine, 3, TRUE)
				beltr = /obj/item/clothing/neck/roguetown/luckcharm/consul_badge/outlander

//The stuff for the consul. Because it's not used anywhere else.
//Probably shouldn't be here but whatever. Temp sprites, and reusing the luckcharm like merc medals.
//Teehee.
/obj/item/clothing/neck/roguetown/luckcharm/consul_badge
	name = "consul writ"
	desc = "A writ of passage, generally given out to a newly arrived consul. How've you gotten your hands on this?"
	icon = 'modular_paragon/icons/clothing/misc.dmi'
	icon_state = "consul_writ"
	//dropshrink = 0.75
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HIP|ITEM_SLOT_WRISTS
	sellprice = 300

/obj/item/clothing/neck/roguetown/luckcharm/consul_badge/confed
	name = "Confederate Wyvern"
	desc = "The golden wyvern. A symbol of the Confederacy's many-headed power. <br>\
	Typically obtained through exemplary service with a great house, though other methods of obtainment exist. \
	Whether that other method be favours of a storied house, or simply knowing a figure of import."
	icon_state = "consul_confed"

/obj/item/clothing/neck/roguetown/luckcharm/consul_badge/outlander
	name = "Outlander Locket"
	desc = "A thick locket made of some unknown, buzzing wood. Topped by a gilbranze seal. <br>\
	To carry this is to carry the hopes of your people. That you may yet find a new land, in which to call home. \
	What do you consider so dear, that you'd keep it inside?"
	icon_state = "consul_outlander"

/obj/item/clothing/neck/roguetown/luckcharm/consul_badge/colonial
	name = "Admiralty Sigil"
	desc = "A sigil of the Etruscan Colonial Admirality board, strung through with trimmed cordage from the fleet's flagship. <br>\
	To hold this is to assure that you've the backing of the largest naval force this world has ever known. \
	That you, of all people, know the heights a nation may rise."
	icon_state = "consul_colonial"

/obj/item/clothing/neck/roguetown/luckcharm/consul_badge/conclave
	name = "Conclave Signet"
	desc = "A signet of the Wylderspirit that rests beneath the Freefolk's haven. <br>\
	You, of the many who had ever found safe passage and love in a place so remote, had been granted an audience. \
	Though, now, thinking back on it? Your head hurts. The memory fading just as quickly. What you now hold is all you can recall."
	icon_state = "consul_conclave"

/obj/item/clothing/neck/roguetown/luckcharm/consul_badge/empire
	name = "Empire Pendant"
	desc = "The Empire is known for its pious nature. This pendant is no different in representing such. <br>\
	Bestowed upon one by the Emperor's own court, it serves as a reminder that we're all so small in the face of Creation. \
	Whether you were once a Priest, or simply a member of a political congregation, this serves as evidence of the noose around your neck should you misstep."
	icon_state = "consul_empire"
