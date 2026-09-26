record LongTermEntry {
	string category;
	string group;
	string name;
	string kind;
	string criteria;
	skill skill_value;
	item item_value;
	boolean complete;
	string status;
};

LongTermEntry[int] long_term_entries;

void add_entry(string category, string group, string name, string kind, string criteria, skill target, boolean complete, string status)
{
	int i = count(long_term_entries);
	long_term_entries[i].category = category;
	long_term_entries[i].group = group;
	long_term_entries[i].name = name;
	long_term_entries[i].kind = kind;
	long_term_entries[i].criteria = criteria;
	long_term_entries[i].skill_value = target;
	long_term_entries[i].complete = complete;
	long_term_entries[i].status = status;
}

void add_skill_entry(string category, string group, skill target, string criteria)
{
	add_entry(category, group, target.to_string(), "skill", criteria, target, have_skill(target), have_skill(target) ? "Known" : "Missing");
}

void add_class_skill(skill target)
{
	string criteria = "Reach level " + target.level.to_string() + " as a " + target.class.to_string() + ", learn the skill from the guild trainer, then perm it with Karma on ascension.";
	add_skill_entry("Class Skills", target.class.to_string(), target, criteria);
}

void add_hcperm_entry(skill target)
{
	boolean[skill] permed = get_permed_skills();
	boolean complete = permed[target];
	add_entry("Hardcore Perms", "Useful skills", target.to_string(), "skill", "Learn this skill, then spend Karma after an ascension to make it Hardcore Permanent. A normal Permanent (P) does not count.", target, complete, complete ? "Hardcore Permanent" : "Needs HC perm");
}

int account_owned_amount(item target)
{
	return item_amount(target) + equipped_amount(target) + closet_amount(target) +
		storage_amount(target) + display_amount(target);
}

void add_item_entry(string category, string group, item target, string criteria)
{
	int i = count(long_term_entries);
	long_term_entries[i].category = category;
	long_term_entries[i].group = group;
	long_term_entries[i].name = target.to_string();
	long_term_entries[i].kind = "item";
	long_term_entries[i].criteria = criteria;
	long_term_entries[i].item_value = target;
	// available_amount() depends on retrieval settings and current ronin state.
	// Check every character-owned location explicitly so Hagnk's and the closet
	// still satisfy durable collection goals.
	long_term_entries[i].complete = account_owned_amount(target) > 0;
	long_term_entries[i].status = long_term_entries[i].complete ? "Owned" : "Not detected";
}

void add_content_entry(string category, string group, string name, string criteria, boolean complete, string status)
{
	add_entry(category, group, name, "content", criteria, $skill[none], complete, status);
}

void add_useful_class_skills()
{
	foreach target in $skills[Pulverize, Rage of the Reindeer, Batter Up!, Double-Fisted Skull Smashing, Musk of the Moose]
		add_class_skill(target);
	foreach target in $skills[Amphibian Sympathy, Empathy of the Newt, Hero of the Half-Shell, Tao of the Terrapin]
		add_class_skill(target);
	foreach target in $skills[Entangling Noodles, Pastamastery, Leash of Linguini, Cannelloni Cocoon, Springy Fusilli, Flavour of Magic]
		add_class_skill(target);
	foreach target in $skills[Advanced Saucecrafting, Saucy Salve, The Way of Sauce, Soul Saucery, Inner Sauce, Saucemaven]
		add_class_skill(target);
	foreach target in $skills[Mad Looting Skillz, Advanced Cocktailcrafting, Ambidextrous Funkslinging, Smooth Movement, Salacious Cocktailcrafting, Deft Hands]
		add_class_skill(target);
	foreach target in $skills[The Moxious Madrigal, The Polka of Plenty, The Magical Mojomuscular Melody, The Power Ballad of the Arrowsmith, Fat Leon's Phat Loot Lyric, The Ode to Booze, The Sonata of Sneakiness, Carlweather's Cantata of Confrontation, Ur-Kel's Aria of Annoyance]
		add_class_skill(target);
}

void add_dread_skill(skill target, string recipient_class, string partner_class)
{
	add_skill_entry(
		"Clan Dungeons",
		"Dreadsylvania — " + recipient_class,
		target,
		"The " + recipient_class + " is the class that learns this skill. Complete its Dreadsylvania skill interaction with help from a " + partner_class + " and a third player."
	);
}

void add_clan_dungeon_skills()
{
	foreach target in $skills[Awesome Balls of Fire, Conjure Relaxing Campfire, Snowclone, Maximum Chill, Eggsplosion, Mudbath, Grease Lightning, Inappropriate Backrub, Natural Born Scrabbler, Thrift and Grift, Abs of Tin, Marginally Insane, Raise Backup Dancer, Creepy Lullaby]
		add_skill_entry("Clan Dungeons", "Hobopolis", target, "Acquire and read the corresponding Hobopolis skill book. Hodgman and the elemental district bosses supply the relevant books and journals.");
	add_item_entry("Clan Dungeons", "Hobopolis", $item[hobo code binder], "Get the binder from Hobopolis and fill it with glyphs found throughout the dungeon; the binder preserves learned hobo-code progress.");
	foreach target in $skills[Slimy Sinews, Slimy Synapses, Slimy Shoulders]
		add_skill_entry("Clan Dungeons", "Slime Tube", target, "Use a Slime Tube skill item made from hardened slime; repeat to raise this passive skill toward its maximum level of 10.");
	foreach target in $items[hardened slime hat, hardened slime pants, hardened slime belt]
		add_item_entry("Clan Dungeons", "Slime Tube", target, "Finish a sufficiently fast Slime Tube run, obtain a hardened slime piece, and assemble the permanent three-piece hardened slime outfit.");
	add_dread_skill($skill[Club Earth], "Seal Clubber", "Turtle Tamer");
	add_dread_skill($skill[Carbohydrate Cudgel], "Seal Clubber", "Pastamancer");
	add_dread_skill($skill[Splattersmash], "Seal Clubber", "Sauceror");
	add_dread_skill($skill[Grab a Cold One], "Seal Clubber", "Disco Bandit");
	add_dread_skill($skill[Song of the North], "Seal Clubber", "Accordion Thief");
	add_dread_skill($skill[Turtleini], "Turtle Tamer", "Pastamancer");
	add_dread_skill($skill[Sauceshell], "Turtle Tamer", "Sauceror");
	add_dread_skill($skill[Conspiratorial Whispers], "Turtle Tamer", "Disco Bandit");
	add_dread_skill($skill[Song of Slowness], "Turtle Tamer", "Accordion Thief");
	add_dread_skill($skill[Spaghetti Breakfast], "Pastamancer", "Sauceror");
	add_dread_skill($skill[Shadow Noodles], "Pastamancer", "Disco Bandit");
	add_dread_skill($skill[Song of Starch], "Pastamancer", "Accordion Thief");
	add_dread_skill($skill[Splashdance], "Sauceror", "Disco Bandit");
	add_dread_skill($skill[Song of Sauce], "Sauceror", "Accordion Thief");
	add_dread_skill($skill[Song of Bravado], "Disco Bandit", "Accordion Thief");
	add_item_entry("Clan Dungeons", "Dreadsylvania — useful gear", $item[Dreadsylvania Auditor's badge], "Accumulate Freddies in Dreadsylvania and buy the Auditor's badge from the village shop; it improves future Freddy acquisition.");
}

void add_sea_progress()
{
	string criteria = "Finish the Sea Monkees quest as this class and claim its Clothing of Loathing reward. Owning the class reward is used as the durable completion signal.";
	add_item_entry("Content", "Sea — Seal Clubber", $item[stick-knife of Loathing], criteria);
	add_item_entry("Content", "Sea — Turtle Tamer", $item[belt of Loathing], criteria);
	add_item_entry("Content", "Sea — Pastamancer", $item[scepter of Loathing], criteria);
	add_item_entry("Content", "Sea — Sauceror", $item[goggles of Loathing], criteria);
	add_item_entry("Content", "Sea — Disco Bandit", $item[jeans of Loathing], criteria);
	add_item_entry("Content", "Sea — Accordion Thief", $item[treads of Loathing], criteria);
}

void add_hardcore_perms()
{
	foreach target in $skills[Really Expensive Jewelrycrafting, Perfect Freeze, Snowclone, Raise Backup Dancer, Deep Dark Visions, Shrap, Intimidating Mien, Dinsey Operations Expert, Bow-Legged Swagger, Astute Angler, Gingerbread Mob Hit, Carol of the Bulls, Carol of the Hells, Crimbo Training: Bartender, Tempuramancy, Deep Saucery, Inner Sauce, Silent Treatment, Salacious Cocktailcrafting, Deft Hands, Aloysius' Antiphon of Aptitude, The Moxious Madrigal, Cletus's Canticle of Celerity, The Polka of Plenty, The Magical Mojomuscular Melody, The Power Ballad of the Arrowsmith, Brawnee's Anthem of Absorption, Fat Leon's Phat Loot Lyric, The Psalm of Pointiness, Jackasses' Symphony of Destruction, Stevedave's Shanty of Superiority, The Ode to Booze, The Sonata of Sneakiness, Carlweather's Cantata of Confrontation, Ur-Kel's Aria of Annoyance]
		add_hcperm_entry(target);
}

void initialize_long_term_entries()
{
	add_skill_entry("Permanent Unlocks", "Bounty Hunter Hunter", $skill[Transcendent Olfaction], "Collect 200 filthy lucre from bounties and trade them to the Bounty Hunter Hunter for Manual of Transcendent Olfaction.");
	int telescope = get_property("telescopeUpgrades").to_int();
	add_content_entry("Permanent Unlocks", "Fernswarthy's Basement", "Seven telescope upgrades", "Reach Basement level 100, 200, 300, 400, 500, 600, and 700. Each milestone permanently adds one telescope upgrade.", telescope >= 7, telescope.to_string() + " / 7 upgrades");
	add_useful_class_skills();
	add_sea_progress();
	add_clan_dungeon_skills();
	add_hardcore_perms();
	add_content_entry("Historical Content", "Standard rewards", "Standard class/year equipment", "Audit the six class rewards for each Standard season. KoLmafia does not expose a reliable account-wide year/class completion table, so this remains visible as an audit target.", false, "Audit needed");
	add_skill_entry("Historical Content", "Challenge paths", $skill[Master of the Surprising Fist], "Complete Way of the Surprising Fist and learn the path's permable mastery skill.");
	add_skill_entry("Historical Content", "Challenge paths", $skill[Lock Picking], "Complete Low Key Summer, obtain Manual of Lock Picking, and read it.");
	add_item_entry("Historical Content", "Challenge paths", $item[The Big Book of Every Skill], "Complete Journeyman and claim The Big Book of Every Skill permanent reward.");
	add_content_entry("Collections", "Monster Manuel", "Monster Manuel factoids", "Collect all three factoids for monsters you care about. KoLmafia has no reliable aggregate known/possible factoid API, so this remains an audit target.", false, "Audit needed");
}

initialize_long_term_entries();
