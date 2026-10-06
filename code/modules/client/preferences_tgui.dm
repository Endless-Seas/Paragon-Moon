//Selectable TGUI themes: internal theme id => display name. Add new themes here. To offer a disabled theme, uncomment its line.
//Paragon themes also need a palette in GLOB.paragon_theme_palettes and tgui/styles/paragon_palettes.scss.
GLOBAL_LIST_INIT(tgui_theme_names, list(
	//"azure_default" = "Ascendant",
	//"azure_green" = "Undivided",
	//"azure_lane" = "Azuria",
	//"azure_gold" = "Lirvas",
	//"azure_purple" = "Zybantium",
	//"azure_gilbranze" = "Gilbranze", //Coming soon :tm:
	//"trey_liam" = "Trey Liam",
	"paragon_classic" = "Paragon Classic",
	"paragon_orange" = "Paragon Orange",
	"paragon_grey" = "Paragon Grey",
	"paragon_navy" = "Paragon Navy",
))

//Paragon palettes for the HTML menus and lobby, which read them as --pg-* CSS variables
//(html/browser/common.css, slop_menustyle2/3.css, html/lobby/lobby.html). Keep in sync with
//tgui/styles/paragon_palettes.scss, which colours the TGUI windows and chat.
GLOBAL_LIST_INIT(paragon_theme_palettes, list(
	"paragon_classic" = list("void" = "#04100f", "panel" = "#0b2423", "raised" = "#0f3b3a", "line" = "#155352", "hatch" = "#2a6b68", "frame" = "#4f8f8a",
		"text" = "#b1c9c3", "bright" = "#e8efe9", "accent" = "#40a4b9", "accent2" = "#77bfcf", "gold" = "#cfc041", "green" = "#00c420", "red" = "#d74200", "orange" = "#e99f10"),
	"paragon_orange" = list("void" = "#110904", "panel" = "#1e1209", "raised" = "#33200f", "line" = "#4f3016", "hatch" = "#7a4a22", "frame" = "#a86e3c",
		"text" = "#d6c3ae", "bright" = "#f3e9dc", "accent" = "#e08a3c", "accent2" = "#f4ae6a", "gold" = "#f0cc58", "green" = "#7ac24a", "red" = "#e0442e", "orange" = "#f0a020"),
	"paragon_grey" = list("void" = "#0e0e0f", "panel" = "#18181a", "raised" = "#26262a", "line" = "#37373c", "hatch" = "#4c4c52", "frame" = "#7c7c84",
		"text" = "#c2c2c6", "bright" = "#ececee", "accent" = "#98a2ae", "accent2" = "#c6ced8", "gold" = "#d2bc64", "green" = "#52b456", "red" = "#d24c3c", "orange" = "#e09c34"),
	"paragon_navy" = list("void" = "#060b17", "panel" = "#0b1426", "raised" = "#132344", "line" = "#1c3260", "hatch" = "#2b4884", "frame" = "#5a78b2",
		"text" = "#b6c4de", "bright" = "#e6ecf8", "accent" = "#4a8ad6", "accent2" = "#84b2ee", "gold" = "#e2c262", "green" = "#44c274", "red" = "#e24c3c", "orange" = "#e8a234"),
))

//theme id => "<style>" block setting the --pg-* variables, built once
GLOBAL_LIST_EMPTY(paragon_theme_styles)

//A <style> block that recolours the Paragon HTML menus to [theme] (defaults to Paragon Classic)
/proc/paragon_theme_style(theme)
	if(!(theme in GLOB.paragon_theme_palettes))
		theme = "paragon_classic"
	if(GLOB.paragon_theme_styles[theme])
		return GLOB.paragon_theme_styles[theme]
	var/list/palette = GLOB.paragon_theme_palettes[theme]
	var/list/vars = list()
	for(var/token in palette)
		vars += "--pg-[token]: [palette[token]];"
	. = "<style>:root { [vars.Join(" ")] }</style>"
	GLOB.paragon_theme_styles[theme] = .

//The <style> block for [user]'s chosen theme
/proc/paragon_theme_style_for(user)
	var/client/C = user
	if(ismob(user))
		var/mob/M = user
		C = M.client
	return paragon_theme_style(istype(C) ? C.prefs?.tgui_theme : null)

//Pushes the theme to the chat panel (which re-skins the client window too) and the lobby
/datum/preferences/proc/apply_paragon_theme()
	var/client/C = parent
	if(!istype(C))
		return
	C.tgui_panel?.send_theme()
	if(isnewplayer(C.mob))
		C << output(url_encode(paragon_theme_style(tgui_theme)), "lobby_window.browser:set_paragon_theme")

//Get the display names of the underlying TGUI themes
/datum/preferences/proc/get_tgui_theme_display_name()
	return GLOB.tgui_theme_names[tgui_theme] || tgui_theme

//Falls back to the default theme if the saved one is no longer offered
/datum/preferences/proc/sanitize_tgui_theme()
	if(tgui_theme == "qud") //Paragon Classic's old id
		tgui_theme = "paragon_classic"
	if(!(tgui_theme in GLOB.tgui_theme_names))
		tgui_theme = initial(tgui_theme)

//Cycle through TGUI styles
/datum/preferences/proc/setTguiStyle(mob/user)
	var/list/styles = GLOB.tgui_theme_names
	var/current_index = styles.Find(tgui_theme)
	if(!current_index)
		current_index = 1
	var/next_index = (current_index % styles.len) + 1
	tgui_theme = styles[next_index]
	to_chat(usr, "<span class='notice'>Theme set to [get_tgui_theme_display_name()].</span>")
	save_preferences()
	apply_paragon_theme()
