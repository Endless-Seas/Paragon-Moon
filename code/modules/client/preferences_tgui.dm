/// Selectable TGUI themes: internal theme id => display name. Add new themes here. To offer a disabled theme, uncomment its line.
GLOBAL_LIST_INIT(tgui_theme_names, list(
	// "azure_default" = "Ascendant",
	// "azure_green" = "Undivided",
	// "azure_lane" = "Azuria",
	// "azure_gold" = "Lirvas",
	// "azure_purple" = "Zybantium",
	// "azure_gilbranze" = "Gilbranze", // Coming soon :tm:
	// "trey_liam" = "Trey Liam",
	"qud" = "Qud"
))

// Get the display names of the underlying TGUI themes
/datum/preferences/proc/get_tgui_theme_display_name()
	return GLOB.tgui_theme_names[tgui_theme] || tgui_theme

/// Falls back to the default theme if the saved one is no longer offered
/datum/preferences/proc/sanitize_tgui_theme()
	if(!(tgui_theme in GLOB.tgui_theme_names))
		tgui_theme = initial(tgui_theme)

// Cycle through TGUI styles
/datum/preferences/proc/setTguiStyle(mob/user)
	var/list/styles = GLOB.tgui_theme_names
	var/current_index = styles.Find(tgui_theme)
	if(!current_index)
		current_index = 1
	var/next_index = (current_index % styles.len) + 1
	tgui_theme = styles[next_index]
	to_chat(usr, "<span class='notice'>TGUI style set to [get_tgui_theme_display_name()].</span>")
	save_preferences()
