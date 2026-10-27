//decorations from sunset ported sloppy-style, all nonfunctional but functionality could be easily added on if wanted

//==================== BASE TYPES ====================

#define SUNSET_DOOR_CLOSED "closed"
#define SUNSET_DOOR_OPEN "open"
#define SUNSET_DOOR_WELDED "welded"
#define SUNSET_DOOR_BOLTED "bolted"

/obj/structure/fluff/sunset
	name = "old machine"
	icon = 'modular_paragon/sunset_decor/icons/terminals.dmi'
	blade_dulling = DULLING_BASH
	//opverlayed on top on init
	var/list/decor_overlays
	// Icon the overlays are taken from
	var/overlay_icon

/obj/structure/fluff/sunset/Initialize(mapload)
	. = ..()
	for(var/overlay_state in decor_overlays)
		add_overlay(mutable_appearance(overlay_icon || icon, overlay_state))

/obj/structure/fluff/walldeco/sunset
	name = "sign"
	icon = 'modular_paragon/sunset_decor/icons/wasteland_decals.dmi'
	//opverlayed on top on init
	var/list/decor_overlays

/obj/structure/fluff/walldeco/sunset/Initialize(mapload)
	. = ..()
	for(var/overlay_state in decor_overlays)
		add_overlay(mutable_appearance(icon, overlay_state))

/obj/structure/fluff/walldeco/sunset/screen
	name = "wall screen"
	icon = 'modular_paragon/sunset_decor/icons/wall_terminals.dmi'

/obj/effect/turf_decal/sunset
	icon = 'modular_paragon/sunset_decor/icons/wasteland_decals.dmi'

/obj/structure/fluff/sunset/terminal
	name = "terminal"
	icon_state = "terminal"

/obj/structure/fluff/sunset/terminal/ruined
	name = "ruined terminal"

/obj/structure/fluff/sunset/airlock
	name = "door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/public.dmi'
	icon_state = "closed"
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/station/overlays.dmi'
	density = TRUE
	opacity = TRUE
	layer = CLOSED_DOOR_LAYER
	resistance_flags = INDESTRUCTIBLE
	var/door_state = SUNSET_DOOR_CLOSED

/obj/structure/fluff/sunset/airlock/Initialize(mapload)
	switch(door_state)
		if(SUNSET_DOOR_OPEN)
			icon_state = "open"
			density = FALSE
			opacity = FALSE
			layer = OPEN_DOOR_LAYER
		if(SUNSET_DOOR_WELDED)
			decor_overlays = list("welded")
		if(SUNSET_DOOR_BOLTED)
			decor_overlays = list("lights_bolts")
	return ..()

/obj/structure/fluff/sunset/window
	name = "window"
	density = TRUE
	opacity = FALSE
	layer = TABLE_LAYER
	resistance_flags = INDESTRUCTIBLE
	pass_flags = LETPASSTHROW

/obj/structure/fluff/sunset/window/Initialize(mapload)
	. = ..()
	if(smooth)
		icon_state = ""

/obj/structure/fluff/railing/sunset_windoor
	name = "glass panel door"
	desc = ""
	icon = 'modular_paragon/sunset_decor/icons/doors/windoor.dmi'
	icon_state = "left"
	climbable = FALSE
	pass_crawl = FALSE
	pass_projectile = FALSE
	pass_throwing = FALSE
	resistance_flags = INDESTRUCTIBLE
	var/blocks_passage = TRUE

/obj/structure/fluff/railing/sunset_windoor/init_connect_loc_element()
	if(blocks_passage)
		return ..()

/obj/structure/fluff/railing/sunset_windoor/CanPass(atom/movable/mover, turf/target)
	if(!blocks_passage || isobserver(mover))
		return TRUE
	return get_dir(loc, target) != dir

//==================== TERMINALS ====================
/obj/structure/fluff/sunset/terminal/terminal
	name = "old terminal"
	icon_state = "terminal"
	decor_overlays = list("terminal_on", "terminal_key")

/obj/structure/fluff/sunset/terminal/terminal/off
	name = "dead old terminal"
	decor_overlays = list("terminal_key_off")

/obj/structure/fluff/sunset/terminal/terminal/broken
	name = "broken old terminal"
	icon_state = "terminal_broken"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/research
	name = "research console"
	icon_state = "research"
	density = TRUE
	decor_overlays = list("research_on", "research_key")

/obj/structure/fluff/sunset/terminal/research/off
	name = "dead research console"
	decor_overlays = list("research_off", "research_key_off")

/obj/structure/fluff/sunset/terminal/research/broken
	name = "broken research console"
	icon_state = "research_broken"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/lab
	name = "laboratory terminal"
	icon_state = "lab"
	decor_overlays = list("lab_on", "lab_key")

/obj/structure/fluff/sunset/terminal/lab/off
	name = "dead laboratory terminal"
	decor_overlays = list("lab_key_off")

/obj/structure/fluff/sunset/terminal/lab/broken
	name = "broken laboratory terminal"
	icon_state = "lab_broken"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/advanced
	name = "advanced terminal"
	icon_state = "advanced"
	decor_overlays = list("advanced_on")

/obj/structure/fluff/sunset/terminal/advanced/off
	name = "dead advanced terminal"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/advanced/broken
	name = "broken advanced terminal"
	icon_state = "advanced_broken"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/lunar
	name = "mainframe cabinet"
	icon_state = "lunar"
	density = TRUE
	decor_overlays = list("lunar_on", "lunar_key")

/obj/structure/fluff/sunset/terminal/lunar/off
	name = "dead mainframe cabinet"
	decor_overlays = list("lunar_key_off")

/obj/structure/fluff/sunset/terminal/lunar/broken
	name = "broken mainframe cabinet"
	icon_state = "lunar_broken"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/enclave
	name = "display terminal"
	icon_state = "enclave"
	density = TRUE
	decor_overlays = list("enclave_on", "enclave_key")

/obj/structure/fluff/sunset/terminal/enclave/off
	name = "dead display terminal"
	decor_overlays = list("enclave_off", "enclave_key_off")

/obj/structure/fluff/sunset/terminal/terminal/alt
	decor_overlays = list("terminal_on_alt", "terminal_key")

/obj/structure/fluff/sunset/terminal/advanced/destroyed
	name = "ruined advanced terminal"
	icon_state = "advanced_destroyed"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/enclave/heart
	decor_overlays = list("enclave_love", "enclave_key")

/obj/structure/fluff/sunset/terminal/enclave/broken
	name = "broken display terminal"
	decor_overlays = list("enclave_broken", "enclave_key_off")

/obj/structure/fluff/sunset/terminal/laptop
	name = "folding terminal"
	icon_state = "laptop"
	decor_overlays = list("laptop_key")

/obj/structure/fluff/sunset/terminal/laptop/medical
	decor_overlays = list("medlaptop", "laptop_key")

/obj/structure/fluff/sunset/terminal/laptop/closed
	name = "closed folding terminal"
	icon_state = "laptop_close"
	decor_overlays = null

/obj/structure/fluff/sunset/terminal/laptop/broken
	name = "broken folding terminal"
	decor_overlays = list("laptop_broken")

/obj/structure/fluff/sunset/terminal/military
	name = "field terminal"
	icon_state = "military"
	density = TRUE

/obj/structure/fluff/sunset/terminal/tracking
	name = "tracking console"
	icon_state = "tracking"
	density = TRUE

/obj/structure/fluff/sunset/terminal/ruined/num_0
	icon_state = "0"

/obj/structure/fluff/sunset/terminal/ruined/num_1
	icon_state = "1"

/obj/structure/fluff/sunset/terminal/ruined/num_2
	icon_state = "2"

/obj/structure/fluff/sunset/terminal/ruined/num_3
	icon_state = "3"

/obj/structure/fluff/sunset/terminal/ruined/num_4
	icon_state = "4"

/obj/structure/fluff/walldeco/sunset/screen/console
	name = "wall console"
	icon_state = "req_comp0"

/obj/structure/fluff/walldeco/sunset/screen/console/message
	icon_state = "req_comp1"

/obj/structure/fluff/walldeco/sunset/screen/console/priority
	icon_state = "req_comp2"

/obj/structure/fluff/walldeco/sunset/screen/console/emergency
	icon_state = "req_comp3"

/obj/structure/fluff/walldeco/sunset/screen/console/off
	name = "dead wall console"
	icon_state = "req_comp_off"

/obj/structure/fluff/walldeco/sunset/screen/production
	name = "production console"
	icon_state = "production_console"

/obj/structure/fluff/walldeco/sunset/screen/production/old
	name = "old production console"
	icon_state = "production_console_old"

/obj/structure/fluff/walldeco/sunset/screen/door_panel
	name = "door panel"
	icon_state = "dorm_available"

/obj/structure/fluff/walldeco/sunset/screen/door_panel/taken
	icon_state = "dorm_taken"

/obj/structure/fluff/walldeco/sunset/screen/door_panel/error
	icon_state = "dorm_error"

/obj/structure/fluff/walldeco/sunset/screen/door_panel/off
	name = "dead door panel"
	icon_state = "dorm_off"

/obj/structure/fluff/walldeco/sunset/screen/news_screen
	name = "news screen"
	icon_state = "newscaster_normal"

/obj/structure/fluff/walldeco/sunset/screen/news_screen/wanted
	icon_state = "newscaster_wanted"

/obj/structure/fluff/walldeco/sunset/screen/news_screen/off
	name = "dead news screen"
	icon_state = "newscaster_off"

/obj/structure/fluff/walldeco/sunset/screen/news_screen/broken
	name = "broken news screen"
	icon_state = "newscaster_off"
	decor_overlays = list("crack2")

/obj/structure/fluff/sunset/fax
	name = "facsimile machine"
	icon = 'modular_paragon/sunset_decor/icons/wall_terminals.dmi'
	icon_state = "fax0"

//==================== WALL DECOR ====================
/obj/structure/fluff/walldeco/sunset/scrawl/num_1
	name = "bloody scrawl"
	icon_state = "blood_pic_1"

/obj/structure/fluff/walldeco/sunset/scrawl/num_2
	name = "bloody scrawl"
	icon_state = "blood_pic_2"

/obj/structure/fluff/walldeco/sunset/scrawl/num_3
	name = "bloody scrawl"
	icon_state = "blood_pic_3"

/obj/structure/fluff/walldeco/sunset/scrawl/num_4
	name = "bloody scrawl"
	icon_state = "blood_pic_4"

/obj/structure/fluff/walldeco/sunset/scrawl/num_5
	name = "bloody scrawl"
	icon_state = "blood_pic_5"

/obj/structure/fluff/walldeco/sunset/scrawl/num_6
	name = "bloody scrawl"
	icon_state = "blood_pic_6"

/obj/structure/fluff/walldeco/sunset/scrawl/num_7
	name = "bloody scrawl"
	icon_state = "blood_pic_7"

/obj/structure/fluff/walldeco/sunset/scrawl/num_8
	name = "bloody scrawl"
	icon_state = "blood_pic_8"

/obj/structure/fluff/walldeco/sunset/scrawl/num_9
	name = "bloody scrawl"
	icon_state = "blood_pic_9"

/obj/structure/fluff/walldeco/sunset/skulls
	name = "hanging skulls"
	icon_state = "skulls"

/obj/structure/fluff/walldeco/sunset/hide
	name = "stretched hide"
	icon_state = "skin"

/obj/structure/fluff/walldeco/sunset/rag
	name = "tattered rag"
	icon_state = "rag"

/obj/structure/fluff/walldeco/sunset/chain
	name = "hanging chain"
	icon_state = "chain"

/obj/structure/fluff/walldeco/sunset/cobweb
	name = "cobweb"
	icon_state = "lifeweb"

/obj/structure/fluff/walldeco/sunset/clock
	name = "wall clock"
	icon_state = "clock_act"

/obj/structure/fluff/walldeco/sunset/clock/stopped
	icon_state = "clock"

/obj/structure/fluff/walldeco/sunset/clock/old
	name = "old wall clock"
	icon_state = "old_clock_act"

/obj/structure/fluff/walldeco/sunset/clock/old/stopped
	icon_state = "old_clock"

/obj/structure/fluff/walldeco/sunset/script
	name = "strange script"
	icon_state = "tech_alphabet"

/obj/structure/fluff/walldeco/sunset/trefoil
	name = "trefoil sign"
	icon_state = "radiation"

/obj/structure/fluff/walldeco/sunset/stencil/caution
	name = "stencilled warning"
	icon_state = "wall_caution"

/obj/structure/fluff/walldeco/sunset/stencil/danger
	name = "stencilled warning"
	icon_state = "wall_danger"

/obj/structure/fluff/walldeco/sunset/stencil/radiation
	name = "stencilled warning"
	icon_state = "wall_radiation"

/obj/structure/fluff/walldeco/sunset/stencil/extreme_cold
	name = "stencilled warning"
	icon_state = "wall_extreme_cold"

/obj/structure/fluff/walldeco/sunset/stencil/extreme_heat
	name = "stencilled warning"
	icon_state = "wall_extreme_heat"

/obj/structure/fluff/walldeco/sunset/stencil/biohazard
	name = "stencilled warning"
	icon_state = "wall_biohazard"

/obj/structure/fluff/walldeco/sunset/stencil/electrical_hazard
	name = "stencilled warning"
	icon_state = "wall_electrical_hazard"

/obj/structure/fluff/walldeco/sunset/stencil/foreign/cp228
	name = "foreign warning"
	icon_state = "wall_cp228_ru"

/obj/structure/fluff/walldeco/sunset/stencil/foreign/forbidden
	name = "foreign warning"
	icon_state = "wall_forbidden_ru"

/obj/structure/fluff/walldeco/sunset/stencil/foreign/danger
	name = "foreign warning"
	icon_state = "wall_danger_ru"

/obj/structure/fluff/walldeco/sunset/stencil/foreign/weapons
	name = "foreign warning"
	icon_state = "wall_weapons_ru"

/obj/structure/fluff/walldeco/sunset/frame
	name = "empty frame"
	icon_state = "frame-empty"

/obj/structure/fluff/walldeco/sunset/frame/moon
	name = "framed photograph"
	icon_state = "photo_moon"

/obj/structure/fluff/walldeco/sunset/frame/portrait
	name = "portrait"
	icon_state = "painting_president"

/obj/structure/fluff/walldeco/sunset/frame/monkey
	name = "small painting"
	icon_state = "painting_monkey"

/obj/structure/fluff/walldeco/sunset/red/caution
	name = "caution sign"
	icon_state = "red_caution"

/obj/structure/fluff/walldeco/sunset/red/entry
	name = "entry sign"
	icon_state = "red_entry"

/obj/structure/fluff/walldeco/sunset/red/exit
	name = "exit sign"
	icon_state = "red_exit"

/obj/structure/fluff/walldeco/sunset/red/read_me
	name = "read me sign"
	icon_state = "red_read_me"

/obj/structure/fluff/walldeco/sunset/memorial
	name = "memorial plaque"
	icon_state = "memorial"

/obj/structure/fluff/walldeco/sunset/plaque
	name = "blank plaque"
	icon_state = "vault_blank"

/obj/structure/fluff/walldeco/sunset/plaque/admin
	name = "admin plaque"
	icon_state = "vault_admin"

/obj/structure/fluff/walldeco/sunset/plaque/arcade
	name = "arcade plaque"
	icon_state = "vault_arcade"

/obj/structure/fluff/walldeco/sunset/plaque/atrium
	name = "atrium plaque"
	icon_state = "vault_atrium"

/obj/structure/fluff/walldeco/sunset/plaque/bar
	name = "bar plaque"
	icon_state = "vault_bar"

/obj/structure/fluff/walldeco/sunset/plaque/biolab
	name = "biolab plaque"
	icon_state = "vault_biolab"

/obj/structure/fluff/walldeco/sunset/plaque/botany
	name = "botany plaque"
	icon_state = "vault_botany"

/obj/structure/fluff/walldeco/sunset/plaque/brig
	name = "brig plaque"
	icon_state = "vault_brig"

/obj/structure/fluff/walldeco/sunset/plaque/cargo
	name = "cargo plaque"
	icon_state = "vault_cargo"

/obj/structure/fluff/walldeco/sunset/plaque/cells
	name = "cells plaque"
	icon_state = "vault_cells"

/obj/structure/fluff/walldeco/sunset/plaque/chapel
	name = "chapel plaque"
	icon_state = "vault_chapel"

/obj/structure/fluff/walldeco/sunset/plaque/church
	name = "church plaque"
	icon_state = "vault_church"

/obj/structure/fluff/walldeco/sunset/plaque/cinema
	name = "cinema plaque"
	icon_state = "vault_cinema"

/obj/structure/fluff/walldeco/sunset/plaque/class
	name = "class plaque"
	icon_state = "vault_class"

/obj/structure/fluff/walldeco/sunset/plaque/clinic
	name = "clinic plaque"
	icon_state = "vault_clinic"

/obj/structure/fluff/walldeco/sunset/plaque/cocatt
	name = "cocatt plaque"
	icon_state = "vault_cocatt"

/obj/structure/fluff/walldeco/sunset/plaque/cryo
	name = "cryo plaque"
	icon_state = "vault_cryo"

/obj/structure/fluff/walldeco/sunset/plaque/diner
	name = "diner plaque"
	icon_state = "vault_diner"

/obj/structure/fluff/walldeco/sunset/plaque/dorm
	name = "dorm plaque"
	icon_state = "vault_dorm"

/obj/structure/fluff/walldeco/sunset/plaque/dorms
	name = "dorms plaque"
	icon_state = "vault_dorms"

/obj/structure/fluff/walldeco/sunset/plaque/entry
	name = "entry plaque"
	icon_state = "vault_entry"

/obj/structure/fluff/walldeco/sunset/plaque/erp
	name = "erp plaque"
	icon_state = "vault_erp"

/obj/structure/fluff/walldeco/sunset/plaque/exit
	name = "exit plaque"
	icon_state = "vault_exit"

/obj/structure/fluff/walldeco/sunset/plaque/garden
	name = "garden plaque"
	icon_state = "vault_garden"

/obj/structure/fluff/walldeco/sunset/plaque/gaybar
	name = "gaybar plaque"
	icon_state = "vault_gaybar"

/obj/structure/fluff/walldeco/sunset/plaque/guard
	name = "guard plaque"
	icon_state = "vault_guard"

/obj/structure/fluff/walldeco/sunset/plaque/guns
	name = "guns plaque"
	icon_state = "vault_guns"

/obj/structure/fluff/walldeco/sunset/plaque/hangar
	name = "hangar plaque"
	icon_state = "vault_hangar"

/obj/structure/fluff/walldeco/sunset/plaque/hotel
	name = "hotel plaque"
	icon_state = "vault_hotel"

/obj/structure/fluff/walldeco/sunset/plaque/kebab
	name = "kebab plaque"
	icon_state = "vault_kebab"

/obj/structure/fluff/walldeco/sunset/plaque/lab
	name = "lab plaque"
	icon_state = "vault_lab"

/obj/structure/fluff/walldeco/sunset/plaque/level1
	name = "level 1 plaque"
	icon_state = "vault_level1"

/obj/structure/fluff/walldeco/sunset/plaque/level2
	name = "level 2 plaque"
	icon_state = "vault_level2"

/obj/structure/fluff/walldeco/sunset/plaque/level5
	name = "level 5 plaque"
	icon_state = "vault_level5"

/obj/structure/fluff/walldeco/sunset/plaque/level6
	name = "level 6 plaque"
	icon_state = "vault_level6"

/obj/structure/fluff/walldeco/sunset/plaque/level7
	name = "level 7 plaque"
	icon_state = "vault_level7"

/obj/structure/fluff/walldeco/sunset/plaque/level9
	name = "level 9 plaque"
	icon_state = "vault_level9"

/obj/structure/fluff/walldeco/sunset/plaque/lobby
	name = "lobby plaque"
	icon_state = "vault_lobby"

/obj/structure/fluff/walldeco/sunset/plaque/lounge
	name = "lounge plaque"
	icon_state = "vault_lounge"

/obj/structure/fluff/walldeco/sunset/plaque/maint
	name = "maint plaque"
	icon_state = "vault_maint"

/obj/structure/fluff/walldeco/sunset/plaque/mine
	name = "mine plaque"
	icon_state = "vault_mine"

/obj/structure/fluff/walldeco/sunset/plaque/mines
	name = "mines plaque"
	icon_state = "vault_mines"

/obj/structure/fluff/walldeco/sunset/plaque/mobs
	name = "mobs plaque"
	icon_state = "vault_mobs"

/obj/structure/fluff/walldeco/sunset/plaque/motel
	name = "motel plaque"
	icon_state = "vault_motel"

/obj/structure/fluff/walldeco/sunset/plaque/office
	name = "office plaque"
	icon_state = "vault_office"

/obj/structure/fluff/walldeco/sunset/plaque/prison
	name = "prison plaque"
	icon_state = "vault_prison"

/obj/structure/fluff/walldeco/sunset/plaque/robots
	name = "robots plaque"
	icon_state = "vault_robots"

/obj/structure/fluff/walldeco/sunset/plaque/sealab
	name = "sealab plaque"
	icon_state = "vault_sealab"

/obj/structure/fluff/walldeco/sunset/plaque/server
	name = "server plaque"
	icon_state = "vault_server"

/obj/structure/fluff/walldeco/sunset/plaque/sewer
	name = "sewer plaque"
	icon_state = "vault_sewer"

/obj/structure/fluff/walldeco/sunset/plaque/store
	name = "store plaque"
	icon_state = "vault_store"

/obj/structure/fluff/walldeco/sunset/plaque/tech
	name = "tech plaque"
	icon_state = "vault_tech"

/obj/structure/fluff/walldeco/sunset/plaque/toilet
	name = "toilet plaque"
	icon_state = "vault_toilet"

/obj/structure/fluff/walldeco/sunset/plaque/toxins
	name = "toxins plaque"
	icon_state = "vault_toxins"

/obj/structure/fluff/walldeco/sunset/plaque/track
	name = "track plaque"
	icon_state = "vault_track"

/obj/structure/fluff/walldeco/sunset/plaque/tunnel
	name = "tunnel plaque"
	icon_state = "vault_tunnel"

/obj/structure/fluff/walldeco/sunset/plaque/zone
	name = "zone plaque"
	icon_state = "vault_zone"

/obj/structure/fluff/walldeco/sunset/banner
	name = "faded banner"
	icon_state = "flag_ncr"

/obj/structure/fluff/walldeco/sunset/hazard/fire
	name = "fire hazard sign"
	icon_state = "fire"

/obj/structure/fluff/walldeco/sunset/hazard/biohazard
	name = "biohazard sign"
	icon_state = "biohaz"

/obj/structure/fluff/walldeco/sunset/hazard/warning
	name = "warning sign"
	icon_state = "warn"

/obj/structure/fluff/walldeco/sunset/hazard/no_smoking
	name = "no smoking sign"
	icon_state = "smokeold"

/obj/structure/fluff/walldeco/sunset/hazard/watched
	name = "watchful eye sign"
	icon_state = "cctv"

/obj/structure/fluff/walldeco/sunset/hazard/rail
	name = "railway sign"
	icon_state = "train"

/obj/structure/fluff/walldeco/sunset/hazard/shock
	name = "lightning sign"
	icon_state = "shock"

/obj/structure/fluff/walldeco/sunset/block
	name = "block sign"
	icon_state = "cells"

//Small wall damage.

/obj/structure/fluff/walldeco/sunset/mark/dent
	name = "dent"
	icon_state = "dent"

/obj/structure/fluff/walldeco/sunset/mark/bhole
	name = "bullet hole"
	icon_state = "bhole"

/obj/structure/fluff/walldeco/sunset/mark/bhole_small
	name = "bullet hole"
	icon_state = "bhole-small"

/obj/structure/fluff/walldeco/sunset/mark/bhole_staple
	name = "bullet hole"
	icon_state = "bhole-staple"

/obj/structure/fluff/walldeco/sunset/mark/bhole_medium
	name = "bullet hole"
	icon_state = "bhole-medium"

/obj/structure/fluff/walldeco/sunset/mark/bhole_large
	name = "bullet hole"
	icon_state = "bhole-large"

/obj/structure/fluff/walldeco/sunset/mark/burn1
	name = "scorch mark"
	icon_state = "burn1"

/obj/structure/fluff/walldeco/sunset/mark/burn2
	name = "scorch mark"
	icon_state = "burn2"

//Old-world department and safety signs.

/obj/structure/fluff/walldeco/sunset/department/doors
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "doors"

/obj/structure/fluff/walldeco/sunset/department/space
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "space"

/obj/structure/fluff/walldeco/sunset/department/deathsposal
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "deathsposal"

/obj/structure/fluff/walldeco/sunset/department/pods
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "pods"

/obj/structure/fluff/walldeco/sunset/department/evac
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "evac"

/obj/structure/fluff/walldeco/sunset/department/custodian
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "custodian"

/obj/structure/fluff/walldeco/sunset/department/engine
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "engine"

/obj/structure/fluff/walldeco/sunset/department/cargo
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "cargo"

/obj/structure/fluff/walldeco/sunset/department/security
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "security"

/obj/structure/fluff/walldeco/sunset/department/holy
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "holy"

/obj/structure/fluff/walldeco/sunset/department/restroom
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "restroom"

/obj/structure/fluff/walldeco/sunset/department/examroom
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "examroom"

/obj/structure/fluff/walldeco/sunset/department/xenobio
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "xenobio"

/obj/structure/fluff/walldeco/sunset/department/xenobio2
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "xenobio2"

/obj/structure/fluff/walldeco/sunset/department/science1
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "science1"

/obj/structure/fluff/walldeco/sunset/department/science2
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "science2"

/obj/structure/fluff/walldeco/sunset/department/chemistry1
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "chemistry1"

/obj/structure/fluff/walldeco/sunset/department/chemistry2
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "chemistry2"

/obj/structure/fluff/walldeco/sunset/department/hydro1
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "hydro1"

/obj/structure/fluff/walldeco/sunset/department/hydro2
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "hydro2"

/obj/structure/fluff/walldeco/sunset/department/hydro3
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "hydro3"

/obj/structure/fluff/walldeco/sunset/department/bodysposal
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "bodysposal"

/obj/structure/fluff/walldeco/sunset/department/testchamber
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "testchamber"

/obj/structure/fluff/walldeco/sunset/department/firingrange
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "firingrange"

/obj/structure/fluff/walldeco/sunset/department/cold
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "cold"

/obj/structure/fluff/walldeco/sunset/department/heat
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "heat"

/obj/structure/fluff/walldeco/sunset/department/gasmask
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "gasmask"

/obj/structure/fluff/walldeco/sunset/department/mait1
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "mait1"

/obj/structure/fluff/walldeco/sunset/department/mait2
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "mait2"

/obj/structure/fluff/walldeco/sunset/department/nanites
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanites"

/obj/structure/fluff/walldeco/sunset/department/psychology
	name = "department sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "psychology"

/obj/structure/fluff/walldeco/sunset/misc/bio
	name = "biohazard sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "bio"

/obj/structure/fluff/walldeco/sunset/misc/fire
	name = "fire hazard sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "fire"

/obj/structure/fluff/walldeco/sunset/misc/nosmoking
	name = "no smoking sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nosmoking"

/obj/structure/fluff/walldeco/sunset/misc/nosmoking2
	name = "no smoking sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nosmoking2"

/obj/structure/fluff/walldeco/sunset/misc/securearea
	name = "warning sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "securearea"

/obj/structure/fluff/walldeco/sunset/misc/shock
	name = "lightning sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "shock"

/obj/structure/fluff/walldeco/sunset/misc/radiation
	name = "trefoil sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "radiation"

/obj/structure/fluff/walldeco/sunset/misc/explosives
	name = "explosives sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "explosives"

/obj/structure/fluff/walldeco/sunset/misc/explosives2
	name = "explosives sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "explosives2"

/obj/structure/fluff/walldeco/sunset/misc/chemdiamond
	name = "hazard diamond"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "chemdiamond"

/obj/structure/fluff/walldeco/sunset/misc/bluecross
	name = "medical sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "bluecross"

/obj/structure/fluff/walldeco/sunset/misc/bluecross2
	name = "medical sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "bluecross2"

/obj/structure/fluff/walldeco/sunset/misc/safety
	name = "safety poster"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "safety"

/obj/structure/fluff/walldeco/sunset/misc/monkey_painting
	name = "small painting"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "monkey_painting"

/obj/structure/fluff/walldeco/sunset/misc/frame_empty
	name = "empty frame"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "frame-empty"

/obj/structure/fluff/walldeco/sunset/misc/goldenplaque
	name = "brass plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "goldenplaque"

/obj/structure/fluff/walldeco/sunset/misc/atmosplaque
	name = "brass plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "atmosplaque"

/obj/structure/fluff/walldeco/sunset/misc/vaultplaque
	name = "brass plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "vaultplaque"

/obj/structure/fluff/walldeco/sunset/misc/kiddieplaque
	name = "plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "kiddieplaque"

/obj/structure/fluff/walldeco/sunset/misc/nanotrasen
	name = "company emblem"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanotrasen"

/obj/structure/fluff/walldeco/sunset/misc/pad_nw
	name = "pad sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "pad_nw"

/obj/structure/fluff/walldeco/sunset/misc/pad_ne
	name = "pad sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "pad_ne"

/obj/structure/fluff/walldeco/sunset/misc/pad_s
	name = "pad sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "pad_s"

/obj/structure/fluff/walldeco/sunset/misc/roomnum
	name = "room number"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "roomnum"

/obj/structure/fluff/walldeco/sunset/misc/dormnum
	name = "dorm number"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "dormnum"

/obj/structure/fluff/walldeco/sunset/misc/cellnum
	name = "cell number"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "cellnum"

/obj/structure/fluff/walldeco/sunset/direction/eng
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_eng"

/obj/structure/fluff/walldeco/sunset/direction/supply
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_supply"

/obj/structure/fluff/walldeco/sunset/direction/sci
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_sci"

/obj/structure/fluff/walldeco/sunset/direction/sec
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_sec"

/obj/structure/fluff/walldeco/sunset/direction/med
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_med"

/obj/structure/fluff/walldeco/sunset/direction/evac
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_evac"

/obj/structure/fluff/walldeco/sunset/direction/bridge
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_bridge"

/obj/structure/fluff/walldeco/sunset/direction/vault
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_vault"

/obj/structure/fluff/walldeco/sunset/direction/upload
	name = "directional sign"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "direction_upload"

/obj/structure/fluff/walldeco/sunset/map/left
	name = "old map"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "map-left"

/obj/structure/fluff/walldeco/sunset/map/right
	name = "old map"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "map-right"

/obj/structure/fluff/walldeco/sunset/map/left_ms
	name = "old map"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "map-left-MS"

/obj/structure/fluff/walldeco/sunset/map/right_ms
	name = "old map"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "map-right-MS"

/obj/structure/fluff/walldeco/sunset/map/pubby
	name = "old map"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "map-pubby"

/obj/structure/fluff/walldeco/sunset/map/cs
	name = "old map"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "map-CS"

/obj/structure/fluff/walldeco/sunset/company_banner/num_1
	name = "company banner"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanotrasen_sign1"

/obj/structure/fluff/walldeco/sunset/company_banner/num_2
	name = "company banner"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanotrasen_sign2"

/obj/structure/fluff/walldeco/sunset/company_banner/num_3
	name = "company banner"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanotrasen_sign3"

/obj/structure/fluff/walldeco/sunset/company_banner/num_4
	name = "company banner"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanotrasen_sign4"

/obj/structure/fluff/walldeco/sunset/company_banner/num_5
	name = "company banner"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "nanotrasen_sign5"

/obj/structure/fluff/walldeco/sunset/office_plaque/rep
	name = "office plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "ncr_rep"

/obj/structure/fluff/walldeco/sunset/office_plaque/lt
	name = "office plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "ncr_lt"

/obj/structure/fluff/walldeco/sunset/office_plaque/cpt
	name = "office plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "ncr_cpt"

/obj/structure/fluff/walldeco/sunset/office_plaque/lo
	name = "office plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "ncr_lo"

/obj/structure/fluff/walldeco/sunset/office_plaque/sea
	name = "office plaque"
	icon = 'modular_paragon/sunset_decor/icons/signs.dmi'
	icon_state = "ncr_sea"

//==================== FLOOR DECALS ====================
//Turf decals bake into the floor and only need a type and icon_state.
/obj/effect/turf_decal/sunset/wasteland/bigstripe
	icon_state = "bigstripe"

/obj/effect/turf_decal/sunset/wasteland/bigstripe_corner
	icon_state = "bigstripe-corner"

/obj/effect/turf_decal/sunset/wasteland/bigstripe_corner2
	icon_state = "bigstripe-corner2"

/obj/effect/turf_decal/sunset/wasteland/bigstripe_edge
	icon_state = "bigstripe-edge"

/obj/effect/turf_decal/sunset/wasteland/bigstripe_edge2
	icon_state = "bigstripe-edge2"

/obj/effect/turf_decal/sunset/wasteland/bigstripe_edge3
	icon_state = "bigstripe-edge3"

/obj/effect/turf_decal/sunset/wasteland/bigstripe2
	icon_state = "bigstripe2"

/obj/effect/turf_decal/sunset/wasteland/bot
	icon_state = "bot"

/obj/effect/turf_decal/sunset/wasteland/delivery
	icon_state = "delivery"

/obj/effect/turf_decal/sunset/wasteland/direction
	icon_state = "direction"

/obj/effect/turf_decal/sunset/wasteland/dottedhorizontal
	icon_state = "dottedhorizontal"

/obj/effect/turf_decal/sunset/wasteland/dottedhorizontalcorroded
	icon_state = "dottedhorizontalcorroded"

/obj/effect/turf_decal/sunset/wasteland/dottedhorizontaldegraded
	icon_state = "dottedhorizontaldegraded"

/obj/effect/turf_decal/sunset/wasteland/dottedvertical
	icon_state = "dottedvertical"

/obj/effect/turf_decal/sunset/wasteland/dottedverticalcorroded
	icon_state = "dottedverticalcorroded"

/obj/effect/turf_decal/sunset/wasteland/dottedverticaldegraded
	icon_state = "dottedverticaldegraded"

/obj/effect/turf_decal/sunset/wasteland/doublehorizontal
	icon_state = "doublehorizontal"

/obj/effect/turf_decal/sunset/wasteland/doublehorizontalcorroded
	icon_state = "doublehorizontalcorroded"

/obj/effect/turf_decal/sunset/wasteland/doublehorizontaldegraded
	icon_state = "doublehorizontaldegraded"

/obj/effect/turf_decal/sunset/wasteland/doublehorizontalleft
	icon_state = "doublehorizontalleft"

/obj/effect/turf_decal/sunset/wasteland/doublehorizontalright
	icon_state = "doublehorizontalright"

/obj/effect/turf_decal/sunset/wasteland/doublevertical
	icon_state = "doublevertical"

/obj/effect/turf_decal/sunset/wasteland/doubleverticalbottom
	icon_state = "doubleverticalbottom"

/obj/effect/turf_decal/sunset/wasteland/doubleverticalcorroded
	icon_state = "doubleverticalcorroded"

/obj/effect/turf_decal/sunset/wasteland/doubleverticaldegraded
	icon_state = "doubleverticaldegraded"

/obj/effect/turf_decal/sunset/wasteland/doubleverticaltop
	icon_state = "doubleverticaltop"

/obj/effect/turf_decal/sunset/wasteland/goo1
	icon_state = "goo1"

/obj/effect/turf_decal/sunset/wasteland/goo10
	icon_state = "goo10"

/obj/effect/turf_decal/sunset/wasteland/goo11
	icon_state = "goo11"

/obj/effect/turf_decal/sunset/wasteland/goo12
	icon_state = "goo12"

/obj/effect/turf_decal/sunset/wasteland/goo13
	icon_state = "goo13"

/obj/effect/turf_decal/sunset/wasteland/goo2
	icon_state = "goo2"

/obj/effect/turf_decal/sunset/wasteland/goo3
	icon_state = "goo3"

/obj/effect/turf_decal/sunset/wasteland/goo4
	icon_state = "goo4"

/obj/effect/turf_decal/sunset/wasteland/goo5
	icon_state = "goo5"

/obj/effect/turf_decal/sunset/wasteland/goo6
	icon_state = "goo6"

/obj/effect/turf_decal/sunset/wasteland/goo7
	icon_state = "goo7"

/obj/effect/turf_decal/sunset/wasteland/goo8
	icon_state = "goo8"

/obj/effect/turf_decal/sunset/wasteland/goo9
	icon_state = "goo9"

/obj/effect/turf_decal/sunset/wasteland/hatch
	icon_state = "hatch"

/obj/effect/turf_decal/sunset/wasteland/hatchbroken
	icon_state = "hatchbroken"

/obj/effect/turf_decal/sunset/wasteland/light_scorch
	icon_state = "light_scorch"

/obj/effect/turf_decal/sunset/wasteland/overlap
	icon_state = "overlap"

/obj/effect/turf_decal/sunset/wasteland/overlapcorner
	icon_state = "overlapcorner"

/obj/effect/turf_decal/sunset/wasteland/overlapcornershade
	icon_state = "overlapcornershade"

/obj/effect/turf_decal/sunset/wasteland/overlapdouble
	icon_state = "overlapdouble"

/obj/effect/turf_decal/sunset/wasteland/overlaptriple
	icon_state = "overlaptriple"

/obj/effect/turf_decal/sunset/wasteland/pit
	icon_state = "pit"

/obj/effect/turf_decal/sunset/wasteland/reflectorhorizontal
	icon_state = "reflectorhorizontal"

/obj/effect/turf_decal/sunset/wasteland/reflectorvertical
	icon_state = "reflectorvertical"

/obj/effect/turf_decal/sunset/wasteland/riverbank
	icon_state = "riverbank"

/obj/effect/turf_decal/sunset/wasteland/riverbank2
	icon_state = "riverbank2"

/obj/effect/turf_decal/sunset/wasteland/scorch
	icon_state = "scorch"

/obj/effect/turf_decal/sunset/wasteland/singlevertical
	icon_state = "singlevertical"

/obj/effect/turf_decal/sunset/wasteland/singleverticalbottom
	icon_state = "singleverticalbottom"

/obj/effect/turf_decal/sunset/wasteland/singleverticaltop
	icon_state = "singleverticaltop"

/obj/effect/turf_decal/sunset/wasteland/stones
	icon_state = "stones"

/obj/effect/turf_decal/sunset/wasteland/stripe
	icon_state = "stripe"

/obj/effect/turf_decal/sunset/wasteland/stripe_edge
	icon_state = "stripe-edge"

/obj/effect/turf_decal/sunset/wasteland/stripe_edge2
	icon_state = "stripe-edge2"

/obj/effect/turf_decal/sunset/wasteland/stripe2
	icon_state = "stripe2"

/obj/effect/turf_decal/sunset/wasteland/ventblue
	icon_state = "ventblue"

/obj/effect/turf_decal/sunset/wasteland/ventorange
	icon_state = "ventorange"

/obj/effect/turf_decal/sunset/wasteland/ventred
	icon_state = "ventred"

/obj/effect/turf_decal/sunset/wasteland/ventrusty
	icon_state = "ventrusty"

/obj/effect/turf_decal/sunset/wasteland/ventrustyalt
	icon_state = "ventrustyalt"

/obj/effect/turf_decal/sunset/wasteland/warningline
	icon_state = "warningline"

/obj/effect/turf_decal/sunset/wasteland/warninglinecorners
	icon_state = "warninglinecorners"

/obj/effect/turf_decal/sunset/wasteland/xmas
	icon_state = "xmas"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe
	icon_state = "xtra_bigstripe"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe_corner
	icon_state = "xtra_bigstripe-corner"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe_corner2
	icon_state = "xtra_bigstripe-corner2"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe_edge
	icon_state = "xtra_bigstripe-edge"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe_edge2
	icon_state = "xtra_bigstripe-edge2"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe_edge3
	icon_state = "xtra_bigstripe-edge3"

/obj/effect/turf_decal/sunset/wasteland/xtra_bigstripe2
	icon_state = "xtra_bigstripe2"

//Floor markings.

/obj/effect/turf_decal/sunset/marking/aop1
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP1"

/obj/effect/turf_decal/sunset/marking/aop2
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP2"

/obj/effect/turf_decal/sunset/marking/aop3
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP3"

/obj/effect/turf_decal/sunset/marking/aop4
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP4"

/obj/effect/turf_decal/sunset/marking/aop5
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP5"

/obj/effect/turf_decal/sunset/marking/aop6
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP6"

/obj/effect/turf_decal/sunset/marking/aop7
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOP7"

/obj/effect/turf_decal/sunset/marking/aopu1
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU1"

/obj/effect/turf_decal/sunset/marking/aopu2
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU2"

/obj/effect/turf_decal/sunset/marking/aopu3
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU3"

/obj/effect/turf_decal/sunset/marking/aopu4
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU4"

/obj/effect/turf_decal/sunset/marking/aopu5
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU5"

/obj/effect/turf_decal/sunset/marking/aopu6
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU6"

/obj/effect/turf_decal/sunset/marking/aopu7
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "AOPU7"

/obj/effect/turf_decal/sunset/marking/l1
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L1"

/obj/effect/turf_decal/sunset/marking/l10
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L10"

/obj/effect/turf_decal/sunset/marking/l11
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L11"

/obj/effect/turf_decal/sunset/marking/l12
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L12"

/obj/effect/turf_decal/sunset/marking/l13
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L13"

/obj/effect/turf_decal/sunset/marking/l14
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L14"

/obj/effect/turf_decal/sunset/marking/l2
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L2"

/obj/effect/turf_decal/sunset/marking/l3
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L3"

/obj/effect/turf_decal/sunset/marking/l4
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L4"

/obj/effect/turf_decal/sunset/marking/l5
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L5"

/obj/effect/turf_decal/sunset/marking/l6
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L6"

/obj/effect/turf_decal/sunset/marking/l7
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L7"

/obj/effect/turf_decal/sunset/marking/l8
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L8"

/obj/effect/turf_decal/sunset/marking/l9
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "L9"

/obj/effect/turf_decal/sunset/marking/sbc1
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC1"

/obj/effect/turf_decal/sunset/marking/sbc10
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC10"

/obj/effect/turf_decal/sunset/marking/sbc2
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC2"

/obj/effect/turf_decal/sunset/marking/sbc3
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC3"

/obj/effect/turf_decal/sunset/marking/sbc4
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC4"

/obj/effect/turf_decal/sunset/marking/sbc5
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC5"

/obj/effect/turf_decal/sunset/marking/sbc6
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC6"

/obj/effect/turf_decal/sunset/marking/sbc7
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC7"

/obj/effect/turf_decal/sunset/marking/sbc8
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC8"

/obj/effect/turf_decal/sunset/marking/sbc9
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "SBC9"

/obj/effect/turf_decal/sunset/marking/arrows
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "arrows"

/obj/effect/turf_decal/sunset/marking/arrows_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "arrows_red"

/obj/effect/turf_decal/sunset/marking/arrows_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "arrows_white"

/obj/effect/turf_decal/sunset/marking/ast_warn
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "ast_warn"

/obj/effect/turf_decal/sunset/marking/ast_warn_box
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "ast_warn_box"

/obj/effect/turf_decal/sunset/marking/ast_warn_corner
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "ast_warn_corner"

/obj/effect/turf_decal/sunset/marking/ast_warn_end
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "ast_warn_end"

/obj/effect/turf_decal/sunset/marking/ast_warn_full
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "ast_warn_full"

/obj/effect/turf_decal/sunset/marking/bot
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot"

/obj/effect/turf_decal/sunset/marking/bot_left
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_left"

/obj/effect/turf_decal/sunset/marking/bot_left_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_left_red"

/obj/effect/turf_decal/sunset/marking/bot_left_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_left_white"

/obj/effect/turf_decal/sunset/marking/bot_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_red"

/obj/effect/turf_decal/sunset/marking/bot_right
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_right"

/obj/effect/turf_decal/sunset/marking/bot_right_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_right_red"

/obj/effect/turf_decal/sunset/marking/bot_right_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_right_white"

/obj/effect/turf_decal/sunset/marking/bot_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "bot_white"

/obj/effect/turf_decal/sunset/marking/box
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "box"

/obj/effect/turf_decal/sunset/marking/box_corners
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "box_corners"

/obj/effect/turf_decal/sunset/marking/box_corners_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "box_corners_red"

/obj/effect/turf_decal/sunset/marking/box_corners_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "box_corners_white"

/obj/effect/turf_decal/sunset/marking/box_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "box_red"

/obj/effect/turf_decal/sunset/marking/box_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "box_white"

/obj/effect/turf_decal/sunset/marking/caution
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "caution"

/obj/effect/turf_decal/sunset/marking/caution_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "caution_red"

/obj/effect/turf_decal/sunset/marking/caution_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "caution_white"

/obj/effect/turf_decal/sunset/marking/corner_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "corner_white"

/obj/effect/turf_decal/sunset/marking/corner_white_diagonal
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "corner_white_diagonal"

/obj/effect/turf_decal/sunset/marking/corner_white_full
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "corner_white_full"

/obj/effect/turf_decal/sunset/marking/corner_white_side
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "corner_white_side"

/obj/effect/turf_decal/sunset/marking/delivery
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "delivery"

/obj/effect/turf_decal/sunset/marking/delivery_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "delivery_red"

/obj/effect/turf_decal/sunset/marking/delivery_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "delivery_white"

/obj/effect/turf_decal/sunset/marking/derelict1
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict1"

/obj/effect/turf_decal/sunset/marking/derelict10
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict10"

/obj/effect/turf_decal/sunset/marking/derelict11
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict11"

/obj/effect/turf_decal/sunset/marking/derelict12
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict12"

/obj/effect/turf_decal/sunset/marking/derelict13
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict13"

/obj/effect/turf_decal/sunset/marking/derelict14
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict14"

/obj/effect/turf_decal/sunset/marking/derelict15
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict15"

/obj/effect/turf_decal/sunset/marking/derelict16
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict16"

/obj/effect/turf_decal/sunset/marking/derelict2
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict2"

/obj/effect/turf_decal/sunset/marking/derelict3
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict3"

/obj/effect/turf_decal/sunset/marking/derelict4
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict4"

/obj/effect/turf_decal/sunset/marking/derelict5
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict5"

/obj/effect/turf_decal/sunset/marking/derelict6
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict6"

/obj/effect/turf_decal/sunset/marking/derelict7
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict7"

/obj/effect/turf_decal/sunset/marking/derelict8
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict8"

/obj/effect/turf_decal/sunset/marking/derelict9
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "derelict9"

/obj/effect/turf_decal/sunset/marking/dirt_side
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "dirt_side"

/obj/effect/turf_decal/sunset/marking/loadingarea
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "loadingarea"

/obj/effect/turf_decal/sunset/marking/loadingarea_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "loadingarea_red"

/obj/effect/turf_decal/sunset/marking/loadingarea_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "loadingarea_white"

/obj/effect/turf_decal/sunset/marking/plaque
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "plaque"

/obj/effect/turf_decal/sunset/marking/sandyfloor
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "sandyfloor"

/obj/effect/turf_decal/sunset/marking/sandyplating
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "sandyplating"

/obj/effect/turf_decal/sunset/marking/stand_clear
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "stand_clear"

/obj/effect/turf_decal/sunset/marking/stand_clear_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "stand_clear_red"

/obj/effect/turf_decal/sunset/marking/stand_clear_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "stand_clear_white"

/obj/effect/turf_decal/sunset/marking/tile_corner
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "tile_corner"

/obj/effect/turf_decal/sunset/marking/trimline
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline"

/obj/effect/turf_decal/sunset/marking/trimline_box
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_box"

/obj/effect/turf_decal/sunset/marking/trimline_box_fill
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/sunset/marking/trimline_corner
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_corner"

/obj/effect/turf_decal/sunset/marking/trimline_corner_fill
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/sunset/marking/trimline_end
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_end"

/obj/effect/turf_decal/sunset/marking/trimline_end_fill
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/sunset/marking/trimline_fill
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "trimline_fill"

/obj/effect/turf_decal/sunset/marking/warn_box
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_box"

/obj/effect/turf_decal/sunset/marking/warn_box_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_box_red"

/obj/effect/turf_decal/sunset/marking/warn_box_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_box_white"

/obj/effect/turf_decal/sunset/marking/warn_end
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_end"

/obj/effect/turf_decal/sunset/marking/warn_end_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_end_red"

/obj/effect/turf_decal/sunset/marking/warn_end_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_end_white"

/obj/effect/turf_decal/sunset/marking/warn_full
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_full"

/obj/effect/turf_decal/sunset/marking/warn_full_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_full_red"

/obj/effect/turf_decal/sunset/marking/warn_full_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warn_full_white"

/obj/effect/turf_decal/sunset/marking/warningline
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warningline"

/obj/effect/turf_decal/sunset/marking/warningline_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warningline_red"

/obj/effect/turf_decal/sunset/marking/warningline_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warningline_white"

/obj/effect/turf_decal/sunset/marking/warninglinecorner
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warninglinecorner"

/obj/effect/turf_decal/sunset/marking/warninglinecorner_red
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warninglinecorner_red"

/obj/effect/turf_decal/sunset/marking/warninglinecorner_white
	icon = 'modular_paragon/sunset_decor/icons/floor_decals.dmi'
	icon_state = "warninglinecorner_white"

//Painted floor lettering.

/obj/effect/turf_decal/sunset/lettering/num_0
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "0"

/obj/effect/turf_decal/sunset/lettering/num_1
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "1"

/obj/effect/turf_decal/sunset/lettering/num_2
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "2"

/obj/effect/turf_decal/sunset/lettering/num_3
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "3"

/obj/effect/turf_decal/sunset/lettering/num_4
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "4"

/obj/effect/turf_decal/sunset/lettering/num_5
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "5"

/obj/effect/turf_decal/sunset/lettering/num_6
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "6"

/obj/effect/turf_decal/sunset/lettering/num_7
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "7"

/obj/effect/turf_decal/sunset/lettering/num_8
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "8"

/obj/effect/turf_decal/sunset/lettering/num_9
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "9"

/obj/effect/turf_decal/sunset/lettering/air
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "air"

/obj/effect/turf_decal/sunset/lettering/bar
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "bar"

/obj/effect/turf_decal/sunset/lettering/carbon_dioxide
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "carbon_dioxide"

/obj/effect/turf_decal/sunset/lettering/cargo
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "cargo"

/obj/effect/turf_decal/sunset/lettering/hop
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "hop"

/obj/effect/turf_decal/sunset/lettering/med
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "med"

/obj/effect/turf_decal/sunset/lettering/mine
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "mine"

/obj/effect/turf_decal/sunset/lettering/mix
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "mix"

/obj/effect/turf_decal/sunset/lettering/nitrogen
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "nitrogen"

/obj/effect/turf_decal/sunset/lettering/nitrous_oxide
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "nitrous_oxide"

/obj/effect/turf_decal/sunset/lettering/no
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "no"

/obj/effect/turf_decal/sunset/lettering/oxygen
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "oxygen"

/obj/effect/turf_decal/sunset/lettering/plasma
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "plasma"

/obj/effect/turf_decal/sunset/lettering/radiation
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "radiation"

/obj/effect/turf_decal/sunset/lettering/radiation_w
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "radiation-w"

/obj/effect/turf_decal/sunset/lettering/radiation_huge
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "radiation_huge"

/obj/effect/turf_decal/sunset/lettering/sci
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "sci"

/obj/effect/turf_decal/sunset/lettering/sec
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "sec"

/obj/effect/turf_decal/sunset/lettering/zoo
	icon = 'modular_paragon/sunset_decor/icons/floor_decals_vg.dmi'
	icon_state = "zoo"

//==================== AIRLOCKS ====================
//Every door has /open, /welded and /bolted variants.
/obj/structure/fluff/sunset/airlock/alien
	name = "alien door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/abductor/abductor_airlock.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/abductor/overlays.dmi'

/obj/structure/fluff/sunset/airlock/alien/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/alien/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/alien/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/secure
	name = "secure door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/centcom/centcom.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/centcom/overlays.dmi'

/obj/structure/fluff/sunset/airlock/secure/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/secure/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/secure/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/bronze
	name = "bronze door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/clockwork/pinion_airlock.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/clockwork/overlays.dmi'

/obj/structure/fluff/sunset/airlock/bronze/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/bronze/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/bronze/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/runed
	name = "runed door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/cult/runed/cult.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/cult/runed/overlays.dmi'

/obj/structure/fluff/sunset/airlock/runed/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/runed/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/runed/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/dark
	name = "dark metal door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/cult/unruned/cult.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/cult/unruned/overlays.dmi'

/obj/structure/fluff/sunset/airlock/dark/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/dark/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/dark/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/external
	name = "external door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/external/external.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/external/overlays.dmi'

/obj/structure/fluff/sunset/airlock/external/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/external/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/external/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/wide_glass
	name = "wide glass door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/glass_large/glass_large.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/glass_large/overlays.dmi'
	opacity = FALSE

/obj/structure/fluff/sunset/airlock/wide_glass/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/wide_glass/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/wide_glass/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/hatch
	name = "hatch"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/hatch/maintenance.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/hatch/overlays.dmi'

/obj/structure/fluff/sunset/airlock/hatch/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/hatch/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/hatch/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/hatch/secure
	name = "secure hatch"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/hatch/centcom.dmi'

/obj/structure/fluff/sunset/airlock/hatch/secure/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/hatch/secure/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/hatch/secure/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/high_security
	name = "high security door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/highsec/highsec.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/highsec/overlays.dmi'

/obj/structure/fluff/sunset/airlock/high_security/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/high_security/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/high_security/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/shuttle
	name = "shuttle door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/shuttle/shuttle.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/shuttle/overlays.dmi'

/obj/structure/fluff/sunset/airlock/shuttle/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/shuttle/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/shuttle/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/glass
	name = "glass door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station2/glass.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/station2/overlays.dmi'
	opacity = FALSE

/obj/structure/fluff/sunset/airlock/glass/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/glass/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/glass/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/survival
	name = "pod door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/survival/survival.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/survival/survival_overlays.dmi'

/obj/structure/fluff/sunset/airlock/survival/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/survival/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/survival/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/survival/horizontal
	icon = 'modular_paragon/sunset_decor/icons/airlocks/survival/horizontal/survival.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/survival/horizontal/survival_overlays.dmi'

/obj/structure/fluff/sunset/airlock/survival/horizontal/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/survival/horizontal/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/survival/horizontal/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/vault
	name = "vault door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/vault/vault.dmi'
	overlay_icon = 'modular_paragon/sunset_decor/icons/airlocks/vault/overlays.dmi'

/obj/structure/fluff/sunset/airlock/vault/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/vault/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/vault/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/atmos
	name = "atmospherics door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/atmos.dmi'

/obj/structure/fluff/sunset/airlock/station/atmos/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/atmos/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/atmos/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/bananium
	name = "bananium door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/bananium.dmi'

/obj/structure/fluff/sunset/airlock/station/bananium/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/bananium/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/bananium/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/command
	name = "command door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/command.dmi'

/obj/structure/fluff/sunset/airlock/station/command/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/command/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/command/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/diamond
	name = "diamond door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/diamond.dmi'

/obj/structure/fluff/sunset/airlock/station/diamond/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/diamond/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/diamond/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/engineering
	name = "engineering door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/engineering.dmi'

/obj/structure/fluff/sunset/airlock/station/engineering/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/engineering/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/engineering/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/freezer
	name = "freezer door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/freezer.dmi'

/obj/structure/fluff/sunset/airlock/station/freezer/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/freezer/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/freezer/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/gold
	name = "gold door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/gold.dmi'

/obj/structure/fluff/sunset/airlock/station/gold/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/gold/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/gold/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/maintenance
	name = "maintenance door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/maintenance.dmi'

/obj/structure/fluff/sunset/airlock/station/maintenance/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/maintenance/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/maintenance/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/maintenanceexternal
	name = "external maintenance door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/maintenanceexternal.dmi'

/obj/structure/fluff/sunset/airlock/station/maintenanceexternal/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/maintenanceexternal/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/maintenanceexternal/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/medical
	name = "medical door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/medical.dmi'

/obj/structure/fluff/sunset/airlock/station/medical/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/medical/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/medical/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/mining
	name = "mining door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/mining.dmi'

/obj/structure/fluff/sunset/airlock/station/mining/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/mining/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/mining/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/plasma
	name = "plasma door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/plasma.dmi'

/obj/structure/fluff/sunset/airlock/station/plasma/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/plasma/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/plasma/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/public
	name = "public door"

/obj/structure/fluff/sunset/airlock/station/public/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/public/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/public/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/research
	name = "research door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/research.dmi'

/obj/structure/fluff/sunset/airlock/station/research/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/research/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/research/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/sandstone
	name = "sandstone door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/sandstone.dmi'

/obj/structure/fluff/sunset/airlock/station/sandstone/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/sandstone/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/sandstone/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/science
	name = "science door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/science.dmi'

/obj/structure/fluff/sunset/airlock/station/science/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/science/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/science/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/security
	name = "security door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/security.dmi'

/obj/structure/fluff/sunset/airlock/station/security/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/security/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/security/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/silver
	name = "silver door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/silver.dmi'

/obj/structure/fluff/sunset/airlock/station/silver/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/silver/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/silver/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/uranium
	name = "uranium door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/uranium.dmi'

/obj/structure/fluff/sunset/airlock/station/uranium/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/uranium/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/uranium/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/virology
	name = "virology door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/virology.dmi'

/obj/structure/fluff/sunset/airlock/station/virology/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/virology/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/virology/bolted
	door_state = SUNSET_DOOR_BOLTED

/obj/structure/fluff/sunset/airlock/station/wood
	name = "wooden door"
	icon = 'modular_paragon/sunset_decor/icons/airlocks/station/wood.dmi'

/obj/structure/fluff/sunset/airlock/station/wood/open
	icon_state = "open"
	door_state = SUNSET_DOOR_OPEN

/obj/structure/fluff/sunset/airlock/station/wood/welded
	door_state = SUNSET_DOOR_WELDED

/obj/structure/fluff/sunset/airlock/station/wood/bolted
	door_state = SUNSET_DOOR_BOLTED

//==================== WINDOWS ====================
/obj/structure/fluff/sunset/window/glass
	name = "window"
	icon = 'modular_paragon/sunset_decor/icons/windows/window.dmi'
	icon_state = "window"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/reinforced
	name = "reinforced window"
	icon = 'modular_paragon/sunset_decor/icons/windows/reinforced_window.dmi'
	icon_state = "r_window"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/tinted
	name = "tinted window"
	icon = 'modular_paragon/sunset_decor/icons/windows/tinted_window.dmi'
	icon_state = "tinted_window"
	smooth = SMOOTH_TRUE
	opacity = TRUE

/obj/structure/fluff/sunset/window/violet
	name = "violet window"
	icon = 'modular_paragon/sunset_decor/icons/windows/plasma_window.dmi'
	icon_state = "plasmawindow"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/violet/reinforced
	name = "reinforced violet window"
	icon = 'modular_paragon/sunset_decor/icons/windows/rplasma_window.dmi'
	icon_state = "rplasmawindow"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/plastitanium
	name = "armoured window"
	icon = 'modular_paragon/sunset_decor/icons/windows/plastitanium_window.dmi'
	icon_state = "plastitanium_window"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/shuttle
	name = "shuttle window"
	icon = 'modular_paragon/sunset_decor/icons/windows/shuttle_window.dmi'
	icon_state = "shuttle_window"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/pod
	name = "pod window"
	icon = 'modular_paragon/sunset_decor/icons/windows/pod_window.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/frosted
	name = "frosted window"
	icon = 'modular_paragon/sunset_decor/icons/windows/rice_window.dmi'
	icon_state = "ice_window"
	smooth = SMOOTH_TRUE

/obj/structure/fluff/sunset/window/bronze
	name = "bronze window"
	icon = 'modular_paragon/sunset_decor/icons/windows/clockwork_window.dmi'
	icon_state = "clockwork_window"
	smooth = SMOOTH_TRUE

//Hand-placed window pieces. These don't smooth, so pick the piece that fits.

/obj/structure/fluff/sunset/window/barred
	name = "barred window"
	icon = 'modular_paragon/sunset_decor/icons/windows/fallout_wall_windows.dmi'
	icon_state = "Single"

/obj/structure/fluff/sunset/window/barred/multi
	icon_state = "Multi"

/obj/structure/fluff/sunset/window/barred/multi_middle
	icon_state = "Multi middle"

/obj/structure/fluff/sunset/window/barred/me
	icon_state = "me"

/obj/structure/fluff/sunset/window/barred/mmn
	icon_state = "mmn"

/obj/structure/fluff/sunset/window/barred/mmw
	icon_state = "mmw"

/obj/structure/fluff/sunset/window/barred/mn
	icon_state = "mn"

/obj/structure/fluff/sunset/window/barred/ms
	icon_state = "ms"

/obj/structure/fluff/sunset/window/barred/mw
	icon_state = "mw"

/obj/structure/fluff/sunset/window/housewindow
	name = "house window"
	icon = 'modular_paragon/sunset_decor/icons/windows/wood_window.dmi'
	icon_state = "housewindow"

/obj/structure/fluff/sunset/window/housewindow/broken
	name = "broken house window"
	icon_state = "housewindowbroken"
	climbable = TRUE

/obj/structure/fluff/sunset/window/housewindow/brokenvertical
	name = "broken house window"
	icon_state = "housewindowbrokenvertical"
	climbable = TRUE

/obj/structure/fluff/sunset/window/housewindow/vertical
	icon_state = "housewindowvertical"

/obj/structure/fluff/sunset/window/ruinswindow
	name = "ruined window"
	icon = 'modular_paragon/sunset_decor/icons/windows/wood_window.dmi'
	icon_state = "ruinswindow"

/obj/structure/fluff/sunset/window/ruinswindow/broken
	name = "broken ruined window"
	icon_state = "ruinswindowbroken"
	climbable = TRUE

/obj/structure/fluff/sunset/window/ruinswindow/brokenvertical
	name = "broken ruined window"
	icon_state = "ruinswindowbrokenvertical"
	climbable = TRUE

/obj/structure/fluff/sunset/window/ruinswindow/destroyed
	name = "broken ruined window"
	icon_state = "ruinswindowdestroyed"
	climbable = TRUE

/obj/structure/fluff/sunset/window/ruinswindow/vertical
	icon_state = "ruinswindowvertical"

/obj/structure/fluff/sunset/window/woodwindow
	name = "wooden window"
	icon = 'modular_paragon/sunset_decor/icons/windows/wood_window.dmi'
	icon_state = "woodwindow"

/obj/structure/fluff/sunset/window/woodwindow/broken
	name = "broken wooden window"
	icon_state = "woodwindowbroken"
	climbable = TRUE

/obj/structure/fluff/sunset/window/storewindow
	name = "shop window"
	icon = 'modular_paragon/sunset_decor/icons/windows/wood_window.dmi'
	icon_state = "storewindowbottom"

/obj/structure/fluff/sunset/window/storewindow/bottom
	icon_state = "storewindowbottom"

/obj/structure/fluff/sunset/window/storewindow/horizontal
	icon_state = "storewindowhorizontal"

/obj/structure/fluff/sunset/window/storewindow/left
	icon_state = "storewindowleft"

/obj/structure/fluff/sunset/window/storewindow/right
	icon_state = "storewindowright"

/obj/structure/fluff/sunset/window/storewindow/top
	icon_state = "storewindowtop"

/obj/structure/fluff/sunset/window/storewindow/vertical
	icon_state = "storewindowvertical"

//Thin edge pieces. These block movement across one side of the tile, like a railing.

/obj/structure/fluff/railing/sunset_windoor/left
	name = "glass panel door"
	icon_state = "left"

/obj/structure/fluff/railing/sunset_windoor/left/open
	icon_state = "leftopen"
	blocks_passage = FALSE

/obj/structure/fluff/railing/sunset_windoor/right
	name = "glass panel door"
	icon_state = "right"

/obj/structure/fluff/railing/sunset_windoor/right/open
	icon_state = "rightopen"
	blocks_passage = FALSE

/obj/structure/fluff/railing/sunset_windoor/secure/left
	name = "secure glass panel door"
	icon_state = "leftsecure"

/obj/structure/fluff/railing/sunset_windoor/secure/left/open
	icon_state = "leftsecureopen"
	blocks_passage = FALSE

/obj/structure/fluff/railing/sunset_windoor/secure/right
	name = "secure glass panel door"
	icon_state = "rightsecure"

/obj/structure/fluff/railing/sunset_windoor/secure/right/open
	icon_state = "rightsecureopen"
	blocks_passage = FALSE

/obj/structure/fluff/railing/sunset_windoor/bronze
	name = "bronze panel door"
	icon_state = "clockwork"

/obj/structure/fluff/railing/sunset_windoor/bronze/open
	icon_state = "clockworkopen"
	blocks_passage = FALSE

/obj/structure/fluff/railing/sunset_windoor/shutter
	name = "emergency shutter"
	icon = 'modular_paragon/sunset_decor/icons/doors/doorfirewindow.dmi'
	icon_state = "door_closed"

/obj/structure/fluff/railing/sunset_windoor/shutter/welded
	icon_state = "welded"

/obj/structure/fluff/railing/sunset_windoor/shutter/open
	icon_state = "door_open"
	blocks_passage = FALSE

//Full-tile window shutters.

/obj/structure/fluff/sunset/shutters
	name = "window shutters"
	icon = 'modular_paragon/sunset_decor/icons/doors/shutters_window.dmi'
	icon_state = "closed"
	density = TRUE
	layer = CLOSED_DOOR_LAYER

/obj/structure/fluff/sunset/shutters/open
	name = "open window shutters"
	icon_state = "open"
	density = FALSE
	layer = OPEN_DOOR_LAYER

//Planks nailed over doorways and windows.

/obj/structure/fluff/sunset/boards
	name = "nailed boards"
	icon = 'modular_paragon/sunset_decor/icons/wasteland_decals.dmi'
	icon_state = "board"
	layer = CLOSED_DOOR_LAYER+0.01

/obj/structure/fluff/sunset/boards/num_1
	icon_state = "board-1"

/obj/structure/fluff/sunset/boards/num_2
	icon_state = "board-2"

/obj/structure/fluff/sunset/boards/num_3
	icon_state = "board-3"
