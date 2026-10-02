/// No real clients are needed to exercise the queue; real ui_state checks also
/// require the ordinary-player and two-client acceptance tests.
/datum/tgui_window/transport_test
	var/allow_actions = TRUE
	var/list/received_actions = list()
	var/list/replies = list()

/datum/tgui_window/transport_test/New()
	id = "transport-test"
	status = TGUI_WINDOW_READY
	locked = TRUE
	locked_by = new /datum/tgui/transport_test

/datum/tgui/transport_test/New()
	return

/datum/tgui/transport_test
	var/suspend_requests = 0

/datum/tgui/transport_test/on_message(type, payload, href_list)
	if(type == "suspend")
		suspend_requests++
	return TRUE

/datum/tgui_window/transport_test/can_accept_payload()
	return allow_actions && locked && locked_by

/datum/tgui_window/transport_test/send_message(type, payload, force)
	replies += list(list("type" = type, "payload" = payload))

/datum/tgui_window/transport_test/on_message(type, payload, href_list)
	if(copytext(type, 1, 5) == "act/")
		received_actions += list(payload)
		return
	return ..()

/datum/unit_test/tgui_transport/Run()
	var/datum/tgui_window/transport_test/window = new
	var/session = window.session_id
	TEST_ASSERT(!window.create_oversized_payload("bad", "act/test", 0, session), "Zero chunks must be rejected")
	TEST_ASSERT(!window.create_oversized_payload("bad", "act/test", "2", session), "Text chunk counts must be rejected")
	TEST_ASSERT(!window.create_oversized_payload("bad", "act/test", TGUI_MAX_CHUNKS + 1, session), "Oversize requests must be rejected")
	TEST_ASSERT(!window.create_oversized_payload("bad", "close", 1, session), "Chunk transport must only dispatch actions")
	TEST_ASSERT(window.create_oversized_payload("valid", "act/test", 2, session), "Valid request should be accepted")
	window.append_payload_chunk("valid", "{\"text\":", 0, session)
	window.append_payload_chunk("valid", "{\"text\":", 0, session)
	TEST_ASSERT_EQUAL(length(window.oversized_payloads["valid"]["chunks"]), 1, "Retries must not append twice")
	window.append_payload_chunk("valid", "\"Zażółć 🦊\"}", 1, session)
	window.append_payload_chunk("valid", "\"Zażółć 🦊\"}", 1, session)
	TEST_ASSERT_EQUAL(length(window.received_actions), 1, "A completed action must execute exactly once")
	TEST_ASSERT_EQUAL(window.received_actions[1]["text"], "Zażółć 🦊", "Unicode payload must round trip")
	TEST_ASSERT_EQUAL(length(window.oversized_payloads), 0, "Completion must release storage")

	window.create_oversized_payload("invalid-json", "act/test", 1, session)
	window.append_payload_chunk("invalid-json", "{broken", 0, session)
	TEST_ASSERT_EQUAL(length(window.received_actions), 1, "Malformed JSON must not execute")
	window.create_oversized_payload("revoked", "act/test", 1, session)
	window.allow_actions = FALSE
	window.append_payload_chunk("revoked", "{}", 0, session)
	TEST_ASSERT_EQUAL(length(window.received_actions), 1, "Permission changes must reject pending actions")
	window.allow_actions = TRUE

	window.create_oversized_payload("expired", "act/test", 1, session)
	window.oversized_payloads["expired"]["created"] = world.time - TGUI_PAYLOAD_LIFETIME - 1
	window.append_payload_chunk("expired", "{}", 0, session)
	TEST_ASSERT_EQUAL(length(window.received_actions), 1, "Expired transfers must not execute")
	window.create_oversized_payload("first", "act/test", 1, session)
	window.create_oversized_payload("second", "act/test", 1, session)
	TEST_ASSERT(!window.create_oversized_payload("third", "act/test", 1, session), "Concurrent queues must be bounded")
	var/datum/tgui/transport_test/owner = window.locked_by
	window.release_lock()
	window.acquire_lock(owner)
	window.append_payload_chunk("first", "{}", 0, session)
	TEST_ASSERT_EQUAL(length(window.received_actions), 1, "Old sessions must not execute on a new owner")
	TEST_ASSERT_EQUAL(length(window.oversized_payloads), 0, "Reuse must release all queues and timers")
	window.on_message("suspend", null, list("windowSession" = "[session]"))
	TEST_ASSERT_EQUAL(owner.suspend_requests, 0, "A delayed suspend must not close the next owner")
	window.on_message("suspend", null, list("windowSession" = "[window.session_id]"))
	TEST_ASSERT_EQUAL(owner.suspend_requests, 1, "The current owner must still be able to suspend")
	window.clear_oversized_payloads()
	qdel(owner)
	qdel(window)
