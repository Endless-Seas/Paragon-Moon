//A smaller set of islands. Incredibly wet. Cold. The 'experience'.
//No snow. Sometimes heat waves. Lotta misery.
/datum/forecast/archipelago
	day_weather = list(
		/datum/particle_weather/rain_gentle = 45,
		/datum/particle_weather/rain_storm = 30,
		/datum/particle_weather/fog = 30,
		/datum/particle_weather/heat_wave = 10,
	)
	dawn_weather = list(
		/datum/particle_weather/fog = 45,
		/datum/particle_weather/rain_gentle = 30,
		/datum/particle_weather/rain_storm = 30,
		/datum/particle_weather/heat_wave = 10,
	)
	dusk_weather = list(
		/datum/particle_weather/fireflies = 45,
		/datum/particle_weather/rain_gentle = 30,
		/datum/particle_weather/rain_storm = 30,
		/datum/particle_weather/fog = 20,
		/datum/particle_weather/heat_wave = 10,
	)
	night_weather =  list(
		/datum/particle_weather/rain_storm = 40,
		/datum/particle_weather/fireflies = 30,
		/datum/particle_weather/rain_gentle = 30,
		/datum/particle_weather/fog = 20,
		/datum/particle_weather/heat_wave = 10,
	)
