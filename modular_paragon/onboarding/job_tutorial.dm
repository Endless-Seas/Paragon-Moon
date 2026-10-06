/*
This is the standing file for tutorial text and onboarding with roles.
If you've any questions, direct them to Carl. - Carl (Who'da thought.)

This is pulled from one of my older projects, brought up to date for PM.

Also, unrelated, this is much larger than I'd originally had it.
So let's move this into different files as a module piece proper at some point.
Why not now? Because it's not THAT big, but I expect we'll size it up.
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
	//Otherwise, enable it on some roles dynamically as a background_hook is selected.
	var/has_rp_hooks = FALSE
	//Specific hooks unrelated to the vault, by other systems. Unused, for now.
	//Character selection related, mostly. I've not fully finished this though, and it's a mess like the rest of this.
	var/background_hook = ""

	//Do we give them the narrative piece, relating to the vault, as if they're one of The Three?
	var/vault_dweller = FALSE
	//If so, the introduction piece.
	var/vault_station = ""
	//Specific hooks for The Three. To elaborate further on their role in this cyclical hell, and the visions. If applicable.
	var/vault_hook = ""

	//Do we HAVE FAITH hooks? Remember that this should always be true for the Church and Inquisition.
	var/has_faith_hooks = FALSE
	//Specific hooks for how the Inquisition should interact with other faiths?
	var/inquis_hook = FALSE
	//Specific hooks for how the Church should interact with other faiths?
	var/church_hook = FALSE

	//Is this class liable to change to an extreme degree at some point in the near future?
	var/fear_of_change = FALSE

//Actual stuff here. Not clean, I know, but, still...
/datum/job/proc/ShowJobStuff(mob/M)
	var/list/dat = list("")

	if(fear_of_change)
		dat += "\n<br><b>- - - - - -</b><br>"
		dat += "<b><FONT color='red'>IMPORTANT</font></b><br>\
		<FONT color='grey'>This class is soon to be the subject of extensive changes. <br>\
		Check your loadout and see that it's to your liking. \
		If anything appears amiss, you're welcome to far-travel. <br>\
		We're always looking for feedback, so shout at Carl.</font>"
		dat += "\n<br><b>- - - - - -</b><br>"

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

	dat += "\n<br>"

	if(has_faith_hooks)
		dat += "<span class='boldannounce'>Your role is one muddled by faith... <a href=?src=[REF(src)];ShowFaithHooks=1>(Click Here)</a></span></b>"
	else
		dat += "<FONT color='grey'><b>Your role comes with no twists of faith...</b></font>"

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

		dat += "<b>Of a party that couldn't be stopped. The Baron, Hand and Honorant.</b> <br>\
		Wretched souls, of a previous lyfe, stepping into the Archaeovault. \
		That had been centuries ago, though the end result had been control of the archipelago. \
		Now and forever.<br><br>"

		dat += "<small><FONT color='grey'>This location is an incredibly powerful plot device, ICly, \
		that should not be discussed beyond the two others that share this secret. \
		People may know of its existence, but only you three have ever seen the interior. \
		A secret you're encouraged to take to the grave, yet may use in RP if such arises. \
		For there is a reason the Baron's grasp is absolute. <br>\
		As a result, your character is capable of entering the vault, should the need arise. \
		The abominable intelligentsia within will not cause you direct harm.</font></small>"

		dat += "\n<br><b>- - -</b><br>"

	if(vault_hook)
		dat += "<FONT style='color: var(--pg-accent, #40A4B9)'><b>You will do a great many things.</b></font><br>"

		dat += "<b><small>You've lived many lives. The presence beneath the estate assures such. \
		No manner of death, collapse or catastrophe can avert the tethers of fate. <br>\
		For there will always be a body for you to inhabit. Just as the locals will forever see you as the same figure. \
		You, and your two beloved companions, trapped in this endless cycle. To forever rule. <br>\
		An eternal slave to the barony, regardless of the truth.</small></b><br>"

		dat += "\n<br><br>"
		dat += "<FONT color='#A64A2E'><b>You. Are. Trapped.</b></font><br>"
		dat += "\n<br><br>"

		dat += "<b>You were the fool to [vault_station] </b><br><br>\
		[vault_hook]"

		dat += "\n<br><b>- - - - - -</b><br>"

	if(background_hook)
		dat += "<b>You are known for someting greater... <br>\
		[background_hook]"

	var/datum/browser/popup = new(M, "roleplay_hooks", "Roleplay Hooks", 640, 400) // Set up the popup browser window
	popup.set_content(dat.Join())
	popup.open()

/datum/job/proc/ShowFaithHookStuff(mob/M)
	var/list/dat = list("")

	dat += "<h1>IC Information</h1>"
	dat += "\n<br><b>- - - - - -</b><br>"

	if(inquis_hook)
		dat += "<FONT color='green'><b>You are expected to have certain reactions to various faiths.</b></font><br>"

		dat += "\n<br>"

		dat += "\n<FONT color='#A56B76'>The Outcasts</font><br><br>"

		dat += "\n<br>"

		dat += "<small><FONT color='grey'>Followers of <b>Baotha</b>:</font> Scorned. <br>\
		They're, quite simply, broken. Though not the way Zizites might be. \
		One is cautioned in interactions, though they should be treated like fools. \
		For what is someone without limitations? A fool. Little more than. <br>\
		<b>Doctrine determines that you take your time, when possible. An easy hand for a heavy heart.</b></small>"

		dat += "\n<br><br>"

		dat += "<small><FONT color='grey'>Followers of <b>Graggar</b>:</font> Hated. <br>\
		A Graggarite will afford you little mercy, should they be caught without their faculties. \
		A common mantra, as followed by the bloodthirsty: <b>Death before Frailty.<b> <br>\
		<b>Doctrine begs you to lay them low. Spare no mercy, should they be too far gone.</b></small>"

		dat += "\n<br><br>"

		dat += "<small><FONT color='grey'>Followers of <b>Mathios</b>:</font> Disgusting. <br>\
		Outsiders among those who already despise authority. Careless rejects who wish for a better lot. \
		They have few friends, especially on the archipelago. <br>\
		<b>Doctrine requires you to beat them. Break their spirit. Return them to the One Truth.</b></small>"

		dat += "\n<br><br>"

		dat += "<small><FONT color='grey'>Followers of <b>Zizo</b>:</font> Deplorable. <br>\
		To be tortured. Broken. Reviled. They deserve no mercy for muddling with the dead. \
		Further still, for trying to destroy the threads of faith and fate. <br>\
		<b>Doctrine begs you to quickly dispose of them, when possible, should they not wish to renounce their vile ways.</b></small>"

		dat += "\n<br><br>"

		dat += "\n<br><FONT style='color: var(--pg-orange, #E99F10)'>The Pantheon</font><br><br>"

		dat += "\n<br>"

		dat += "<small><FONT color='grey'>Followers of the <b>Pantheon</b>:</font> Unfortunates. <br>\
		The Emperor's will bid all who follow the false faiths to abide by our teachings. \
		To understand their place in the world. They are not foes, certainly. Rather, a pitiful flock of sheep. <br>\
		<b>Doctrine urges you to take caution, for conversion of the pitifully plenty may bring violence.</b></small>"

		dat += "\n<br><br>"

		dat += "\n<br><FONT style='color: var(--pg-accent, #40A4B9)'>The Maker's Own</font><br><br>"

		dat += "\n<br>"

		dat += "<small><FONT color='grey'>Followers of The <b>One</b>:</font> Kin. <br>\
		The Emperor's wish is that you pay your own people no mind. \
		Do not aid them, should it not be in your own interests. We all carve our own path. \
		Yet do not let violence go unanswered. <br>\
		<b>Doctrine bids you to act as you will.</b></small>"

		dat += "\n<br><b>- - - - - -</b><br>"

	if(church_hook)
		dat += "<FONT color='green'><b>You are expected to have certain reactions to various faiths.</b></font><br>"

		dat += "\n<FONT color='#A56B76'>The Outcasts</font><br><br>"

		dat += "\n<br>"

		dat += "<small><FONT color='grey'>Followers of <b>Baotha</b>:</font> Outcasts. <br>\
		Baothites are lost, with no better way to describe the state of their souls. \
		They've taken to excess, lust and longing over issues they may have not even caused themselves. \
		To be Baothan is to lose one's self and worth, yet some may yet be redeemed. <br>\
		<b>Common thought is that they should be shepherded with an easy hand.</b></small>"

		dat += "\n<br><br>"

		dat += "<small><FONT color='grey'>Followers of <b>Graggar</b>:</font> Detestable. <br>\
		Graggarites, through and through, are those who've given up their judgement to the Aspect of War. \
		They will spare you little mercy. One must imagine you to do the same, should you wish to live. <br>\
		<b>Though they aren't all husks of bloodlust and violence, few would yet hear reason.</b></small>"

		dat += "\n<br><br>"

		dat += "<small><FONT color='grey'>Followers of <b>Mathios</b>:</font> Arrogant. <br>\
		Those who throw their lot in with the Aspect of Pride will care little for your words. \
		They're known to spit or curse upon the pantheon, just on a whim. \
		Further still, they likely don't care for any assumed normality. <br>\
		<b>You must be better. Appeal to self-worth in an attempt to sway the fools.</b></small>"

		dat += "\n<br><br>"

		dat += "<small><FONT color='grey'>Followers of <b>Zizo</b>:</font> Dreaded. <br>\
		Of those we do not look kindly upon, Zizites are the worst of them all. \
		Pawns of a game they do not understand, exchanging life and freedom for ambition and power. \
		Hands caught up in the loom of fate. The rules of life simple toys to this lot. <br>\
		<b>While repentance is not impossible, one shouldn't spend too much time on those so set on seeing us slain.</b></small>"

		dat += "\n<br><br>"

		dat += "\n<br><FONT style='color: var(--pg-orange, #E99F10)'>The Pantheon</font><br><br>"

		dat += "\n<br>"

		dat += "<small><FONT color='grey'>Followers of the <b>Pantheon</b>:</font> Family. <br>\
		They are your brothers. Your sisters. Your family. \
		All common thought is that you are to aid those of your own faith, whether it be remote, secondary or primary. <br>\
		<b>We are all in this together, after all.</b></small>"

		dat += "\n<br><br>"

		dat += "\n<br><FONT style='color: var(--pg-accent, #40A4B9)'>The Maker's Own</font><br><br>"

		dat += "\n<br>"

		dat += "<small><FONT color='grey'>Followers of The <b>Maker</b>:</font> Spurned. <br>\
		Fools that follow the Empire's lie. A 'unified' front, in the name of a false god. \
		There is no circumstance in which reason may prevail, for they're all lost. \
		Worse still, they will try to lead you astray. Steady your heart. <br>\
		<b>Pay these fools no mind, lest they get the idea to lay hands on you.</b></small>"

		dat += "\n<br><b>- - - - - -</b><br>"

	var/datum/browser/popup = new(M, "faith_hooks", "Faith Hooks", 640, 400) // Set up the popup browser window
	popup.set_content(dat.Join())
	popup.open()

/*
The procs and such used to display the above.
*/
/datum/job/proc/job_help_message(mob/M)
	to_chat(M, "<span class='boldannounce'>Your role in the realm has additional information attached to it. <a href=?src=[REF(src)];ShowJobStuff=1>(Click Here)</a></span>")

/datum/job/proc/job_hook_message(mob/M)
	to_chat(M, "<span class='boldannounce'>Your role comes with RP hooks. <a href=?src=[REF(src)];ShowRPHooks=1>(Click Here)</a></span>")

/datum/job/proc/job_faith_hook_message(mob/M)
	to_chat(M, "<span class='boldannounce'>Your role comes with Faith hooks. <a href=?src=[REF(src)];ShowFaithHooks=1>(Click Here)</a></span>")

/datum/job/Topic(href, href_list)
	if(href_list["ShowJobStuff"])
		ShowJobStuff(usr)
	if(href_list["ShowRPHooks"])
		ShowRPHookStuff(usr)
	if(href_list["ShowFaithHooks"])
		ShowFaithHookStuff(usr)
	. = ..()
