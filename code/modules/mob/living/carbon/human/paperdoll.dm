//Paper doll: the Equipment and Inventory popups (tgui/packages/tgui/interfaces/Paperdoll.tsx).
//Replaces the equipment slots that used to sit on the left HUD panel, and the old HTML strip menu.
//Looking at yourself, every action is routed through the same click code the HUD slots used
//(Click() on the worn item, or attack_ui() on an empty slot), so equip rules and delays are unchanged.
//Looking at someone else ("stripping"), actions run the same strip procs the old menu used, so strip delays,
//obscured-slot checks and logging are unchanged too.

#define PAPERDOLL_TAB_EQUIPMENT "equipment"
#define PAPERDOLL_TAB_INVENTORY "inventory"
#define PAPERDOLL_TAB_SKILLS "skills"
#define PAPERDOLL_TAB_ATTRIBUTES "attributes"
#define PAPERDOLL_TAB_CRAFTING "crafting"
#define PAPERDOLL_TAB_COMPENDIUM "compendium"
//How many storages deep the inventory list looks (bag in a bag in a bag)
#define PAPERDOLL_MAX_DEPTH 4

//Worn slots shown on the doll, in display order. "glyph" is the empty-slot icon state in the HUD icon file.
GLOBAL_LIST_INIT(paperdoll_slots, list(
	list("id" = SLOT_HEAD, "key" = "head", "name" = "Head", "glyph" = "head"),
	list("id" = SLOT_WEAR_MASK, "key" = "mask", "name" = "Mask", "glyph" = "mask"),
	list("id" = SLOT_MOUTH, "key" = "mouth", "name" = "Mouth", "glyph" = "mouth"),
	list("id" = SLOT_NECK, "key" = "neck", "name" = "Neck", "glyph" = "neck"),
	list("id" = SLOT_CLOAK, "key" = "cloak", "name" = "Cloak", "glyph" = "cloak"),
	list("id" = SLOT_BACK_L, "key" = "backl", "name" = "Back (Left)", "glyph" = "back"),
	list("id" = SLOT_BACK_R, "key" = "backr", "name" = "Back (Right)", "glyph" = "back"),
	list("id" = SLOT_ARMOR, "key" = "armor", "name" = "Armor", "glyph" = "armor"),
	list("id" = SLOT_SHIRT, "key" = "shirt", "name" = "Shirt", "glyph" = "shirt"),
	list("id" = SLOT_WRISTS, "key" = "wrists", "name" = "Bracers", "glyph" = "wrist"),
	list("id" = SLOT_GLOVES, "key" = "gloves", "name" = "Gloves", "glyph" = "gloves"),
	list("id" = SLOT_RING, "key" = "ring", "name" = "Ring", "glyph" = "ring"),
	list("id" = SLOT_BELT, "key" = "belt", "name" = "Belt", "glyph" = "belt"),
	list("id" = SLOT_BELT_L, "key" = "beltl", "name" = "Hip (Left)", "glyph" = "hip"),
	list("id" = SLOT_BELT_R, "key" = "beltr", "name" = "Hip (Right)", "glyph" = "hip"),
	list("id" = SLOT_PANTS, "key" = "pants", "name" = "Trousers", "glyph" = "pants"),
	list("id" = SLOT_SHOES, "key" = "shoes", "name" = "Shoes", "glyph" = "shoes"),
))

//"icon|state|color" => asset name. Each picture is flattened once per round and registered with the asset
//cache as a png; clients are sent it once (paperdoll_asset_url()) and keep it, so window updates only carry its URL.
GLOBAL_LIST_EMPTY(paperdoll_icon_cache)

//Registers [flat] as a png asset under a name derived from [key], and returns that name
/proc/paperdoll_register_icon(key, icon/flat)
	var/asset_name = "pd_[md5(key)].png"
	SSassets.transport.register_asset(asset_name, flat)
	return asset_name

//The URL a window uses to show [asset_name], sending the picture to [C] first if it has not had it yet
/proc/paperdoll_asset_url(asset_name, client/C)
	if(!asset_name || !C)
		return null
	SSassets.transport.send_assets(C, asset_name)
	return SSassets.transport.get_asset_url(asset_name)

/proc/paperdoll_icon(icon_file, icon_state, color)
	if(!icon_file)
		return null
	var/key = "[icon_file]|[icon_state]|[istext(color) ? color : ""]"
	if(key in GLOB.paperdoll_icon_cache)
		return GLOB.paperdoll_icon_cache[key]
	var/result = null
	if(icon_state in icon_states(icon_file))
		var/icon/flat = icon(icon_file, icon_state, SOUTH, 1)
		if(istext(color))
			flat.Blend(color, ICON_MULTIPLY)
		result = paperdoll_register_icon(key, flat)
	GLOB.paperdoll_icon_cache[key] = result
	return result

//Item picture for the popups. Items drawn with overlays (bottles with their liquid, sheaths with their blade,
//dyed trims) are flattened so they look as they do in the world; plain items just use their icon state.
/proc/paperdoll_item_icon(obj/item/I)
	if(!length(I.overlays))
		return paperdoll_icon(I.icon, I.icon_state, I.color)
	var/list/key_parts = list("flat", "[I.icon]", "[I.icon_state]", "[I.color]")
	for(var/image/overlay as anything in I.overlays)
		key_parts += "[overlay.icon]:[overlay.icon_state]:[overlay.color]:[overlay.alpha]"
	var/key = key_parts.Join("|")
	if(key in GLOB.paperdoll_icon_cache)
		return GLOB.paperdoll_icon_cache[key]
	//Flatten a copy without underlays, so grid-storage cell backgrounds are not baked in
	var/mutable_appearance/look = new(I)
	look.underlays = list()
	look.dir = SOUTH
	var/result = paperdoll_register_icon(key, getFlatIcon(look, SOUTH, no_anim = TRUE))
	GLOB.paperdoll_icon_cache[key] = result
	return result

//Sent on a human when something is equipped, taken off, picked up, or the active hand changes
#define COMSIG_PARAGON_INVENTORY_CHANGED "paragon_inventory_changed"

/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_PARAGON_INVENTORY_CHANGED)

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_PARAGON_INVENTORY_CHANGED)

/mob/living/carbon/human/put_in_hand(obj/item/I, hand_index, forced = FALSE, ignore_anim = TRUE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_PARAGON_INVENTORY_CHANGED)

/mob/living/carbon/human/swap_hand(held_index)
	. = ..()
	SEND_SIGNAL(src, COMSIG_PARAGON_INVENTORY_CHANGED)

//Keeps a tgui window (the paper doll, the container view) up to date by change instead of on a timer. The window's
//autoupdate is off; this listens to what it shows (the mobs, the items they carry, the insides of every bag)
//and refreshes it when any of that changes, a few changes in one tick making one refresh. A slow backstop
//refresh catches what has no signal, such as wear on an item.
/datum/paragon_ui_watcher
	//The tgui src_object being kept up to date
	var/datum/host
	var/list/atom/watched = list()
	var/backstop_timer

/datum/paragon_ui_watcher/New(datum/host)
	. = ..()
	src.host = host

/datum/paragon_ui_watcher/Destroy(force)
	unwatch()
	if(backstop_timer)
		deltimer(backstop_timer)
	host = null
	return ..()

//Starts watching once the window opens
/datum/paragon_ui_watcher/proc/start(datum/tgui/ui)
	ui.set_autoupdate(FALSE)
	rewatch()
	if(!backstop_timer)
		backstop_timer = addtimer(CALLBACK(src, PROC_REF(backstop)), 5 SECONDS, TIMER_STOPPABLE)

/datum/paragon_ui_watcher/proc/unwatch()
	for(var/atom/A as anything in watched)
		UnregisterSignal(A, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_PARAGON_INVENTORY_CHANGED, COMSIG_MOVABLE_MOVED))
	watched.Cut()

//Watches the host's current paragon_watch_targets() (things move between bags, so this is redone each refresh)
/datum/paragon_ui_watcher/proc/rewatch()
	unwatch()
	var/list/targets = host.paragon_watch_targets()
	for(var/atom/A as anything in targets)
		if(QDELETED(A))
			continue
		var/list/signals = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED)
		if(ishuman(A))
			signals += COMSIG_PARAGON_INVENTORY_CHANGED
		if(targets[A] == "moves")
			signals += COMSIG_MOVABLE_MOVED
		RegisterSignal(A, signals, PROC_REF(on_change))
		watched += A

/datum/paragon_ui_watcher/proc/on_change()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(refresh)), 1, TIMER_UNIQUE)

/datum/paragon_ui_watcher/proc/refresh()
	if(QDELETED(host))
		return
	if(SStgui.update_uis(host))
		rewatch()
	else
		unwatch()

/datum/paragon_ui_watcher/proc/backstop()
	backstop_timer = null
	if(QDELETED(host) || !SStgui.update_uis(host))
		unwatch()
		return
	rewatch()
	backstop_timer = addtimer(CALLBACK(src, PROC_REF(backstop)), 5 SECONDS, TIMER_STOPPABLE)

//What a watched window shows: atoms whose contents changing should refresh it. An atom associated with "moves"
//also refreshes it when it moves.
/datum/proc/paragon_watch_targets()
	return list()

//[holder], everything it carries, and every item inside those, down to [depth] bags deep
/proc/paragon_carried_atoms(atom/holder, depth = 4)
	. = list(holder)
	if(depth <= 0)
		return
	for(var/obj/item/I in holder)
		. |= paragon_carried_atoms(I, depth - 1)
		var/datum/component/storage/storage = I.GetComponent(/datum/component/storage)
		var/atom/inside = storage?.real_location()
		if(inside && inside != I)
			. |= paragon_carried_atoms(inside, depth - 1)

/mob
	var/datum/paperdoll/paperdoll

//Opens (or refreshes) the paper doll for [target]. Opening it on someone else is the strip menu.
/mob/proc/open_paperdoll(mob/living/carbon/human/target, tab)
	if(!client || !istype(target))
		return
	if(paperdoll && paperdoll.owner != target)
		QDEL_NULL(paperdoll)
	if(!paperdoll)
		paperdoll = new(src, target)
	if(tab)
		paperdoll.tab = tab
	paperdoll.ui_interact(src)

/mob/living/carbon/human/show_inv(mob/user)
	user.open_paperdoll(src, PAPERDOLL_TAB_EQUIPMENT)

/datum/paperdoll
	var/mob/living/carbon/human/owner
	var/mob/viewer
	var/tab = PAPERDOLL_TAB_EQUIPMENT
	var/datum/paragon_ui_watcher/watcher

/datum/paperdoll/New(mob/viewer, mob/living/carbon/human/owner)
	. = ..()
	src.viewer = viewer
	src.owner = owner
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_deleted))
	watcher = new(src)

/datum/paperdoll/Destroy(force)
	SStgui.close_uis(src)
	QDEL_NULL(watcher)
	if(viewer?.paperdoll == src)
		viewer.paperdoll = null
	viewer = null
	owner = null
	return ..()

/datum/paperdoll/proc/on_owner_deleted()
	SIGNAL_HANDLER
	qdel(src)

/datum/paperdoll/proc/stripping()
	return viewer != owner

/datum/paperdoll/ui_state(mob/user)
	return GLOB.always_state

/datum/paperdoll/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(owner) || user != viewer)
		return UI_CLOSE
	if(stripping())
		if(!user.Adjacent(owner))
			return UI_CLOSE
		return user.incapacitated() ? UI_UPDATE : UI_INTERACTIVE
	return user.stat == CONSCIOUS ? UI_INTERACTIVE : UI_UPDATE

/datum/paperdoll/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Paperdoll")
		ui.open()
		watcher.start(ui)

//Refreshes on what the owner wears and carries, and on their moving while the Crafting tab lists what is to hand
/datum/paperdoll/paragon_watch_targets()
	. = paragon_carried_atoms(owner)
	if(tab == PAPERDOLL_TAB_CRAFTING)
		.[owner] = "moves"

/datum/paperdoll/ui_static_data(mob/user)
	var/hud_icon = user.client?.prefs ? user.client.prefs.get_roguehud_icon() : 'icons/mob/roguehud.dmi'
	var/list/slots = list()
	for(var/list/slot as anything in GLOB.paperdoll_slots)
		slots += list(list(
			"id" = slot["id"],
			"key" = slot["key"],
			"name" = slot["name"],
			"glyph" = paperdoll_asset_url(paperdoll_icon(hud_icon, slot["glyph"]), user.client),
		))
	var/list/data = list("slot_info" = slots)
	//The two heavy lists are only sent while their tab is open; switching to it refreshes the static data
	if(!stripping())
		if(tab == PAPERDOLL_TAB_CRAFTING)
			data["crafting_recipes"] = build_crafting_recipes(user)
		if(tab == PAPERDOLL_TAB_COMPENDIUM)
			data["compendium"] = paperdoll_compendium()
	return data

/datum/paperdoll/proc/item_data(obj/item/I, with_stats = FALSE)
	var/list/data = list(
		"ref" = REF(I),
		"name" = I.name,
		"segments" = paperdoll_name_segments(I),
		"icon" = paperdoll_asset_url(paperdoll_item_icon(I), viewer?.client),
	)
	//Same thresholds the HUD slots used for their damaged / broken frames
	if(I.max_integrity && I.obj_integrity < I.max_integrity)
		data["condition"] = (I.integrity_failure && (I.obj_integrity / I.max_integrity) <= I.integrity_failure) ? "broken" : "damaged"
	var/capacity = paperdoll_capacity(I)
	if(capacity)
		data["capacity"] = capacity
	if(with_stats)
		//The same stat lines the hover tooltip shows; durability only when looking at your own gear
		var/list/stats = I.get_hover_examine_stat_lines(viewer, !stripping())
		var/condition_text = I.get_hover_examine_condition_text()
		if(condition_text)
			stats = list(condition_text) + stats
		if(I.body_parts_covered)
			stats += "<b>COVERS:</b> [english_list(body_parts_covered2organ_names(I.body_parts_covered))]"
		data["stats"] = stats
		data["desc"] = I.get_hover_examine_description()
	return data

//"used/total" space in a container, or null if the item has no real inventory of its own.
//Grid storages count cells, others count items. Items that carry a storage component but cannot be
//looked into, or have no finite room, are not containers as far as the player is concerned.
/proc/paperdoll_capacity(obj/item/I)
	var/datum/component/storage/storage = I.GetComponent(/datum/component/storage)
	//attack_hand_interact is off for attach-onto storages (pins and badges on armour and hats), which are not inventories
	if(!storage || !storage.allow_look_inside || !storage.attack_hand_interact)
		return null
	return paperdoll_storage_capacity(storage)

//"used/total" for any storage, carried or standing in the world
/proc/paperdoll_storage_capacity(datum/component/storage/storage)
	var/used
	var/total
	var/unit
	if(storage.grid)
		used = LAZYLEN(storage.grid_coordinates_to_item)
		total = storage.screen_max_columns * storage.screen_max_rows
		unit = "slots"
	else
		var/atom/real_location = storage.real_location()
		used = length(real_location?.contents)
		total = storage.max_items
		unit = "items"
	//Defaults are effectively unlimited (INFINITY columns, 1000 items); those are not inventories worth counting
	if(!isnum(total) || total <= 0 || total >= 100)
		return null
	return list("used" = used, "total" = total, "unit" = unit)

/datum/paperdoll/ui_data(mob/user)
	var/list/data = list()
	data["tab"] = tab
	data["stripping"] = stripping()
	data["owner_name"] = owner.name

	var/list/obscured = stripping() ? owner.check_obscured_slots() : list()
	var/list/blocked = owner.dna?.species?.no_equip || list()
	var/list/slots = list()
	for(var/list/slot as anything in GLOB.paperdoll_slots)
		var/id = slot["id"]
		var/list/entry = list("id" = id)
		if(id in blocked)
			entry["blocked"] = TRUE
		else if(id in obscured)
			entry["obscured"] = TRUE
		else
			var/obj/item/I = owner.get_item_by_slot(id)
			if(I && !(I.item_flags & ABSTRACT))
				entry["item"] = item_data(I, TRUE)
		slots["[slot["key"]]"] = entry
	data["slots"] = slots

	var/list/hands = list()
	for(var/i in 1 to length(owner.held_items))
		var/obj/item/I = owner.get_item_for_held_index(i)
		hands += list(list(
			"index" = i,
			"name" = capitalize(owner.get_held_index_name(i)),
			"active" = !stripping() && owner.active_hand_index == i,
			"item" = (I && !(I.item_flags & ABSTRACT)) ? item_data(I, TRUE) : null,
		))
	data["hands"] = hands

	if(stripping())
		data["handcuffed"] = !!owner.handcuffed
		data["legcuffed"] = !!owner.legcuffed
#ifdef MATURESERVER
		if(get_location_accessible(owner, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE))
			data["underwear"] = owner.underwear ? "Remove" : "Nothing"
			data["legwear"] = owner.legwear_socks ? "Remove" : "Nothing"
			data["extras"] = !!owner.modular_strippanel_chastity_row()
#endif
	else
		//Each tab's data is only built while it is open; ui_data runs on every refresh
		if(tab == PAPERDOLL_TAB_INVENTORY)
			data["inventory"] = build_inventory()
			data["containers"] = build_containers()
			data["quickbar"] = owner.quickbar_refs()
		if(tab == PAPERDOLL_TAB_SKILLS)
			data["skills"] = build_skills()
		if(tab == PAPERDOLL_TAB_ATTRIBUTES)
			data["attributes"] = build_attributes()
		if(tab == PAPERDOLL_TAB_CRAFTING)
			data["crafting"] = build_crafting_state(user)
	return data

//Every item on the owner: held, worn, and everything inside worn or held containers
/datum/paperdoll/proc/build_inventory()
	var/list/items = list()
	for(var/i in 1 to length(owner.held_items))
		var/obj/item/I = owner.get_item_for_held_index(i)
		if(I && !(I.item_flags & ABSTRACT))
			items += list(inventory_entry(I, "[capitalize(owner.get_held_index_name(i))]", TRUE))
			collect_contents(I, items, 1)
	for(var/list/slot as anything in GLOB.paperdoll_slots)
		var/obj/item/I = owner.get_item_by_slot(slot["id"])
		if(I && !(I.item_flags & ABSTRACT))
			items += list(inventory_entry(I, "Worn: [slot["name"]]", TRUE))
			collect_contents(I, items, 1)
	return items

//Space left in each held or worn container, for the bars under the inventory list
/datum/paperdoll/proc/build_containers()
	var/list/containers = list()
	var/list/carried = owner.held_items.Copy()
	for(var/list/slot as anything in GLOB.paperdoll_slots)
		carried += owner.get_item_by_slot(slot["id"])
	for(var/obj/item/I in carried)
		var/list/capacity = paperdoll_capacity(I)
		if(capacity)
			containers += list(list("name" = I.name) + capacity)
	return containers

/datum/paperdoll/proc/collect_contents(obj/item/container, list/items, depth)
	if(depth > PAPERDOLL_MAX_DEPTH)
		return
	var/obj/item/rogueweapon/scabbard/scabbard = container
	if(istype(scabbard) && scabbard.sheathed)
		items += list(inventory_entry(scabbard.sheathed, "Sheathed in [scabbard.name]", FALSE))
	var/datum/component/storage/storage = container.GetComponent(/datum/component/storage)
	if(!storage)
		return
	var/atom/real_location = storage.real_location()
	if(!real_location)
		return
	for(var/obj/item/I in real_location)
		if(I.item_flags & ABSTRACT)
			continue
		var/list/entry = inventory_entry(I, container.name, FALSE)
		entry["reachable"] = !storage.should_block_user_take(I, owner, TRUE, TRUE)
		items += list(entry)
		collect_contents(I, items, depth + 1)

/datum/paperdoll/proc/inventory_entry(obj/item/I, where, equipped)
	var/list/entry = item_data(I)
	entry["where"] = where
	entry["equipped"] = equipped
	entry["category"] = paperdoll_category(I)
	entry["container"] = !!paperdoll_capacity(I)
	entry["reachable"] = TRUE
	entry["held"] = (I in owner.held_items)
	return entry

/proc/paperdoll_category(obj/item/I)
	if(istype(I, /obj/item/rogueweapon) || istype(I, /obj/item/gun))
		return "Weapons"
	if(istype(I, /obj/item/ammo_casing))
		return "Ammunition"
	if(paperdoll_capacity(I))
		return "Containers"
	if(istype(I, /obj/item/clothing))
		return "Clothing"
	if(istype(I, /obj/item/reagent_containers/food/snacks))
		return "Provisions"
	if(istype(I, /obj/item/reagent_containers))
		return "Drinks & Potions"
	if(istype(I, /obj/item/book) || istype(I, /obj/item/paper))
		return "Books & Notes"
	if(istype(I, /obj/item/roguegem) || istype(I, /obj/item/roguecoin))
		return "Valuables"
	if(istype(I, /obj/item/roguekey))
		return "Keys"
	if(istype(I, /obj/item/natural) || istype(I, /obj/item/ingot) || istype(I, /obj/item/rogueore))
		return "Materials"
	return "Miscellaneous"

//Resolves a ref sent by the UI, only if that item is actually on the owner (held, worn or inside their containers)
/datum/paperdoll/proc/resolve_item(ref)
	var/obj/item/I = locate(ref)
	if(!istype(I))
		return null
	var/atom/loc_check = I.loc
	for(var/i in 0 to PAPERDOLL_MAX_DEPTH + 1)
		if(loc_check == owner)
			return I
		if(!loc_check || isturf(loc_check))
			return null
		loc_check = loc_check.loc
	return null

//Rebuilds BYOND click params from the UI's mouse info, so item Click() code sees the same modifiers as a HUD click
/proc/paperdoll_click_params(list/params)
	var/list/out = list()
	switch(params["button"])
		if("right")
			out["right"] = "1"
		if("middle")
			out["middle"] = "1"
		else
			out["left"] = "1"
	if(text2num(params["shift"]))
		out["shift"] = "1"
	if(text2num(params["ctrl"]))
		out["ctrl"] = "1"
	if(text2num(params["alt"]))
		out["alt"] = "1"
	return list2params(out)

/datum/paperdoll/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(action == "tab")
		if(params["tab"] in list(PAPERDOLL_TAB_EQUIPMENT, PAPERDOLL_TAB_INVENTORY, PAPERDOLL_TAB_SKILLS, PAPERDOLL_TAB_ATTRIBUTES, PAPERDOLL_TAB_CRAFTING, PAPERDOLL_TAB_COMPENDIUM))
			var/old_tab = tab
			tab = params["tab"]
			//Recipes and the compendium are static data sent only with their tab (ui_static_data)
			if(tab != old_tab && (tab in list(PAPERDOLL_TAB_CRAFTING, PAPERDOLL_TAB_COMPENDIUM, old_tab)))
				update_static_data(user)
			watcher.rewatch()
		return TRUE
	if(stripping())
		return strip_act(action, params, user)
	return self_act(action, params, user)

//Looking at someone else: the old strip menu's actions
/datum/paperdoll/proc/strip_act(action, list/params, mob/user)
	switch(action)
		if("slot")
			strip_slot(user, text2num(params["id"]))
		if("hand")
			strip_slot(user, SLOT_HANDS, text2num(params["index"]))
		if("handcuffs")
			strip_slot(user, SLOT_HANDCUFFED)
		if("legcuffs")
			strip_slot(user, SLOT_LEGCUFFED)
#ifdef MATURESERVER
		if("underwear")
			owner.Topic(null, list("undiesthing" = "1"))
		if("legwear")
			owner.Topic(null, list("legwearsthing" = "1"))
		if("extras")
			owner.show_inv_legacy(user)
#endif
		else
			return FALSE
	return TRUE

//What the old strip menu's links did (mob/Topic), called directly so it does not depend on usr.
//Runs async: stripping waits on a do_after, which must not hold up the UI message.
/datum/paperdoll/proc/strip_slot(mob/living/user, slot, hand_index)
	if(!slot || !istype(user))
		return
	if(slot in owner.check_obscured_slots(TRUE))
		to_chat(user, span_warning("I can't reach that! Something is covering it."))
		return
	if(!user.canUseTopic(owner, BE_CLOSE, NO_DEXTERITY))
		return
	var/obj/item/what
	var/where = slot
	if(hand_index)
		what = owner.get_item_for_held_index(hand_index)
		where = list(slot, hand_index)
	else
		what = owner.get_item_by_slot(slot)
	if(what)
		if(!(what.item_flags & ABSTRACT))
			INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, stripPanelUnequip), what, owner, where)
	else
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, stripPanelEquip), null, owner, where)

//Takes worn storage off into a free hand, with the item's usual unequip delay
/proc/paperdoll_take_off(obj/item/I, mob/living/carbon/human/user)
	var/list/free = user.get_empty_held_indexes()
	if(!length(free))
		to_chat(user, span_warning("My hands are full."))
		return
	var/hand = (user.active_hand_index in free) ? user.active_hand_index : free[1]
	if(I.unequip_delay_self > 1 && !do_after(user, I.unequip_delay_self, target = user))
		return
	if(I.loc != user || (I in user.held_items))
		return
	user.putItemFromInventoryInHandIfPossible(I, hand)

//Looking at yourself: same click handling as the old HUD slots
/datum/paperdoll/proc/self_act(action, list/params, mob/user)
	if(world.time <= user.next_move || user.incapacitated())
		return TRUE
	var/click_params = paperdoll_click_params(params)
	switch(action)
		if("slot")
			var/slot_id = text2num(params["id"])
			if(!slot_id)
				return FALSE
			var/obj/item/worn = owner.get_item_by_slot(slot_id)
			if(worn && paperdoll_capacity(worn) && params["button"] != "right" && !text2num(params["shift"]) && !text2num(params["ctrl"]) && !text2num(params["alt"]))
				//Clicking worn storage would just open it; the doll's job is taking it off. Bags open from the Inventory tab.
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(paperdoll_take_off), worn, user)
			else if(worn)
				worn.Click(null, null, click_params)
			else if(user.attack_ui(slot_id))
				user.update_inv_hands()
		if("hand")
			var/index = text2num(params["index"])
			if(index && index != owner.active_hand_index)
				owner.activate_hand(index)
			else
				var/obj/item/held = owner.get_active_held_item()
				held?.Click(null, null, click_params)
		if("take")
			var/obj/item/I = resolve_item(params["ref"])
			if(!I)
				return FALSE
			if(I.loc == owner)
				//Worn or held: clicking it is exactly what the HUD slot did
				I.Click(null, null, click_params)
				return TRUE
			var/obj/item/rogueweapon/scabbard/scabbard = I.loc
			if(istype(scabbard) && scabbard.sheathed == I)
				if(user.get_active_held_item())
					to_chat(user, span_warning("My hand is full."))
				else
					scabbard.puke_sword(user)
				return TRUE
			paperdoll_take_from_storage(I, user)
		if("open")
			var/obj/item/I = resolve_item(params["ref"])
			var/datum/component/storage/storage = I?.GetComponent(/datum/component/storage)
			if(storage && storage.worn_check(I, user))
				storage.user_show_to_mob(user)
		if("store")
			//Puts a held (or bagged) item into one of the owner's own containers
			var/obj/item/I = resolve_item(params["ref"])
			var/obj/item/into = resolve_item(params["into"])
			var/datum/component/storage/storage = into?.GetComponent(/datum/component/storage)
			if(!I || !storage || !paperdoll_capacity(into) || storage.locked || !storage.worn_check(into, user))
				return FALSE
			container_put(I, storage, user)
		if("bind")
			var/obj/item/I = resolve_item(params["ref"])
			var/index = text2num(params["slot"])
			if(I && ishuman(owner))
				owner.quickbar_bind(index, I)
		if("craft", "checkboxonlycraftable")
			//Crafting runs through the crafting component, exactly as its old window did
			var/mob/living/carbon/human/H = user
			var/datum/component/personal_crafting/crafting = istype(H) ? H.craftingthing : null
			var/area/here = get_area(user)
			if(!crafting || !here?.can_craft_here())
				to_chat(user, span_warning("I can't craft here."))
				return TRUE
			crafting.ui_act(action, params)
		if("examine")
			var/obj/item/I = resolve_item(params["ref"])
			if(I)
				user.examinate(I)
		else
			return FALSE
	return TRUE

//Takes an item out of whatever container it is in and into [user]'s active hand, obeying the storage's reach rules
/proc/paperdoll_take_from_storage(obj/item/I, mob/user)
	var/datum/component/storage/storage = I.loc?.GetComponent(/datum/component/storage)
	if(!storage)
		return
	if(!length(user.get_empty_held_indexes()))
		to_chat(user, span_warning("My hands are full."))
		return
	if(storage.should_block_user_take(I, user, TRUE))
		return
	if(!SEND_SIGNAL(storage.parent, COMSIG_TRY_STORAGE_TAKE, I, get_turf(user)))
		return
	if(!user.put_in_active_hand(I))
		user.put_in_hands(I)
	return TRUE

//How many bags deep the container window folds open
#define CONTAINER_VIEW_MAX_DEPTH 4

//Container window: opening a bag, chest or pouch shows its contents as a trade-style list instead of the
//grid on the HUD. The container is on the left, everything carried is on the right, and bags inside bags fold
//open in place. The grid still decides what fits; items are just placed in the first free cells.

/mob
	var/datum/container_view/container_view

//Humans on the paper doll HUD get the container window; everyone else keeps the grid
/datum/component/storage/show_to(mob/M)
	if(!ishuman(M) || !M.client || !M.hud_used || M.hud_used.show_worn_items)
		return ..()
	if(M.container_view?.root != src && M.stat == CONSCIOUS)
		for(var/obj/item/I in real_location())
			if(I.on_found(M))
				return FALSE
	if(M.active_storage)
		M.active_storage.hide_from(M)
	//Async: show_to also runs from refresh_mob_views() during a storage's Destroy(), which must not sleep,
	//and opening a tgui window can
	INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, open_container_view), src)
	return TRUE

/mob/proc/open_container_view(datum/component/storage/storage)
	if(container_view && container_view.root != storage)
		QDEL_NULL(container_view)
	if(!container_view)
		container_view = new(src, storage)
	container_view.ui_interact(src)

/datum/container_view
	var/mob/viewer
	var/datum/paragon_ui_watcher/watcher
	var/datum/component/storage/root
	//The storage shown on the left; a bag inside [root] when the player has opened one
	var/datum/component/storage/focus

/datum/container_view/New(mob/viewer, datum/component/storage/storage)
	. = ..()
	src.viewer = viewer
	root = storage
	focus = storage
	RegisterSignal(storage.parent, COMSIG_PARENT_QDELETING, PROC_REF(on_container_deleted))
	watcher = new(src)

/datum/container_view/Destroy(force)
	SStgui.close_uis(src)
	QDEL_NULL(watcher)
	if(viewer?.container_view == src)
		viewer.container_view = null
	viewer = null
	root = null
	focus = null
	return ..()

/datum/container_view/proc/on_container_deleted()
	SIGNAL_HANDLER
	qdel(src)

/datum/container_view/ui_state(mob/user)
	return GLOB.always_state

/datum/container_view/ui_status(mob/user, datum/ui_state/state)
	if(user != viewer || QDELETED(root) || QDELETED(root.parent) || root.locked)
		return UI_CLOSE
	var/atom/host = root.parent
	if(!user.CanReach(host, view_only = TRUE))
		return UI_CLOSE
	if(isitem(host) && !root.worn_check(host, user, TRUE))
		return UI_CLOSE
	return (user.stat == CONSCIOUS && !user.incapacitated()) ? UI_INTERACTIVE : UI_UPDATE

/datum/container_view/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Container")
		ui.open()
		watcher.start(ui)

//Refreshes on the opened container and everything in it, and on what the viewer carries (the right-hand list)
/datum/container_view/paragon_watch_targets()
	. = paragon_carried_atoms(root.parent) | paragon_carried_atoms(viewer)

/datum/container_view/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/container_view/ui_data(mob/user)
	if(QDELETED(focus) || !in_root(focus.parent))
		focus = root
	var/atom/host = focus.parent
	var/list/data = list()
	data["title"] = host.name
	data["viewer_name"] = user.name
	data["capacity"] = paperdoll_storage_capacity(focus)
	data["contents"] = storage_nodes(focus, 1)
	//Breadcrumbs from the opened container down to the bag being looked into
	var/list/path = list()
	var/atom/step = host
	while(step)
		path.Insert(1, list(list("name" = step.name, "ref" = REF(step))))
		if(step == root.parent)
			break
		step = step.loc
	data["path"] = path
	data["carried"] = ishuman(user) ? carried_nodes(user) : list()
	data["hands_free"] = length(user.get_empty_held_indexes())
	return data

//One row of the list. Containers carry their own contents as children, sheaths their blade.
/datum/container_view/proc/node(obj/item/I, datum/component/storage/holder, depth)
	var/list/entry = list(
		"ref" = REF(I),
		"name" = I.name,
		"segments" = paperdoll_name_segments(I),
		"icon" = paperdoll_asset_url(paperdoll_item_icon(I), viewer?.client),
		"category" = paperdoll_category(I),
		"size" = weightclass2text(I.w_class),
	)
	if(I.max_integrity && I.obj_integrity < I.max_integrity)
		entry["condition"] = (I.integrity_failure && (I.obj_integrity / I.max_integrity) <= I.integrity_failure) ? "broken" : "damaged"
	if(holder)
		entry["reachable"] = !holder.should_block_user_take(I, viewer, TRUE, TRUE)
	else
		entry["reachable"] = TRUE
	var/list/capacity = paperdoll_capacity(I)
	if(capacity)
		entry["capacity"] = capacity
		if(depth < CONTAINER_VIEW_MAX_DEPTH)
			entry["children"] = storage_nodes(I.GetComponent(/datum/component/storage), depth + 1)
	var/obj/item/rogueweapon/scabbard/scabbard = I
	if(istype(scabbard) && scabbard.sheathed)
		var/list/blade = node(scabbard.sheathed, null, depth + 1)
		blade["sheathed"] = TRUE
		entry["children"] = list(blade)
	return entry

/datum/container_view/proc/storage_nodes(datum/component/storage/storage, depth)
	var/list/nodes = list()
	var/atom/real_location = storage?.real_location()
	if(!real_location)
		return nodes
	for(var/obj/item/I in real_location)
		if(I.item_flags & ABSTRACT)
			continue
		nodes += list(node(I, storage, depth))
	return nodes

//Hands first, then worn gear, each with whatever is inside
/datum/container_view/proc/carried_nodes(mob/living/carbon/human/H)
	var/list/nodes = list()
	for(var/i in 1 to length(H.held_items))
		var/obj/item/I = H.get_item_for_held_index(i)
		if(I && !(I.item_flags & ABSTRACT))
			var/list/entry = node(I, null, 1)
			entry["where"] = capitalize(H.get_held_index_name(i))
			entry["held"] = TRUE
			nodes += list(entry)
	for(var/list/slot as anything in GLOB.paperdoll_slots)
		var/obj/item/I = H.get_item_by_slot(slot["id"])
		if(I && !(I.item_flags & ABSTRACT))
			var/list/entry = node(I, null, 1)
			entry["where"] = slot["name"]
			nodes += list(entry)
	return nodes

//TRUE if [A] is the opened container or somewhere inside it
/datum/container_view/proc/in_root(atom/A)
	var/atom/root_location = root.real_location()
	for(var/i in 0 to CONTAINER_VIEW_MAX_DEPTH + 1)
		if(!A || isturf(A))
			return FALSE
		if(A == root.parent || A == root_location)
			return TRUE
		A = A.loc
	return FALSE

//TRUE if [A] is on the viewer: held, worn, or inside something they carry
/datum/container_view/proc/on_viewer(atom/A)
	for(var/i in 0 to CONTAINER_VIEW_MAX_DEPTH + 1)
		if(!A || isturf(A))
			return FALSE
		if(A.loc == viewer)
			return TRUE
		A = A.loc
	return FALSE

/datum/container_view/proc/resolve(ref)
	var/obj/item/I = locate(ref)
	if(!istype(I) || (I.item_flags & ABSTRACT))
		return null
	if(in_root(I.loc) || on_viewer(I))
		return I
	return null

/datum/container_view/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(world.time <= user.next_move)
		return TRUE
	var/obj/item/I = resolve(params["ref"])
	switch(action)
		if("take")
			if(!I || I.loc == user)
				return FALSE
			var/obj/item/rogueweapon/scabbard/scabbard = I.loc
			if(istype(scabbard) && scabbard.sheathed == I)
				if(!length(user.get_empty_held_indexes()))
					to_chat(user, span_warning("My hands are full."))
				else
					scabbard.puke_sword(user)
				return TRUE
			paperdoll_take_from_storage(I, user)
		if("put")
			if(!I)
				return FALSE
			container_put(I, focus, user)
		if("open")
			//Looks into a bag inside the container, or back up to one along the path
			var/atom/target = locate(params["ref"])
			if(target == root.parent)
				focus = root
				return TRUE
			if(!isitem(target) || !in_root(target.loc))
				return FALSE
			var/datum/component/storage/storage = target.GetComponent(/datum/component/storage)
			if(storage && paperdoll_capacity(target) && !storage.locked)
				focus = storage
		if("examine")
			if(I)
				user.examinate(I)
		else
			return FALSE
	return TRUE

//Moves [I] into [target] storage for [user]: straight from the hand, or out of another bag first
/proc/container_put(obj/item/I, datum/component/storage/target, mob/user)
	var/atom/host = target.parent
	//A bag cannot go inside something that is already inside it
	for(var/atom/A = host; A && !isturf(A); A = A.loc)
		if(A == I)
			to_chat(user, span_warning("[I] can't go inside itself."))
			return FALSE
	if(I.loc == user && !(I in user.held_items))
		to_chat(user, span_warning("I need to take [I] off first."))
		return FALSE
	if(!target.can_be_inserted(I, FALSE, user))
		return FALSE
	var/datum/component/storage/source = I.loc?.GetComponent(/datum/component/storage)
	if(source && !(I in user.held_items))
		if(source.should_block_user_take(I, user, TRUE))
			return FALSE
		if(!SEND_SIGNAL(source.parent, COMSIG_TRY_STORAGE_TAKE, I, get_turf(user)))
			return FALSE
	return target.handle_item_insertion(I, FALSE, user)

#undef CONTAINER_VIEW_MAX_DEPTH
#undef PAPERDOLL_MAX_DEPTH

//HUD buttons that open the popups, in the panel space the equipment slots used to fill
/atom/movable/screen/paperdoll_button
	name = "equipment"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "pd_equip"
	screen_loc = "WEST-4:16,SOUTH+5"
	var/tab = PAPERDOLL_TAB_EQUIPMENT

/atom/movable/screen/paperdoll_button/Click(location, control, params)
	usr.toggle_paperdoll(tab)

//Opens your own paper doll on [tab], or closes it if that tab is already showing
/mob/proc/toggle_paperdoll(tab)
	if(!ishuman(src))
		return
	//Pressing the button or key for the tab already open closes the window again
	if(paperdoll && paperdoll.owner == src && paperdoll.tab == tab && SStgui.get_open_ui(src, paperdoll))
		SStgui.close_uis(paperdoll)
		return
	open_paperdoll(src, tab)

/atom/movable/screen/paperdoll_button/equipment

/atom/movable/screen/paperdoll_button/inventory
	name = "inventory"
	icon_state = "pd_inv"
	screen_loc = "WEST-3:16,SOUTH+5"
	tab = PAPERDOLL_TAB_INVENTORY

/atom/movable/screen/paperdoll_button/skills
	name = "skills"
	icon_state = "pd_skills"
	screen_loc = "WEST-4:16,SOUTH+4"
	tab = PAPERDOLL_TAB_SKILLS

/atom/movable/screen/paperdoll_button/attributes
	name = "attributes"
	icon_state = "pd_stats"
	screen_loc = "WEST-3:16,SOUTH+4"
	tab = PAPERDOLL_TAB_ATTRIBUTES

/datum/keybinding/human/open_equipment
	hotkey_keys = list("U")
	name = "open_equipment"
	full_name = "Equipment"
	description = "Open or close the Equipment window"

/datum/keybinding/human/open_equipment/down(client/user)
	. = ..()
	if(!. || !ishuman(user.mob))
		return FALSE
	user.mob.toggle_paperdoll(PAPERDOLL_TAB_EQUIPMENT)
	return TRUE

/datum/keybinding/human/open_inventory
	hotkey_keys = list("I")
	name = "open_inventory"
	full_name = "Inventory"
	description = "Open or close the Inventory window"

/datum/keybinding/human/open_inventory/down(client/user)
	. = ..()
	if(!. || !ishuman(user.mob))
		return FALSE
	user.mob.toggle_paperdoll(PAPERDOLL_TAB_INVENTORY)
	return TRUE


//Item name colouring for the Equipment / Inventory popups: each word of a name that
//names a quality, material or aspect is drawn in that aspect's colour, so a "masterwork steel sword"
//reads at a glance. Words with no aspect keep the default text colour.

//The 18 item-name colours, by their & code
GLOBAL_LIST_INIT(paragon_colors, list(
	"r" = "#a64a2e", "R" = "#d74200",
	"o" = "#f15f22", "O" = "#e99f10",
	"w" = "#98875f", "W" = "#cfc041",
	"g" = "#009403", "G" = "#00c420",
	"b" = "#0048bd", "B" = "#0096ff",
	"c" = "#40a4b9", "C" = "#77bfcf",
	"m" = "#b154cf", "M" = "#da5bd6",
	"k" = "#0f3b3a", "K" = "#155352",
	"y" = "#b1c9c3", "Y" = "#ffffff",
))

//Name word => colour code. Covers smithing and pottery quality, materials, and holy / unholy / magic aspects.
GLOBAL_LIST_INIT(paperdoll_aspect_words, list(
	//Quality, worst to best (smith_components.dm, crafting.dm)
	"ruined" = "K", "awful" = "r", "crude" = "r", "rough" = "w",
	"fine" = "G", "flawless" = "C", "masterwork" = "W", "legendary" = "M",
	//Wear
	"rusty" = "r", "rusted" = "o", "old" = "w", "decrepit" = "r", "tattered" = "w", "torn" = "w", "worn" = "w",
	//Metals
	"iron" = "c", "steel" = "Y", "blacksteel" = "K", "bronze" = "O", "copper" = "o", "tin" = "y",
	"gold" = "W", "golden" = "W", "gilded" = "W", "gilbranze" = "W", "silver" = "Y", "silvered" = "Y",
	"draconic" = "R", "sylveric" = "C", "weeping" = "m",
	//Other materials
	"wooden" = "w", "wood" = "w", "oak" = "w", "bone" = "Y", "chitin" = "c", "leather" = "w", "hide" = "w",
	"fur" = "w", "furred" = "w", "cloth" = "y", "linen" = "y", "silk" = "M", "wool" = "y", "woolen" = "y",
	"stone" = "y", "glass" = "C", "crystal" = "C", "obsidian" = "K", "jade" = "G", "ruby" = "R",
	"emerald" = "G", "sapphire" = "B", "topaz" = "O", "amethyst" = "m", "diamond" = "Y", "pearl" = "Y",
	//Aspects
	"blessed" = "Y", "holy" = "Y", "psydonic" = "Y", "sacred" = "Y", "divine" = "W",
	"cursed" = "r", "unholy" = "r", "profane" = "r", "zizite" = "m",
	"enchanted" = "M", "arcyne" = "M", "magic" = "M", "magical" = "M", "runed" = "M",
	"poisoned" = "g", "poison" = "g", "toxic" = "g",
	"bloody" = "R", "bloodied" = "R", "burning" = "O", "frozen" = "C",
	"heavy" = "K", "reinforced" = "c", "padded" = "w", "plate" = "Y", "chain" = "c", "mail" = "c",
))

//Smelt result type => colour of the item's metal, for items whose name does not say what they are made of
GLOBAL_LIST_INIT(paperdoll_smelt_colors, list(
	/obj/item/ingot/gold = "W", /obj/item/ingot/iron = "c", /obj/item/ingot/copper = "o",
	/obj/item/ingot/tin = "y", /obj/item/ingot/bronze = "O", /obj/item/ingot/silver = "Y",
	/obj/item/ingot/steel = "Y", /obj/item/ingot/blacksteel = "K", /obj/item/ingot/gilbranze = "W",
	/obj/item/ingot/draconic = "R", /obj/item/ingot/sylveric = "C",
))

//Words that already name a metal, so the smelt tint is not doubled up
GLOBAL_LIST_INIT(paperdoll_smelt_words, list("iron", "steel", "blacksteel", "bronze", "copper", "tin", "gold", "golden", "gilded",
	"gilbranze", "silver", "silvered", "draconic", "sylveric"))

//"name|smelt" => segments, since names rarely change
GLOBAL_LIST_EMPTY(paperdoll_name_cache)

//Splits [I]'s name into list(list("text", "#colour" or null), ...) segments.
//Words naming an aspect get its colour. Then, for names that do not spell it out, the item's own
//properties fill in: its crafted quality tints the first word, and what it is made of tints the noun.
/proc/paperdoll_name_segments(obj/item/I)
	//What it is made of: the metal it smelts into, else how it is repaired (anvil = metalwork, needle = cloth / leather)
	var/material_code = null
	if(I.smeltresult)
		material_code = GLOB.paperdoll_smelt_colors[I.smeltresult]
	if(!material_code && I.is_silver)
		material_code = "Y"
	if(!material_code && I.anvilrepair)
		material_code = "c"
	if(!material_code && I.sewrepair)
		material_code = "w"
	//How well it was made: pottery / crafting tiers (only for crafted items), and the masterwork polish
	var/quality_code = null
	if(I.creator_skill)
		quality_code = list("r", "w", null, "G", "C", "W")[clamp(I.pottery_quality, 0, 5) + 1]
	if(I.polished >= 4)
		quality_code = "W"

	var/key = "[I.name]|[material_code]|[quality_code]"
	if(key in GLOB.paperdoll_name_cache)
		return GLOB.paperdoll_name_cache[key]

	var/list/words = splittext(I.name, " ")
	var/list/segments = list()
	var/named_material = FALSE
	var/named_quality = FALSE
	for(var/i in 1 to length(words))
		var/word = words[i]
		//Match on the bare lowercase word, so "steel," or "(steel)" still count
		var/bare = LOWER_TEXT(replacetext(replacetext(replacetext(word, ",", ""), "(", ""), ")", ""))
		var/code = GLOB.paperdoll_aspect_words[bare]
		if(code)
			if(bare in GLOB.paperdoll_quality_words)
				named_quality = TRUE
			else
				named_material = TRUE
		segments += list(list("text" = (i < length(words)) ? "[word] " : word, "color" = code ? GLOB.paragon_colors[code] : null))
	if(length(segments))
		//"sword" made of steel: tint the noun in the material's colour
		var/list/last = segments[length(segments)]
		if(material_code && !named_material && !last["color"])
			last["color"] = GLOB.paragon_colors[material_code]
		//A fine piece whose name does not say so: tint the first word in the quality's colour
		var/list/first = segments[1]
		if(quality_code && !named_quality && (length(segments) > 1 || !first["color"]))
			first["color"] = GLOB.paragon_colors[quality_code]
	GLOB.paperdoll_name_cache[key] = segments
	return segments

//Aspect words that describe how well something was made, rather than what it is made of
GLOBAL_LIST_INIT(paperdoll_quality_words, list("ruined", "awful", "crude", "rough", "fine", "flawless", "masterwork", "legendary"))

//Skills tab: every skill grouped by its kind, with level, progress and description
/datum/paperdoll/proc/build_skills()
	var/datum/skill_holder/holder = owner.ensure_skills()
	var/static/list/categories = list(
		/datum/skill/combat = "Combat",
		/datum/skill/magic = "Magic",
		/datum/skill/craft = "Crafting",
		/datum/skill/labor = "Labour",
		/datum/skill/misc = "Miscellaneous",
	)
	var/list/skills = list()
	for(var/skill_type in SSskills.all_skills)
		//all_skills maps each skill type to its shared datum
		var/datum/skill/skill = SSskills.all_skills[skill_type]
		if(!istype(skill))
			continue
		var/category = "Miscellaneous"
		for(var/path in categories)
			if(istype(skill, path))
				category = categories[path]
				break
		var/level = holder.get_skill_level(skill.type)
		var/list/entry = list(
			"name" = skill.name,
			"desc" = skill.desc,
			"category" = category,
			"level" = level,
			"level_name" = SSskills.level_names_plain[level] || "Unskilled",
			"color" = skill.color,
		)
		if(level)
			entry += holder.get_skill_progress(skill)
		skills += list(entry)
	return skills

//Attributes tab: the seven stats, health and stamina, and the traits, vices and faith that shape the character
/datum/paperdoll/proc/build_attributes()
	var/list/data = list()
	data["name"] = owner.real_name
	data["species"] = owner.dna?.species?.name
	data["job"] = owner.job
	data["age"] = owner.age
	data["patron"] = owner.patron?.name
	data["stats"] = list(
		list("key" = "STR", "name" = "Strength", "value" = owner.STASTR, "desc" = "Melee damage, carrying, and forcing things open or apart."),
		list("key" = "PER", "name" = "Perception", "value" = owner.STAPER, "desc" = "Accuracy, sight, and noticing what others hide."),
		list("key" = "INT", "name" = "Intelligence", "value" = owner.STAINT, "desc" = "Learning, crafting, magic, and reading."),
		list("key" = "CON", "name" = "Constitution", "value" = owner.STACON, "desc" = "How much punishment the body takes before it breaks."),
		list("key" = "WIL", "name" = "Willpower", "value" = owner.STAWIL, "desc" = "Stamina, resisting pain and fear, and holding on."),
		list("key" = "SPD", "name" = "Speed", "value" = owner.STASPD, "desc" = "Movement, dodging, and how quickly you act."),
		list("key" = "LUC", "name" = "Fortune", "value" = owner.STALUC, "desc" = "Luck in all things, for better or worse."),
	)
	data["secondary"] = list(
		list("key" = "HP", "name" = "Health", "value" = "[round(max(owner.health, 0) / max(owner.maxHealth, 1) * 100)]%"),
		list("key" = "STA", "name" = "Stamina", "value" = "[round(max(owner.max_stamina - owner.stamina, 0) / max(owner.max_stamina, 1) * 100)]%"),
		list("key" = "EN", "name" = "Energy", "value" = "[round(owner.energy / max(owner.max_energy, 1) * 100)]%"),
	)
	var/list/traits = list()
	for(var/trait in owner.status_traits)
		var/desc = GLOB.roguetraits[trait]
		if(desc)
			traits += list(list("name" = "[trait]", "desc" = desc))
	data["traits"] = traits
	var/list/vices = list()
	for(var/datum/charflaw/vice in owner.vices)
		vices += list(list("name" = vice.name, "desc" = vice.desc))
	data["vices"] = vices
	return data

//Crafting tab, static part: every recipe the owner knows, grouped by its skill, with the result's picture
/datum/paperdoll/proc/build_crafting_recipes(mob/user)
	var/list/recipes = list()
	for(var/datum/crafting_recipe/R as anything in GLOB.crafting_recipes)
		if(!R.name || R.hides_from_crafting_menu)
			continue
		if(!R.always_availible && !(R.type in user?.mind?.learned_recipes))
			continue
		if(R.required_tech_node && !R.tech_unlocked)
			continue
		if(!R.cached_display_data)
			R.build_display_cache()
		var/list/entry = R.cached_display_data.Copy()
		entry["category"] = R.cached_category
		entry["icon"] = paperdoll_asset_url(paperdoll_recipe_icon(R), user?.client)
		recipes += list(entry)
	return recipes

//Picture of what a recipe makes, from the result type's icon
/proc/paperdoll_recipe_icon(datum/crafting_recipe/R)
	var/result = R.result
	if(islist(result))
		var/list/results = result
		result = length(results) ? results[1] : null
	if(!ispath(result, /atom))
		return null
	var/atom/result_type = result
	return paperdoll_icon(initial(result_type.icon), initial(result_type.icon_state))

//Crafting tab, live part: what can be made right now with what is to hand
/datum/paperdoll/proc/build_crafting_state(mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/component/personal_crafting/crafting = istype(H) ? H.craftingthing : null
	var/area/here = get_area(user)
	if(!crafting)
		return list("available" = FALSE)
	var/list/state = crafting.ui_data(user)
	state["available"] = TRUE
	state["can_craft_here"] = !!here?.can_craft_here()
	return state

//Compendium tab: the roleplay primer and the regions of the world (modular_paragon/compendium.dm)
/proc/paperdoll_compendium()
	var/static/list/compendium
	if(compendium)
		return compendium
	var/list/entries = list()
	entries += list(list("title" = "The Primer", "subtitle" = "Paragon Moon", "body" = jointext(GLOB.roleplay_readme, "\n")))
	for(var/region_id in GLOB.fluff_regions)
		var/datum/fluff_region/region = GLOB.fluff_regions[region_id]
		if(region)
			entries += list(list("title" = region.name, "subtitle" = region.subtitle, "body" = region.description, "group" = "Foes of Fate"))
	compendium = entries
	return compendium
