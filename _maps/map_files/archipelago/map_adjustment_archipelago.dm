/datum/map_adjustment/template/archipelago
	map_file_name = "archipelago.dmm"
	realm_name = "Northwich"
	slot_adjust = list(
		//Keep start.
		/datum/job/roguetown/manorguard = 3,//Lowpop blues.
		/datum/job/roguetown/wapprentice = 2,
		/datum/job/roguetown/squire = 2,//The CAPTAIN requires NO HELP. GOOD GOD. NO.
		//Inquis start.
		/datum/job/roguetown/orthodoxist = 2,
		//Church start.
		/datum/job/roguetown/templar = 2,
		/datum/job/roguetown/monk = 2,
		/datum/job/roguetown/druid = 2,
		/datum/job/roguetown/keeper = 1,//I HATE YOU
	)
	title_adjust = list(
		//Court
		/datum/job/roguetown/lord = list(display_title = "Baron", f_title = "Baroness"),
		/datum/job/roguetown/prince = list(display_title = "Heir", f_title = "Heiress"),
		/datum/job/roguetown/veteran = list(display_title = "Honorant"),
		//Garrison
		/datum/job/roguetown/captain = list(display_title = "Mordgaunt"),
		/datum/job/roguetown/knight = list(display_title = "Gaunt"),
		//Church
		/datum/job/roguetown/martyr = list(display_title = "Sanguifier"),
	)
	tutorial_adjust = list(
	//Keep aligned, first. The main three.
	/datum/job/roguetown/lord = "You are the Baron. A figure of incredible sway within the region, laying claim to an entire archipelago. \
	After the See's attempt at securing their own power, only to find themselves swayed by your Archeovault's toys, \
	or the Inquisitorial retinue having attempted to leap at your throat when they learned the truth? \
	An uneasy peace has been brokered. You are no heretic, at least in their eyes. You've simply stumbled upon something horrific, \
	with them now duty bound to assure it remains guarded. The fools.",
	/datum/job/roguetown/hand = "You are the Hand. The lord's Maven. Their second, in function, of nearly the same stature and station. \
	A figure ennobled by the discovery you and your two companions had made, nearly a decade ago. <br>\
	It had been you who tarried, just as it'll be you to die, should the Baron's trust be a fool's endeavour.",
	/datum/job/roguetown/veteran = "Fools may see a simple 'veteran', or perhaps an old codger. \
	Though, not far from the truth, you've done more than most can lay claim to in your life. \
	You were there. Present during the Baron's ascension to power, with the tools gained. \
	Still, of course, present now. Retained, unlike many others the lord had discarded, simply for your knowledge and skill alone. <br>\
	You're, quite possibly, the most decorated figure on the isle. Something none can lay claim to, or challenge. \
	Though, these days, both Baron and Hand seem content to pretend you're a simple menial in their employ.",
	//Garison. Still keep aligned.
	/datum/job/roguetown/captain = "You were the first among those uplifted, by the Baron. \
	To have been given armour and weapon that appeared divine in origin, though you know better now. <br>\
	You'd asked, pleaded and questioned some more, with the only response you had received being an expectation of service. \
	There was no point arguing, of course. For you were - nae, are - the Baron's strongest warrior. The first to be called, in the event of an issue. \
	Your martial prowess, and the very weapons you wield, are quite simply not of this world.",
	/datum/job/roguetown/knight = "One of two, the next to be uplifted by the Archeovault's trinkets. \
	That is, beyond the Captain, now called the Mordgaunt, by the Baron's mad muse. Even now, you've taken on the moniker, quite simply, of 'Gaunt'.<br>\
	You've been charged with standing sentry over the Baron's estate. To act as an attack dog, in place of the Captain's absent reach, \
	with the astronomical power that you've been granted. There are few who may call themselves equals of you now. Fewer still, who'd dare.",
	/datum/job/roguetown/squire = "Not a squire in the traditional sense. \
	Though you still polish boots and help don and doff armour, you're special. Or so the Gaunts say. \
	For in time, you will come to replace them. To inherit the gifts they've been given. \
	In what state you're in when such a time comes, however? That is yet to be seen. <br>\
	For the island has a way of making the naive suffer, and you've been thrust into a position few would envy.",
	/datum/job/roguetown/manorguard = "After the Discovery of the Archeovault, the Baron saw fit to purging those with knowledge of it. \
	A maddening thing to think about, now, given the vague understanding most have. Yet, you stood as one of the few he did not find the want to remove. <br>\
	Indeed, you've since been granted many gifts for your service. Whatever makes you special, you're sure to stand out in the troubles to come. \
	Brandish arclight rifle and banner. Raise your head high, and parade behind the Gaunts as they carry out the Baron's will.",
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
	/datum/job/roguetown/priest = "You are the Bishop of this squalid island, either sent here as punishment by the See, or a figure of unsound judgement. \
	Perhaps you may yet do some good, assuming the entire isle isn't beyond saving. \
	Tend to your newfound congregation, and see to it that the Ten's light isn't forgotten in a place such as this.",
	//Now, for the Inquisition.
	/datum/job/roguetown/puritan = "That estate. That damnable estate. The cause of problems on the mainland. \
	It all points to the Baron. You just don't know <b>why</b>! \
	Such is the concern that you've been dispatched, undermanned though you may be, with the goal of investigating. \
	To establish a foothold on the archipelago. Operating from your own ship will ease the process, yet these seas are especially rough...",
	)
	blacklist = list(
		//Antags.
		/datum/job/roguetown/wretch,//Later. Have to redo you.
		/datum/job/roguetown/bandit,//You too.
		/datum/job/roguetown/assassin,//Need to redo this entirely.
		/datum/job/roguetown/gnoll,//No. Not here. On an ISLAND?

		//Keep.
		/datum/job/roguetown/jester,//Enable later. Maybe. Redo you, first. Turn you into a mummer.

		//Inquis. Maybe prune Absolver?

		//Mercs.
		/datum/job/roguetown/mercenary,

		//Church.
		/datum/job/roguetown/churchling,

		//General towners. Unfortunately, Homesteader replaces some of you.
		//I'm sorry. Will return a few when I ONCE AGAIN FOR THE THIRD TIME remove that GARBAGE.
		//Oh my lord.
		/datum/job/roguetown/apothecary,
		/datum/job/roguetown/clerk,
		/datum/job/roguetown/orphan,
		/datum/job/roguetown/shophand,
		/datum/job/roguetown/tailor,

		//Outsiders.
		/datum/job/roguetown/pilgrim,
		/datum/job/roguetown/lunatic,

		//I hate you so much.
		/datum/job/roguetown/cataphract,
		/datum/job/roguetown/headslave,
		/datum/job/roguetown/janissary,
		/datum/job/roguetown/janissarysergeant,
		/datum/job/roguetown/azebagha,
		/datum/job/roguetown/slavemaster,
		/datum/job/roguetown/slave,
		/datum/job/roguetown/adventurer/courtslave,
	)
	threat_regions = list(
		THREAT_REGION_NORTHWICH_ISLE,
		THREAT_REGION_NORTWHICH_OUTLYING,
	)
