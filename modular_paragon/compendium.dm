/*
Your lore being trapped to Discord disgusts me.
Have you no respect for what you've written?
Let's have it shown to players, in the moment, as needed.
At least, we'll do that later. With hooks to certain words.
For now, a direct AP port with reworks will suffice.
*/

GLOBAL_LIST_INIT(fluff_regions, init_fluff_regions())

#define FLUFF_REGION_BARONY			"northwich"
#define FLUFF_REGION_EMPIRE			"empire"
#define FLUFF_REGION_CONFEDERACY	"confederacy"
#define FLUFF_REGION_CONCLAVES		"conclaves"
#define FLUFF_REGION_COLONIAL		"colonial"
#define FLUFF_REGION_OTHER			"outlands"

/proc/build_lore_primer_content()
	var/list/dat = list()
	dat += GLOB.roleplay_readme
	dat += build_regions_primer_html()
	return dat.Join()

/mob/dead/new_player/verb/do_rp_prompt()
	set name = "Compendium"
	set category = "IC"
	var/datum/browser/popup = new(src, "Blessed Compendium", "PARAGON MOON", 460, 550)
	popup.set_content(build_lore_primer_content())
	popup.open()

//We don't have the economy. At least not the way AP does.
//Instead, we use this for lore purposes. Wild how that works.
/proc/build_regions_primer_html()
	var/list/parts = list()
	parts += "<details>"
	parts += "<summary><strong><span style='font-size:130%'> THE STAGE </span></strong></summary>"
	parts += "<strong><span style='font-size:115%'> FOES OF FATE  </span></strong>"
	parts += "<br><br>"
	for(var/region_id in GLOB.fluff_regions)
		var/datum/fluff_region/region = GLOB.fluff_regions[region_id]
		if(!region)
			continue
		parts += "<details>"
		parts += "<summary><strong> [uppertext(region.name)] </strong></summary>"
		parts += "<br>"
		if(region.subtitle)
			parts += "<em>[region.subtitle]</em>"
			parts += "<br><br>"
		parts += region.description
		parts += "<br>"
		parts += "</details>"
	parts += "<br><br>"
	parts += "</details>"
	return jointext(parts, "\n")

/proc/init_fluff_regions()
	var/list/result = list()
	for(var/datum/fluff_region/er as anything in subtypesof(/datum/fluff_region))
		var/datum/fluff_region/instance = new er()
		if(!instance.region_id)
			continue
		result[instance.region_id] = instance
	return result

/datum/fluff_region
	var/region_id
	var/name
	var/subtitle = ""
	var/description = ""

/datum/fluff_region/northwich
	region_id = FLUFF_REGION_BARONY
	name = "The Barony"
	subtitle = "The Ever Baron's Demesne"
	description = "An impossibly ancient barony, typically referred to by the locals as 'Northwich', \
	secured on every which side by violent seas and bone-biting chill. <br>\
	Neither Confederacy nor Empire wished to settle the archipelago, for it had been a harsh place. \
	Yet, under the watchful eye of its dutiful, forever independent Great Leader, it has seen relative peace and comfort for centuries. <br>\
	<small>In whispers and tongues, something grand is beheld beneath the Baron's estate. The source of perpetual conquest.</small>"

/datum/fluff_region/empire
	region_id = FLUFF_REGION_EMPIRE
	name = "Otavan Empire"
	subtitle = "The Pious, Neither Guiltless nor Free of the Emperor's Domain"
	description = "The grand Empire to the west is the oldest and largest of the emergent nations. \
	A theocratic hegemony where each emperor is crowned by none other than the head of the clergy. \
	Faith in the maker, often referred to as Psydon, is all. It is in duty and perseverance you pay your due respect. \
	Other views, while accepted, are closely watched, for none shall impede the divine sanctity and peace."

/datum/fluff_region/confederacy
	region_id = FLUFF_REGION_CONFEDERACY
	name = "The Grenzelhoft Confederacy"
	subtitle = "The Great Houses, Forming the Wyvern of the Confederacy's Martial Dominance"
	description = "On the mainland to the east lies the confederacy of free city states. \
	The second largest known nation only rivaled by the empire in sheer size. \
	Once a splintered group of cities and noble houses, now a bustling union where each region sends forth one of their own to represent them in the house of lords. \
	Old rivalries remain, but together they field the largest army known to date."

/datum/fluff_region/freefolk
	region_id = FLUFF_REGION_CONCLAVES
	name = "Freefolk Conclaves"
	subtitle = "The Vagrants, Dreamers and Fools Seeking the Wylderspirit's Peace"
	description = "Further north of the Empire, lies the home of the freefolk. A culturally diverse people of travelers, refugees and tribal folk. \
	While a loose communal group only guided by their elders, \
	their faith in spirits and the wild gods of this world has bestowed them with fertile and bountiful lands. \
	An ancestral home that seems to live and writhe, warding itself and its people from harm."

/datum/fluff_region/colonial
	region_id = FLUFF_REGION_COLONIAL
	name = "Etruscan Colonies"
	subtitle = "The Sailors, Proud and Few, of the Tyrannical Admiralty"
	description = "A young maritime nation of merchants, mariners, explorers and vagabonds. \
	The colonies are the springboard for expeditions to any yet uncharted coast and a bustling hub of trade. \
	Under the firm leadership of the great admiralty, piracy is punished with a heavy hand. Fortune and fame however, favour only the bold..."

/datum/fluff_region/other
	region_id = FLUFF_REGION_OTHER
	name = "Outlands"
	subtitle = "The Lost, Bearers of Purpose and Distinction"
	description = "A great deal of kingdoms exist, in the scarred and desolate landscapes of the main continents. \
	Though, for the purposes of this story, they're irrelevant. Outlanders among outsiders."
