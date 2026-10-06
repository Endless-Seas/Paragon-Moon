//Paragon HUD: a status strip across the top and a column of combat controls down the right of the map, in
//place of the old left-hand panel. The human HUD builds its usual screen objects, then apply_paragon_layout()
//moves them into place. show_hud() puts the intent selector back where it started, so it is applied again there.
//
//Top strip (two rows above the map and the column), read like Qud's:
//  a status line across the full width: name |--| T: temperature :: hunger thirst |--| tags ... time :: place
//  under it on the left, a solid HP bar with its value written inside, and slim segmented stamina and
//  energy gauges below that; on the right, the Equip Pack Skill Stats Craft Lore buttons
//Right column (EAST+1 to EAST+4), from the top:
//  NORTH, NORTH-1        target doll, vitae / devotion, eye, stress
//  NORTH-2               intents
//  NORTH-3               rmb, mmb, defence, combat mode
//  NORTH-4               sneak/sprint, stand/lie, drop/give/throw
//  NORTH-5 to SOUTH+3    ACTIVE EFFECTS: the alert icons, four to a row
//  SOUTH+2               hands
//  SOUTH+1, SOUTH        quickbar
//
//Text is a pixel font after Source Code Pro, the face Qud uses (paragon_text). Bar textures are drawn at runtime (paragon_bar_icons())
//so their troughs take the player's theme colours; the fills use the Qud palette.

//Map shape, in tiles, of this layout: the 15x15 view, four columns to the right and two rows on top
#define PARAGON_HUD_WIDTH 19
#define PARAGON_HUD_HEIGHT 17
//Where the old panel's half-width offset puts the centre of the 15x15 view in this layout
#define PARAGON_VIEW_CENTRE "CENTER+2,CENTER+1"

//The Caves of Qud palette (wiki.cavesofqud.com/wiki/Visual_Style), for the bars and status tags
#define QUD_RED "#d74200"
#define QUD_ORANGE "#e99f10"
#define QUD_GOLD "#cfc041"
#define QUD_GREEN_DARK "#009403"
#define QUD_GREEN "#00c420"
#define QUD_BLUE_DARK "#0048bd"
#define QUD_BLUE "#0096ff"
#define QUD_TEAL "#40a4b9"
#define QUD_CYAN "#77bfcf"
#define QUD_BLACK "#0f3b3a"
#define QUD_GREY "#b1c9c3"
#define QUD_WHITE "#ffffff"
//Where the menu buttons start, and so where the bars end
#define PARAGON_BUTTONS_COLUMN 13
//Map shape of the old left-panel layout, still used by ghosts and other mobs
#define PANEL_HUD_WIDTH 20
#define PANEL_HUD_HEIGHT 15

/datum/hud
	//TRUE for HUDs laid out in top and bottom strips (paragon_hud.dm) instead of the left-hand panel
	var/paragon_layout = FALSE
	var/atom/movable/screen/paragon_strip/strip_top
	var/atom/movable/screen/paragon_strip/strip_bottom
	//Rules and dividers between the strip sections, recoloured with the theme
	var/list/atom/movable/screen/paragon_strip/paragon_rules
	//The status line: name, temperature, hunger and thirst, tags on the left; time and place on the right
	var/atom/movable/screen/paragon_text/label/status_label
	var/atom/movable/screen/paragon_text/label/clock_label
	//Heading over the alert icons in the right-hand column
	var/atom/movable/screen/paragon_text/label/effects_label
	var/atom/movable/screen/paragon_bar/health/hp_bar
	var/atom/movable/screen/paragon_bar/stamina/sta_bar
	var/atom/movable/screen/paragon_bar/energy/en_bar
	var/list/paragon_palette

/datum/hud/human
	paragon_layout = TRUE

//Builds the strips, bars and menu buttons. Called once from the human HUD's New().
/datum/hud/proc/build_paragon_hud()
	strip_top = new(null, "WEST,NORTH+1 to EAST+4,NORTH+2")
	strip_bottom = new(null, "EAST+1,SOUTH to EAST+4,NORTH")
	static_inventory += list(strip_top, strip_bottom)

	paragon_rules = list()
	//Edges: a bright outer line round both, and the lines where they meet the map
	add_paragon_rule("WEST,NORTH+2 to EAST+4,NORTH+2", 31, FALSE, "frame")
	add_paragon_rule("WEST,NORTH+1 to EAST,NORTH+1", 0, FALSE, "frame")
	add_paragon_rule("EAST+1,SOUTH to EAST+1,NORTH", 0, TRUE, "frame")
	add_paragon_rule("EAST+4,SOUTH to EAST+4,NORTH+2", 31, TRUE, "frame")
	add_paragon_rule("EAST+1,SOUTH to EAST+4,SOUTH", 0, FALSE, "frame")
	//Under the status line, and between the bars and the buttons
	add_paragon_rule("WEST,NORTH+2 to EAST+4,NORTH+2", 14, FALSE)
	add_paragon_rule("WEST+[PARAGON_BUTTONS_COLUMN],NORTH+1", 0, TRUE)
	add_paragon_rule("WEST+[PARAGON_BUTTONS_COLUMN],NORTH+1:15", 0, TRUE)
	//Sections of the column
	add_paragon_rule("EAST+1,NORTH+1 to EAST+4,NORTH+1", 0, FALSE)
	add_paragon_rule("EAST+1,NORTH-1 to EAST+4,NORTH-1", 0, FALSE)
	add_paragon_rule("EAST+1,NORTH-4 to EAST+4,NORTH-4", 0, FALSE)
	add_paragon_rule("EAST+1,SOUTH+3 to EAST+4,SOUTH+3", 0, FALSE)

	var/strip_width = PARAGON_HUD_WIDTH * world.icon_size - 12
	status_label = new(null, "WEST:6,NORTH+2:15", strip_width)
	clock_label = new(null, "WEST:6,NORTH+2:15", strip_width)
	effects_label = new(null, "EAST+1:5,NORTH-5:16", 4 * world.icon_size - 10)
	static_inventory += list(status_label, clock_label, effects_label)

	//HP as Qud draws it, a solid bar with the value inside; stamina and energy as slim gauges under it
	var/bars_width = PARAGON_BUTTONS_COLUMN * world.icon_size - 12
	hp_bar = new(null, "WEST:6,NORTH+1", bars_width, 31)
	sta_bar = new(null, "WEST:6,NORTH+1", bars_width, 22)
	en_bar = new(null, "WEST:6,NORTH+1", bars_width, 8)
	for(var/atom/movable/screen/paragon_bar/bar as anything in list(hp_bar, sta_bar, en_bar))
		bar.hud = src
		infodisplay += bar

	var/list/buttons = list(
		/atom/movable/screen/paperdoll_button/equipment,
		/atom/movable/screen/paperdoll_button/inventory,
		/atom/movable/screen/paperdoll_button/skills,
		/atom/movable/screen/paperdoll_button/attributes,
		/atom/movable/screen/craft/paragon,
		/atom/movable/screen/paperdoll_button/compendium,
	)
	var/column = PARAGON_HUD_WIDTH - length(buttons)
	for(var/button_type in buttons)
		var/atom/movable/screen/button = new button_type()
		button.hud = src
		button.screen_loc = "WEST+[column],NORTH+1:12"
		static_inventory += button
		column++

	paragon_recolor()

//A one-pixel line: along the bottom of a tile row ([vertical] FALSE) or down its left edge, moved [offset] pixels
//up or right. Screen objects ignore pixel_x/pixel_y, so the offset goes into the screen_loc.
/datum/hud/proc/add_paragon_rule(new_loc, offset, vertical, colour_key = "line")
	var/atom/movable/screen/paragon_strip/rule/rule = new(null, paragon_offset_loc(new_loc, vertical ? offset : 0, vertical ? 0 : offset))
	rule.colour_key = colour_key
	if(vertical)
		rule.transform = matrix(1 / 32, 0, -15.5, 0, 1, 0)
	paragon_rules += rule
	static_inventory += rule
	return rule

//Moves the existing HUD objects into the strips and hides the ones the bars replace
/datum/hud/proc/apply_paragon_layout()
	if(!paragon_layout)
		return
	zone_select?.screen_loc = "EAST+1,NORTH-1"
	stressies?.screen_loc = "EAST+4,NORTH-1"
	action_intent?.screen_loc = "EAST+1,NORTH-2"
	rmb_intent?.screen_loc = "EAST+1,NORTH-3"
	quad_intents?.screen_loc = "EAST+2,NORTH-3"
	def_intent?.screen_loc = "EAST+3,NORTH-3"
	cmode_button?.screen_loc = "EAST+4,NORTH-3"
	give_intent?.screen_loc = "EAST+3,NORTH-4"
	throw_icon?.screen_loc = "EAST+3,NORTH-4"
	bloodpool?.screen_loc = "EAST+3,NORTH-1"
	for(var/atom/movable/screen/screen_object as anything in static_inventory)
		if(istype(screen_object, /atom/movable/screen/eye_intent))
			screen_object.screen_loc = "EAST+4,NORTH"
		else if(istype(screen_object, /atom/movable/screen/rogmove))
			screen_object.screen_loc = "EAST+1,NORTH-4"
		else if(istype(screen_object, /atom/movable/screen/restup) || istype(screen_object, /atom/movable/screen/restdown))
			screen_object.screen_loc = "EAST+2,NORTH-4"
		else if(istype(screen_object, /atom/movable/screen/drop))
			screen_object.screen_loc = "EAST+3,NORTH-4"
		else if(istype(screen_object, /atom/movable/screen/action_bar/clickdelay/left))
			screen_object.screen_loc = "EAST+2,SOUTH+2"
		else if(istype(screen_object, /atom/movable/screen/action_bar/clickdelay/right))
			screen_object.screen_loc = "EAST+3,SOUTH+2"
		else if(istype(screen_object, /atom/movable/screen/action_bar/clickdelay))
			screen_object.screen_loc = "EAST+2:16,SOUTH+2"
	//The CRT overlay was drawn for the old 20x15 tile box; stretch it over the new 19x17 one
	if(scannies)
		paragon_fit_fullscreen(scannies)
	//These two were offset by half the old panel's width to stay centred on the view; offset them by half
	//of the right-hand column and the top strip instead
	for(var/plane in plane_masters)
		var/atom/movable/screen/plane_master/plane_master = plane_masters[plane]
		if(plane_master.screen_loc == "CENTER-2:-16, CENTER")
			plane_master.screen_loc = PARAGON_VIEW_CENTRE

//Refits a screen-sized overlay made for the old panel layout (640x480 from WEST-5) to the strip layout
/datum/hud/proc/paragon_fit_fullscreen(atom/movable/screen/overlay)
	if(!paragon_layout || !overlay)
		return
	if(overlay.screen_loc == "CENTER-2:-16, CENTER")
		overlay.screen_loc = PARAGON_VIEW_CENTRE
		return
	if(overlay.screen_loc != ui_backhudl && overlay.screen_loc != "WEST,SOUTH")
		return
	var/width = PARAGON_HUD_WIDTH * world.icon_size
	var/height = PARAGON_HUD_HEIGHT * world.icon_size
	overlay.screen_loc = "WEST,SOUTH"
	overlay.transform = matrix(width / 640, 0, (width - 640) / 2, 0, height / 480, (height - 480) / 2)

//Theme colours for the strips and bars, from the player's Paragon theme (preferences_tgui.dm)
/datum/hud/proc/paragon_recolor()
	if(!paragon_layout || !strip_top)
		return
	paragon_palette = GLOB.paragon_theme_palettes[mymob?.client?.prefs?.tgui_theme] || GLOB.paragon_theme_palettes["paragon_classic"]
	strip_top.color = paragon_palette["void"]
	strip_bottom.color = paragon_palette["void"]
	for(var/atom/movable/screen/paragon_strip/rule/rule as anything in paragon_rules)
		rule.color = paragon_palette[rule.colour_key]
	for(var/atom/movable/screen/paragon_bar/bar as anything in list(hp_bar, sta_bar, en_bar))
		bar.set_palette(paragon_palette)
	update_paragon_status()
	update_paragon_effects()

//Refreshes the bars and the status line. Called from update_health_hud().
/datum/hud/proc/update_paragon_status()
	if(!paragon_layout || !hp_bar)
		return
	var/mob/living/carbon/human/owner = mymob
	if(!istype(owner))
		return
	//Green while healthy, then orange and red, as Qud's health bar does
	var/condition = owner.stat == DEAD ? 0 : owner.paragon_condition()
	var/hp_color = QUD_GREEN_DARK
	if(condition < 0.3)
		hp_color = QUD_RED
	else if(condition < 0.6)
		hp_color = QUD_ORANGE
	var/max_hp = round(owner.maxHealth)
	hp_bar.set_fill_color(hp_color)
	hp_bar.set_value(condition, "HP: [round(condition * max_hp)] / [max_hp]")
	if(owner.max_stamina)
		var/rested = owner.max_stamina - owner.stamina
		sta_bar.set_value(rested / owner.max_stamina, "ST", "[max(round(rested), 0)] / [round(owner.max_stamina)]")
	if(owner.max_energy)
		en_bar.set_value(owner.energy / owner.max_energy, "EN", "[round(owner.energy)] / [round(owner.max_energy)]")

	//The status line, as text and colour pairs for paragon_text. In the font, "{~~}" draws ├──┤.
	var/list/palette = paragon_palette || GLOB.paragon_theme_palettes["paragon_classic"]
	var/dim = palette["frame"]
	var/list/line = list(owner.real_name, palette["bright"], " {~~} ", dim, "T: ", palette["text"])

	var/temp = owner.bodytemperature
	if(temp < BODYTEMP_COLD_LEVEL_ONE_MAX)
		line += list("Freezing", QUD_BLUE)
	else if(temp < BODYTEMP_NORMAL_MIN)
		line += list("Cold", QUD_CYAN)
	else if(temp > BODYTEMP_HEAT_LEVEL_ONE_MAX)
		line += list("Burning", QUD_RED)
	else if(temp > BODYTEMP_NORMAL_MAX)
		line += list("Hot", QUD_ORANGE)
	else
		line += list("Comfortable", QUD_GREEN)
	line += list(" :: ", dim)

	//Sated Quenched, as Qud words its hunger and thirst
	if(owner.nutrition < NUTRITION_LEVEL_STARVING)
		line += list("Starving", QUD_RED)
	else if(owner.nutrition < NUTRITION_LEVEL_HUNGRY)
		line += list("Hungry", QUD_GOLD)
	else
		line += list("Sated", QUD_GREEN)
	line += list(" ", dim)
	if(owner.hydration < HYDRATION_LEVEL_DEHYDRATED)
		line += list("Parched", QUD_RED)
	else if(owner.hydration < HYDRATION_LEVEL_THIRSTY)
		line += list("Thirsty", QUD_GOLD)
	else
		line += list("Quenched", QUD_GREEN)

	//The conditions the old heart showed as overlays
	var/list/tags = list()
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		tags += list("Bleeding [round(owner.blood_volume / BLOOD_VOLUME_NORMAL * 100)]%", QUD_RED)
	var/pain = owner.get_complex_pain() / max(owner.pain_threshold, 1)
	if(pain >= 0.3)
		tags += list(pain >= 0.8 ? "Agony" : "Pain", QUD_ORANGE)
	if(owner.getToxLoss() > 20)
		tags += list("Poisoned", QUD_GREEN)
	if(owner.getOxyLoss() > 20)
		tags += list("Breathless", QUD_CYAN)
	for(var/i in 1 to length(tags) step 2)
		line += list(i == 1 ? " {~~} " : " :: ", dim, tags[i], tags[i + 1])
	status_label.set_segments(line)

	var/area/where = get_area(owner)
	var/when = "[capitalize(GLOB.tod || "day")] of [paragon_day_name()]"
	clock_label.set_segments(list(when, palette["text"], " :: ", dim, where?.name || "Nowhere", palette["bright"]), "right")

//The heading over the alert icons in the right-hand column, "none" when there are none
/datum/hud/proc/update_paragon_effects(count = length(mymob?.alerts))
	if(!paragon_layout || !effects_label)
		return
	var/list/palette = paragon_palette || GLOB.paragon_theme_palettes["paragon_classic"]
	var/list/heading = list("ACTIVE EFFECTS:", palette["text"])
	if(!count)
		heading += list(" none", palette["frame"])
	effects_label.set_segments(heading)

//Lays the alert icons out four to a row under the ACTIVE EFFECTS heading in the right-hand column, status
//alerts first, then debuffs, then buffs. Six rows fit; any more wait off screen until a slot frees up.
/datum/hud/proc/place_paragon_alerts(list/alerts)
	var/list/ordered = list()
	for(var/group in list(ALERT_STATUS, ALERT_DEBUFF, ALERT_BUFF))
		for(var/category in alerts)
			var/atom/movable/screen/alert/alert = alerts[category]
			if(alert.alert_group == group)
				ordered += alert
	for(var/category in alerts)
		ordered |= alerts[category]
	var/index = 0
	for(var/atom/movable/screen/alert/alert as anything in ordered)
		if(index < 24)
			alert.screen_loc = "EAST+[1 + index % 4],NORTH-[5 + round(index / 4)]:-14"
			mymob.client.screen |= alert
		else
			alert.screen_loc = ""
			mymob.client.screen -= alert
		index++
	update_paragon_effects(length(ordered))

//The week-day names the status panel uses, in title case
/proc/paragon_day_name()
	switch(GLOB.dayspassed)
		if(1)
			return "Moon's Dae"
		if(2)
			return "Tiw's Dae"
		if(3)
			return "Wedding's Dae"
		if(4)
			return "Thule's Dae"
		if(5)
			return "Freyja's Dae"
		if(6)
			return "Saturn's Dae"
		if(7)
			return "Sun's Dae"
	return "Twilight"

//Overall condition from 0 to 1 for the HP bar: the health of the whole body, each limb counted by how
//damaged it is (head and chest count double, a missing limb counts as fully lost), then lowered further by
//toxins and suffocation. Burns are already in each limb's damage (brute + burn), so `health`, which re-counts
//head and chest burns, is not used. Blood loss has its own tag in the status line.
/mob/living/carbon/human/proc/paragon_condition()
	var/loss = 0
	var/weight = 0
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(!part.max_damage)
			continue
		var/part_weight = (part.body_zone == BODY_ZONE_HEAD || part.body_zone == BODY_ZONE_CHEST) ? 2 : 1
		loss += min(part.get_damage() / part.max_damage, 1) * part_weight
		weight += part_weight
	for(var/zone in get_missing_limbs())
		var/part_weight = (zone == BODY_ZONE_HEAD || zone == BODY_ZONE_CHEST) ? 2 : 1
		loss += part_weight
		weight += part_weight
	var/body_loss = weight ? loss / weight : 0
	var/other_loss = max(getToxLoss(), getOxyLoss(), 0) / max(maxHealth, 1)
	return clamp(1 - body_loss - other_loss, 0, 1)

//Plain backdrop for the strips: the white HUD tile, tinted by paragon_recolor()
/atom/movable/screen/paragon_strip
	name = ""
	icon = 'icons/hud/storage.dmi'
	icon_state = "white"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = HUD_LAYER - 0.5
	plane = HUD_PLANE

/atom/movable/screen/paragon_strip/Initialize(mapload, new_loc)
	. = ..()
	screen_loc = new_loc

//One-pixel rule along the bottom of its tile row (the transform squashes the tile to a single line)
/atom/movable/screen/paragon_strip/rule
	layer = HUD_LAYER - 0.4
	transform = matrix(1, 0, 0, 0, 1 / 32, -15.5)
	//Palette entry the rule takes its colour from
	var/colour_key = "line"

//Adds [dx], [dy] pixels to every corner of a screen_loc, "A to B" ranges included
/proc/paragon_offset_loc(loc, dx, dy)
	if(!dx && !dy)
		return loc
	var/list/corners = list()
	for(var/corner in splittext(loc, " to "))
		var/list/axes = splittext(corner, ",")
		axes[1] = paragon_offset_axis(axes[1], dx)
		axes[2] = paragon_offset_axis(axes[2], dy)
		corners += jointext(axes, ",")
	return jointext(corners, " to ")

/proc/paragon_offset_axis(axis, offset)
	if(!offset)
		return axis
	var/colon = findtext(axis, ":")
	if(!colon)
		return "[axis]:[offset]"
	return "[copytext(axis, 1, colon)]:[text2num(copytext(axis, colon + 1)) + offset]"

//Pixels each glyph of paragon_font.dmi advances the pen, by character code. Generated with the font.
GLOBAL_LIST_INIT(paragon_font_advance, list("32" = 3, "33" = 2, "34" = 4, "35" = 5, "37" = 5, "38" = 5, "39" = 2, "40" = 3, "41" = 3, "42" = 4, "43" = 4, "44" = 2, "45" = 4, "46" = 2, "47" = 5, "48" = 5, "49" = 4, "50" = 5, "51" = 5, "52" = 5, "53" = 5, "54" = 5, "55" = 5, "56" = 5, "57" = 5, "58" = 2, "59" = 2, "60" = 4, "61" = 4, "62" = 4, "63" = 5, "65" = 5, "66" = 5, "67" = 5, "68" = 5, "69" = 5, "70" = 5, "71" = 5, "72" = 5, "73" = 4, "74" = 5, "75" = 5, "76" = 5, "77" = 6, "78" = 5, "79" = 5, "80" = 5, "81" = 5, "82" = 5, "83" = 5, "84" = 6, "85" = 5, "86" = 6, "87" = 6, "88" = 5, "89" = 6, "90" = 5, "91" = 3, "92" = 5, "93" = 3, "95" = 5, "96" = 3, "97" = 5, "98" = 5, "99" = 4, "100" = 5, "101" = 5, "102" = 5, "103" = 5, "104" = 5, "105" = 4, "106" = 4, "107" = 5, "108" = 4, "109" = 6, "110" = 5, "111" = 5, "112" = 5, "113" = 5, "114" = 4, "115" = 4, "116" = 5, "117" = 5, "118" = 6, "119" = 6, "120" = 5, "121" = 5, "122" = 5, "123" = 4, "125" = 4, "126" = 4))

//HUD text in a pixel font, one overlay per glyph from paragon_font.dmi. BYOND draws the map at its own 32 pixels
//a tile and then stretches it to the window, so maptext in an ordinary typeface comes out soft or loses strokes;
//a pixel font scales up as cleanly as the sprites around it. The glyphs are the mixed-case face the HUD buttons
//use, drawn after Source Code Pro: caps six pixels high, sitting three pixels above the bottom of each cell.
/atom/movable/screen/paragon_text
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = HUD_PLANE
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	//Left of the text box, bottom of the glyph cells, and the box's width (for right alignment)
	var/text_x = 0
	var/text_y = 0
	var/box_width = 64
	//What was last drawn, so an unchanged line is not rebuilt
	var/drawn

/atom/movable/screen/paragon_text/proc/place(x, y, width)
	text_x = x
	text_y = y
	box_width = width

//[segments] alternates text and colour. [shadow], if given, is drawn under each glyph a pixel down and right.
/atom/movable/screen/paragon_text/proc/set_segments(list/segments, align = "left", shadow)
	var/key = "[jointext(segments, "|")]|[align]|[shadow]"
	if(key == drawn)
		return
	drawn = key
	var/x = text_x
	if(align == "right")
		var/total = 0
		for(var/i in 1 to length(segments) step 2)
			total += paragon_text_width(segments[i])
		x = text_x + box_width - total
	var/list/glyphs = list()
	for(var/i in 1 to length(segments) step 2)
		var/text = segments[i]
		var/colour = segments[i + 1]
		for(var/position in 1 to length(text))
			var/code = text2ascii(text, position)
			if(!GLOB.paragon_font_advance["[code]"])
				code = 63
			if(code != 32)
				if(shadow)
					glyphs += paragon_glyph(code, x + 1, text_y - 1, shadow)
				glyphs += paragon_glyph(code, x, text_y, colour)
			x += GLOB.paragon_font_advance["[code]"]
	overlays = glyphs

/proc/paragon_glyph(code, x, y, colour)
	var/mutable_appearance/glyph = mutable_appearance('icons/hud/paragon_font.dmi', "c[code]")
	glyph.pixel_x = x
	glyph.pixel_y = y
	glyph.color = colour
	return glyph

/proc/paragon_text_width(text)
	. = 0
	for(var/position in 1 to length(text))
		. += GLOB.paragon_font_advance["[text2ascii(text, position)]"] || GLOB.paragon_font_advance["63"]

//A line of HUD text placed on the screen by itself: the status line, the clock, the effects heading
/atom/movable/screen/paragon_text/label

/atom/movable/screen/paragon_text/label/Initialize(mapload, new_loc, width)
	. = ..()
	screen_loc = new_loc
	place(0, 2, width)

//"[width]x[height]|colours" => list("back", "fill", "mask") icons, so each bar texture is only drawn once
GLOBAL_LIST_EMPTY(paragon_bar_icon_cache)

//Textures for a [width] x [height] bar. The solid kind is Qud's: a flat block of colour with a lit top edge over
//a dim trough of the same hue. The segmented kind is cut into twenty cells with a one-pixel gap between, like a
//Dwarf Fortress or CDDA meter, and its empty cells are only stippled. The mask is what reveals part of the fill.
/proc/paragon_bar_icons(width, height, list/palette, fill_color, segmented = FALSE)
	var/key = "[width]x[height]|[segmented]|[palette["panel"]]|[fill_color]"
	if(GLOB.paragon_bar_icon_cache[key])
		return GLOB.paragon_bar_icon_cache[key]

	var/icon/back = icon('icons/hud/storage.dmi', "blank")
	back.Scale(width, height)
	var/icon/fill = icon('icons/hud/storage.dmi', "blank")
	fill.Scale(width, height)
	if(segmented)
		var/trough = BlendRGB(palette["panel"], fill_color, 0.22)
		var/stipple = BlendRGB(palette["panel"], fill_color, 0.4)
		var/lit = BlendRGB(fill_color, "#ffffff", 0.35)
		var/cells = 20
		for(var/cell in 0 to cells - 1)
			var/left = 1 + round(cell * width / cells)
			var/right = round((cell + 1) * width / cells) - 1
			back.DrawBox(trough, left, 1, right, height)
			for(var/x in left to right)
				if(x % 2)
					back.DrawBox(stipple, x, round((height + 1) / 2))
			fill.DrawBox(fill_color, left, 1, right, height)
			fill.DrawBox(lit, left, height, right, height)
	else
		back.DrawBox(BlendRGB(palette["panel"], fill_color, 0.18), 1, 1, width, height)
		back.DrawBox(BlendRGB(palette["panel"], fill_color, 0.3), 1, height, width, height)
		fill.DrawBox(fill_color, 1, 1, width, height)
		fill.DrawBox(BlendRGB(fill_color, "#ffffff", 0.3), 1, height, width, height)
		fill.DrawBox(BlendRGB(fill_color, "#000000", 0.25), 1, 1, width, 1)

	var/icon/mask = icon('icons/hud/storage.dmi', "blank")
	mask.Scale(width, height)
	mask.DrawBox("#ffffff", 1, 1, width, height)

	. = list("back" = back, "fill" = fill, "mask" = mask)
	GLOB.paragon_bar_icon_cache[key] = .

//A HUD bar. The solid kind (health) is Qud's, "HP: 18 / 18" written inside it. The slim kind (stamina,
//energy) is a segmented gauge with its label to the left and its value to the right. Clicks land on the bar
//itself: the parts are drawn through vis_contents and inherit its identity.
/atom/movable/screen/paragon_bar
	name = "bar"
	plane = HUD_PLANE
	maptext_height = 16
	//Width the whole bar may take, label and value included
	var/total_width = 96
	//The gauge itself: where it starts, how wide and tall it is, and how high it sits in the tile row
	var/bar_x = 0
	var/bar_width = 96
	var/bar_height = 12
	var/bar_y = 0
	var/slim = FALSE
	var/value = 1
	var/fill_color = QUD_GREEN_DARK
	var/list/palette
	var/atom/movable/screen/paragon_bar_part/back
	var/atom/movable/screen/paragon_bar_part/fill
	//Text inside a solid bar or left of a slim one, and the value right of a slim one
	var/atom/movable/screen/paragon_text/label_text
	var/atom/movable/screen/paragon_text/value_text

/atom/movable/screen/paragon_bar/Initialize(mapload, new_loc, width, new_bar_y = 0)
	. = ..()
	screen_loc = new_loc
	total_width = width
	bar_y = new_bar_y
	back = new
	fill = new
	label_text = new
	value_text = new
	if(slim)
		//Two letters of label, then the gauge, then room for "1350 / 1350" after it
		bar_x = 18
		bar_width = total_width - bar_x - 70
		//Caps centred on the gauge
		var/text_y = bar_y + round(bar_height / 2) - 5
		label_text.place(0, text_y, bar_x)
		value_text.place(bar_x + bar_width + 6, text_y, 64)
	else
		bar_width = total_width
		label_text.place(4, bar_y, bar_width - 4)
	back.pixel_x = bar_x
	fill.pixel_x = bar_x
	back.pixel_y = bar_y
	fill.pixel_y = bar_y
	back.layer = layer - 0.02
	fill.layer = layer - 0.01
	label_text.layer = layer + 0.01
	value_text.layer = layer + 0.01
	vis_contents += list(back, fill, label_text, value_text)

/atom/movable/screen/paragon_bar/Destroy()
	vis_contents.Cut()
	QDEL_NULL(back)
	QDEL_NULL(fill)
	QDEL_NULL(label_text)
	QDEL_NULL(value_text)
	return ..()

/atom/movable/screen/paragon_bar/proc/set_palette(list/new_palette)
	palette = new_palette
	apply_palette(palette)
	redraw()

//Per-bar fill colour from the palette
/atom/movable/screen/paragon_bar/proc/apply_palette(list/new_palette)
	return

/atom/movable/screen/paragon_bar/proc/set_fill_color(new_color)
	if(fill_color == new_color)
		return
	fill_color = new_color
	redraw()

//Puts this bar's textures on its parts and re-reveals the fill
/atom/movable/screen/paragon_bar/proc/redraw()
	if(!palette)
		return
	var/list/icons = paragon_bar_icons(bar_width, bar_height, palette, fill_color, slim)
	back.icon = icons["back"]
	fill.icon = icons["fill"]
	fill.filters = filter(type = "alpha", icon = icons["mask"], x = reveal_offset())

//How far left the mask slides so only the filled part of the bar shows
/atom/movable/screen/paragon_bar/proc/reveal_offset()
	return round(bar_width * value) - bar_width

//[label] is the text inside a solid bar, or the label left of a slim one; [value_string] goes right of a slim one
/atom/movable/screen/paragon_bar/proc/set_value(new_value, label, value_string)
	new_value = clamp(new_value, 0, 1)
	if(new_value != value)
		value = new_value
		if(length(fill.filters))
			animate(fill.filters[1], x = reveal_offset(), time = 3)
	var/list/colours = palette || GLOB.paragon_theme_palettes["paragon_classic"]
	if(slim)
		label_text.set_segments(list(label, colours["text"]))
		value_text.set_segments(list(value_string, colours["bright"]))
	else
		label_text.set_segments(list(label, QUD_WHITE), shadow = BlendRGB(fill_color, "#000000", 0.55))

/atom/movable/screen/paragon_bar_part
	name = ""
	plane = HUD_PLANE
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE

/atom/movable/screen/paragon_bar/health
	name = "health"

//Left-click checks my wounds, right-click lists the people I know, as the old heart did
/atom/movable/screen/paragon_bar/health/Click(location, control, params)
	return hud?.bloods?.Click(location, control, params)

/atom/movable/screen/paragon_bar/stamina
	name = "stamina"
	slim = TRUE
	bar_height = 5
	fill_color = QUD_TEAL

/atom/movable/screen/paragon_bar/energy
	name = "energy"
	slim = TRUE
	bar_height = 5
	fill_color = QUD_BLUE

//The Craft button in the top strip: the old craft button's behaviour (left opens the Crafting tab,
//right repeats the last recipe) in the menu-button style
/atom/movable/screen/craft/paragon
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "pd_craft"

/atom/movable/screen/paperdoll_button/compendium
	name = "compendium"
	icon_state = "pd_lore"
	tab = "compendium"

//Right-click Stats for the vices, languages and traits summary the old Skills button gave
/atom/movable/screen/paperdoll_button/attributes/Click(location, control, params)
	var/list/modifiers = params2list(params)
	var/mob/living/user = usr
	if(modifiers["right"] && istype(user))
		user.print_traits_summary()
		return
	return ..()

//Sizes the map pane to the HUD's shape, so the map fills it without black bars at the side.
//Runs when a HUD is shown and whenever the game window is resized.
/client/proc/fit_map_to_hud()
	var/datum/hud/hud = mob?.hud_used
	var/paragon = hud?.paragon_layout
	//Only touch the splitter for the strip layout, or to put it back after the strip layout moved it
	if(!paragon && !paragon_map_fitted)
		return
	paragon_map_fitted = paragon
	//Keep the drawn map centred in its pane
	winset(src, "mapwindow.map", "letterbox=true")
	var/aspect = paragon ? (PARAGON_HUD_WIDTH / PARAGON_HUD_HEIGHT) : (PANEL_HUD_WIDTH / PANEL_HUD_HEIGHT)
	//Prefer the shape the map is really drawn at, so anything widening the screen is accounted for
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/list/map_size = splittext(sizes["mapwindow.size"], "x")
	var/list/split_size = splittext(sizes["mainwindow.split.size"], "x")
	if(length(map_size) < 2 || length(split_size) < 2)
		return
	var/list/view_size = splittext(winget(src, "mapwindow.map", "view-size"), "x")
	if(length(view_size) == 2)
		var/view_width = text2num(view_size[1])
		var/view_height = text2num(view_size[2])
		//Only trust it when it shows letterboxing; otherwise it is just the pane's own size
		if(view_width > 0 && view_height > 0 && (view_width < text2num(map_size[1]) - 2 || view_height < text2num(map_size[2]) - 2))
			aspect = view_width / view_height
	var/desired_width = round(text2num(map_size[2]) * aspect)
	var/split_width = text2num(split_size[1])
	if(!split_width || abs(text2num(map_size[1]) - desired_width) <= 2)
		return
	//+4 pixels for the splitter's handle; then nudge until the map pane is the right width
	var/pct = clamp(100 * (desired_width + 4) / split_width, 20, 85)
	winset(src, "mainwindow.split", "splitter=[pct]")
	for(var/attempt in 1 to 6)
		var/list/after = splittext(winget(src, "mapwindow", "size"), "x")
		var/got_width = text2num(after[1])
		if(abs(got_width - desired_width) <= 2)
			return
		pct = clamp(pct + 100 * (desired_width - got_width) / split_width, 20, 85)
		winset(src, "mainwindow.split", "splitter=[pct]")

/client
	//TRUE once fit_map_to_hud() has sized the map pane for the strip layout
	var/paragon_map_fitted = FALSE

/client/verb/paragon_fit_map()
	set hidden = TRUE
	set name = ".paragon_fit_map"
	fit_map_to_hud()

#undef PARAGON_HUD_WIDTH
#undef PARAGON_HUD_HEIGHT
#undef PARAGON_VIEW_CENTRE
#undef QUD_RED
#undef QUD_ORANGE
#undef QUD_GOLD
#undef QUD_GREEN_DARK
#undef QUD_GREEN
#undef QUD_BLUE_DARK
#undef QUD_BLUE
#undef QUD_TEAL
#undef QUD_CYAN
#undef QUD_BLACK
#undef QUD_GREY
#undef QUD_WHITE
#undef PARAGON_BUTTONS_COLUMN
#undef PANEL_HUD_WIDTH
#undef PANEL_HUD_HEIGHT
