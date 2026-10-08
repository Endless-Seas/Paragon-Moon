/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/template/dunworld
	map_file_name = "dun_world.dmm"
	realm_name = "Northwich"
	slot_adjust = list(
		//Keep start.
		/datum/job/roguetown/prince = 1,//We only want one, here.
		/datum/job/roguetown/manorguard = 3,
		/datum/job/roguetown/wapprentice = 2,
		/datum/job/roguetown/squire = 2,//The CAPTAIN requires NO HELP. GOOD GOD. NO.
		/datum/job/roguetown/servant = 3,
		//Inquis start.
		/datum/job/roguetown/orthodoxist = 2,
		//Church start.
		/datum/job/roguetown/templar = 2,
		/datum/job/roguetown/monk = 2,
		/datum/job/roguetown/druid = 2,
		/datum/job/roguetown/keeper = 1,//I HATE YOU
		//Yeoman start.
		/datum/job/roguetown/guildsman = 2,//Because the funny Artificers will be coming to town.
	)
	title_adjust = list(
		//Court
		/datum/job/roguetown/lord = list(display_title = "Baron", f_title = "Baroness"),
		/datum/job/roguetown/prince = list(display_title = "Heir", f_title = "Heiress"),
		/datum/job/roguetown/veteran = list(display_title = "Honorant"),
		//Garrison
		/datum/job/roguetown/squire = list(display_title = "Aspirant"),
		//Church
		/datum/job/roguetown/martyr = list(display_title = "Sanguifier"),
	)
	tutorial_adjust = list(
	//Keep aligned, first. The main three.
	/datum/job/roguetown/lord = "You are the 'forever' Baron. A figure of incredible sway within the region, laying claim to an entire archipelago. \
	After the Confederacy's attempt at securing their own power, only to find themselves swayed by your Archeovault's toys, \
	or the Inquisitorial arm of the Empire having attempted to leap at your throat when they learned the truth, centuries ago? \
	An uneasy peace has been brokered. You are no heretic, at least in their eyes. You've simply stumbled upon something horrific, \
	with you now duty bound to assure it remains guarded. The fools.",
	/datum/job/roguetown/hand = "You are the Hand. The lord's Maven. Their second, in function, of nearly the same stature and station. \
	A figure ennobled by the discovery you and your two companions had made, centuries ago. <br>\
	It had been you who tarried, just as it'll be you to die, should the Baron's trust be a fool's endeavour. \
	Except, of course, that you can't die. Like the other two. An unfortunate reality.",
	/datum/job/roguetown/veteran = "Fools may see a simple 'veteran', or perhaps an old codger. \
	Though, not far from the truth, you've done more than most can lay claim to in your life. \
	You were there. Present during the Baron's ascension to power, with the tools gained. \
	Still, of course, present now, centuries later. Incapable of hanging up your blade. <br>\
	You're, quite possibly, the most decorated figure on the isle. Something none can lay claim to, or challenge. \
	Though, these days, both Baron and Hand seem content to pretend you're a simple menial in their employ.",
	//Garison. Still keep aligned.
	/datum/job/roguetown/captain = "You were the first among those uplifted, in the current cycle, by the eternal Baron. \
	To have been given armour and weapon that appeared divine in origin, though you know better now. <br>\
	You'd asked, pleaded and questioned some more, with the only response you had received being an expectation of service. \
	There was no point arguing, of course. For you were - nae, are - the Baron's strongest warrior. The first to be called, in the event of an issue. \
	Your martial prowess, and the very weapons you wield, are quite simply not of this world.",
	/datum/job/roguetown/knight = "One of two, the next to be uplifted by the Archeovault's trinkets. \
	That is, beyond the Captain, who'd been seen to by the Baron's mad muse. <br>\
	You've been charged with standing sentry over the Baron's estate. To act as an attack dog, in place of the Captain's absent reach, \
	with the astronomical power that you've been granted. There are few who may call themselves equals of you now. Fewer still, who'd dare.",
	/datum/job/roguetown/squire = "Not a squire in the traditional sense. \
	Though you still polish boots and help don and doff armour, you're special. Or so they say. \
	For in time, you will come to replace them. To inherit the gifts they've been given. \
	In what state you're in when such a time comes, however? That is yet to be seen. <br>\
	For the island has a way of making the naive suffer, and you've been thrust into a position few would envy.",
	/datum/job/roguetown/manorguard = "After the Baron's rise to power, few remained with knowledge of the truth. \
	That had been centuries ago. A maddening thing to think about, now, given the vague understanding most have on the matter. <br>\
	Rather than worry, you'd signed up, having been granted many gifts for your service. \
	Whatever makes you special, you're sure to stand out in the troubles to come. \
	Brandish arclight rifle and banner. Raise your head high, and parade behind the knights as they carry out the Baron's will.",
	/datum/job/roguetown/warden = "A seafarer, in your current years. Likely trusted of the Baron, once, and now relegated to dock-duty. \
	Or perhaps you're simply some fool who bought the words of the island being safe. No matter. You're now a sword that defends it. In a sense. <br>\
	Spend time drinking in the tavern, where your lot is quartered. \
	Better yet, ingratiate yourself with the locals and assure whatever's coming in on boat won't harm the status quo.",
	//Church, now. Priest and Martyr.
	/datum/job/roguetown/martyr = "You are the Sanguifier. A being empowered by relics of the Baron's Archeovault. Trinkets to keep the peace. <br>\
	Though no different than the See's Martyrs in function - of the same guild, in truth, and intended to perish in your duties, at that - \
	you have a slightly different set of tools. <br>\
	Wield hellfire and refraction lance in the name of your beloved Patron and the diocese's own. \
	For the horrors will come soon, and the toys provided by the Baron to hide their faults will not avail them, should the truth get out.",
	/datum/job/roguetown/priest = "You are the Bishop of this squalid island, either sent here as punishment by the Confederacy's See, \
	or a figure of unsound judgement. <br>\
	Perhaps you may yet do some good, assuming the entire isle isn't beyond saving. \
	Tend to your newfound congregation, and see to it that the Pantheon's light isn't forgotten in a place such as this.",
	//Now, for the Inquisition.
	/datum/job/roguetown/puritan = "That estate. That damnable estate. The cause of problems on the mainland. \
	It all points to the Baron. You just don't know <b>why</b>! And neither does the Empire itself or the wretched Confederacy. \
	Such is the concern that you've been dispatched, undermanned though you may be, with the goal of investigating. \
	To establish a foothold on the archipelago. Operating from your own ship will ease the process, yet these seas are especially rough...",
	//Baron's family. Host wants Baron family. We keep Baron family. Justify it here. Same with suitors.
	/datum/job/roguetown/prince = "You are an Heir in all but function. \
	Not even the Baron will tell you what your purpose is to be, if they even yet know, though you are of the forever Baron's lineage all the same. <br>\
	One may wonder still as to why a figure, without end to their rule, may bring a fool to believe themselves to inherit it. Perhaps you'll be the one? \
	How many came before you? You certainly won't be the last. One might imagine the Baron simply likes to keep their own blood around.",
	/datum/job/roguetown/lady = "You are unlikely the first Consort of the Baron. A figure without end to their rule, having held sway for centuries. \
	Yet, you can lay claim all the same to the fact that you do hold their ear, attention and, potentially, love. \
	Something not many may say with a straight face.",
	/datum/job/roguetown/suitor = "The 'forever' Baron, a figure of astronomical power, may be your key to power. \
	To hold whatever sits within their soul. The key to longevity and endless despondency. Or, the fool that you may be, do you yet seek true love? \
	It doesn't truly matter. You'll find your fate in this land, one way or another.",
	//Guild guys.
	/datum/job/roguetown/guildmaster = "You lead the Guild of Crafts. A collection of architects, smiths and the isle's own gifted residents. \
	Many look to you for guidance. Many more will ask how the ins and outs of something function. <br><br>\
	Yet, at the end of the dae? Your main goal remains the same. \
	Undercut and destroy the competition!",
	/datum/job/roguetown/guildsman = "You're one of two that works under the Guildmaster. A figure of great respect and means. \
	Perhaps, one day, with your toil and sweat? You may yet come to take up the mantle of leadership. \
	For now, however, you've your quarters and a respected position. A simple smith or architect you yet remain.",
	)
	blacklist = list(
		//Antags.
		/datum/job/roguetown/wretch,//Later. Have to redo you. Slot adjustment handles this anyways.
		/datum/job/roguetown/bandit,//You too. Slot adjustment handles this, too.
		/datum/job/roguetown/gnoll,//No. Not here. On an ISLAND?

		//Keep.
		/datum/job/roguetown/jester,//Enable later. Maybe. Redo you, first. Turn you into a mummer.
/*
		//Host wants the below. So we keep the below. Refluffing above via fluff text. - Carl
		/datum/job/roguetown/prince,//Immortal Baron. No, thanks.
		/datum/job/roguetown/lady,//Same here.
		/datum/job/roguetown/suitor,//Yup yup. Replaced by an ambassador.
*/
		//Inquis. Maybe prune Absolver?

		//Mercs.
		/datum/job/roguetown/mercenary,

		//Church.
		/datum/job/roguetown/churchling,
		/datum/job/roguetown/martyr,//You need to be redone. See text above.

		//General towners. Unfortunately, Homesteader replaces some of you.
		//When I gut that again or we figure something NEW out, we'll return you.
		/datum/job/roguetown/apothecary,
		/datum/job/roguetown/clerk,
		/datum/job/roguetown/orphan,
		/datum/job/roguetown/shophand,
		/datum/job/roguetown/tailor,

		//Outsiders.
		/datum/job/roguetown/pilgrim,
		/datum/job/roguetown/lunatic,
		/datum/job/roguetown/prisonerr,//Kind of an outsider. Need to fix this up later.

	)
	species_adjust = list()
	sexes_adjust = list()

	//Threat regions is used for displaying specific regions on notice boards
	threat_regions = list(
		THREAT_REGION_AZURE_BASIN,
		THREAT_REGION_AZURE_GROVE,
		THREAT_REGION_TERRORBOG,
		THREAT_REGION_AZUREAN_COAST,
		THREAT_REGION_MOUNT_DECAP
	)
