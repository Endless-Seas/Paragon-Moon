/*
This is the standing file for tutorial text and onboarding with roles.
If you've any questions, direct them to Carl. - Carl (Who'da thought.)

This is pulled from one of my older projects, brought up to date for PM.
*/
//We load the edits here so it's kept modular.
//Can only keep it so modular, though. As we have to ref it elsewhere.
/datum/job
	//For things that faction enforces or otherwise encourages heavily. IE: Encouraged/Enforced, on desc.
	var/rp_enforce = ""
	//For things that the faction forbids or otherwise discourages heavily. IE: Discouraged/Forbidden, on desc.
	var/rp_forbid = ""
	//When leaving the round, do we want them to have to follow the 'don't just vanish' rule?
	var/leave_admin_shout = FALSE
	//Is this role RP heavy? As in, should it be forbidden from dungeons and offensive combat?
	var/roleplay_exclusive_notify = FALSE

//Actual stuff here. Not clean, I know, but, still...
/datum/job/proc/ShowJobStuff(mob/M)
	var/list/dat = list("")

	dat += "<h1>IC Information</h1>"
	dat += "\n<br><b>- - - - - -</b><br>"

	dat += "\n<br><b><FONT color='red'>[title]</font></b><br>"

	if(tutorial)
		dat += "<b>[tutorial]</b>"
	else
		dat += "<FONT color='grey'><b>Your job has no tutorial. This is a bug. Tell Carl.</b></font>"

	dat += "\n<br><b>- - -</b><br>"

	if(supervisors)
		dat += "<b>You answer to the following roles, in order of priority: <br>\
				<FONT color='green'>[supervisors]</font></b>"
	else
		dat += "<FONT color='grey'><b>You answer to none.</b></font>"

	dat += "\n<br><br>"

	if(give_bank_account)
		dat += "<FONT color='green'><b>You've been provided a nervelock account.</b></font>"
	else
		dat += "<FONT color='grey'><b>Your position is NOT given a nervelock account by default.</b></font>"

	dat += "\n<br>"

	if(noble_income)
		dat += "<b>You're entitled to a noble's stipend, once a day, at a rate of: (<FONT color='green'>[noble_income] mammon</font>)	</b>"
	else
		dat += "<FONT color='grey'><b>Your position is NOT given a noble's stipend.</b></font>"

	dat += "\n<br><b>- - - - - -</b><br>"

	if(rp_enforce)
		dat += "<b>[rp_enforce]</b>"
	else
		dat += "<FONT color='grey'><b>Your job has no enforced or otherwise encouraged actions. This is a bug. Tell Carl.</b></font>"

	dat += "\n<br><br>"

	if(rp_forbid)
		dat += "<b>[rp_forbid]</b>"
	else
		dat += "<FONT color='grey'><b>Your job has no foribdden or otherwise discouraged actions. This is a bug. Tell Carl.</b></font>"

	dat += "\n<br><b>- - - - - -</b><br>"
	dat += "<h2>OOC Information</h2>"
	dat += "\n<br><b>- - - - - -</b><br>"
	dat += "<b>Storyteller: <FONT color='red'>[SSgamemode.storyteller_name]</font></b>"
	dat += "\n<br><b>- - - - - -</b><br>"

	if(leave_admin_shout)
		dat += "<FONT color='orange'><b>You are playing a job that is important for Game Progression. \
		If you have to disconnect immediately, please notify the admins via adminhelp. \
		Otherwise, see to it ICly. Leave pertinent equipment and items in safety.</b></font>"

	dat += "\n<br><br>"

	if(roleplay_exclusive_notify)
		dat += "<FONT color='orange'><b>You are playing a job that is important for roleplay. \
		In the event of an offensive conflict, you are discouraged from participating in an attack. \
		Please refrain from running dungeons when possible.</b></font>"

		dat += "\n<br><b>- - - - - -</b><br>"

	var/datum/browser/popup = new(M, "mob_occupation", "Occupational Information", 640, 400) // Set up the popup browser window
	popup.set_content(dat.Join())
	popup.open()


//	to_chat(M, "[dat.Join()]")

/*
This is the proc used to display the above.
*/
/datum/job/proc/job_help_message(mob/M)
	to_chat(M, "<span class='boldannounce'>Your role in the realm has additional information attached to it. <a href=?src=[REF(src)];ShowJobStuff=1>(Click Here)</a></span>")

/datum/job/Topic(href, href_list)
	if(href_list["ShowJobStuff"])
		ShowJobStuff(usr)
