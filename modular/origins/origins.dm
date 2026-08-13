/datum/origin
	var/name = null
	var/desc = ""
	var/origin_title = null
	var/region_title = null
	var/map_x = 0
	var/map_y = 0
	var/origin_language = null

GLOBAL_LIST_INIT(origins, build_origins())

/proc/build_origins()
	. = list()
	for(var/type in subtypesof(/datum/origin))
		.[type] = new type()

/datum/origin/northwich
	name = "The Barony"
	desc = "An impossibly ancient barony, typically referred to by the locals as 'Northwich', secured on every which side by violent seas and bone-biting chill. <br>\
	Neither Confederacy nor Empire wished to settle the archipelago, for it had been a harsh place. \
	Yet, under the watchful eye of its dutiful, forever independent Great Leader, it has seen relative peace and comfort for centuries. <br>\
	<small>In whispers and tongues, something grand is beheld beneath the Baron's estate. The source of perpetual conquest.</small>"
	origin_title = "Islander"
	map_x = 529
	map_y = 215

/datum/origin/empire
	name = "Otavan Empire"
	desc = "The grand Empire to the west is the oldest and largest of the emergent nations. \
	A theocratic hegemony where each emperor is crowned by none other than the head of the clergy. \
	Faith in the maker, often referred to as Psydon, is all. It is in duty and perseverance you pay your due respect. \
	Other views, while accepted, are closely watched, for none shall impede the divine sanctity and peace."
	origin_title = "Imperial"
	origin_language = /datum/language/otavan
	map_x = 322
	map_y = 325

/datum/origin/confederacy
	name = "The Grenzelhoft Confederacy"
	desc = "On the mainland to the east lies the confederacy of free city states. \
	The second largest known nation only rivaled by the empire in sheer size. \
	Once a splintered group of cities and noble houses, now a bustling union where each region sends forth one of their own to represent them in the house of lords. \
	Old rivalries remain, but together they field the largest army known to date."
	origin_title = "'Hoft"
	origin_language = /datum/language/grenzelhoftian
	map_x = 720
	map_y = 236

/datum/origin/freefolk
	name = "Freefolk Conclaves"
	desc = "Further north of the Empire, lies the home of the freefolk. A culturally diverse people of travelers, refugees and tribal folk. \
	While a loose communal group only guided by their elders, \
	their faith in spirits and the wild gods of this world has bestowed them with fertile and bountiful lands. \
	An ancestral home that seems to live and writhe, warding itself and its people from harm."
	origin_title = "Freefolk"
	origin_language = /datum/language/elvish
	map_x = 248
	map_y = 173

/datum/origin/colonial
	name = "Etruscan Colonies"
	desc = "A young maritime nation of merchants, mariners, explorers and vagabonds. \
	The colonies are the springboard for expeditions to any yet uncharted coast and a bustling hub of trade. \
	Under the firm leadership of the great admiralty, piracy is punished with a heavy hand. Fortune and fame however, favour only the bold..."
	origin_title = "'Can"
	origin_language = /datum/language/etruscan
	map_x = 586
	map_y = 135

/datum/origin/other
	name = "Outlands"
	desc = "Not an unknown in the traditional sense. Quite simply, your homelands don't matter.. \
	A great deal of kingdoms exist, in the scarred and desolate landscapes of the main continents. \
	Though, for the purposes of this story, they're irrelevant. You're an outlander among outsiders."
	origin_title = "Outlander"
	map_x = 572
	map_y = 415

/datum/preferences/proc/open_origin_map(mob/user)
	var/html = build_origin_map_html()
	user << browse_rsc(file("html/paragon_map.png"), "paragon_map.png")
	user << browse(html, "window=origin_map;size=960x500")
	onclose(user, "origin_map", src)

/datum/preferences/proc/build_origin_map_html()
	var/html = ""
	html += "<html><head><style>"
	html += {"body{margin:0;padding:0;background:#1a1209;color:#e8dcc8;font-family:Georgia,serif;overflow:hidden;user-select:none;}"}
	html += {".map-wrap{position:relative;width:960px;height:459px;display:block;margin:0 auto;}"}
	html += {".map-wrap img{width:960px;height:459px;display:block;pointer-events:none;}"}
	html += {".pin{position:absolute;width:18px;height:18px;border-radius:50%;background:#6bba75;border:2px solid #e8c87a;cursor:pointer;transform:translate(-50%,-50%);transition:all 0.15s ease;z-index:10;}"}
	html += {".pin:hover,.pin.selected{background:#e8c87a;border-color:#fff;box-shadow:0 0 10px rgba(232,200,122,0.9);transform:translate(-50%,-50%) scale(1.3);z-index:20;}"}
	html += {".pin.selected{background:#c8a020;}"}
	html += {".tooltip{position:fixed;background:rgba(18,12,5,0.97);border:1px solid #8b6914;border-radius:4px;padding:10px 14px;max-width:240px;z-index:100;pointer-events:none;display:none;color:#e8dcc8;}"}
	html += {".tooltip b{color:#e8c87a;font-size:14px;}"}
	html += {".tooltip p{margin:4px 0 0 0;font-size:12px;line-height:1.4;}"}
	html += {".panel{width:512px;margin:0 auto;padding:6px 0;text-align:center;background:#1a1209;border-top:1px solid #4a3010;}"}
	html += {".panel b{color:#e8c87a;font-size:13px;}"}
	html += {"#selected-label{color:#c8a020;font-size:13px;margin-top:3px;}"}
	html += {".confirm-btn{display:inline-block;margin-top:6px;padding:5px 18px;background:#5a2800;border:1px solid #8b6914;color:#e8dcc8;font-family:Georgia,serif;font-size:13px;cursor:pointer;border-radius:2px;}"}
	html += {".confirm-btn:hover{background:#8b4010;border-color:#e8c87a;}"}
	html += "</style></head><body>"
	html += "<div class='map-wrap'>"
	html += "<img src='paragon_map.png' alt='Paragon Map'>"
	for(var/otype as anything in GLOB.origins)
		var/datum/origin/O = GLOB.origins[otype]
		var/sel_cls = (origin == O) ? " selected" : ""
		var/safe_name = replacetext(O.name, "'", "\\'")
		var/safe_desc = replacetext(O.desc, "'", "\\'")
		var/node_href = "byond://?src=\ref[src];preference=origin_select;type=[url_encode("[otype]")]"
		html += "<div class='pin[sel_cls]' style='left:[O.map_x]px;top:[O.map_y]px;' "
		html += "onclick=\"window.location.href='[node_href]'; return false;\" "
		html += "onmouseenter=\"showTip(event,'[safe_name]','[safe_desc]')\" "
		html += "onmouseleave=\"hideTip()\"></div>"
	html += "</div>"
	html += "<div class='panel'>"
	var/current_label = origin ? origin.name : "None selected"
	html += "<b>Selected: [current_label]</b>"
	html += "</div>"
	html += "<div class='tooltip' id='tip'></div>"
	html += "<script>"
	html += {"function showTip(e, name, desc) {"}
	html += "  var t = document.getElementById('tip');"
	html += "  t.innerHTML = '<b>' + name + '</b>' + (desc ? '<p>' + desc + '</p>' : '');"
	html += "  t.style.left = '-9999px';"
	html += "  t.style.display = 'block';"
	html += "  var x = e.clientX + 14;"
	html += "  var y = e.clientY + 14;"
	html += "  var tw = t.offsetWidth;"
	html += "  var th = t.offsetHeight;"
	html += "  if (x + tw > window.innerWidth) x = e.clientX - tw - 14;"
	html += "  if (y + th > window.innerHeight) y = e.clientY - th - 14;"
	html += "  t.style.left = x + 'px';"
	html += "  t.style.top = y + 'px';"
	html += "}"
	html += {"function hideTip() { document.getElementById('tip').style.display='none'; }"}
	html += "</script></body></html>"
	return html
