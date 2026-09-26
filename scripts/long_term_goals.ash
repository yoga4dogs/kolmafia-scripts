record LongTermGoal {
	string id;
	string title;
	string description;
	string category;
	int priority;
	boolean automatic;
};

LongTermGoal[int] long_term_goals;

void add_long_term_goal(string id, string title, string description, string category, int priority, boolean automatic)
{
	int index = count(long_term_goals);
	long_term_goals[index].id = id;
	long_term_goals[index].title = title;
	long_term_goals[index].description = description;
	long_term_goals[index].category = category;
	long_term_goals[index].priority = priority;
	long_term_goals[index].automatic = automatic;
}

void initialize_long_term_goals()
{
	add_long_term_goal("transcendent_olfaction", "Transcendent Olfaction", "Get Transcendent Olfaction", "permanent skill", 1, true);
	add_long_term_goal("pulverize", "Pulverize", "Learn Pulverize", "permanent skill", 1, true);
	add_long_term_goal("sea_classes", "Sea progression", "Finish class-specific Sea progression", "content completion", 1, false);
	add_long_term_goal("telescope", "Telescope", "Continue Fernswarthy's Basement / telescope upgrades", "permanent unlock", 2, false);
	add_long_term_goal("hobopolis", "Hobopolis reward audit", "Check missing Hobopolis skills/rewards", "clan dungeon", 2, false);
	add_long_term_goal("slime_tube", "Slime Tube reward audit", "Check missing Slime Tube skills/rewards", "clan dungeon", 2, false);
	add_long_term_goal("dreadsylvania", "Dreadsylvania reward audit", "Check missing Dreadsylvania skills/rewards", "clan dungeon", 2, false);
	add_long_term_goal("base_class_skills", "Base-class skill library", "Fill missing normal class skills", "skills", 2, true);
	add_long_term_goal("hardcore_perms", "Hardcore perms", "Hardcore-perm useful skills", "skills", 2, true);
	add_long_term_goal("standard_rewards", "Missing Standard rewards", "Fill missing Standard class/year rewards", "ascension", 2, false);
	add_long_term_goal("challenge_paths", "Challenge-path rewards", "Check unfinished challenge-path permanent rewards", "ascension", 3, false);
	add_long_term_goal("factoids", "Monster Manuel factoids", "Work on Monster Manuel factoids", "collection", 3, false);
	add_long_term_goal("tattoos", "Tattoos", "Check missing tattoos", "collection", 3, false);
	add_long_term_goal("trophies", "Trophies", "Check obtainable missing trophies", "collection", 3, false);
}

boolean known_long_term_goal(string id)
{
	foreach i, goal in long_term_goals
		if (goal.id == id)
			return true;
	return false;
}

string goal_complete_property(string id)
{
	return "customGoal_" + id + "_complete";
}

string goal_hidden_property(string id)
{
	return "customGoal_" + id + "_hidden";
}

boolean goal_hidden(string id)
{
	return get_property(goal_hidden_property(id)).to_boolean();
}

string[int] base_class_skill_ids()
{
	// Generated from current KoLmafia classskills.txt entries for the six normal
	// classes that have a Level attribute. This deliberately excludes obsolete,
	// special-source, and explicitly unpermable class-range skills.
	return split_string(
		"1000,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1014,1015,1016,1017,1018,1019,1022,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040," +
		"2000,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2014,2015,2016,2020,2021,2023,2027,2028,2029,2030,2031,2032,2033,2034,2035,2036,2037,2038,2039,2040,2041," +
		"3000,3003,3004,3005,3006,3007,3008,3009,3010,3011,3012,3014,3015,3016,3017,3018,3020,3025,3026,3027,3028,3029,3030,3031,3032,3033,3034,3035,3036,3037,3038,3039," +
		"4000,4003,4004,4005,4006,4007,4008,4009,4010,4011,4012,4014,4015,4016,4017,4018,4020,4024,4025,4026,4027,4028,4029,4030,4031,4032,4033,4034,4035,4037,4038,4039," +
		"5000,5003,5004,5005,5006,5007,5008,5009,5010,5011,5012,5014,5015,5016,5017,5018,5021,5025,5026,5027,5028,5029,5030,5031,5032,5033,5034,5035,5036,5037,5038,5039," +
		"6000,6003,6004,6005,6006,6007,6008,6009,6010,6011,6012,6013,6014,6015,6016,6017,6025,6029,6030,6031,6032,6033,6034,6035,6036,6037,6038,6039,6040,6041,6042,6043",
		","
	);
}

skill[int] hardcore_perm_watch_list()
{
	return $skills[
		Really Expensive Jewelrycrafting, Perfect Freeze, Snowclone,
		Raise Backup Dancer, Deep Dark Visions, Shrap, Intimidating Mien,
		Dinsey Operations Expert, Bow-Legged Swagger, Astute Angler,
		Gingerbread Mob Hit, Carol of the Bulls, Carol of the Hells,
		Crimbo Training: Bartender, Tempuramancy, Deep Saucery, Inner Sauce,
		Silent Treatment, Salacious Cocktailcrafting, Deft Hands,
		Aloysius' Antiphon of Aptitude, The Moxious Madrigal,
		Cletus's Canticle of Celerity, The Polka of Plenty,
		The Magical Mojomuscular Melody, The Power Ballad of the Arrowsmith,
		Brawnee's Anthem of Absorption, Fat Leon's Phat Loot Lyric,
		The Psalm of Pointiness, Jackasses' Symphony of Destruction,
		Stevedave's Shanty of Superiority, The Ode to Booze,
		The Sonata of Sneakiness, Carlweather's Cantata of Confrontation,
		Ur-Kel's Aria of Annoyance
	];
}

boolean hcperm_ignored(skill candidate)
{
	string[int] ignored = split_string(get_property("customGoal_hcpermIgnore"), "\\s*,\\s*");
	foreach i, value in ignored
		if (value != "" && (value.to_lower_case() == candidate.to_string().to_lower_case() || value.to_int() == candidate.to_int()))
			return true;
	return false;
}

int sea_classes_complete()
{
	string[int] abbreviations = split_string("SC,TT,PM,S,DB,AT", ",");
	class[int] classes = $classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief];
	int complete = 0;
	foreach i, abbreviation in abbreviations
	{
		boolean done = get_property("_customGoal_sea_" + abbreviation).to_boolean();
		if (!done && my_class() == classes[i] && get_property("questS02Monkees") == "finished")
			done = true;
		if (done)
			complete += 1;
	}
	return complete;
}

int base_skills_known()
{
	int known = 0;
	foreach i, skill_id in base_class_skill_ids()
		if (have_skill(skill_id.to_int().to_skill()))
			known += 1;
	return known;
}

int hardcore_perms_remaining()
{
	boolean[skill] permed = get_permed_skills();
	int remaining = 0;
	foreach i, candidate in hardcore_perm_watch_list()
		if (!hcperm_ignored(candidate) && !permed[candidate])
			remaining += 1;
	return remaining;
}

boolean goal_complete(string id)
{
	if (get_property(goal_complete_property(id)).to_boolean())
		return true;

	switch (id)
	{
	case "transcendent_olfaction": return have_skill($skill[Transcendent Olfaction]);
	case "pulverize": return have_skill($skill[Pulverize]);
	case "telescope": return get_property("telescopeUpgrades").to_int() >= 7 || get_property("_customGoal_telescopeComplete").to_boolean();
	case "sea_classes": return sea_classes_complete() == 6;
	case "base_class_skills": return base_skills_known() == count(base_class_skill_ids());
	case "hardcore_perms": return hardcore_perms_remaining() == 0;
	case "hobopolis": return get_property("_customGoal_hobopolisComplete").to_boolean();
	case "slime_tube": return get_property("_customGoal_slimeTubeComplete").to_boolean();
	case "dreadsylvania": return get_property("_customGoal_dreadsylvaniaComplete").to_boolean();
	}

	return false;
}

string goal_progress(string id)
{
	if (id == "telescope")
		return get_property("telescopeUpgrades").to_int() + " / 7";
	if (id == "sea_classes")
		return sea_classes_complete() + " / 6 classes complete";
	if (id == "base_class_skills")
		return base_skills_known() + " / " + count(base_class_skill_ids());
	if (id == "hardcore_perms")
		return hardcore_perms_remaining() + " remaining";
	return "";
}

void handle_long_term_goal_action()
{
	string[string] fields = form_fields();
	string action = fields["customGoalAction"];
	string id = fields["customGoalId"];
	if (!known_long_term_goal(id))
		return;

	if (action == "done")
		set_property(goal_complete_property(id), "true");
	else if (action == "hide")
		set_property(goal_hidden_property(id), "true");
}

string render_goal_control(string id, string action, string label)
{
	return "<form method=\"get\" action=\"main.php\" style=\"display:inline; margin-left:5px;\">" +
		"<input type=\"hidden\" name=\"customGoalAction\" value=\"" + action + "\">" +
		"<input type=\"hidden\" name=\"customGoalId\" value=\"" + id + "\">" +
		"<button type=\"submit\" style=\"font-size:10px; padding:0 3px;\">" + label + "</button></form>";
}

string render_long_term_goals()
{
	string rows = "";
	for priority from 1 to 3
		foreach i, goal in long_term_goals
		{
			if (goal.priority != priority || goal_complete(goal.id) || goal_hidden(goal.id))
				continue;

			string progress = goal_progress(goal.id);
			string marker = priority == 1 ? "&#9888;" : "&#8226;";
			rows += "<div style=\"padding:3px 5px; border-top:1px solid #ddd;\" title=\"" + goal.description + "\">" +
				"<span style=\"color:" + (priority == 1 ? "#a00" : "#555") + "; margin-right:5px;\">" + marker + "</span>" +
				"<strong>" + goal.title + "</strong>" + (progress == "" ? "" : ": " + progress);
			if (!goal.automatic)
				rows += render_goal_control(goal.id, "done", "done") + render_goal_control(goal.id, "hide", "hide");
			rows += "</div>";
		}

	if (rows == "")
		return "";

	return "<div id=\"mafia-long-term-goals\" style=\"width:95%; margin:6px auto; border:1px solid #777; background:#fafafa; font:12px Arial,sans-serif;\">" +
		"<div style=\"padding:4px 6px; background:#ddd; text-align:center; font-weight:bold; letter-spacing:.08em;\">LONG-TERM GOALS</div>" +
		rows + "</div>";
}

initialize_long_term_goals();
