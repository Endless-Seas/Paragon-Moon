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
	//Do we HAVE RP hooks? Remember that this should always be true for The Three.
	var/has_rp_hooks = FALSE
	//Do we give them the narrative piece, relating to the vault, as if they're one of The Three?
	var/vault_dweller = FALSE
	//If so, who were they? Baron, Hand or Honorant?
	var/vault_station = ""
	//Specific hooks for The Three. To elaborate further on their role in this cyclical hell, and the visions. If applicable.
	var/vault_hook = ""
	//Specific hooks unrelated to the vault, by other systems. Unused, for now.
	var/background_hook = ""

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

	if(has_rp_hooks)
		dat += "<span class='boldannounce'>Your role is one muddled by fate... <a href=?src=[REF(src)];ShowRPHooks=1>(Click Here)</a></span></b>"
	else
		dat += "<FONT color='grey'><b>Your role comes with no twists of fate...</b></font>"

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


/datum/job/proc/ShowRPHookStuff(mob/M)
	var/list/dat = list("")

	dat += "<h1>IC Information</h1>"
	dat += "\n<br><b>- - - - - -</b><br>"

	if(vault_dweller)
		dat += "<FONT color='green'><b>You are relevant to the meta-plot.</b></font><br>"

		dat += "<b>For you were the fool to [vault_station] </b><br>\
		Of the three that entered the Archeovault, beneath the Baron's estate. Whether that be Hand, Baron or Honorant.<br>\
		A party that couldn't be stopped, after their departure. A straight march to power, in whatever manner that came. \
		By way of conquest, coercion or simply revealing, to the powers that be, the exact contents of that wretched place. \
		The end result had been the Baron's rise to control of the archipelago. Now and forever.<br><br>"

		dat += "<small><FONT color='grey'>This location is an incredibly powerful plot device, ICly, that should not be discussed beyond the two others that share this secret. \
		People may know of it's existence, but only you three have ever seen the interior. \
		A secret you're encouraged to take to the grave, yet may use in RP if such arises. \
		For there is a reason the Baron's grasp is absolute, in however a manner you wish to argue it. <br>\
		As a result, your character is capable of entering the vault, should the need arise. \
		The abominable intelligentsia within will not cause you direct harm.</font></small>"

		dat += "\n<br><b>- - - - - -</b><br>"

	if(vault_hook)
		dat += "<b><small>You've lived many lives. You don't know how. You are incapable of explaining it, even if tortured. \
		You simply know that, in some manner, you've come to this horrid isle for centuries. \
		That you, and your two beloved companions, are trapped in this endless cycle. To forever rule. \
		Always aided to such heights by fiasco or providence. </b><br>\
		No manner of death, collapse or catastrophe can keep you from this fate. \
		For there will always be a body for you to inhabit. Just as the locals will forever see you as the same figure. \
		An eternal slave to the barony, regardless of the truth.\
		</small><br><br>\
		[vault_hook]"

		dat += "\n<br><b>- - - - - -</b><br>"

	if(background_hook)
		dat += "<b>You are known for someting greater... <br>\
		[background_hook]"

	var/datum/browser/popup = new(M, "roleplay_hooks", "Roleplay Hooks", 640, 400) // Set up the popup browser window
	popup.set_content(dat.Join())
	popup.open()

/*
The procs and such used to display the above.
*/
/datum/job/proc/job_help_message(mob/M)
	to_chat(M, "<span class='boldannounce'>Your role in the realm has additional information attached to it. <a href=?src=[REF(src)];ShowJobStuff=1>(Click Here)</a></span>")

/datum/job/proc/job_hook_message(mob/M)
	to_chat(M, "<span class='boldannounce'>Your role comes with RP hooks. <a href=?src=[REF(src)];ShowRPHooks=1>(Click Here)</a></span>")

/datum/job/Topic(href, href_list)
	if(href_list["ShowJobStuff"])
		ShowJobStuff(usr)
	if(href_list["ShowRPHooks"])
		ShowRPHookStuff(usr)
