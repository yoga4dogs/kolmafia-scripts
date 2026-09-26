import <browser_notify.ash>;

/*
	Login reminders for useful daily actions.

	Settings (set them with `set name = value` in the gCLI):

	  dailyRemindersFreeRests = true
	  dailyRemindersGarden = true
	  dailyRemindersDailyDungeon = true
	  dailyRemindersNeverendingParty = true
	  dailyRemindersBounties = true
	  dailyRemindersChateauDesk = true
	  dailyRemindersFreeFights = true
	  dailyRemindersProgression = true
	  dailyRemindersClan = true
	  dailyRemindersWorkshed = true
	  dailyRemindersVoting = true
	  dailyRemindersCampaway = true
	  dailyRemindersItemGenerators = true

	Each setting defaults to true. The script only queues reminders; it never
	spends a turn, uses an item, or harvests the garden.
*/

boolean reminder_enabled(string property)
{
	string value = get_property(property);

	if (value == "")
		return true;

	return value.to_boolean();
}

int garden_growth()
{
	string garden = my_garden_type();
	item seed_packet = $item[none];

	switch (garden)
	{
	case "pumpkin":
		seed_packet = $item[packet of pumpkin seeds];
		break;
	case "peppermint":
		seed_packet = $item[Peppermint Pip Packet];
		break;
	case "skeleton":
		seed_packet = $item[packet of dragon\'s teeth];
		break;
	case "beer":
		seed_packet = $item[packet of beer seeds];
		break;
	case "winter":
		seed_packet = $item[packet of winter seeds];
		break;
	case "thanksgarden":
		seed_packet = $item[packet of thanksgarden seeds];
		break;
	case "grass":
		seed_packet = $item[packet of tall grass seeds];
		break;
	case "mushroom":
		seed_packet = $item[packet of mushroom spores];
		break;
	default:
		return 0;
	}

	return get_campground()[seed_packet];
}

void remind_about_free_rests()
{
	if (!reminder_enabled("dailyRemindersFreeRests"))
		return;

	int rests_left = total_free_rests() - get_property("timesRested").to_int();
	boolean needs_recovery = my_hp() < my_maxhp() || my_mp() < my_maxmp();

	if (rests_left <= 0 || !needs_recovery)
		return;

	browser_notify(
		"daily-free-rests",
		rests_left + " free " + (rests_left == 1 ? "rest" : "rests") + " available",
		"campground.php",
		"You are missing HP or MP. Resting at your campground may restore both for free.",
		"message"
	);
}

void remind_about_garden()
{
	if (!reminder_enabled("dailyRemindersGarden"))
		return;

	string garden = my_garden_type();
	int growth = garden_growth();

	if (garden == "none" || garden == "" || growth <= 0)
		return;

	browser_notify(
		"daily-garden",
		"Your " + garden + " garden has grown (stage " + growth + ")",
		"campground.php?action=garden",
		"Open the garden to inspect it. This reminder does not harvest anything.",
		"message"
	);
}

void remind_about_daily_dungeon()
{
	if (!reminder_enabled("dailyRemindersDailyDungeon"))
		return;

	if (get_property("_dailyDungeonDone").to_boolean())
		return;

	browser_notify(
		"daily-dungeon",
		"The Daily Dungeon is still available",
		"da.php",
		"Open the Daily Dungeon. Disable with: set dailyRemindersDailyDungeon = false",
		"message"
	);
}

void remind_about_neverending_party()
{
	if (!reminder_enabled("dailyRemindersNeverendingParty"))
		return;

	boolean party_available =
		get_property("neverendingPartyAlways").to_boolean() ||
		get_property("_neverendingPartyToday").to_boolean();

	if (!party_available)
		return;

	if (have_skill($skill[Drinking to Drink]))
		return;

	if (get_property("_questPartyFair") == "finished")
		return;

	browser_notify(
		"daily-neverending-party",
		"The Neverending Party quest is not complete",
		to_url($location[The Neverending Party]),
		"Complete the daily Party Fair quest while working toward Drinking to Drink.",
		"alert"
	);
}

void remind_about_chateau_desk()
{
	if (!reminder_enabled("dailyRemindersChateauDesk"))
		return;

	if (!get_property("chateauAvailable").to_boolean())
		return;

	if (get_property("_chateauDeskHarvested").to_boolean())
		return;

	browser_notify(
		"daily-chateau-desk",
		"Your Chateau desk item is still available",
		"place.php?whichplace=chateau&action=chateau_desk",
		"Visit the desk to collect its free daily item.",
		"message"
	);
}

void add_free_fights(string [int] sources, string name, int used, int maximum)
{
	int remaining = maximum - used;
	if (remaining > 0)
		sources[count(sources)] = name + ": " + remaining;
}

void remind_about_free_fights()
{
	if (!reminder_enabled("dailyRemindersFreeFights"))
		return;

	string [int] sources;

	if (get_campground()[$item[Witchess Set]] > 0)
		add_free_fights(sources, "Witchess", get_property("_witchessFights").to_int(), 5);

	if (get_property("snojoAvailable").to_boolean())
		add_free_fights(sources, "Snojo", get_property("_snojoFreeFights").to_int(), 10);

	boolean party_available =
		get_property("neverendingPartyAlways").to_boolean() ||
		get_property("_neverendingPartyToday").to_boolean();
	if (party_available)
		add_free_fights(sources, "Neverending Party", get_property("_neverendingPartyFreeTurns").to_int(), 10);

	if (get_property("ownsSpeakeasy").to_boolean())
		add_free_fights(sources, "Speakeasy", get_property("_speakeasyFreeFights").to_int(), 3);

	if (have_familiar($familiar[God Lobster]))
		add_free_fights(sources, "God Lobster", get_property("_godLobsterFights").to_int(), 3);

	if (get_property("voteAlways").to_boolean() && get_property("_voteToday").to_boolean())
		add_free_fights(sources, "Voting Booth", get_property("_voteFreeFights").to_int(), 3);

	if (count(sources) == 0)
		return;

	int total = 0;
	string details = "";
	foreach i, source in sources
	{
		if (details != "")
			details += ", ";
		details += source;
		total += source.substring(source.index_of(": ") + 2).to_int();
	}

	browser_notify(
		"daily-free-fights",
		total + " free " + (total == 1 ? "fight" : "fights") + " available",
		"main.php",
		details + ".",
		"message"
	);
}

void remind_about_progression()
{
	if (!reminder_enabled("dailyRemindersProgression"))
		return;

	if (get_property("telegraphOfficeAvailable").to_boolean() &&
		!get_property("_telegraphOfficeToday").to_boolean())
	{
		browser_notify(
			"daily-progression-telegraph",
			"An LT&T telegram quest is available",
			"place.php?whichplace=town_right&action=townright_ltt",
			"Telegram quests advance the office's permanent rewards.",
			"alert"
		);
	}

	if (get_property("gingerbreadCityAvailable").to_boolean())
	{
		string missing = "";
		if (!get_property("gingerAdvanceClockUnlocked").to_boolean())
			missing += "clock advancement";
		if (!get_property("gingerRetailUnlocked").to_boolean())
			missing += (missing == "" ? "" : ", ") + "retail district";
		if (!get_property("gingerSewersUnlocked").to_boolean())
			missing += (missing == "" ? "" : ", ") + "sewers";
		if (!get_property("gingerExtraAdventures").to_boolean())
			missing += (missing == "" ? "" : ", ") + "thicker city walls";

		if (missing != "")
			browser_notify(
				"daily-progression-gingerbread",
				"Gingerbread City upgrades remain",
				"place.php?whichplace=gingerbreadcity",
				"Missing permanent upgrades: " + missing + ".",
				"alert"
			);
	}

	if (get_property("spacegateAlways").to_boolean())
	{
		int vaccines = 0;
		if (get_property("spacegateVaccine1").to_boolean()) vaccines += 1;
		if (get_property("spacegateVaccine2").to_boolean()) vaccines += 1;
		if (get_property("spacegateVaccine3").to_boolean()) vaccines += 1;

		if (vaccines < 3 && !get_property("_spacegateToday").to_boolean())
			browser_notify(
				"daily-progression-spacegate",
				(3 - vaccines) + " Spacegate " + ((3 - vaccines) == 1 ? "vaccine" : "vaccines") + " still locked",
				"place.php?whichplace=spacegate",
				"A daily Spacegate expedition can discover hazards used to unlock permanent vaccines.",
				"alert"
			);
	}

	if (get_property("snojoAvailable").to_boolean())
	{
		int muscle = get_property("snojoMuscleWins").to_int();
		int mysticality = get_property("snojoMysticalityWins").to_int();
		int moxie = get_property("snojoMoxieWins").to_int();
		if (muscle < 50 || mysticality < 50 || moxie < 50)
			browser_notify(
				"daily-progression-snojo",
				"Snojo reward tracks are incomplete",
				"place.php?whichplace=snojo",
				"Wins toward 50 — Muscle: " + muscle + ", Mysticality: " + mysticality + ", Moxie: " + moxie + ".",
				"alert"
			);
	}

	if (get_campground()[$item[Witchess Set]] > 0 && get_property("chessboardsCleared").to_int() < 50)
		browser_notify(
			"daily-progression-witchess",
			"Witchess puzzles remain",
			"campground.php?action=witchess",
			get_property("chessboardsCleared") + "/50 puzzles cleared toward maximum Puzzle Champ.",
			"alert"
		);
}

void remind_about_clan_freebies()
{
	if (!reminder_enabled("dailyRemindersClan"))
		return;

	if (available_amount($item[Clan VIP Lounge key]) == 0)
		return;

	string lounge = visit_url("clan_viplounge.php", false);
	string available = "";

	if (contains_text(lounge, "klaw") && get_property("_deluxeKlawSummons").to_int() < 3)
		available += "Mr. Klaw: " + (3 - get_property("_deluxeKlawSummons").to_int());
	if (contains_text(lounge, "lookingglass") && !get_property("_lookingGlass").to_boolean())
		available += (available == "" ? "" : ", ") + "looking glass";
	if (contains_text(lounge, "crimbotree") && !get_property("_crimboTree").to_boolean() && get_property("crimboTreeDays").to_int() == 0)
		available += (available == "" ? "" : ", ") + "Crimbo tree";
	if (contains_text(lounge, "pooltable") && get_property("_poolGames").to_int() < 3)
		available += (available == "" ? "" : ", ") + "pool games: " + (3 - get_property("_poolGames").to_int());
	if (contains_text(lounge, "shower") && !get_property("_aprilShower").to_boolean())
		available += (available == "" ? "" : ", ") + "April shower";
	if (contains_text(lounge, "swimmingpool") && !get_property("_olympicSwimmingPool").to_boolean())
		available += (available == "" ? "" : ", ") + "swimming pool";
	if (contains_text(lounge, "lovetester") && !get_property("_clanFortuneBuffUsed").to_boolean())
		available += (available == "" ? "" : ", ") + "fortune buff";

	if (available != "")
		browser_notify(
			"daily-clan-freebies",
			"Clan VIP freebies remain",
			"clan_viplounge.php",
			available + ".",
			"message"
		);
}

void remind_about_workshed()
{
	if (!reminder_enabled("dailyRemindersWorkshed"))
		return;

	item workshed = get_workshed();
	string available = "";

	if (workshed == $item[cold medicine cabinet] && get_property("_coldMedicineConsults").to_int() < 5)
		available = "medicine consultations used: " + get_property("_coldMedicineConsults") + "/5";
	else if (workshed == $item[Little Geneticist DNA-Splicing Lab] &&
		get_property("dnaSyringe") != "" && get_property("_dnaPotionsMade").to_int() < 3)
		available = "DNA potions made: " + get_property("_dnaPotionsMade") + "/3";
	else if (workshed == $item[portable Mayo Clinic] && !get_property("_mayoTankSoaked").to_boolean())
		available = "Mayo tank soak";

	if (available != "")
		browser_notify(
			"daily-workshed",
			"A workshed daily is available",
			"campground.php?action=workshed",
			available + ".",
			"message"
		);
}

void remind_about_voting()
{
	if (!reminder_enabled("dailyRemindersVoting") || !get_property("voteAlways").to_boolean())
		return;

	if (!get_property("_voteToday").to_boolean())
		browser_notify(
			"daily-voting",
			"You have not voted today",
			"place.php?whichplace=town_right&action=townright_vote",
			"Vote to collect today's free sticker and enable voter-monster fights.",
			"message"
		);
}

void remind_about_campaway()
{
	if (!reminder_enabled("dailyRemindersCampaway") || !get_property("getawayCampsiteUnlocked").to_boolean())
		return;

	string available = "";
	if (get_property("_campAwayCloudBuffs").to_int() == 0)
		available = "sky buff";
	if (get_property("_campAwaySmileBuffs").to_int() == 0)
		available += (available == "" ? "" : ", ") + "smile buff";

	if (available != "")
		browser_notify(
			"daily-campaway",
			"Distant Woods Getaway freebies remain",
			"place.php?whichplace=campaway",
			available + ".",
			"message"
		);
}

void remind_about_item_generators()
{
	if (!reminder_enabled("dailyRemindersItemGenerators"))
		return;

	string available = "";
	if (available_amount($item[Deck of Every Card]) > 0 && get_property("_deckCardsDrawn").to_int() < 15)
		available = "Deck draws: " + (15 - get_property("_deckCardsDrawn").to_int());
	if (available_amount($item[potted tea tree]) > 0 && !get_property("_pottedTeaTreeUsed").to_boolean())
		available += (available == "" ? "" : ", ") + "potted tea tree";
	if (get_property("barrelShrineUnlocked").to_boolean() && !get_property("_barrelPrayer").to_boolean())
		available += (available == "" ? "" : ", ") + "Barrel god prayer";
	if (get_campground()[$item[Source terminal]] > 0 && get_property("_sourceTerminalExtrudes").to_int() < 3)
		available += (available == "" ? "" : ", ") + "Source Terminal extrudes: " + (3 - get_property("_sourceTerminalExtrudes").to_int());
	if (get_campground()[$item[spinning wheel]] > 0 && !get_property("_spinningWheel").to_boolean())
		available += (available == "" ? "" : ", ") + "spinning wheel";

	if (available != "")
		browser_notify(
			"daily-item-generators",
			"Daily item generation remains",
			"campground.php",
			available + ".",
			"message"
		);
}

boolean bounty_available(string tier)
{
	return get_property("_untaken" + tier + "BountyItem") != "" ||
		get_property("_unknown" + tier + "BountyItem") != "";
}

int filthy_lucre_owned()
{
	int total = available_amount($item[filthy lucre]);

	/* Hagnk's is inaccessible in Hardcore and Ronin, so available_amount()
	   does not include the lucre stored there. It still counts toward the
	   long-term Transcendent Olfaction goal. */
	if (!can_interact())
		total += storage_amount($item[filthy lucre]);

	return total;
}

void remind_about_bounties()
{
	if (!reminder_enabled("dailyRemindersBounties"))
		return;

	/* Refresh the page so KoLmafia populates today's untaken bounty prefs. */
	visit_url("bounty.php", false);

	string [int] tiers;
	if (bounty_available("Easy"))
		tiers[count(tiers)] = "easy";
	if (bounty_available("Hard"))
		tiers[count(tiers)] = "hard";
	if (bounty_available("Special"))
		tiers[count(tiers)] = "specialty";

	if (count(tiers) == 0)
		return;

	string available = "";
	foreach i, tier in tiers
	{
		if (available != "")
			available += ", ";
		available += tier;
	}

	string details = "Available tiers: " + available + ".";
	if (!have_skill($skill[Transcendent Olfaction]))
		details += " Filthy lucre: " + filthy_lucre_owned() + "/200.";

	browser_notify(
		"daily-bounties",
		count(tiers) + " bounty " + (count(tiers) == 1 ? "assignment" : "assignments") + " available",
		"bounty.php",
		details,
		"message"
	);
}

void main()
{
	/* Stored notices survive page refreshes, so rebuild ours on every run. */
	browser_notify_remove_prefix("daily-");

	remind_about_free_rests();
	remind_about_garden();
	remind_about_daily_dungeon();
	remind_about_neverending_party();
	remind_about_chateau_desk();
	remind_about_free_fights();
	remind_about_progression();
	remind_about_clan_freebies();
	remind_about_workshed();
	remind_about_voting();
	remind_about_campaway();
	remind_about_item_generators();
	remind_about_bounties();
}
