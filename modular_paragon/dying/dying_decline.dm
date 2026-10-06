/*
The slow decline. As someone slips toward death, the world slowly drains away for THEM and only them.
Modelled on Casualties: Unknown's dying track - a lone low pulse warns you first, then music fades out, a saturated low
tritone swallows everything, a beating tone bends upward over it, distortion grinds in toward the end, and on death it
all swells and then just stops.

Everything here is sent to the dying player's client alone. Nobody standing over the body hears or sees any of it.

How intensity works (0 to 1):
- Health starts it at DYING_ONSET_HEALTH, crit sits around 0.41, and HEALTH_THRESHOLD_DEAD is 1.
- Blood loss below DYING_ONSET_BLOOD can drive it on its own, since bleeding out is how most people go.
- It starts early on purpose: players should know things are bad well before they're on the floor.
- Most deaths land well before 1 (blood loss, oxy, a last big hit), so everything is at its worst by DYING_GRIND_FULL -
  roughly health -45.
- The displayed intensity creeps toward that target, and no layer can swell in faster than DYING_SWELL_RATE,
  so even a sudden wound sinks in rather than snapping on.

The layers, each its own looping channel, interlacing as they hand over to one another (health in brackets):
- pulse (CHANNEL_DYING_PULSE) - a lone low D throbbing every few seconds. The first warning (70), handing over to the low
  layer once that's settled (45 to 20).
- low   (CHANNEL_DYING)       - D1 against G#1 (55, full by 35), sinking under the grind at the end.
- rise  (CHANNEL_DYING_RISE)  - beating D4 with octave and fifth (35, full by -10). Starts a semitone flat and is pitched
  up as it builds; a hint of it stays over the grind.
- grind (CHANNEL_DYING_GRIND) - the torn, saturated wall (10, full by -45). The one complete layer, carrying the end.

Loudness: each file is mastered loud on its own. BYOND sums channels on the client with nothing stopping the total going
over full scale - that's what crackles - and the more layers are up at once, the higher their combined peaks reach.
So apply_layers() works out how many layers are effectively playing and only lets the mix get as loud as keeps its
peaks under DYING_DRONE_TARGET. The handovers above keep that to two or three at most, so it can stay loud.
The heartbeat only gets whatever headroom is left (cap_heartbeat()).
tools/dying_audio/MixSim.cs is what DYING_CREST_ONE / DYING_CREST_STEP were measured with - re-check with it if you
change the files or the layer windows.

Death on the player's screen is held back by DYING_FINAL_TIME. The mob is dead server-side straight away, nothing about
the actual death changes, but the dying player keeps seeing and hearing the decline while dying_final.ogg swells to its
peak. Then everything is cut at once: sound, heartbeat, colour, to black. A beat of silence later the death screen
(death_screen.dm) comes up over sound/misc/deth.ogg - a flatline over a low fade-out, made by the same tool.

Music isn't stopped, it's ducked: client.music_duck scales every music volume calculation (area droning,
combat music, jukeboxes, instruments), so newly started tracks come in quiet too and nothing pops back.

The sounds are synthesized by tools/dying_audio - rerun its build.bat if you tweak them.
*/

#define DYING_STATE_DECLINE 1
#define DYING_STATE_FINAL 2
#define DYING_STATE_AFTER 3

#define DYING_ONSET_HEALTH 70
/// Blood volume where blood loss starts it - where you first start feeling dizzy.
#define DYING_ONSET_BLOOD BLOOD_VOLUME_SAFE
/// How fast the effect sinks in, per second.
#define DYING_RISE_RATE 0.1
/// How fast it lifts once someone is stabilised.
#define DYING_FALL_RATE 0.1
/// However fast intensity climbs, no layer swells in faster than this (per second) - about 6 seconds from silence.
#define DYING_SWELL_RATE 0.17
/// Music is fully gone by this intensity (health 40).
#define DYING_MUSIC_GONE 0.176
// Each layer's window, in intensity: where it starts fading in and is full, and where it starts and finishes sinking out.
#define DYING_PULSE_FULL 0.088
#define DYING_PULSE_OUT_START 0.15
#define DYING_PULSE_OUT_FULL 0.3
#define DYING_LOW_START 0.088
#define DYING_LOW_FULL 0.206
#define DYING_LOW_OUT_START 0.45
#define DYING_LOW_OUT_FULL 0.676
#define DYING_RISE_START 0.206
#define DYING_RISE_FULL 0.471
#define DYING_RISE_OUT_START 0.5
#define DYING_RISE_OUT_FULL 0.676
/// How much of the rise layer is left over the grind at the end.
#define DYING_RISE_LEFT 0.25
#define DYING_GRIND_START 0.353
#define DYING_GRIND_FULL 0.676
/// The rise layer is rendered at D4 and starts out pitched down to C#4.
#define DYING_RISE_START_PITCH 0.944
/// How long the death is held off on the dying player's screen. Matches the length of dying_final.ogg.
#define DYING_FINAL_TIME (4 SECONDS)
/// Black silence between the cutoff and the death screen.
#define DYING_BLACK_HOLD (1.5 SECONDS)
/// How long music stays gone after the cutoff.
#define DYING_DEATH_HOLD (10 SECONDS)
/// How long music takes to come back afterward.
#define DYING_RESTORE_TIME (5 SECONDS)
/// Worst-case peak of one layer at full volume, decoded.
#define DYING_CREST_ONE 0.87
/// How much higher the worst-case peak gets per extra layer effectively playing, at the same combined level.
#define DYING_CREST_STEP 0.21
/// How high the layers' combined peaks may reach. Leaves room for the heartbeat under DYING_MIX_CEILING.
#define DYING_DRONE_TARGET 0.85
/// Loudest peak of slowbeat.ogg.
#define DYING_BEAT_PEAK 0.73
/// How close to full scale the drone and heartbeat together may get.
#define DYING_MIX_CEILING 0.97

/client
	/// 0 to 1 multiplier on every music volume. Lowered by the dying decline.
	var/music_duck = 1

/// Music-type loops (jukeboxes, music boxes, instruments) get ducked; everything else plays as normal.
/client/proc/get_loop_duck(datum/looping_sound/loop)
	if(istype(loop, /datum/looping_sound/instrument) || istype(loop, /datum/looping_sound/musloop) || istype(loop, /datum/looping_sound/dmusloop))
		return music_duck
	return 1

/mob/living/carbon
	var/datum/dying_decline/dying_decline

/// How close we are to death, 0 to 1.
/mob/living/carbon/proc/get_dying_intensity()
	if(stat == DEAD || (status_flags & GODMODE))
		return 0
	var/intensity = 0
	if(health < DYING_ONSET_HEALTH)
		intensity = (DYING_ONSET_HEALTH - health) / (DYING_ONSET_HEALTH - HEALTH_THRESHOLD_DEAD)
	if(blood_volume < DYING_ONSET_BLOOD && !HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE) && !(dna?.species && (NOBLOOD in dna.species.species_traits)))
		intensity = max(intensity, (DYING_ONSET_BLOOD - blood_volume) / DYING_ONSET_BLOOD)
	return clamp(intensity, 0, 1)

/// Called from update_damage_hud. Starts the decline once there's something to decline into.
/mob/living/carbon/proc/handle_dying_decline()
	if(dying_decline || !client || stat == DEAD)
		return
	if(get_dying_intensity() <= 0)
		return
	dying_decline = new(src)

/mob/living/carbon/hold_death_cutscene(gibbed)
	if(gibbed || !dying_decline)
		return FALSE
	return dying_decline.begin_final()

/// Volume (before master volume) for heart.dm to start a heartbeat at, leaving room for the drone.
/mob/living/carbon/proc/get_heartbeat_volume(base)
	if(!dying_decline)
		return base
	var/master = client?.prefs ? client.prefs.mastervol * 0.01 : 1
	return min(base, dying_decline.cap_heartbeat(base * master) / max(master, 0.01))

/datum/dying_decline
	var/mob/living/carbon/owner
	/// The client we're actually playing to. Tracked separately so we can clean up if it leaves the mob.
	var/client/listener
	var/state = DYING_STATE_DECLINE
	/// Smoothed intensity actually being shown.
	var/intensity = 0
	/// Intensity at the last time we pushed visuals, to avoid spamming the client.
	var/last_visual = -1
	var/last_pulse_severity = 0
	var/datum/client_colour/dying/colour
	/// Looping layers currently playing, by key.
	var/list/layers = list()
	/// Each layer's actual gain, eased toward its target so nothing ever snaps on.
	var/list/gains = list("pulse" = 0, "low" = 0, "rise" = 0, "grind" = 0)
	/// Estimated worst-case peak of the layers as last pushed (0 to 1, after master). Fits the heartbeat under it.
	var/drone_peak = 0
	/// Length of the current process tick in seconds.
	var/tick_seconds = 0.2
	var/sound/final_swell
	/// Last values pushed per channel, so we only send what changed.
	var/list/sent_volumes = list()
	/// Cached values are thrown out every second, so anything that started (or restarted) since gets ducked too.
	var/next_refresh = 0
	var/final_started_at = 0
	var/cut_at = 0
	/// We took the death cutscene off death() and still owe it to the player.
	var/cutscene_pending = FALSE
	var/final_beat_started = FALSE
	/// The black that covers the whole screen from the cutoff until the death screen is up.
	var/atom/movable/screen/death_screen/backdrop/blackout

/datum/dying_decline/New(mob/living/carbon/new_owner)
	owner = new_owner
	listener = owner.client
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(owner_deleted))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(owner_died))
	START_PROCESSING(SSfastprocess, src)

/datum/dying_decline/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	release_client(listener)
	if(owner)
		UnregisterSignal(owner, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
		clear_visuals()
		if(cutscene_pending && !QDELETED(owner) && owner.stat == DEAD && owner.client)
			play_owed_cutscene()
		if(owner.dying_decline == src)
			owner.dying_decline = null
	lift_blackout()
	owner = null
	listener = null
	return ..()

/datum/dying_decline/proc/owner_deleted()
	SIGNAL_HANDLER
	qdel(src)

/// Deaths we couldn't hold back (no cutscene, client elsewhere) still get the sudden cutoff, just straight away.
/datum/dying_decline/proc/owner_died()
	SIGNAL_HANDLER
	if(state == DYING_STATE_DECLINE)
		hard_cut()

/// Death has happened. Take over the death cutscene and play the final swell first. Returns TRUE if we did.
/datum/dying_decline/proc/begin_final()
	if(state != DYING_STATE_DECLINE || !listener || owner.client != listener)
		return FALSE
	state = DYING_STATE_FINAL
	final_started_at = world.time
	cutscene_pending = TRUE
	final_swell = sound('sound/health/dying_final.ogg', repeat = FALSE, wait = FALSE, channel = CHANNEL_DYING_FINAL, volume = 100 * get_master())
	final_swell.priority = 250
	SEND_SOUND(listener, final_swell)
	return TRUE

/datum/dying_decline/process(delta_time)
	if(QDELETED(owner))
		qdel(src)
		return
	var/seconds = delta_time / (1 SECONDS)
	tick_seconds = seconds
	if(world.time >= next_refresh)
		next_refresh = world.time + 1 SECONDS
		sent_volumes.Cut()
	switch(state)
		if(DYING_STATE_DECLINE)
			process_decline(seconds)
		if(DYING_STATE_FINAL)
			process_final()
		if(DYING_STATE_AFTER)
			process_after()

/datum/dying_decline/proc/process_decline(seconds)
	if(owner.client != listener)
		// Ghosted, disconnected or swapped bodies. Give the old client its music back and start over with the new one.
		release_client(listener)
		listener = owner.client
		layers.Cut()
		for(var/key in gains)
			gains[key] = 0
		sent_volumes.Cut()
		last_visual = -1
		if(!listener)
			qdel(src)
			return

	var/target = owner.get_dying_intensity()
	if(target > intensity)
		intensity = min(target, intensity + DYING_RISE_RATE * seconds)
	else
		intensity = max(target, intensity - DYING_FALL_RATE * seconds)

	if(intensity <= 0 && target <= 0)
		qdel(src)
		return

	apply_ducking(listener, 1 - smoothstep_dying(0, DYING_MUSIC_GONE, intensity))
	apply_layers(1)
	// The heart.dm heartbeat keeps playing, dragging slower - and drowned out, there's only so much room left over.
	var/depth = get_depth()
	push_heartbeat(listener, cap_heartbeat((40 + 10 * depth) * get_master()), 1 - 0.25 * depth)
	if(abs(intensity - last_visual) >= 0.01)
		apply_visuals()

/// Already dead server-side; on their screen it's still happening. Everything swells to the top, then the cut.
/datum/dying_decline/proc/process_final()
	if(owner.stat != DEAD)
		// Brought back inside the window, somehow. Drop the swell and carry on dying the slow way.
		SEND_SOUND(listener, sound(null, channel = CHANNEL_DYING_FINAL))
		final_swell = null
		state = DYING_STATE_DECLINE
		cutscene_pending = FALSE
		final_beat_started = FALSE
		return
	if(!listener || owner.client != listener)
		hard_cut()
		return
	var/elapsed = world.time - final_started_at
	if(elapsed >= DYING_FINAL_TIME)
		hard_cut()
		return
	intensity = max(intensity, elapsed / DYING_FINAL_TIME)
	apply_ducking(listener, 0)
	// The swell plays at full from the start and builds on its own; the layers sink away under it over the whole hold.
	// This is the death itself, so it's allowed to hit the top.
	apply_layers(1 - 0.85 * (elapsed / DYING_FINAL_TIME))
	drone_peak += get_master()
	if(!final_beat_started)
		// Death already stopped the real heartbeat. Keep one dragging along until the cut so nothing gives it away.
		final_beat_started = TRUE
		var/sound/beat = sound('sound/health/slowbeat.ogg', repeat = TRUE, wait = FALSE, channel = CHANNEL_HEARTBEAT, volume = cap_heartbeat(45 * get_master()))
		beat.frequency = 0.7
		SEND_SOUND(listener, beat)
	else
		push_heartbeat(listener, cap_heartbeat(45 * get_master()), 0.7)
	if(abs(intensity - last_visual) >= 0.01)
		apply_visuals()

/// Black and silent, then the death screen, then music is let back in.
/datum/dying_decline/proc/process_after()
	if(owner.stat != DEAD && owner.client == listener)
		// Revived. Back to normal life (or another slow decline, if they're still in a bad way).
		clear_visuals()
		lift_blackout()
		cutscene_pending = FALSE
		state = DYING_STATE_DECLINE
		intensity = 0
		return
	if(!listener)
		qdel(src)
		return
	var/since = world.time - cut_at
	if(cutscene_pending && since >= DYING_BLACK_HOLD)
		cutscene_pending = FALSE
		clear_visuals()
		if(owner.client == listener)
			play_owed_cutscene()
		else
			lift_blackout()
	if(since < DYING_DEATH_HOLD)
		apply_ducking(listener, 0)
		return
	var/restored = clamp((since - DYING_DEATH_HOLD) / DYING_RESTORE_TIME, 0, 1)
	apply_ducking(listener, restored)
	if(restored >= 1)
		qdel(src)

/// The sudden cutoff. Every sound we own stops at once and the screen goes black.
/datum/dying_decline/proc/hard_cut()
	state = DYING_STATE_AFTER
	cut_at = world.time
	if(listener)
		for(var/chan in list(CHANNEL_DYING_PULSE, CHANNEL_DYING, CHANNEL_DYING_RISE, CHANNEL_DYING_GRIND, CHANNEL_DYING_FINAL, CHANNEL_HEARTBEAT))
			SEND_SOUND(listener, sound(null, channel = chan))
		apply_ducking(listener, 0)
	layers.Cut()
	for(var/key in gains)
		gains[key] = 0
	final_swell = null
	drone_peak = 0
	owner.clear_fullscreen("dying_pulse", 0)
	last_pulse_severity = 0
	clear_visuals()
	if(!cutscene_pending || !listener)
		return
	// The whole screen goes black at once - map, HUD, everything - and stays that way until the death screen,
	// whose own black backdrop takes over without a seam.
	blackout = new()
	blackout.alpha = 255
	listener.screen += blackout

/datum/dying_decline/proc/lift_blackout()
	if(!blackout)
		return
	listener?.screen -= blackout
	QDEL_NULL(blackout)

/// What death() would have shown, had we not held it back.
/datum/dying_decline/proc/play_owed_cutscene()
	cutscene_pending = FALSE
	owner.playsound_local(owner, 'sound/misc/deth.ogg', 100)
	owner.show_death_cutscene() // puts its own black up first, so ours can come down underneath it
	owner.add_client_colour(/datum/client_colour/monochrome)
	lift_blackout()

/// Intensity rescaled so the visuals and heartbeat bottom out together with the sound, when the grind is at full.
/datum/dying_decline/proc/get_depth()
	return min(1, intensity / DYING_GRIND_FULL)

/datum/dying_decline/proc/get_master()
	return listener?.prefs ? listener.prefs.mastervol * 0.01 : 1

/// The loudest a heartbeat can be (after master volume) without the drone and it summing past the ceiling.
/datum/dying_decline/proc/cap_heartbeat(wanted)
	var/room = DYING_MIX_CEILING - drone_peak
	return clamp(min(wanted, 100 * room / DYING_BEAT_PEAK), 0, 100)

/// Sets the duck multiplier and pushes the new volume to music already playing.
/// Loops (jukeboxes, instruments) pick it up on their own next refresh in update_sounds().
/datum/dying_decline/proc/apply_ducking(client/C, music)
	C.music_duck = music
	push_channel_volume(C, CHANNEL_MUSIC, SSdroning.get_channel_volume(C, CHANNEL_MUSIC))
	push_channel_volume(C, CHANNEL_BUZZ, SSdroning.get_channel_volume(C, CHANNEL_BUZZ) * 1.2) // play_combat_music's boost
	// Admin music is sent at (chosen volume * music pref); we can't know the first half, so assume full.
	push_channel_volume(C, CHANNEL_ADMIN, C.prefs ? C.prefs.musicvol * music : 0)

/datum/dying_decline/proc/push_channel_volume(client/C, chan, volume)
	volume = round(max(volume, 0), 0.5)
	if(C == listener)
		if(sent_volumes["[chan]"] == volume)
			return
		sent_volumes["[chan]"] = volume
	var/sound/update = sound(null, repeat = FALSE, wait = FALSE, channel = chan, volume = volume)
	update.status = SOUND_UPDATE
	SEND_SOUND(C, update)

/// Eases a layer's gain toward its target: down straight away, up no faster than DYING_SWELL_RATE.
/datum/dying_decline/proc/ease_gain(key, target)
	var/current = gains[key]
	current = target < current ? target : min(target, current + DYING_SWELL_RATE * tick_seconds)
	gains[key] = current
	return current

/// Works out each layer's gain from its window, then scales the lot so their combined worst-case peak stays under
/// DYING_DRONE_TARGET. The more layers are effectively up at once, the higher their peaks stack, so the less loud the
/// mix is allowed to be - which is why the layers hand over rather than all piling up. mix scales everything (they sink
/// under the final swell).
/datum/dying_decline/proc/apply_layers(mix = 1)
	var/pulse = ease_gain("pulse", smoothstep_dying(0, DYING_PULSE_FULL, intensity) * (1 - smoothstep_dying(DYING_PULSE_OUT_START, DYING_PULSE_OUT_FULL, intensity)))
	var/low = ease_gain("low", smoothstep_dying(DYING_LOW_START, DYING_LOW_FULL, intensity) * (1 - smoothstep_dying(DYING_LOW_OUT_START, DYING_LOW_OUT_FULL, intensity)))
	var/rise = ease_gain("rise", smoothstep_dying(DYING_RISE_START, DYING_RISE_FULL, intensity) * (1 - (1 - DYING_RISE_LEFT) * smoothstep_dying(DYING_RISE_OUT_START, DYING_RISE_OUT_FULL, intensity)))
	var/grind = ease_gain("grind", smoothstep_dying(DYING_GRIND_START, DYING_GRIND_FULL, intensity))
	var/power = pulse * pulse + low * low + rise * rise + grind * grind
	var/sum = pulse + low + rise + grind
	// How many layers are effectively playing: 1 when one has it all, up to 4 when all are equal.
	var/effective = power > 0 ? sum * sum / power : 1
	var/crest = DYING_CREST_ONE + DYING_CREST_STEP * (effective - 1)
	var/allowed = (DYING_DRONE_TARGET / crest) ** 2
	var/fit = power > allowed ? sqrt(allowed / power) : 1
	var/volume = 100 * get_master() * mix * fit
	drone_peak = crest * sqrt(power) * fit * get_master() * mix
	var/rise_pitch = LERP(DYING_RISE_START_PITCH, 1, smoothstep_dying(DYING_RISE_START, DYING_GRIND_FULL, intensity))
	layer_loop("pulse", 'sound/health/dying_pulse.ogg', CHANNEL_DYING_PULSE, volume * pulse, 1)
	layer_loop("low", 'sound/health/dying_low.ogg', CHANNEL_DYING, volume * low, 1)
	layer_loop("rise", 'sound/health/dying_rise.ogg', CHANNEL_DYING_RISE, volume * rise, rise_pitch)
	layer_loop("grind", 'sound/health/dying_grind.ogg', CHANNEL_DYING_GRIND, volume * grind, 1)

/// Starts a layer the first time it's audible, then keeps its volume and pitch up to date.
/datum/dying_decline/proc/layer_loop(key, file, chan, volume, frequency)
	volume = round(max(volume, 0), 0.5)
	frequency = round(frequency, 0.005)
	var/sound/S = layers[key]
	if(!S)
		if(volume <= 0)
			return
		S = sound(file, repeat = TRUE, wait = FALSE, channel = chan, volume = volume)
		S.frequency = frequency
		S.priority = 250
		layers[key] = S
		sent_volumes[key] = volume
		SEND_SOUND(listener, S)
		return
	if(sent_volumes[key] == volume && S.frequency == frequency)
		return
	sent_volumes[key] = volume
	S.volume = volume
	S.frequency = frequency
	S.status = SOUND_UPDATE
	SEND_SOUND(listener, S)
	S.status = 0

/datum/dying_decline/proc/push_heartbeat(client/C, volume, frequency)
	volume = round(volume, 0.5)
	frequency = round(frequency, 0.01)
	if(C == listener)
		if(sent_volumes["beat"] == volume && sent_volumes["beatfreq"] == frequency)
			return
		sent_volumes["beat"] = volume
		sent_volumes["beatfreq"] = frequency
	var/sound/beat = sound(null, repeat = FALSE, wait = FALSE, channel = CHANNEL_HEARTBEAT, volume = volume)
	beat.frequency = frequency
	beat.status = SOUND_UPDATE
	SEND_SOUND(C, beat)

/datum/dying_decline/proc/apply_visuals()
	last_visual = intensity
	if(!colour)
		colour = owner.add_client_colour(/datum/client_colour/dying)
	if(colour)
		colour.colour = dying_colour_matrix(get_depth())
		if(owner.client && length(owner.client_colours) && owner.client_colours[1] == colour)
			animate(owner.client, color = colour.colour, time = 2)

	var/severity = clamp(round(get_depth() * 7), 1, 7)
	var/atom/movable/screen/fullscreen/dying_pulse/pulse = owner.overlay_fullscreen("dying_pulse", /atom/movable/screen/fullscreen/dying_pulse, severity)
	if(pulse && severity != last_pulse_severity)
		last_pulse_severity = severity
		pulse.beat(get_depth())

/datum/dying_decline/proc/clear_visuals()
	if(colour)
		colour = null
		owner.remove_client_colour(/datum/client_colour/dying)
	owner.clear_fullscreen("dying_pulse", 20)
	last_pulse_severity = 0
	last_visual = -1

/// Hand a client back to normal: music at full, our sounds silenced, heartbeat back to its usual self.
/datum/dying_decline/proc/release_client(client/C)
	if(!C)
		return
	apply_ducking(C, 1)
	for(var/chan in list(CHANNEL_DYING_PULSE, CHANNEL_DYING, CHANNEL_DYING_RISE, CHANNEL_DYING_GRIND, CHANNEL_DYING_FINAL))
		SEND_SOUND(C, sound(null, channel = chan))
	drone_peak = 0
	if(final_beat_started)
		SEND_SOUND(C, sound(null, channel = CHANNEL_HEARTBEAT))
	else
		push_heartbeat(C, 40 * (C.prefs ? C.prefs.mastervol * 0.01 : 1), 1)

/proc/smoothstep_dying(edge0, edge1, x)
	var/t = clamp((x - edge0) / (edge1 - edge0), 0, 1)
	return t * t * (3 - 2 * t)

/// Desaturate, darken and push slightly toward red as intensity rises.
/proc/dying_colour_matrix(intensity)
	var/sat = 1 - 0.85 * intensity
	var/bright = 1 - 0.4 * intensity
	var/red = 1 + 0.15 * intensity
	var/list/lum = list(0.3086, 0.6094, 0.082)
	var/list/out = list()
	for(var/i in 1 to 3)
		for(var/j in 1 to 3)
			var/v = (1 - sat) * lum[i] + (i == j ? sat : 0)
			out += v * bright * (j == 1 ? red : 1)
	out += list(0, 0, 0)
	return out

/datum/client_colour/dying
	colour = list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
	priority = 3

/// Dark vignette that throbs in time with a slowing pulse. Stays up after death so the held-back death isn't given away.
/atom/movable/screen/fullscreen/dying_pulse
	icon_state = "oxydamageoverlay"
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE
	alpha = 0
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/dying_pulse/proc/beat(intensity)
	var/period = (1.1 + 1.2 * intensity) SECONDS
	var/low = 40 + 60 * intensity
	animate(src, alpha = 255, time = period * 0.25, loop = -1, easing = SINE_EASING)
	animate(alpha = low, time = period * 0.75, easing = SINE_EASING)

#undef DYING_STATE_DECLINE
#undef DYING_STATE_FINAL
#undef DYING_STATE_AFTER
#undef DYING_ONSET_HEALTH
#undef DYING_ONSET_BLOOD
#undef DYING_RISE_RATE
#undef DYING_FALL_RATE
#undef DYING_SWELL_RATE
#undef DYING_MUSIC_GONE
#undef DYING_PULSE_FULL
#undef DYING_PULSE_OUT_START
#undef DYING_PULSE_OUT_FULL
#undef DYING_LOW_START
#undef DYING_LOW_FULL
#undef DYING_LOW_OUT_START
#undef DYING_LOW_OUT_FULL
#undef DYING_RISE_START
#undef DYING_RISE_FULL
#undef DYING_RISE_OUT_START
#undef DYING_RISE_OUT_FULL
#undef DYING_RISE_LEFT
#undef DYING_GRIND_START
#undef DYING_GRIND_FULL
#undef DYING_RISE_START_PITCH
#undef DYING_FINAL_TIME
#undef DYING_BLACK_HOLD
#undef DYING_DEATH_HOLD
#undef DYING_RESTORE_TIME
#undef DYING_CREST_ONE
#undef DYING_CREST_STEP
#undef DYING_DRONE_TARGET
#undef DYING_BEAT_PEAK
#undef DYING_MIX_CEILING
