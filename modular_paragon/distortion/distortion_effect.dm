// dis is where our actual fx objects live

/atom/movable/distortion_effect
	plane = DISTORTION_PLANE
	icon = 'icons/effects/light_overlays/light_352.dmi'
	icon_state = "light"
	appearance_flags = PIXEL_SCALE|LONG_GLIDE|RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	var/icon_half = 176 // half the width of our icon for centering, change this if we use a different sprite (so like 128 would be 64. u know math dude. we're all gamers here)

/atom/movable/distortion_effect/Initialize(mapload, center_x = world.icon_size / 2, center_y = world.icon_size / 2)
	. = ..()
	pixel_x = center_x - icon_half
	pixel_y = center_y - icon_half
	add_distortion_source()

/atom/movable/distortion_effect/Destroy(force)
	remove_distortion_source()
	return ..()

// basic; one ripple that grows out and fades in strength
/atom/movable/distortion_effect/proc/pulse(duration = 2 SECONDS, start_scale = 0.2, end_scale = 1)
	transform = matrix().Scale(start_scale)
	alpha = 255
	animate(src, transform = matrix().Scale(end_scale), alpha = 0, time = duration, easing = SINE_EASING|EASE_OUT)
