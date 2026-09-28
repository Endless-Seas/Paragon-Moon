//The Mystic's 'brain dance' ability.
//Will later reveal details about in round antags.
//For now, only provides fluff stuff for RP. Which is fine.
//Do not turn this into any form of combat utility, I BEG YOU. - Carl
//TODO: Drain the Mystic for doing this. Give hints to round antag to target.
//Provide EXTREME consequences for further use, beyond one reading in a round.
/obj/effect/proc_holder/spell/invoked/braindance
	name = "Braindance"
	desc = "Reach out, brushing against another fool's lux. You shall share your burden, temporarily."
	overlay_icon = 'icons/mob/actions/zizomiracles.dmi'
	action_icon = 'icons/mob/actions/zizomiracles.dmi'
	overlay_state = "lacrima"
	xp_gain = TRUE
	releasedrain = 60
	chargedrain = 1
	chargetime = 15
	recharge_time = 4 MINUTES
	human_req = TRUE
	warnie = "spellwarning"
	school = "transmutation"
	no_early_release = TRUE
	movement_interrupt = FALSE
	spell_tier = 1
	invocations = list("Onus communicandum est intemperans...")
	invocation_type = "whisper"
	glow_color = GLOW_COLOR_BUFF
	glow_intensity = GLOW_INTENSITY_LOW
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/blood

/obj/effect/proc_holder/spell/invoked/braindance/cast(list/targets, mob/user)
	var/atom/A = targets[1]
	if(!isliving(A))
		revert_cast()
		return

	//This is dirty and can be done better but it WORKS. Whatever.
	var/providence_check = pick("<span class='his_grace'><b>You see yourself standing atop a pillar. \
		Below, the isle. A voice calls up to you, heavenly in nature. Yet you can make out no words this high above it all.</b></span>",
		"<span class='his_grace'><b>A figure brushes a hand against your flesh. It speaks to you of certainty. Of security. \
		It simply asks you to understand. To find it and fulfil your purpose.</span> <br>\
		<span class='danger'>It laments, knowing you will fail.</b></span>",
		"<span class='his_grace'><b>There are voices shouting in the distance. They warn you of your companion.</span> <br>\
		<span class='danger'>You feel yourself promptly torn asunder, split in twain by an unfathomable horror's hands alone.</b></span>",
		"<span class='his_grace'><b>You find yourself needing to suck in a breath. Your eyes forced to gaze beyond the veil.</span> <br>\
		<span class='danger'>You see a figure. A sack over their shoulder. Nae, a body. You recognise it, yet you do not know how. \
		Or who, for that matter.</b></span>",
		"<span class='danger'><b>The lifeblood in your veins burns. It hurts. \
		Just as it becomes unbearable, ome unseen force protects you from yourself.</b></span>",
		"<span class='danger'><b>You die. You do not know how. You do not know when. \
		What you see, however, is truly horrific. For you no longer have a face. \
		You've been bisected, with your lower half nowhere to be seen. <br>\
		It feasts, in the corner. You cannot make out what it is. Yet you know it consumes what remains of you.</b></span>",
		"<span class='danger'><b>You are taken by the rot. Your mind a numb, useless harbour for what remains of your lifespark. \
		Your companions beg you to regain your senses. You retort by brandishing fang and claw, tearing throat and adoration alike from their form. <br>\
		You shall remain in this endless hell, for it is all you deserve.</b></span>",
		"<span class='danger'><b>You scream. Your voice is readily carried out along the murk, yet the fog prevents any rescue. \
		Your legs, sunken into the mire, seals your fate. You watch as your end approaches. Slowly. Surely. \
		It asks you to beg. You oblige.</b></span>",
		"<span class='danger'><b>You watch in horror as an abyss of swirling entropy opens up above you. \
		It is a horrific thing, to be skinned alive by a force that no mortal can understand. Worse still? \
		You try to scream, yet your lungs are pulled clear from your chest. \
		You suffer a fate worse than death, as the void consumes what remains of your mind.</b></span>",
		"<span class='danger'><b>You kick, scratch and bite. No matter how much you fight or beg, they force the cordage around your throat. \
		The chair is kicked out from under you. It is a slow, painful death. A show, for the masses. <br>\
		They burn your body. You feel every moment of it, for no one truly dies in damned place.</b></span>")

	var/mob/living/L = targets
	to_chat(L, "<small>Your mind is temporarily in freefall...</small> <br>\
	[providence_check] <br>\
	<small>Just as quickly, your mind is once again your own.</small>")
