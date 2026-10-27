/turf/closed/wall/sunset
	name = "wall"
	desc = "You shouldn't be seeing me. Poke a dev about this. Error: somehow a base turf/closed/wall/sunset generated."
	icon = 'modular_paragon/sunset_decor/icons/walls/reinforced.dmi'
	icon_state = "rrust"

/turf/closed/wall/sunset/metal/rusted
	name = "rusted metal wall"
	desc = "A rusted wall made of some kind of metal."
	icon_state = "wall"
	canSmoothWith = (/turf/closed/wall/sunset/reinforced)

/turf/closed/wall/sunset/reinforced
	name = "strange metal wall"
	desc = "A wall made of some strange alloy. It looks pristine."
	icon = 'modular_paragon/sunset_decor/icons/walls/reinforced_new.dmi'
	icon_state = "r_wall"

/turf/closed/wall/sunset/reinforced/rusted
	name = "rusted reinforced wall"
	desc = "A rusted wall made out of some kind of metal. It seems reinforced."
	icon = 'modular_paragon/sunset_decor/icons/walls/reinforced.dmi'
	icon_state = "rrust"
	canSmoothWith = (/turf/closed/wall/sunset/metal)

//Green patinaed wall
/turf/closed/wall/sunset/r_wall
	name = "corroded metal wall"
	desc = "A metal wall covered in corrosion."
	icon = 'modular_paragon/sunset_decor/icons/walls/corroded.dmi'
	icon_state = "vaultwall"
//The next six are various stages of deconstruction. Since we can't do that, I'm using them as decoration. Remove these if we can make/deconstruct walls later.
/turf/closed/wall/sunset/r_wall/one
	icon_state = "r_wall-1"

/turf/closed/wall/sunset/r_wall/two
	icon_state = "r_wall-2"

/turf/closed/wall/sunset/r_wall/three
	icon_state = "r_wall-3"

/turf/closed/wall/sunset/r_wall/four
	desc = "A metal wall covered in corrosion. Most of its plating is missing, revealing a tangle of support structures inside."
	icon_state = "r_wall-4"

/turf/closed/wall/sunset/r_wall/five
	desc = "A metal wall covered in corrosion. Most of its plating is missing, revealing a tangle of support structures inside."
	icon_state = "r_wall-5"

/turf/closed/wall/sunset/r_wall/six
	desc = "A metal wall covered in corrosion. Most of its plating is missing, revealing a tangle of support structures inside."
	icon_state = "r_wall-6"

//Copper patinaed wall.
/turf/closed/wall/sunset/r_wall/rusted
	name = "rusted metal wall"
	desc = "A metal wall covered in rust."
	icon = 'modular_paragon/sunset_decor/icons/walls/copper.dmi'
	icon_state = "vaultwall"

/turf/closed/wall/sunset/r_wall/rusted/one
	icon_state = "rr_wall-1"

/turf/closed/wall/sunset/r_wall/rusted/two
	icon_state = "rr_wall-2"

/turf/closed/wall/sunset/r_wall/rusted/three
	icon_state = "rr_wall-3"

/turf/closed/wall/sunset/r_wall/rusted/four
	desc = "A metal wall covered in rust. Most of its plating is missing, revealing a tangle of support structures inside."
	icon_state = "rr_wall-4"

/turf/closed/wall/sunset/r_wall/rusted/five
	desc = "A metal wall covered in rust. Most of its plating is missing, revealing a tangle of support structures inside."
	icon_state = "rr_wall-5"

/turf/closed/wall/sunset/r_wall/rusted/six
	desc = "A metal wall covered in rust. Most of its plating is missing, revealing a tangle of support structures inside."
	icon_state = "rr_wall-6"
