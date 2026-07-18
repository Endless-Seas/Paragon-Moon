/proc/get_skill_delay(skill_level, fastest = 0.5, slowest = 5) 
	if(skill_level == SKILL_LEVEL_NONE) //can't divivde by zero
		return slowest SECONDS
	else
		var/percentage = skill_level / SKILL_LEVEL_LEGENDARY // Turns it into a percentage
		var/result = LERP(slowest, fastest, percentage)
		return result SECONDS
