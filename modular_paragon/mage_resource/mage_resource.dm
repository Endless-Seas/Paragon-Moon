/mob/living/carbon/human
	var/spark = SPARK_LEVEL_FULL
//get_user_spell_tier
/datum/species/spec_life(mob/living/carbon/human/H)
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
		src.add_nausea(100)
		src.blood_volume = max(src.blood_volume-35, 0)
		src.handle_blood()
		new /obj/effect/decal/cleanable/blood/puddle(src.loc)
	spark = max(0, spark - change - src.STAWIL)

/obj/effect/proc_holder/spell
	var/spark_immune = FALSE//Will it drain a mage's soul when casting?

//Actual cost after cast.
/*
/obj/effect/proc_holder/spell/cast(mob/living/carbon/human/H)
	if(!spark_immune)
		H.lessen_spark(21 * (src.spell_tier))
	. = ..()
*/

//Debuffs.
/datum/status_effect/debuff/spark_low
	id = "spark_low"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/spark_low
	effectedstats = list(STATKEY_WIL = -1)
	duration = -1
	needs_processing = FALSE

/atom/movable/screen/alert/status_effect/debuff/spark_low
	name = "Drained"
	desc = "I've strained my capability to cast! <br>\
	<font color=red>Any more, and I may find myself in danger.</font>"
	icon = 'modular_paragon/mage_resource/icons/mob/mage_resource.dmi'
	icon_state = "spark_low"

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
	Any further casting will be to my own detriment.</font>"
	icon = 'modular_paragon/mage_resource/icons/mob/mage_resource.dmi'
	icon_state = "spark_death"
