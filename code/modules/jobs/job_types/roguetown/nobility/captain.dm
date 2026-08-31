//You might look at the below and go:
//"Carl, this isn't a Captain! Good lord, what is this?!!!!
//Simple. It's /our/ Captain. The Baron's hound.
//We want him capable of taking on groups, without any issue whatsoever.
//He'll be getting a lot more when his stuff is done.
/datum/job/roguetown/captain
	title = "Knight Captain" //The Knight Captain is clearly not drawn from the ranks of guardsmen, or sergeants. They're drawn from the Knightly ranks and should be treated as such.
	flag = GUARD_CAPTAIN
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_TOLERATED_UP
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	tutorial = "Your lineage is noble, and generations of strong, loyal knights have come before you. You served your time \
	gracefully as knight of his royal majesty, and now you've grown into a role which many men can only dream of becoming. \
	Veteran among knights, you lead the crown's knights to battle and organize the training squires. Obey the Marshal and the Crown. \
	Lead your men to victory--and keep them in line--and you will see this realm prosper under a thousand suns."
	display_order = JDO_GUARD_CAPTAIN
	advclass_cat_rolls = list(CTAG_CAPTAIN = 20)

	spells = list(/obj/effect/proc_holder/spell/self/convertrole/guard)
	outfit = /datum/outfit/job/roguetown/captain

	give_bank_account = 26
	noble_income = 16
	min_pq = 9
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_noble.ogg'
	social_rank = SOCIAL_RANK_NOBLE
	job_traits = list(TRAIT_HEAVYARMOR, TRAIT_STEELHEARTED, TRAIT_NOBLE, TRAIT_GUARDSMAN, TRAIT_BREADY)
	job_subclasses = list(
		/datum/advclass/captain/infantry
	)

	virtue_restrictions = list(
		/datum/virtue/utility/riding,
	)

	supervisors = "Regent | Hand <br>\
					Marshal"
	leave_admin_shout = TRUE

	rp_enforce = "You are <FONT color='green'>expected</font> to: <br> \
				- Uphold the laws, as instructed and set by the regent. <br> \
				- Act as the regent's hound and proverbial sheriff. <br> \
				- Train and discipline your Knights, or maintain vigil in court. <br> \
				- Maintain the regent's honour, as with your own."

	rp_forbid = "You are <FONT color='red'>discouraged</font> from: <br> \
				- Disparaging the regent, or others, of high station. <br> \
				- Through action or inaction, imperiling the court. <br> \
				- Abandoning your post. <br> \
				- Working alone, for you are a pillar of the garrison."

/datum/outfit/job/roguetown/captain
	head = /obj/item/clothing/head/roguetown/helmet/heavy/captain
	neck = /obj/item/clothing/neck/roguetown/bevor
	cloak = /obj/item/clothing/cloak/captain
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/captain
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/chainlegs/captain
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	id = /obj/item/scomstone/garrison
	job_bitflag = BITFLAG_ROYALTY | BITFLAG_GARRISON

/datum/job/roguetown/captain/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/tabard/knight/guard)  || (istype(H.cloak, /obj/item/clothing/cloak/captain)))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "Captain Tabard ([index])" //This doesn't even actually work but you know.
		var/prev_real_name = H.real_name
		var/prev_name = H.name
		var/honorary = "Ser"
		if(should_wear_femme_clothes(H))
			honorary = "Dame"
		H.real_name = "[honorary] [prev_real_name]"
		H.name = "[honorary] [prev_name]"

		for(var/X in peopleknowme)
			for(var/datum/mind/MF in get_minds(X))
				if(MF.known_people)
					MF.known_people -= prev_real_name
					H.mind.person_knows_me(MF)

/datum/advclass/captain/infantry
	name = "Knight Captain"
	tutorial = "You've fought shoulder to shoulder with the realm's worthiest Knights while embedded directly within \
	massed infantry formations. As a peerless armed combatant and tactician both, you are a formidable presence \
	on any battlefield."
	outfit = /datum/outfit/job/roguetown/captain/infantry
	category_tags = list(CTAG_CAPTAIN)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = 2,
		STATKEY_PER = 1,
		STATKEY_LCK = 1
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/shields = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/crossbows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/bows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
	)

	extra_context = "This class gains Master skill in their weapon of choice."

/datum/outfit/job/roguetown/captain/infantry/pre_equip(mob/living/carbon/human/H)
	..()
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(
		/obj/item/storage/keyring/kcaptain = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/movemovemove)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/takeaim)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/onfeet)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/hold)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/focustarget)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= list(
		/mob/living/carbon/human/proc/request_outlaw,
		/mob/proc/haltyell,
		/mob/living/carbon/human/mind/proc/setorders,
	)
	H.adjust_blindness(-3)
	if(H.mind)
		var/weapons = list(
			"Sabre",
			"Glaive",
			)
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		H.set_blindness(0)
		switch(weapon_choice)
			if("Sabre")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, 5, TRUE)
				r_hand = /obj/item/rogueweapon/sword/capsabre
				l_hand = /obj/item/rogueweapon/shield/capbuckler
				beltr = /obj/item/rogueweapon/scabbard/sword
			if("Glaive")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, 5, TRUE)
				r_hand = /obj/item/rogueweapon/halberd/capglaive
				backl = /obj/item/rogueweapon/scabbard/gwstrap
	if(H.mind && !H.mind.has_spell(/obj/effect/proc_holder/spell/self/choose_riding_virtue_mount))
		H.AddSpell(new /obj/effect/proc_holder/spell/self/choose_riding_virtue_mount)
	H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/captorial_lament)

/obj/effect/proc_holder/spell/self/convertrole
	name = "Recruit Beggar"
	desc = "Recruit someone to your cause."
	overlay_state = "recruit_bog"
	antimagic_allowed = TRUE
	recharge_time = 100
	/// Role given if recruitment is accepted
	var/new_role = "Beggar"
	/// Faction shown to the user in the recruitment prompt
	var/recruitment_faction = "Beggars"
	/// Message the recruiter gives
	var/recruitment_message = "Serve the beggars, %RECRUIT!"
	/// Range to search for potential recruits
	var/recruitment_range = 3
	/// Say message when the recruit accepts
	var/accept_message = "I will serve!"
	/// Say message when the recruit refuses
	var/refuse_message = "I refuse."

/obj/effect/proc_holder/spell/self/convertrole/cast(list/targets,mob/user = usr)
	. = ..()
	var/list/recruitment = list()
	for(var/mob/living/carbon/human/recruit in (get_hearers_in_view(recruitment_range, user) - user))
		//not allowed
		if(!can_convert(recruit))
			continue
		recruitment[recruit.name] = recruit
	if(!length(recruitment))
		to_chat(user, span_warning("There are no potential recruits in range."))
		return
	var/inputty = input(user, "Select a potential recruit!", "[name]") as anything in recruitment
	if(inputty)
		var/mob/living/carbon/human/recruit = recruitment[inputty]
		if(!QDELETED(recruit) && (recruit in get_hearers_in_view(recruitment_range, user)))
			INVOKE_ASYNC(src, PROC_REF(convert), recruit, user)
		else
			to_chat(user, span_warning("Recruitment failed!"))
	else
		to_chat(user, span_warning("Recruitment cancelled."))

/obj/effect/proc_holder/spell/self/convertrole/proc/can_convert(mob/living/carbon/human/recruit)
	//wtf
	if(QDELETED(recruit))
		return FALSE
	//need a mind
	if(!recruit.mind)
		return FALSE
	//only migrants and peasants
	if(!(recruit.job in GLOB.peasant_positions) && \
		!(recruit.job in GLOB.yeoman_positions) && \
		!(recruit.job in GLOB.wanderer_positions))
		return FALSE
	//need to see their damn face
	if(!recruit.get_face_name(null))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/self/convertrole/proc/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
	if(QDELETED(recruit) || QDELETED(recruiter))
		return FALSE
	recruiter.say(replacetext(recruitment_message, "%RECRUIT", "[recruit]"), forced = "[name]")
	var/prompt = alert(recruit, "Do you wish to become a [new_role]?", "[recruitment_faction] Recruitment", "Yes", "No")
	if(QDELETED(recruit) || QDELETED(recruiter) || !(recruiter in get_hearers_in_view(recruitment_range, recruit)))
		return FALSE
	if(prompt != "Yes")
		if(refuse_message)
			recruit.say(refuse_message, forced = "[name]")
		return FALSE
	if(accept_message)
		recruit.say(accept_message, forced = "[name]")
	if(new_role)
		recruit.job = new_role
		SEND_SIGNAL(SSdcs, COMSIG_GLOB_ROLE_CONVERTED, recruiter, recruit, new_role)
	return TRUE

/obj/effect/proc_holder/spell/self/convertrole/guard
	name = "Recruit Guardsmen"
	new_role = "Watchman"
	overlay_state = "recruit_guard"
	recruitment_faction = "Watchman"
	recruitment_message = "Serve the town guard, %RECRUIT!"
	accept_message = "FOR THE CROWN!"
	refuse_message = "I refuse."

/obj/effect/proc_holder/spell/self/convertrole/guard/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
	. = ..()
	if(!.)
		return
	recruit.verbs |= /mob/proc/haltyell

//Funny limb tearing.
/obj/effect/proc_holder/spell/invoked/captorial_lament
	name = "Captain's Rend"
	desc = "Grasp a fool that you intend to lay low, fracturing the targeted location. \
	If 'cast' on a location that already has a fracture, either removes the limb, or in the case of head/chest, applies an arterial."
	overlay_state = "bcry"
	recharge_time = 6 SECONDS
	human_req = TRUE
	warnie = null
	no_early_release = FALSE
	movement_interrupt = FALSE
	charging_slowdown = 1
	associated_skill = /datum/skill/combat/unarmed
	invocation_type = "none"
	range = 1
	ignore_los = FALSE
	ignore_cockblock = TRUE//Not a SPELL
	invocations = list(",..")
	invocation_type = "shout"

//Carl, you MORON. Fix this. Good lord.
/obj/effect/proc_holder/spell/invoked/captorial_lament/cast(list/targets, mob/living/user)
	if(isliving(targets[1]))

		var/mob/living/carbon/M = targets[1]
		var/def_zone = user.zone_selected
		var/obj/item/bodypart/BP = null
		BP = M.get_bodypart(check_zone(def_zone))
		if(!BP)
			BP = M.get_bodypart(BODY_ZONE_CHEST)

		user.visible_message(span_danger("[user] flickers before your eyes, as if beset by an unsen force, only to focus on [M]!"))
		to_chat(M, span_notice("[user] mutters incoherently!"))
		if(do_after(user, 5 SECONDS))//Do after has the same issue as something like potions.
			user.visible_message(span_danger("[user] grabs [M] by their [BP]!"))
			to_chat(M, span_notice("[user] growls under their breath, taking a firm hold of [BP]!"))
			M.emote("scream", forced = TRUE)

			if(do_after(user, 5 SECONDS))//As above. If it needs the prox check, just... add it. I guess. Why not now? Because I'm tired.
				if(!BP.has_wound(/datum/wound/fracture))//So do the two seconds of intelligent work yourself, given I'm dumb.
					user.visible_message(span_danger("[user] rends [M], shattering [BP]!"))
					to_chat(M, span_notice("[user] howls in an uncertain tongue, sinking digits into [BP]!"))
					BP.add_wound(/datum/wound/fracture)
					user.emote("warcry")

				else
					if(BP == M.get_bodypart(BODY_ZONE_CHEST))
						user.visible_message(span_danger("[user] punches a fist into [M], tearing a hole through their chest!!!!"))
						to_chat(M, span_notice("[user] jitters, punching a hole through your chest! Gods above!"))
						BP.add_wound(/datum/wound/artery/chest)
					if(BP == M.get_bodypart(BODY_ZONE_HEAD))
						user.visible_message(span_danger("[user] grabs a hold of [M], tearing out their throat!"))
						to_chat(M, span_notice("[user] jitters, before promptly tearing your throat open! Gods above!"))
						BP.add_wound(/datum/wound/artery/neck)
					else
						user.visible_message(span_danger("[user] tears into [M], wrenching their [BP] messily from the poor fool's frame!"))
						to_chat(M, span_notice("[user] jitters, before promptly tearing [BP] clear! Gods above!"))
						BP.drop_limb()

				BP.update_disabled()
				M.emote("agony", forced = TRUE)
				M.adjustBruteLoss(50)

	else
		to_chat(user, span_notice("This isn't something I'd want to tear apart..."))
		return
