/datum/reagent/medicine/stimpen_health
	name = "Stimpen Fluid"
	description = "An incredibly odd fluid."
	color = "#463c3c"
	taste_description = "catharsis"
	metabolization_rate = 5

/datum/reagent/medicine/stimpen_health/on_mob_life(mob/living/carbon/M)
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = min(M.blood_volume+80, BLOOD_VOLUME_NORMAL)
	var/list/wCount = M.get_wounds()
	if(wCount.len > 0)
		M.heal_wounds(30)
	if(volume > 0.99)
		M.adjustBruteLoss(-24*REM, 0)
		M.adjustFireLoss(-24*REM, 0)
		M.adjustOxyLoss(-32, 0)
		M.adjustToxLoss(-32, 0)
		M.adjustCloneLoss(-60*REM, 0)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -24*REM)
		M.adjustOrganLoss(ORGAN_SLOT_EYES, -24*REM)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R.harmful)
			holder.remove_reagent(R.type, 1)
	..()
	. = 1
