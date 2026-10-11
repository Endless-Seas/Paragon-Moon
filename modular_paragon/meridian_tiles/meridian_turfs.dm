//Indestructible mapping turfs ported from Meridian-Rift. Subtypes are generated in meridian_walls.dm and meridian_floors.dm.

/turf/closed/wall/meridian
	name = "wall"
	desc = "A sturdy wall."
	icon = 'modular_paragon/meridian_tiles/icons/walls/wall.dmi'
	icon_state = "preview"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/wall/meridian)
	blade_dulling = DULLING_BASH
	max_integrity = 10000000
	damage_deflection = 99999999
	explosion_block = 50

/turf/closed/wall/meridian/Initialize(mapload)
	. = ..()
	if(smooth)
		icon_state = "" //"preview" is for map editors only

/turf/closed/wall/meridian/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE)
	return 0

/turf/closed/wall/meridian/ex_act(severity, target, epicenter, devastation_range, heavy_impact_range, light_impact_range, flame_range)
	return

/turf/closed/wall/meridian/dismantle_wall(devastated = 0, explode = 0)
	return

/turf/closed/wall/meridian/turf_destruction(damage_flag)
	return

/turf/closed/wall/meridian/acid_act(acidpwr, acid_volume)
	return 0

/turf/open/floor/meridian
	name = "floor"
	icon = 'modular_paragon/meridian_tiles/icons/floors/station.dmi'
	icon_state = "floor"
	baseturfs = list(/turf/open/floor/rogue/dirt/road)
	max_integrity = 10000000
	damage_deflection = 99999999
	spread_chance = 0
	burn_power = 0
	tiled_dirt = FALSE

/turf/open/floor/meridian/Initialize(mapload)
	. = ..()
	if(smooth)
		icon_state = "" //"preview" is for map editors only

/turf/open/floor/meridian/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE)
	return 0

/turf/open/floor/meridian/ex_act(severity, target, epicenter, devastation_range, heavy_impact_range, light_impact_range, flame_range)
	return

/turf/open/floor/meridian/break_tile()
	return

/turf/open/floor/meridian/burn_tile()
	return

/turf/open/floor/meridian/make_plating()
	return

/turf/open/floor/meridian/acid_melt()
	return
