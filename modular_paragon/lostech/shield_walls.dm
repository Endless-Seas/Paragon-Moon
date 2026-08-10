//Shieldwalls ripped from another project of mine. Gutted of like 99% functionality.
//We reuse(d) the sprite I'd had there for these. Much love to my awesome spriters over the years.
//Seriously. Y'all rock. - Carl

/datum/looping_sound/shieldwall
	//This file is ENORMOUS. FIX THIS. GOOD GOD. WHY. OH MY LORD. MY WEARY HEART
	//Calm down, Carl. It was only 6MB FUCK WHY
	//Ok it's fixed now. We're cool. - Carl
	mid_sounds = list('modular_paragon/lostech/sound/shields/shieldloop.ogg')
	mid_length = 15 SECONDS
	volume = 15

//We don't include the checks for 'do you have access' or 'is this off' as we did on the other project.
//You either have access, or you do not. Simple as.
/obj/structure/shieldwall
	name = "Parent of Parent Shields - DO NOT USE"
	desc = "An incredibly dangerous wall of light."
	icon = 'modular_paragon/lostech/icons/fields.dmi'
	icon_state = "ERROR"// DON'T USE THIS | God I love this icon...
	density = 1
	anchored = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/req_trait_access = list(TRAIT_PERPETUAL)//What trait do we want them to have?
	var/datum/looping_sound/shieldwall/soundloop

/obj/structure/shieldwall/Initialize(mapload)
	. = ..()
	soundloop = new(src, TRUE)
	soundloop.volume = 100
	soundloop.start()


/obj/structure/shieldwall/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The light shimmers with an unknown intelligence.</span>"

/obj/structure/shieldwall/CanPass(atom/movable/AM, turf/target)
	if(!isliving(AM))
		. = TRUE

	var/mob/living/carbon/human/M = AM
	if(HAS_TRAIT(M, TRAIT_PERPETUAL))
		playsound(src, "modular_paragon/lostech/sound/shields/shield_pass_[rand(1,2)].ogg" ,50,0,3)
		. = TRUE
	else

		var/the_end_text = pick("<span class='his_grace'><b>The strands of lifeblood in your veins catch alight. \
		You shriek like a hurt living thing. All sense and reason has abandoned you. The dream has perished.</b></span>",
		"<span class='his_grace'><b>The blade comes out through your front, driven clear through ribs and shattering your form. \
		The abominable figure above you simply chuckles, like a cruel gaoler. Your mind, for what remains in these final moments, enters freefall.</b></span>",
		"<span class='his_grace'><b>It had been in an instant. The trap sprung. Your legs giving out. \
		The agonised wail you attempt to force out is pitiful, for your lungs no longer exist. In as little as a moment, you cease to flail.</b></span>",
		"<span class='his_grace'><b>The flesh peels clear from your bone. The figures in the distance await the coming apotheosis. \
		They are incapable of understanding that you are simply too fragile. Your form quickly evaporating into the aether as you plead for mercy.</b></span>",
		"<span class='his_grace'><b>An agonised wail pierces the already frigid air. You turn around, immediately regretting your choice. \
		A spear of manifested entropy hurls towards you. You do not manage so much as a whimper, for it excoriates bone and mind alike.</b></span>")


		playsound(src,'modular_paragon/lostech/sound/access_alarm.ogg',50,0,3)
		to_chat(M, "[the_end_text]<br>\
		<i><span class='bloody'>Wait, what? What just happened? Where are you?</i></span>")

		M.visible_message("<span class='danger'>[M] collapses in an instant, body seizing violently!</span>", "", "", COMBAT_MESSAGE_RANGE)
		M.emote("agony", forced = TRUE)
		M.Unconscious(100)
		M.Jitter(15)
		loud_message("[src] ejects a pained wail", hearing_distance = 24)//Twice as loud as the alarms. What are you doing? Seriously?

		. = FALSE

/*
Below are all the shields. The above is the parent.
Keep that in mind when making edits. I beg you.
*/
/obj/structure/shieldwall/standard
	name = "arclight field"
	desc = "A field of light. You swear you can see eyes darting along the surface. Staring. Waiting. <br>\
	<small>Begging you to save them...</small>"
	icon_state = "field_main"
	light_outer_range = 2
	light_power = 1
	light_color = "#6ED8D8"
