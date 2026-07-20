/datum/map_adjustment/template/archipelago
	map_file_name = "archipelago.dmm"
	realm_name = "Northwich"
	slot_adjust = list(
		//Keep start.
		/datum/job/roguetown/manorguard = 3,//Lowpop blues.
		/datum/job/roguetown/wapprentice = 2,
		//Inquis start.
		/datum/job/roguetown/orthodoxist = 2,
		//Church start.
		/datum/job/roguetown/templar = 2,
		/datum/job/roguetown/monk = 2,
		/datum/job/roguetown/druid = 2,
	)
	title_adjust = list(
		//Court
		/datum/job/roguetown/lord = list(display_title = "Baron", f_title = "Baroness"),
	)
	blacklist = list(
		//Antags.
		/datum/job/roguetown/wretch,//Later. Have to redo you.
		/datum/job/roguetown/bandit,//You too.
		/datum/job/roguetown/assassin,//Need to redo this entirely.
		/datum/job/roguetown/gnoll,//No. Not here. On an ISLAND?

		//Keep.
		/datum/job/roguetown/jester,//Enable later. Maybe. Redo you, first.

		//Inquis. Maybe prune Absolver?

		//Mercs.
		/datum/job/roguetown/mercenary,

		//Church.
		/datum/job/roguetown/churchling,

		//General towners.
		/datum/job/roguetown/apothecary,
		/datum/job/roguetown/clerk,
		/datum/job/roguetown/orphan,
		/datum/job/roguetown/shophand,

		//Outsiders.
		/datum/job/roguetown/pilgrim,

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
