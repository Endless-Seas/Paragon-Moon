//We hold the 'brain dance' stuff here.
//Both for 'The Three' and the mystic class.
//What are these? Don't worry about it. - Carl

/datum/sleep_adv/proc/perpetual_vision(mob/living/carbon/CB)
	//First, what does the fortune teller see?
	//They're intended to be vague. Super vague.
	//Visions of the future only.
	var/mystic_visions = pick("<span class='his_grace'><b>They raised a brow. Curious, as to the nature of your being. \
		You waved them away. What good is it to explain, of all times, now? Your master provided you ample already.</b></span>",

		"<span class='danger'><b>Your body was broken. Shattered. Sundered into a thousand pieces. Your lux torn free. \
		The beast snarled, licking its chops before discarding your carcass. It had been displeased, for it could not understand you, even in the end.</b></span>",

		"<span class='his_grace'><b>The Baron arrived. You speak on good terms. Of service. Of life and death. \
		They leave uncharacteristically pleased. This is a common occurrence.</b></span>",

		"<span class='danger'><b>Your legs gave out as a vision struck you. It had been wrong. Twisted. \
		The subject troubled you. You did not sleep, then, knowing what you do, now.</b></span>",

		"<span class='danger'><b>The woman's face went pale. You'd revealed too much. \
		They arrived later, carrying her kicking and screaming into the night. You begged them to reconsider.</b></span>")

	//Now, what about The Three?
	//These are intended to be past lives / deaths / victories.
	//Visions of the past only.
	var/perpetual_visions = pick("<span class='his_grace'><b>You dream of fields. \
		Of an earlier vision of the archipelago, before the vault's rot had consumed the wilds. Of blue waves. Of laughing friends.</span> <br>\
		<span class='danger'>You tense, knowing what's to come. What you became. \
		What you'd abandoned. They can't ever understand. Would they forgive you?</b></span>",

		"<span class='danger'><b>You swung the blade as your muscles failed. \
		Fingers curled tightly around the pommel, even then, as your skin sloughed off. \
		You were so close. Escape. Even as the walls themselves melded with your form.</span> <br>\
		<span class='his_grace'>They returned to find that you had perished, daes later. You were laid to rest in a shallow grave, looking out to sea. \
		A statue, long since gone, had been erected in your name. The lives you saved that day were countless.</b></span>",

		"<span class='his_grace'><b>It begs you in those early years. To give up. To relent. \
		You'd not known it then, though you do now. You should've listened. You were too strong, of both mind and body.</span> <br>\
		<span class='danger'>It dawned on you, as the creature pulled the marrow from your bones. As tears pricked your eyes. \
		As you offered the others, in your place. This would happen again. In an eternity of rule.</b></span>",

		"<span class='his_grace'><b>You'd had a family, in those early years. A love, too. How foolish you'd been. \
		You'd have traded it for nothing. Even now, you would die a thousand times to return to such a life. \
		At the end of it all, after you perished? You attempted to find them in your next life.</span> <br>\
		<span class='danger'>What you found still haunts you. You shan't ever forget.</b></span>",

		"<span class='his_grace'><b>There will come a time when you are free of this cyclical hell. You know this. \
		So sure of it, you are, that you dream of it this night. Sleep comes easy. Perhaps for the first time in yils.</b></span>",

		"<span class='his_grace'><b>You dreamt of shadows for yils. Of figures who begged you to return to them. \
		In time, you came to understand that they were once your people. Those you'd given everything to protect.</span> <br>\
		<span class='danger'>You've become bitter. A venom in your tone as you curse their existence. \
		You will pour all you may yet give into to seeing them erased. This hell reversed. The slate wiped clean.</b></span>",

		"<span class='his_grace'><b>The Archeovault's presence speaks to you. It reminds you of the pact. Of how it saved you. \
		You acquiesce. For it speaks true. It had saved you. Yet, how much of <large>you</large> truly remains? \
		How many times must you go through this song and dance?</span> <br>\
		<span class='danger'>It laughs, for it believes you naive. An insect, amongst gods. \
		You're slated to suffer a thousand more lifetimes for its amusement. \
		Your world the stage in which it will enact the wretched plan it imprints upon your mind.</b></span>")

	var/mob/living/carbon/human/H = CB

	//Visions. For The Three and Mystic. They are ALWAYS seeing these.
	if(HAS_TRAIT(H, TRAIT_PERPETUAL))
		to_chat(H, "<small>You dream of your past. It leaves you restless.</small> <br>\
		[pick(perpetual_visions)] <br>\
		<small>You're left with a headache, your heart thumping painfully.</small>")
		H.emote("groan", forced = TRUE)

	if(HAS_TRAIT(H, TRAIT_MYSTIC))
		to_chat(H, "<small>You unwillingly dream of an uncertain future. The consequences will be vile, paid tenfold.</small> <br>\
		[pick(mystic_visions)] <br>\
		<small>You're left with a headache, your heart thumping painfully.</small>")
		H.emote("groan", forced = TRUE)
