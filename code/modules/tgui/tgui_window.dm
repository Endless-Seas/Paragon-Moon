/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/datum/tgui_window
	var/id
	var/client/client
	var/pooled
	var/pool_index
	var/is_browser = FALSE
	var/status = TGUI_WINDOW_CLOSED
	var/locked = FALSE
	var/visible = FALSE
	var/datum/tgui/locked_by
	var/datum/subscriber_object
	var/subscriber_delegate
	var/fatally_errored = FALSE
	var/message_queue
	var/sent_assets = list()
	// Vars passed to initialize proc (and saved for later)
	var/initial_strict_mode
	var/initial_fancy
	var/initial_assets
	var/initial_inline_html
	var/initial_inline_js
	var/initial_inline_css

	var/list/oversized_payloads = list()
	var/list/completed_payloads = list()
	/// Changes whenever a pooled window changes owners; never reuse an old action.
	var/session_id = 0

/**
 * public
 *
 * Create a new tgui window.
 *
 * required client /client
 * required id string A unique window identifier.
 */
/datum/tgui_window/New(client/client, id, pooled = FALSE)
	src.id = id
	src.client = client
	src.client.tgui_windows[id] = src
	src.pooled = pooled
	if(pooled)
		src.pool_index = TGUI_WINDOW_INDEX(id)

/**
 * public
 *
 * Initializes the window with a fresh page. Puts window into the "loading"
 * state. You can begin sending messages right after initializing. Messages
 * will be put into the queue until the window finishes loading.
 *
 * optional strict_mode bool - Enables strict error handling and BSOD.
 * optional fancy bool - If TRUE and if this is NOT a panel, will hide the window titlebar.
 * optional assets list - List of assets to load during initialization.
 * optional inline_html string - Custom HTML to inject.
 * optional inline_js string - Custom JS to inject.
 * optional inline_css string - Custom CSS to inject.
 */
/datum/tgui_window/proc/initialize(
		strict_mode = FALSE,
		fancy = FALSE,
		assets = list(),
		inline_html = "",
		inline_js = "",
		inline_css = "")
	log_tgui(client,
		context = "[id]/initialize",
		window = src)
	if(!client)
		return
	src.initial_fancy = fancy
	src.initial_strict_mode = strict_mode
	src.initial_assets = assets
	src.initial_inline_html = inline_html
	src.initial_inline_js = inline_js
	src.initial_inline_css = inline_css
	status = TGUI_WINDOW_LOADING
	fatally_errored = FALSE
	// Build window options
	var/options = "file=[id].html;can_minimize=0;auto_format=0;"
	// Remove titlebar and resize handles for a fancy window
	if(fancy)
		options += "titlebar=0;can_resize=0;"
	else
		options += "titlebar=1;can_resize=1;"
	// Generate page html
	var/html = SStgui.basehtml
	html = replacetextEx(html, "\[tgui:windowId]", id)
	html = replacetextEx(html, "\[tgui:strictMode]", strict_mode)
	// Inject assets
	var/inline_assets_str = ""
	for(var/datum/asset/asset in assets)
		var/mappings = asset.get_url_mappings()
		for(var/name in mappings)
			var/url = mappings[name]
			// Not encoding since asset strings are considered safe
			if(copytext(name, -4) == ".css")
				inline_assets_str += "Byond.loadCss('[url]', true);\n"
			else if(copytext(name, -3) == ".js")
				inline_assets_str += "Byond.loadJs('[url]', true);\n"
		asset.send(client)
	if(length(inline_assets_str))
		inline_assets_str = "<script>\n" + inline_assets_str + "</script>\n"
	html = replacetextEx(html, "<!-- tgui:assets -->\n", inline_assets_str)
	// Inject inline HTML
	if (inline_html)
		html = replacetextEx(html, "<!-- tgui:inline-html -->", isfile(inline_html) ? file2text(inline_html) : inline_html)
	// Inject inline JS
	if (inline_js)
		inline_js = "<script>\n'use strict';\n[isfile(inline_js) ? file2text(inline_js) : inline_js]\n</script>"
		html = replacetextEx(html, "<!-- tgui:inline-js -->", inline_js)
	// Inject inline CSS
	if (inline_css)
		inline_css = "<style>\n[isfile(inline_css) ? file2text(inline_css) : inline_css]\n</style>"
		html = replacetextEx(html, "<!-- tgui:inline-css -->", inline_css)
	// Open the window
	client << browse(html, "window=[id];[options]")
	// Detect whether the control is a browser
	is_browser = winexists(client, id) == "BROWSER"
	// Instruct the client to signal UI when the window is closed.
	if(!is_browser && client)
		winset(client, id, "on-close=\"uiclose [id]\"")

/**
 * public
 *
 * Reinitializes the panel with previous data used for initialization.
 */
/datum/tgui_window/proc/reinitialize()
	initialize(
		strict_mode = initial_strict_mode,
		fancy = initial_fancy,
		assets = initial_assets,
		inline_html = initial_inline_html,
		inline_js = initial_inline_js,
		inline_css = initial_inline_css)
	// Resend assets
	for(var/datum/asset/asset in sent_assets)
		send_asset(asset)

/**
 * public
 *
 * Checks if the window is ready to receive data.
 *
 * return bool
 */
/datum/tgui_window/proc/is_ready()
	return status == TGUI_WINDOW_READY

/**
 * public
 *
 * Checks if the window can be sanely suspended.
 *
 * return bool
 */
/datum/tgui_window/proc/can_be_suspended()
	return !fatally_errored \
		&& pooled \
		&& pool_index > 0 \
		&& pool_index <= TGUI_WINDOW_SOFT_LIMIT \
		&& status == TGUI_WINDOW_READY

/**
 * public
 *
 * Acquire the window lock. Pool will not be able to provide this window
 * to other UIs for the duration of the lock.
 *
 * Can be given an optional tgui datum, which will be automatically
 * subscribed to incoming messages via the on_message proc.
 *
 * optional ui /datum/tgui
 */
/datum/tgui_window/proc/acquire_lock(datum/tgui/ui)
	clear_oversized_payloads()
	session_id++
	locked = TRUE
	locked_by = ui

/**
 * public
 *
 * Release the window lock.
 */
/datum/tgui_window/proc/release_lock()
	clear_oversized_payloads()
	session_id++
	// Clean up assets sent by tgui datum which requested the lock
	if(locked)
		sent_assets = list()
	locked = FALSE
	locked_by = null

/**
 * public
 *
 * Subscribes the datum to consume window messages on a specified proc.
 *
 * Note, that this supports only one subscriber, because code for that
 * is simpler and therefore faster. If necessary, this can be rewritten
 * to support multiple subscribers.
 */
/datum/tgui_window/proc/subscribe(datum/object, delegate)
	subscriber_object = object
	subscriber_delegate = delegate

/**
 * public
 *
 * Unsubscribes the datum. Do not forget to call this when cleaning up.
 */
/datum/tgui_window/proc/unsubscribe(datum/object)
	subscriber_object = null
	subscriber_delegate = null

/**
 * public
 *
 * Close the UI.
 *
 * optional can_be_suspended bool
 */
/datum/tgui_window/proc/close(can_be_suspended = TRUE)
	clear_oversized_payloads()
	if(!client)
		return
	if(can_be_suspended && can_be_suspended())
		log_tgui(client,
			context = "[id]/close (suspending)",
			window = src)
		visible = FALSE
		status = TGUI_WINDOW_READY
		send_message("suspend")
		return
	log_tgui(client,
		context = "[id]/close",
		window = src)
	release_lock()
	visible = FALSE
	status = TGUI_WINDOW_CLOSED
	message_queue = null
	// Do not close the window to give user some time
	// to read the error message.
	if(!fatally_errored)
		client << browse(null, "window=[id]")

/**
 * public
 *
 * Sends a message to tgui window.
 *
 * required type string Message type
 * required payload list Message payload
 * optional force bool Send regardless of the ready status.
 */
/datum/tgui_window/proc/send_message(type, payload, force)
	if(!client)
		return
	var/message = TGUI_CREATE_MESSAGE(type, payload)
	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * public
 *
 * Sends a raw payload to tgui window.
 *
 * required message string JSON+urlencoded blob to send.
 * optional force bool Send regardless of the ready status.
 */
/datum/tgui_window/proc/send_raw_message(message, force)
	if(!client)
		return
	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * public
 *
 * Makes an asset available to use in tgui.
 *
 * required asset datum/asset
 *
 * return bool - TRUE if any assets had to be sent to the client
 */
/datum/tgui_window/proc/send_asset(datum/asset/asset)
	if(!client || !asset)
		return
	sent_assets |= list(asset)
	. = asset.send(client)
	if(istype(asset, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/spritesheet = asset
		send_message("asset/stylesheet", spritesheet.css_filename())
	// else if(istype(asset, /datum/asset/spritesheet_batched))
	// 	var/datum/asset/spritesheet_batched/spritesheet = asset
	// 	send_message("asset/stylesheet", spritesheet.css_filename())
	send_raw_message(asset.get_serialized_url_mappings())

/**
 * private
 *
 * Sends queued messages if the queue wasn't empty.
 */
/datum/tgui_window/proc/flush_message_queue()
	if(!client || !message_queue)
		return
	for(var/message in message_queue)
		client << output(message, is_browser \
			? "[id]:update" \
			: "[id].browser:update")
	message_queue = null

/**
 * public
 *
 * Replaces the inline HTML content.
 *
 * required inline_html string HTML to inject
 */
/datum/tgui_window/proc/replace_html(inline_html = "")
	client << output(url_encode(inline_html), is_browser \
		? "[id]:replaceHtml" \
		: "[id].browser:replaceHtml")

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_window/proc/on_message(type, payload, href_list)
	if(!istext(type))
		return
	// A delayed close request must not close the next owner of a pooled window.
	if(type == "suspend" && href_list["windowSession"] != "[session_id]")
		return
	if(copytext(type, 1, 5) == "act/" || type == "setSharedState")
		if(!can_accept_payload() || href_list["windowSession"] != "[session_id]")
			// Old cached bundles cannot attach actions to the current owner.
			if(locked && !href_list["windowSession"])
				reinitialize()
			return
	// Status can be READY if user has refreshed the window.
	if(type == "ready" && status == TGUI_WINDOW_READY)
		// Resend the assets
		for(var/asset in sent_assets)
			send_asset(asset)
	// Mark this window as fatally errored which prevents it from
	// being suspended.
	if(type == "log" && href_list["fatal"])
		fatally_errored = TRUE
	// Mark window as ready since we received this message from somewhere
	if(status != TGUI_WINDOW_READY)
		status = TGUI_WINDOW_READY
		flush_message_queue()
	// Pass message to UI that requested the lock
	if(locked && locked_by)
		var/prevent_default = locked_by.on_message(type, payload, href_list)
		if(prevent_default)
			return
	// Pass message to the subscriber
	else if(subscriber_object)
		var/prevent_default = call(
			subscriber_object,
			subscriber_delegate)(type, payload, href_list)
		if(prevent_default)
			return
	// If not locked, handle these message types
	switch(type)
		if("ping")
			send_message("ping/reply", payload)
		if("visible")
			visible = TRUE
			SEND_SIGNAL(src, COMSIG_TGUI_WINDOW_VISIBLE, client)
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("openLink")
			client << link(href_list["url"])
		if("cacheReloaded")
			reinitialize()
		if("chat/resend")
			if(client?.tgui_panel?.window == src && isnum(payload) && payload >= 0 && payload == round(payload))
				SSchat.handle_resend(client, payload)
		if("oversizedPayloadRequest")
			if(!islist(payload))
				return
			var/payload_id = payload["id"]
			var/chunk_count = payload["chunkCount"]
			var/permit_payload = create_oversized_payload(payload_id, payload["type"], chunk_count, payload["session"])
			var/interval = 750
			var/minute_limit = CONFIG_GET(number/minute_topic_limit)
			var/second_limit = CONFIG_GET(number/second_topic_limit)
			if(minute_limit)
				interval = max(interval, 61000 / minute_limit)
			if(second_limit)
				interval = max(interval, 1100 / second_limit)
			send_message("oversizePayloadResponse", list("allow" = permit_payload, "id" = payload_id, "interval" = interval))
		if("payloadChunk")
			if(islist(payload))
				append_payload_chunk(payload["id"], payload["chunk"], payload["index"], payload["session"])
		if("cancelPayload")
			if(islist(payload) && payload["session"] == session_id && istext(payload["id"]))
				remove_oversized_payload(payload["id"])

/datum/tgui_window/vv_edit_var(var_name, var_value)
	return var_name != NAMEOF(src, id) && ..()

/datum/tgui_window/proc/can_accept_payload()
	if(!client || !locked || QDELETED(locked_by) || locked_by.closing || QDELETED(locked_by.user) || locked_by.user.client != client || QDELETED(locked_by.src_object))
		return FALSE
	locked_by.process_status()
	return locked_by.status == UI_INTERACTIVE

/datum/tgui_window/proc/create_oversized_payload(payload_id, message_type, chunk_count, session)
	if(!can_accept_payload() || session != session_id)
		return FALSE
	if(!istext(payload_id) || !length(payload_id) || length(payload_id) > 80)
		return FALSE
	if(!istext(message_type) || copytext(message_type, 1, 5) != "act/" || length(message_type) > 128)
		return FALSE
	if(!isnum(chunk_count) || chunk_count != round(chunk_count) || chunk_count < 1 || chunk_count > TGUI_MAX_CHUNKS)
		return FALSE
	var/list/existing = oversized_payloads[payload_id]
	if(existing)
		return existing["type"] == message_type && existing["count"] == chunk_count
	if(length(oversized_payloads) >= TGUI_MAX_PAYLOADS || completed_payloads[payload_id])
		return FALSE
	oversized_payloads[payload_id] = list(
		"type" = message_type,
		"count" = chunk_count,
		"chunks" = list(),
		"session" = session,
		"owner" = locked_by,
		"created" = world.time,
		"timeout" = addtimer(CALLBACK(src, PROC_REF(remove_oversized_payload), payload_id), TGUI_PAYLOAD_TIMEOUT, TIMER_STOPPABLE)
	)
	return TRUE

/datum/tgui_window/proc/append_payload_chunk(payload_id, chunk, chunk_index, session)
	if(!istext(payload_id) || session != session_id)
		return
	var/list/payload = oversized_payloads[payload_id]
	var/list/completed = completed_payloads[payload_id]
	if(completed && completed["index"] == chunk_index && completed["expires"] > world.time)
		send_message("acknowledgePayloadChunk", list("id" = payload_id, "index" = chunk_index))
		return
	if(!payload)
		send_message("rejectPayload", list("id" = payload_id))
		return
	if(!can_accept_payload() || payload["owner"] != locked_by || payload["session"] != session_id || world.time > payload["created"] + TGUI_PAYLOAD_LIFETIME)
		remove_oversized_payload(payload_id)
		send_message("rejectPayload", list("id" = payload_id))
		return
	if(!istext(chunk) || !length(chunk) || length(url_encode(chunk)) > TGUI_MAX_CHUNK_SIZE || !isnum(chunk_index) || chunk_index != round(chunk_index) || chunk_index < 0)
		remove_oversized_payload(payload_id)
		send_message("rejectPayload", list("id" = payload_id))
		return
	var/list/chunks = payload["chunks"]
	// Retries acknowledge the same index without appending or executing twice.
	if(chunk_index < length(chunks) && chunks[chunk_index + 1] == chunk)
		send_message("acknowledgePayloadChunk", list("id" = payload_id, "index" = chunk_index))
		return
	if(chunk_index != length(chunks))
		remove_oversized_payload(payload_id)
		send_message("rejectPayload", list("id" = payload_id))
		return
	chunks += chunk
	if(length(chunks) == payload["count"])
		var/message_type = payload["type"]
		var/final_payload = chunks.Join()
		remove_oversized_payload(payload_id)
		if(copytext(final_payload, 1, 2) != "{" || !rustg_json_is_valid(final_payload))
			send_message("rejectPayload", list("id" = payload_id))
			return
		var/list/decoded = json_decode(final_payload)
		if(!islist(decoded))
			return
		if(length(completed_payloads) >= 16)
			completed_payloads.Cut(1, 2)
		completed_payloads[payload_id] = list("index" = chunk_index, "expires" = world.time + TGUI_PAYLOAD_TIMEOUT)
		send_message("acknowledgePayloadChunk", list("id" = payload_id, "index" = chunk_index))
		on_message(message_type, decoded, list("type" = message_type, "payload" = final_payload, "tgui" = TRUE, "window_id" = id, "windowSession" = "[session_id]"))
	else
		deltimer(payload["timeout"])
		payload["timeout"] = addtimer(CALLBACK(src, PROC_REF(remove_oversized_payload), payload_id), TGUI_PAYLOAD_TIMEOUT, TIMER_STOPPABLE)
		send_message("acknowledgePayloadChunk", list("id" = payload_id, "index" = chunk_index))

/datum/tgui_window/proc/remove_oversized_payload(payload_id)
	var/list/payload = oversized_payloads[payload_id]
	if(payload)
		deltimer(payload["timeout"])
	oversized_payloads -= payload_id

/datum/tgui_window/proc/clear_oversized_payloads()
	for(var/payload_id in oversized_payloads.Copy())
		remove_oversized_payload(payload_id)
	completed_payloads.Cut()
