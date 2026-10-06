//Quickbar: six bindable HUD slots in the panel space the equipment slots used to fill.
//Bind an item by dragging it onto a slot, or with [bind] in the Inventory popup. Then press the slot
//(or its keybind) to pull the item into your active hand from wherever you carry it; press again while
//holding it to put it back where it came from (its bag, sheath or worn slot). When a bound item is used up, the slot
//remembers its type and picks up the next one you carry. Right-click a slot to clear it.

#define QUICKBAR_SIZE 6

/mob/living/carbon/human
	//Weakrefs to the items bound to each quickbar slot
	var/list/quickbar_items = new /list(QUICKBAR_SIZE)
	//Type of each bound item, so the slot can fall back to another one of the same kind
	var/list/quickbar_types = new /list(QUICKBAR_SIZE)
	//Where each slot last took its item from: a weakref to the container or scabbard, or a worn slot id
	var/list/quickbar_origins = new /list(QUICKBAR_SIZE)

//Every item on this mob: held, worn, and inside worn or held containers (a few bags deep)
/mob/living/carbon/human/proc/get_carried_items()
	var/list/found = list()
	var/list/queue = list()
	for(var/obj/item/I in held_items)
		queue += I
	for(var/list/slot as anything in GLOB.paperdoll_slots)
		var/obj/item/I = get_item_by_slot(slot["id"])
		if(I)
			queue += I
	var/depth = 0
	while(length(queue) && depth < 4)
		var/list/next = list()
		for(var/obj/item/I in queue)
			if(I.item_flags & ABSTRACT)
				continue
			found += I
			var/datum/component/storage/storage = I.GetComponent(/datum/component/storage)
			var/atom/real_location = storage?.real_location()
			if(real_location)
				for(var/obj/item/inner in real_location)
					next += inner
			//Sheathed weapons sit inside their scabbard without a storage component
			var/obj/item/rogueweapon/scabbard/scabbard = I
			if(istype(scabbard) && scabbard.sheathed)
				next += scabbard.sheathed
		queue = next
		depth++
	return found

//The bound item for [index], falling back to another carried item of the same type
/mob/living/carbon/human/proc/quickbar_resolve(index)
	var/datum/weakref/ref = quickbar_items[index]
	var/obj/item/I = ref?.resolve()
	var/list/carried = get_carried_items()
	if(I && (I in carried))
		return I
	var/bound_type = quickbar_types[index]
	if(!bound_type)
		return null
	for(var/obj/item/candidate in carried)
		if(candidate.type == bound_type)
			quickbar_watch(index, candidate)
			return candidate
	return null

/mob/living/carbon/human/proc/quickbar_bind(index, obj/item/I)
	if(!isnum(index) || index < 1 || index > QUICKBAR_SIZE || !istype(I))
		return
	quickbar_types[index] = I.type
	quickbar_watch(index, I)
	to_chat(src, span_notice("[I] is bound to quick slot [index]."))

/mob/living/carbon/human/proc/quickbar_clear(index)
	var/datum/weakref/ref = quickbar_items[index]
	var/obj/item/old = ref?.resolve()
	if(old)
		UnregisterSignal(old, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	quickbar_items[index] = null
	quickbar_types[index] = null
	quickbar_origins[index] = null
	update_quickbar()

//Tracks [I] in slot [index] and refreshes the HUD whenever it moves or is destroyed
/mob/living/carbon/human/proc/quickbar_watch(index, obj/item/I)
	var/datum/weakref/ref = quickbar_items[index]
	var/obj/item/old = ref?.resolve()
	if(old && old != I && !(old in quickbar_bound_items(index)))
		UnregisterSignal(old, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	quickbar_items[index] = WEAKREF(I)
	RegisterSignal(I, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), PROC_REF(on_quickbar_item_changed), override = TRUE)
	update_quickbar()

//Items bound to any slot other than [except]
/mob/living/carbon/human/proc/quickbar_bound_items(except)
	var/list/items = list()
	for(var/i in 1 to QUICKBAR_SIZE)
		if(i == except)
			continue
		var/datum/weakref/ref = quickbar_items[i]
		var/obj/item/I = ref?.resolve()
		if(I)
			items += I
	return items

/mob/living/carbon/human/proc/on_quickbar_item_changed(datum/source)
	SIGNAL_HANDLER
	//Moving happens a lot (in and out of hands), so batch the HUD refresh to the next tick
	addtimer(CALLBACK(src, PROC_REF(update_quickbar)), 1, TIMER_UNIQUE | TIMER_OVERRIDE)

//Refs bound to each slot, for the Inventory popup's [bind] markers
/mob/living/carbon/human/proc/quickbar_refs()
	var/list/refs = list()
	for(var/i in 1 to QUICKBAR_SIZE)
		var/datum/weakref/ref = quickbar_items[i]
		var/obj/item/I = ref?.resolve()
		refs += I ? REF(I) : ""
	return refs

/mob/living/carbon/human/proc/quickbar_use(index)
	if(!isnum(index) || index < 1 || index > QUICKBAR_SIZE)
		return
	if(world.time <= next_move || incapacitated())
		return
	var/obj/item/I = quickbar_resolve(index)
	if(!I)
		if(quickbar_types[index])
			to_chat(src, span_warning("I have nothing like that left."))
		return
	var/obj/item/held = get_active_held_item()
	if(I in held_items)
		quickbar_return(index, I)
		update_quickbar()
		return
	var/obj/item/rogueweapon/scabbard/scabbard = I.loc
	if(istype(scabbard) && scabbard.sheathed == I)
		//A bound weapon that is sheathed: draw it
		if(held)
			to_chat(src, span_warning("My hand is full."))
			return
		quickbar_origins[index] = WEAKREF(scabbard)
		scabbard.puke_sword(src)
	else if(I.loc == src)
		for(var/list/slot as anything in GLOB.paperdoll_slots)
			if(get_item_by_slot(slot["id"]) == I)
				quickbar_origins[index] = slot["id"]
				break
		//Worn: exactly what clicking its old HUD slot did. With an empty hand that draws from a sheath or
		//strap and opens bags; with something held it sheathes or stows it
		I.Click(null, null, "left=1")
	else if(held)
		to_chat(src, span_warning("My hand is full."))
		return
	else
		var/atom/container = I.loc
		if(paperdoll_take_from_storage(I, src))
			quickbar_origins[index] = WEAKREF(container)
	update_quickbar()

//Puts a held bound item back where the slot took it from, or failing that into any bag, sheath or slot that fits
/mob/living/carbon/human/proc/quickbar_return(index, obj/item/I)
	if(HAS_TRAIT(I, TRAIT_NODROP))
		to_chat(src, span_warning("[I] won't leave my hand!"))
		return FALSE
	var/origin = quickbar_origins[index]
	if(isnum(origin))
		if(equip_to_slot_if_possible(I, origin, FALSE, TRUE))
			return TRUE
	else if(istype(origin, /datum/weakref))
		var/datum/weakref/ref = origin
		if(quickbar_stow(I, ref.resolve()))
			return TRUE
	//Nowhere remembered, or it is full now: try every bag and sheath I carry, then any slot it can be worn in
	for(var/obj/item/carried in get_carried_items())
		if(carried != I && quickbar_stow(I, carried, TRUE))
			return TRUE
	if(equip_to_appropriate_slot(I))
		return TRUE
	to_chat(src, span_warning("I have nowhere to put [I]."))
	return FALSE

//Tries to put [I] into [target] if it is a bag or scabbard I carry
/mob/living/carbon/human/proc/quickbar_stow(obj/item/I, obj/item/target, silent = FALSE)
	if(!istype(target) || !(target in get_carried_items()))
		return FALSE
	var/obj/item/rogueweapon/scabbard/scabbard = target
	if(istype(scabbard))
		if(scabbard.sheathed || (silent && !scabbard.weapon_check_quiet(I)))
			return FALSE
		return scabbard.eat_sword(src, I)
	if(!paperdoll_capacity(target))
		return FALSE
	if(!SEND_SIGNAL(target, COMSIG_TRY_STORAGE_CAN_INSERT, I, src, TRUE))
		return FALSE
	return SEND_SIGNAL(target, COMSIG_TRY_STORAGE_INSERT, I, src)

/mob/living/carbon/human/proc/update_quickbar()
	if(!hud_used)
		return
	for(var/atom/movable/screen/quickslot/slot in hud_used.static_inventory)
		slot.update_icon()

/atom/movable/screen/quickslot
	name = "quick slot"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "pd_quick"
	var/index = 1

/atom/movable/screen/quickslot/Initialize(mapload, new_index)
	. = ..()
	if(new_index)
		index = new_index
	//Slots sit in a 3 x 2 block under the hands in the right-hand column (paragon_hud.dm)
	screen_loc = "EAST+[1 + ((index - 1) % 3)]:16,SOUTH+[1 - round((index - 1) / 3)]"
	maptext = "<span style='font-family:\"Small Fonts\"; font-size:6px; color:#cfc041; -dm-text-outline:1px #04100f'>[index]</span>"
	maptext_x = 3
	maptext_y = 20

/atom/movable/screen/quickslot/update_overlays()
	. = ..()
	var/mob/living/carbon/human/H = hud?.mymob
	if(!istype(H))
		return
	var/datum/weakref/ref = H.quickbar_items[index]
	var/obj/item/I = ref?.resolve()
	var/list/carried_items = H.get_carried_items()
	if(!(I in carried_items) && H.quickbar_types[index])
		//Bound item is gone; preview the next one of its kind that the slot will pick up
		for(var/obj/item/candidate in carried_items)
			if(candidate.type == H.quickbar_types[index])
				I = candidate
				break
	var/carried = I && (I in carried_items)
	if(!I && H.quickbar_types[index])
		//Bound but used up: show a faded picture of the kind of thing it was
		var/obj/item/path = H.quickbar_types[index]
		var/mutable_appearance/ghost = mutable_appearance(initial(path.icon), initial(path.icon_state), layer + 0.1, plane)
		ghost.transform = quickslot_fit(initial(path.icon))
		ghost.alpha = 70
		. += ghost
		name = "quick slot [index] (none left)"
		return
	if(!I)
		name = "quick slot [index]"
		return
	var/mutable_appearance/picture = quickslot_picture(I)
	picture.plane = plane
	picture.layer = layer + 0.1
	picture.alpha = carried ? 255 : 70
	. += picture
	name = "quick slot [index]: [I.name]"

/atom/movable/screen/quickslot/Click(location, control, params)
	var/mob/living/carbon/human/H = usr
	if(!istype(H) || H != hud?.mymob)
		return
	var/list/modifiers = params2list(params)
	if(modifiers["right"])
		H.quickbar_clear(index)
		return
	if(modifiers["shift"])
		var/obj/item/I = H.quickbar_resolve(index)
		if(I)
			H.examinate(I)
		return
	H.quickbar_use(index)

/atom/movable/screen/quickslot/MouseDrop_T(atom/dropped, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || H != hud?.mymob || !isitem(dropped))
		return
	if(!(dropped in H.get_carried_items()))
		return
	H.quickbar_bind(index, dropped)

/datum/hud/human/proc/build_quickbar()
	for(var/i in 1 to QUICKBAR_SIZE)
		var/atom/movable/screen/quickslot/slot = new(null, i)
		slot.hud = src
		static_inventory += slot
		slot.update_icon()

/datum/keybinding/human/quickbar
	hotkey_keys = null //Abstract; the numbered slots below are the real bindings
	var/index = 1

/datum/keybinding/human/quickbar/down(client/user)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = user.mob
	if(!istype(H))
		return FALSE
	H.quickbar_use(index)
	return TRUE

/datum/keybinding/human/quickbar/one
	name = "quickbar_1"
	full_name = "Quick slot 1"
	description = "Use the item bound to quick slot 1"
	hotkey_keys = list("Unbound")
	index = 1

/datum/keybinding/human/quickbar/two
	name = "quickbar_2"
	full_name = "Quick slot 2"
	description = "Use the item bound to quick slot 2"
	hotkey_keys = list("Unbound")
	index = 2

/datum/keybinding/human/quickbar/three
	name = "quickbar_3"
	full_name = "Quick slot 3"
	description = "Use the item bound to quick slot 3"
	hotkey_keys = list("Unbound")
	index = 3

/datum/keybinding/human/quickbar/four
	name = "quickbar_4"
	full_name = "Quick slot 4"
	description = "Use the item bound to quick slot 4"
	hotkey_keys = list("Unbound")
	index = 4

/datum/keybinding/human/quickbar/five
	name = "quickbar_5"
	full_name = "Quick slot 5"
	description = "Use the item bound to quick slot 5"
	hotkey_keys = list("Unbound")
	index = 5

/datum/keybinding/human/quickbar/six
	name = "quickbar_6"
	full_name = "Quick slot 6"
	description = "Use the item bound to quick slot 6"
	hotkey_keys = list("Unbound")
	index = 6

#undef QUICKBAR_SIZE

//Pixel size of each icon file, so big sprites can be shrunk and centred in a 32px slot
GLOBAL_LIST_EMPTY(quickslot_icon_sizes)

//The item's look, cleaned of everything it picks up from where it sits (grid underlays, screen offsets, scaling) and fitted to one tile
/proc/quickslot_picture(obj/item/I)
	var/mutable_appearance/picture = new(I)
	picture.underlays = list()
	picture.screen_loc = null
	picture.pixel_x = 0
	picture.pixel_y = 0
	picture.pixel_w = 0
	picture.pixel_z = 0
	picture.transform = quickslot_fit(I.icon)
	return picture

//Matrix that shrinks [icon_file]'s sprites to one tile if needed and centres them on it
/proc/quickslot_fit(icon_file)
	var/list/size = GLOB.quickslot_icon_sizes["[icon_file]"]
	if(!size)
		var/icon/sizer = icon(icon_file)
		size = list(sizer.Width(), sizer.Height())
		GLOB.quickslot_icon_sizes["[icon_file]"] = size
	var/matrix/fit = matrix()
	var/largest = max(size[1], size[2])
	if(largest > world.icon_size)
		//Scale about the sprite's centre, then shift that centre onto the tile's centre
		fit.Scale(world.icon_size / largest)
	fit.Translate((world.icon_size - size[1]) / 2, (world.icon_size - size[2]) / 2)
	return fit

//weapon_check without the chat messages, for trying every sheath in turn
/obj/item/rogueweapon/scabbard/proc/weapon_check_quiet(obj/A)
	if(sheathed)
		return FALSE
	if(valid_blade && !istype(A, valid_blade))
		return FALSE
	if(valid_blades && !(A.type in valid_blades))
		return FALSE
	if(invalid_blades && (A.type in invalid_blades))
		return FALSE
	return TRUE
