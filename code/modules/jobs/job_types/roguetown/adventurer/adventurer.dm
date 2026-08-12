GLOBAL_LIST_EMPTY(billagerspawns)

GLOBAL_VAR_INIT(adventurer_hugbox_duration, 40 SECONDS)
GLOBAL_VAR_INIT(adventurer_hugbox_duration_still, 3 MINUTES)

/datum/job/roguetown/adventurer
	title = "Adventurer"
	flag = ADVENTURER
	department_flag = WANDERERS
	faction = "Station"
	total_positions = 20
	spawn_positions = 20
	allowed_races = RACES_ALL_KINDS
	tutorial = "You are no hero. Unlikely to be a figure of note or worth. \
	For why else would you come to this horrid place? No, truly, you'd likely few options. \
	Any of which were likely lost long before coming to this isle. <br>\
	Set out and find your worth, now, fool. Whether it be alone or with the trusted few you may call friends."
	class_categories = TRUE

	outfit = null
	outfit_female = null

	display_order = JDO_ADVENTURER
	show_in_credits = FALSE
	min_pq = 0
	max_pq = null

	advclass_cat_rolls = list(CTAG_ADVENTURER = 20)
	PQ_boost_divider = 10

	announce_latejoin = FALSE
	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = TRUE
	job_reopens_slots_on_death = TRUE
	same_job_respawn_delay = 1 MINUTES

	cmode_music = 'sound/music/combat_routier.ogg'
	job_traits = list(TRAIT_OUTLANDER)

	job_subclasses = list(
		/datum/advclass/cleric,
		/datum/advclass/cleric/paladin,
		/datum/advclass/cleric/missionary,
		/datum/advclass/sfighter,
		/datum/advclass/sfighter/barbarian,
		/datum/advclass/sfighter/stalker,
		/datum/advclass/mage,
		/datum/advclass/mage/conjurer,
	)

	fear_of_change = TRUE//Couldn't possibly imagine why...

	rp_enforce = "You are <FONT color='green'>expected</font> to: <br> \
				- Explore. Adapt. Abuse the resources given to you, away from the isle."

	rp_forbid = "You are <FONT color='red'>discouraged</font> from: <br> \
				- Settling down."

/mob/living/carbon/human/proc/adv_hugboxing_start()
	to_chat(src, span_warning("I will be in danger once I start moving."))
	status_flags |= GODMODE
	ADD_TRAIT(src, TRAIT_PACIFISM, HUGBOX_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(adv_hugboxing_moved))
	//Lies, it goes away even if you don't move after enough time
	if(GLOB.adventurer_hugbox_duration_still)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_end)), GLOB.adventurer_hugbox_duration_still)

/mob/living/carbon/human/proc/adv_hugboxing_moved()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	to_chat(src, span_danger("I have [DisplayTimeText(GLOB.adventurer_hugbox_duration)] to begone!"))
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_end)), GLOB.adventurer_hugbox_duration)

/mob/living/carbon/human/proc/adv_hugboxing_end()
	if(QDELETED(src))
		return
	//hugbox already ended
	if(!(status_flags & GODMODE))
		return
	status_flags &= ~GODMODE
	REMOVE_TRAIT(src, TRAIT_PACIFISM, HUGBOX_TRAIT)
	to_chat(src, span_danger("My joy is gone! Danger surrounds me."))
