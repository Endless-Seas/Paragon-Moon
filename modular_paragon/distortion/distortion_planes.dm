GLOBAL_VAR_INIT(distortion_sources, 0)

// holds the displacement maps, not drawn
/atom/movable/screen/plane_master/distortion
	name = "distortion plane master"
	plane = DISTORTION_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = DISTORTION_RENDER_TARGET

/atom/movable/screen/plane_master
	var/distortable = FALSE

// this is shitcode for a reason please look below
/atom/movable/screen/plane_master/proc/apply_distortion()
	if(!distortable || !GLOB.distortion_sources) //but if no sources r distorting, we don't draw it. this is a todo bc the pulses draw when ppl aren't nearby soo maybe tie them to when mob AI is active???
		return
	filters += filter(type = "displace", render_source = DISTORTION_RENDER_TARGET, size = DISTORTION_FILTER_SIZE)

/proc/refresh_distortion_planes()
	for(var/client/C as anything in GLOB.clients)
		var/datum/hud/hud = C?.mob?.hud_used
		if(!hud)
			continue
		for(var/key in hud.plane_masters)
			var/atom/movable/screen/plane_master/PM = hud.plane_masters[key]
			if(PM.distortable)
				PM.backdrop(hud.mymob)

/proc/add_distortion_source()
	GLOB.distortion_sources++
	if(GLOB.distortion_sources == 1)
		refresh_distortion_planes()

/proc/remove_distortion_source()
	GLOB.distortion_sources = max(GLOB.distortion_sources - 1, 0)
	if(!GLOB.distortion_sources)
		refresh_distortion_planes()

//OKAY SO. each backdrop() wipes and rebuilds its filters every time u get blurry or druggie or whatever, so the displacement filter gets readded to each worldplane lol lmao. IDK WHY THERE ARE TWO GAME_WORLD_WALLS I JUST DID BOTH. IDK WHICH ONE DOES SHIT!!

/atom/movable/screen/plane_master/osreal
	distortable = TRUE

/atom/movable/screen/plane_master/osreal/backdrop(mob/mymob)
	. = ..()
	apply_distortion()

/atom/movable/screen/plane_master/floor
	distortable = TRUE

/atom/movable/screen/plane_master/floor/backdrop(mob/mymob)
	. = ..()
	apply_distortion()

/atom/movable/screen/plane_master/game_world_walls
	distortable = TRUE

/atom/movable/screen/plane_master/game_world_walls/backdrop(mob/mymob)
	. = ..()
	apply_distortion()

/atom/movable/screen/plane_master/game_world_below
	distortable = TRUE

/atom/movable/screen/plane_master/game_world_below/backdrop(mob/mymob)
	. = ..()
	apply_distortion()

/atom/movable/screen/plane_master/game_world
	distortable = TRUE

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	. = ..()
	apply_distortion()

/atom/movable/screen/plane_master/game_world_fov_hidden
	distortable = TRUE

/atom/movable/screen/plane_master/game_world_fov_hidden/backdrop(mob/mymob)
	. = ..()
	apply_distortion()

/atom/movable/screen/plane_master/game_world_above
	distortable = TRUE

/atom/movable/screen/plane_master/game_world_above/backdrop(mob/mymob)
	. = ..()
	apply_distortion()
