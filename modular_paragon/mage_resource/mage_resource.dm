/mob/living/carbon/human
	var/spark = SPARK_LEVEL_FULL

//We really shouldn't hook this into Life(), but we do.
/datum/species/proc/spec_spark(mob/living/carbon/human/H)
	//Yeah, I KNOW.
	switch(H.spark)
		if(SPARK_LEVEL_HALF_UP to SPARK_LEVEL_FULL)
			H.remove_status_effect(/datum/status_effect/debuff/spark_death)
			H.remove_status_effect(/datum/status_effect/debuff/spark_low)
		if(SPARK_LEVEL_DRAINED to SPARK_LEVEL_HALF)
			H.apply_status_effect(/datum/status_effect/debuff/spark_low)
			H.remove_status_effect(/datum/status_effect/debuff/spark_death)
		if(0 to SPARK_LEVEL_FADED)
			H.apply_status_effect(/datum/status_effect/debuff/spark_death)
			H.remove_status_effect(/datum/status_effect/debuff/spark_low)

/mob/living/carbon/human/proc/adjust_spark(change)
	if(spark <= SPARK_LEVEL_FADED && !HAS_TRAIT(src, TRAIT_ARCYNE_T4))
		return//If you've gone dark, you can't get it back. Sorry. Exception to T4 mages.
	spark = max(0, spark + change)
	if(spark > SPARK_LEVEL_FULL)
		spark = SPARK_LEVEL_FULL

/mob/living/carbon/human/proc/lessen_spark(change)
	if(spark <= SPARK_LEVEL_FADED)
		src.add_nausea(12)
		src.blood_volume = max(src.blood_volume-35, 0)
		src.handle_blood()
		new /obj/effect/decal/cleanable/blood/puddle(src.loc)
	//(21 - WIL * Spell Tier). Unless you adjust base drain. Out of a total of the SPARK_LEVEL_FULL value (750 at time of creation).
	spark = max(0, spark - change - src.STAWIL)

/obj/effect/proc_holder/spell
	var/spark_immune = FALSE//Will it drain a mage's soul when casting?

//Actual cost after cast. Hooked into 'after_cast'.
/obj/effect/proc_holder/spell/proc/spark_check(mob/living/carbon/human/H)
	if(!spark_immune && !miracle)//We don't care about miracles.
		H.lessen_spark(21 * (src.spell_tier))

//Debuffs.
/datum/status_effect/debuff/spark_low
	id = "spark_low"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/spark_low
	effectedstats = list(STATKEY_WIL = -1)
	duration = -1
	needs_processing = FALSE

//We do this, as a sort of 'STOP CASTING' and to alert mages they really should recover.
//To force engagement with the mechanic, and to stop 'WHY AM I DYING'.
/datum/status_effect/debuff/spark_low/on_apply()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		loud_warning_ohmylord(C)
	return ..()

/atom/movable/screen/alert/status_effect/debuff/spark_low
	name = "Drained"
	desc = "I've strained my capability to cast!  <br>\
	<font color=red>Any more might place myself in danger.</font> <br>\
	<font color=green>I should recover, whether by potion or arcyne recovery.</font>"
	icon = 'modular_paragon/mage_resource/icons/mob/mage_resource.dmi'
	icon_state = "spark_low"

#define FILTER_SPARKLOSS "spark_low_glow"

/mob/proc/mageloss_curse()
	sleep(2)
	overlay_fullscreen("ANATHEMA", /atom/movable/screen/fullscreen/curse)
	sleep(2)
	clear_fullscreen("ANATHEMA")

//This is just to make it VERY CLEAR that continuing to cast is a VERY DUMB idea.
//Rest and gather your strength, m'lord. Stop spamming arcane bolt.
/datum/status_effect/debuff/spark_low/proc/loud_warning_ohmylord(mob/living/carbon/H)
	ADD_TRAIT(H, TRAIT_SPELLCOCKBLOCK, MAGIC_TRAIT)
	H.add_filter(FILTER_SPARKLOSS, 2, list("type" = "outline", "color" = "#FFFFFF", "alpha" = 30, "size" = 1))
	to_chat(H, span_warning("I've pushed myself beyond safe arcyne limits! I should rest and recover!"))
	H.visible_message("[H]'s frame shimmers...")
	addtimer(CALLBACK(src, PROC_REF(loud_warning_finished), H), wait = 10 SECONDS)//Half a counterspell duration.
	H.blur_eyes(5)
	H.mageloss_curse()
	return TRUE

/datum/status_effect/debuff/spark_low/proc/loud_warning_finished(mob/living/carbon/H)
	REMOVE_TRAIT(H, TRAIT_SPELLCOCKBLOCK, MAGIC_TRAIT)
	H.remove_filter(FILTER_SPARKLOSS)
	H.visible_message("[H]'s frame shimmers...")
	H.mageloss_curse()

#undef FILTER_SPARKLOSS

/datum/status_effect/debuff/spark_death
	id = "spark_gone"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/spark_death
	effectedstats = list(STATKEY_WIL = -2)
	duration = -1
	needs_processing = FALSE

/atom/movable/screen/alert/status_effect/debuff/spark_death
	name = "Faded"
	desc = "I've pushed myself too far. My powers have abandoned me. <br>\
	<font color=grey>No recovery can return what I've lost. It's over. <br>\
	Any further casting will be to my own detriment, for only a skilled Magos can escape this state.</font>"
	icon = 'modular_paragon/mage_resource/icons/mob/mage_resource.dmi'
	icon_state = "spark_death"

