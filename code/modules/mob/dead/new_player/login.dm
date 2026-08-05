/mob/dead/new_player/Login()
	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()
		client.set_db_player_flags()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	..()

	if(client)
		client.update_ooc_verb_visibility()

	sight |= SEE_TURFS

	addtimer(CALLBACK(src, PROC_REF(do_after_login)), 4 SECONDS)
	new_player_panel()

	if(client)
		client.playtitlemusic()

/mob/dead/new_player/proc/do_after_login()
	PRIVATE_PROC(TRUE)
	if(!client)
		return

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)

	if(GLOB.rogue_round_id)
		to_chat(src, span_info("ROUND ID: [GLOB.rogue_round_id]"))

	if(client.is_new_player())
		to_chat(src, span_userdanger("You are strongly encouraged to join the Discord, if you are somehow whitelisted yet not inside of such."))
		to_chat(src, span_info("You may otherwise miss important news or announcements."))
	else
		var/shown_patreon_level = client.patreonlevel()
		if(!shown_patreon_level)
			shown_patreon_level = "<font color='#7F6899'><b>Pontiff</b></font>"
		switch(shown_patreon_level)
			if(1)
				shown_patreon_level = "Silver"
			if(2)
				shown_patreon_level = "Gold"
			if(3)
				shown_patreon_level = "Mythril"
			if(4)
				shown_patreon_level = "Merchant"
			if(5)
				shown_patreon_level = "Lord"
		to_chat(src, span_info("Donator Level: [shown_patreon_level]"))
//	client.changelog()

	to_chat(src, "<a href='?src=[REF(src)];open_changelog=1' style='color:#638500;text-decoration:underline;'><b>Open Changelog</b></a>")

	to_chat(src, "<a href='?src=[REF(src)];rpprompt=1' style='color:#5CA4B2;text-decoration:underline;'><b>Open Compendium</b></a>")

	if(GLOB.admin_notice)
		to_chat(src, span_notice("<b>Admin Notice:</b>\n \t [GLOB.admin_notice]"))

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, span_notice("<b>Server Notice:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]"))

	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		var/postfix
		if(tl > 0)
			postfix = "in about [DisplayTimeText(tl)]"
		else
			postfix = "soon"
		to_chat(src, "The game will start [postfix].")

		SSvote.send_vote(client)
		var/usedkey = ckey(key)
		var/list/thinz = list("has found safe harbour.", "emerges from their cabin.", "peers out to sea.", "stands at attention!", "bows gracefully.")
		SEND_TEXT(world, span_notice("[usedkey] [pick(thinz)]"))
