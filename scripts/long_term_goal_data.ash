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

void add_item_entry(string category, string group, item target, string criteria, boolean complete, string status)
{
	int i = count(long_term_entries);
	long_term_entries[i].category = category;
	long_term_entries[i].group = group;
	long_term_entries[i].name = target.to_string();
	long_term_entries[i].kind = "item";
	long_term_entries[i].criteria = criteria;
	long_term_entries[i].item_value = target;
	long_term_entries[i].complete = complete;
	long_term_entries[i].status = status;
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
	foreach target in $items[Hodgman's whackin' stick, Hodgman's imaginary hamster, Hodgman's disgusting technicolor overcoat, Hodgman's porkpie hat, Hodgman's lobsterskin pants, Hodgman's bow tie, Hodgman's lucky sock, Hodgman's varcolac paw, Hodgman's almanac, Hodgman's harmonica, Hodgman's garbage sticker, Hodgman's metal detector, Hodgman's cane]
		add_item_entry("Clan Dungeon Gear", "Hobopolis — Hodgman", target, "Defeat Hodgman and obtain this boss-equipment drop. Ownership is checked in inventory, equipped slots, the closet, Hagnk's storage, and the display case.");
	foreach target in $items[Ol' Scratch's infernal pitchfork, Ol' Scratch's stove door, Ol' Scratch's manacles]
		add_item_entry("Clan Dungeon Gear", "Hobopolis — Ol' Scratch", target, "Defeat Ol' Scratch in Burnbarrel Blvd. and obtain this boss drop.");
	foreach target in $items[Chester's sunglasses, Chester's muscle shirt, Chester's Aquarius medallion]
		add_item_entry("Clan Dungeon Gear", "Hobopolis — Chester", target, "Defeat Chester in the Purple Light District and obtain this boss drop.");
	foreach target in $items[Zombo's shoulder blade, Zombo's skull ring, Zombo's empty eye]
		add_item_entry("Clan Dungeon Gear", "Hobopolis — Zombo", target, "Defeat Zombo in The Ancient Hobo Burial Ground and obtain this boss drop.");
	foreach target in $items[Frosty's arm, Staff of the Deepest Freeze, Frosty's iceball]
		add_item_entry("Clan Dungeon Gear", "Hobopolis — Frosty", target, "Defeat Frosty in Exposure Esplanade and obtain this boss drop.");
	foreach target in $items[Oscus's garbage can lid, Oscus's neverending soda, Oscus's flypaper pants]
		add_item_entry("Clan Dungeon Gear", "Hobopolis — Oscus", target, "Defeat Oscus in The Heap and obtain this boss drop.");
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
	foreach target in $items[dreadful fedora, dreadful sweater, dreadful glove]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Freddy shop", target, "Earn Freddy Kruegerands from Dreadsylvania and buy this permanent equipment from the village shop.");
	foreach target in $items[Covers-Your-Head, Drapes-You-Regally, Warms-Your-Tush, Helps-You-Sleep, Quiets-Your-Steps, Protects-Your-Junk]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Falls-From-Sky", target, "Defeat Falls-From-Sky and obtain this boss-equipment drop.");
	foreach target in $items[Great Wolf's headband, Great Wolf's left paw, Great Wolf's right paw, Great Wolf's rocket launcher, Great Wolf's beastly trousers]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Great Wolf", target, "Defeat the Great Wolf and obtain this boss-equipment drop.");
	foreach target in $items[zombie mariachi hat, zombie accordion, zombie mariachi pants, HOA regulation book, HOA zombie eyes]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Zombie Homeowners' Association", target, "Defeat the Zombie Homeowners' Association and obtain this boss-equipment drop.");
	foreach target in $items[Mayor Ghost's toupee, Mayor Ghost's cloak, Mayor Ghost's khakis, Mayor Ghost's gavel, Mayor Ghost's sash]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Mayor Ghost", target, "Defeat Mayor Ghost and obtain this boss-equipment drop.");
	foreach target in $items[Thunkula's drinking cap, Drunkula's cape, Drunkula's silky pants, Drunkula's ring of haze, Drunkula's wineglass]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Count Drunkula", target, "Defeat Count Drunkula and obtain this boss-equipment drop.");
	foreach target in $items[Unkillable Skeleton's skullcap, Unkillable Skeleton's breastplate, Unkillable Skeleton's shinguards, Unkillable Skeleton's sawsword, Unkillable Skeleton's shield, Unkillable Skeleton's restless leg]
		add_item_entry("Clan Dungeon Gear", "Dreadsylvania — Unkillable Skeleton", target, "Defeat the Unkillable Skeleton and obtain this boss-equipment drop.");
}

void add_seasonal_and_buyable_skills()
{
	add_skill_entry("Permanent Unlocks", "Neverending Party", $skill[Drinking to Drink], "Complete the Neverending Party's quest progression and learn Drinking to Drink, the party's permanent passive skill.");

	foreach target in $skills[Carol of the Bulls, Carol of the Hells, Carol of the Thrills]
		add_skill_entry("Seasonal Skills", "Crimbo Carols", target, "Acquire the matching Crimbo Carol skill item and use it to learn this permanent skill.");
	foreach target in $skills[Crimbo Training: First Aid Technician, Crimbo Training: Passenger Greeter, Crimbo Training: Concierge, Crimbo Training: Track Switcher, Crimbo Training: Bartender, Crimbo Training:  Waiter, Crimbo Training: Coal Taster, Crimbo Training: Dessert Steward, Crimbo Training: Night Watchman, Crimbo Training: Sanitation Consultant, Crimbo Training: Graffiti Censor]
		add_skill_entry("Seasonal Skills", "Crimbo Training", target, "Acquire a Crimbo training manual that teaches this specialty and use it to learn the permanent skill.");
	foreach target in $skills[Ancient Crymbo Lore, Long Winter's Nap, Bowl Full of Jelly, Ashes and Soot, Eye and a Twist, Chubby and Plump, Dead Nostrils, Secret Door Awareness, Perpetrate Mild Evil, Chitinous Soul, Just the Facts, Elf Guard Cooking, Old-School Cocktailcrafting, Elf Guard Extortion Techniques, Fruit Recognition, Elf Guard Relaxation Techniques, Too Cool, Attract Snakes, Hide From Seekers, Reindeer Games, Master Egg Hunter, Holiday Multitasking]
		add_skill_entry("Seasonal Skills", "Other Crimbo skills", target, "Obtain this permanent seasonal skill from its associated Crimbo reward, skill item, or training source.");
	add_skill_entry("Seasonal Skills", "Other Crimbo skills", to_skill("Dimples, How Merry!"), "Obtain this permanent seasonal skill from its associated Crimbo reward, skill item, or training source.");

	foreach target in $skills[Really Expensive Jewelrycrafting, Perfect Freeze, Deep Dark Visions, Shrap, Intimidating Mien, Dinsey Operations Expert, Bow-Legged Swagger, Astute Angler, Gingerbread Mob Hit, Tempuramancy, Deep Saucery, Silent Treatment]
		add_skill_entry("Purchasable Skills", "Skill books and manuals", target, "Buy, trade for, or otherwise acquire the corresponding skill book or manual, then use it to learn this permanent skill.");
	add_skill_entry("Purchasable Skills", "Skill books and manuals", $skill[Rainbow Gravitation], "Buy or trade for the Traveling Trader's skill book, then use it to learn Rainbow Gravitation.");
	add_skill_entry("Purchasable Skills", "Skill books and manuals", $skill[Olfactory Burnout], "Buy or trade for A Scratch 'n' Sniff Guide to Dinseylandfill, then use it to learn Olfactory Burnout.");
	add_skill_entry("Purchasable Skills", "Skill books and manuals", $skill[Vent Rage Gland], "Buy or trade for a throbbing rage gland, then use it to learn Vent Rage Gland.");
}

void add_sea_progress()
{
	foreach target in $items[Lens of Violence, Pigsticker of Violence, Brand of Violence, Jodhpurs of Violence, Ass-Stompers of Violence, Novelty Belt Buckle of Violence]
		add_item_entry("Content", "The Sea — Violent Vestments", target, "Complete the relevant Sea Monkees finale and obtain this piece of the Violent Vestments outfit.");
	foreach target in $items[Lens of Hatred, Staff of Simmering Hatred, Cold Stone of Hatred, Pantaloons of Hatred, Fuzzy Slippers of Hatred, Girdle of Hatred]
		add_item_entry("Content", "The Sea — Hateful Habiliment", target, "Complete the relevant Sea Monkees finale and obtain this piece of the Hateful Habiliment outfit.");
	foreach target in $items[Goggles of Loathing, Stick-Knife of Loathing, Scepter of Loathing, Jeans of Loathing, Treads of Loathing, Belt of Loathing, Pocket Square of Loathing]
		add_item_entry("Content", "The Sea — Clothing of Loathing", target, "Complete the Sea Monkees quest with the appropriate class and obtain this piece of the Clothing of Loathing outfit.");
}

void add_hardcore_perms()
{
	foreach target in $skills[Really Expensive Jewelrycrafting, Perfect Freeze, Snowclone, Raise Backup Dancer, Deep Dark Visions, Shrap, Intimidating Mien, Dinsey Operations Expert, Bow-Legged Swagger, Astute Angler, Gingerbread Mob Hit, Carol of the Bulls, Carol of the Hells, Crimbo Training: Bartender, Tempuramancy, Deep Saucery, Inner Sauce, Silent Treatment, Salacious Cocktailcrafting, Deft Hands, Aloysius' Antiphon of Aptitude, The Moxious Madrigal, Cletus's Canticle of Celerity, The Polka of Plenty, The Magical Mojomuscular Melody, The Power Ballad of the Arrowsmith, Brawnee's Anthem of Absorption, Fat Leon's Phat Loot Lyric, The Psalm of Pointiness, Jackasses' Symphony of Destruction, Stevedave's Shanty of Superiority, The Ode to Booze, The Sonata of Sneakiness, Carlweather's Cantata of Confrontation, Ur-Kel's Aria of Annoyance]
		add_hcperm_entry(target);
}

void initialize_long_term_entries()
{
	add_skill_entry("Permanent Unlocks", "Bounty Hunter Hunter", $skill[Transcendent Olfaction], "Collect 200 filthy lucre from bounties and trade them to the Bounty Hunter Hunter for Manual of Transcendent Olfaction.");
	foreach target in $items[bounty-hunting helmet, bounty-hunting rifle, bounty-hunting pants]
		add_item_entry("Permanent Unlocks", "Bounty Hunter Hunter", target, "Buy this Bounty-Hunting Rig piece from the Bounty Hunter Hunter for 15 filthy lucre.");
	add_item_entry("Permanent Unlocks", "Bounty Hunter Hunter", $item[pompadour'd puppy], "Buy the pompadour'd puppy for 100 filthy lucre and hatch it to obtain the Jumpsuited Hound Dog familiar.", have_familiar($familiar[Jumpsuited Hound Dog]), have_familiar($familiar[Jumpsuited Hound Dog]) ? "Familiar owned" : "Missing");
	int telescope = get_property("telescopeUpgrades").to_int();
	add_content_entry("Permanent Unlocks", "Fernswarthy's Basement", "Seven telescope upgrades", "Reach Basement level 500 and use the Discount Telescope Warehouse gift certificate. Repeat this in seven ascensions to install all seven permanent telescope upgrades. The consumable rewards from levels 100–400 are intentionally not tracked.", telescope >= 7, telescope.to_string() + " / 7 upgrades");
	add_seasonal_and_buyable_skills();
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
