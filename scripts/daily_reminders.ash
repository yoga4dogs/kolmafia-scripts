import <browser_notify.ash>;

/*
	Login reminders for useful daily actions.

	Settings (set them with `set name = value` in the gCLI):

	  dailyRemindersFreeRests = true
	  dailyRemindersGarden = true
	  dailyRemindersDailyDungeon = true
	  dailyRemindersNeverendingParty = true
	  dailyRemindersBounties = true
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
	if (contains_text(lounge, "klaw") && get_property("_deluxeKlawSummons").to_int() < 3)
		browser_notify(
			"daily-clan-klaw",
			(3 - get_property("_deluxeKlawSummons").to_int()) + " Deluxe Mr. Klaw pulls remain",
			"clan_viplounge.php?action=klaw",
			"Use the Deluxe Mr. Klaw crane game.",
			"message"
		);

	if (contains_text(lounge, "lookingglass") && !get_property("_lookingGlass").to_boolean())
		browser_notify(
			"daily-clan-looking-glass",
			"The VIP looking-glass item is available",
			"clan_viplounge.php?action=lookingglass",
			"Collect today's item from the looking glass.",
			"message"
		);

	if (contains_text(lounge, "crimbotree") && !get_property("_crimboTree").to_boolean() && get_property("crimboTreeDays").to_int() == 0)
		browser_notify(
			"daily-clan-crimbo-tree",
			"A Crimbo tree present is ready",
			"clan_viplounge.php?action=crimbotree",
			"Collect the present from the clan Crimbo tree.",
			"message"
		);

	if (contains_text(lounge, "lovetester") && !get_property("_clanFortuneBuffUsed").to_boolean())
		browser_notify(
			"daily-clan-fortune",
			"Your clan fortune buff is unused",
			"clan_viplounge.php?preaction=lovetester",
			"Consult the Fortune Teller for today's buff.",
			"message"
		);

	if (contains_text(lounge, "photobooth") && get_property("_photoBoothEquipment").to_int() < 3)
		browser_notify(
			"daily-clan-photobooth-equipment",
			(3 - get_property("_photoBoothEquipment").to_int()) + " Photo Booth equipment uses remain",
			"clan_viplounge.php?action=photobooth",
			"Collect equipment from the clan Photo Booth.",
			"message"
		);

	if (contains_text(lounge, "photobooth") && get_property("_photoBoothEffects").to_int() < 3)
		browser_notify(
			"daily-clan-photobooth-effects",
			(3 - get_property("_photoBoothEffects").to_int()) + " Photo Booth effects remain",
			"clan_viplounge.php?action=photobooth",
			"Choose an effect from the clan Photo Booth.",
			"message"
		);

	if (contains_text(lounge, "floundry") && !get_property("_floundryItemCreated").to_boolean())
		browser_notify(
			"daily-clan-floundry",
			"Your daily Floundry item is unclaimed",
			"clan_viplounge.php?action=floundry",
			"Create one item from the clan Floundry.",
			"message"
		);
}

void remind_about_workshed()
{
	if (!reminder_enabled("dailyRemindersWorkshed"))
		return;

	item workshed = get_workshed();

	if (workshed == $item[cold medicine cabinet] && get_property("_coldMedicineConsults").to_int() < 5)
		browser_notify(
			"daily-cold-medicine-cabinet",
			(5 - get_property("_coldMedicineConsults").to_int()) + " cold-medicine consultations remain",
			"campground.php?action=workshed",
			"Consult the cold medicine cabinet when its timer is ready.",
			"message"
		);
	else if (workshed == $item[Little Geneticist DNA-Splicing Lab] &&
		get_property("dnaSyringe") != "" && get_property("_dnaPotionsMade").to_int() < 3)
		browser_notify(
			"daily-dna-potions",
			(3 - get_property("_dnaPotionsMade").to_int()) + " DNA potions remain",
			"campground.php?action=workshed",
			"Use the DNA stored in your syringe to make a tonic.",
			"message"
		);
	else if (workshed == $item[portable Mayo Clinic] && !get_property("_mayoTankSoaked").to_boolean())
		browser_notify(
			"daily-mayo-tank-soak",
			"Your daily Mayo tank soak is available",
			"campground.php?action=workshed",
			"Soak in the Mayo tank for its daily effect.",
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

	if (get_property("_campAwayCloudBuffs").to_int() == 0)
		browser_notify(
			"daily-campaway-sky",
			"Your Campaway sky buff is available",
			"place.php?whichplace=campaway&action=campaway_sky",
			"Look at the sky at your Distant Woods Getaway.",
			"message"
		);

	if (get_property("_campAwaySmileBuffs").to_int() == 0)
		browser_notify(
			"daily-campaway-smile",
			"Your Campaway smile buff is available",
			"place.php?whichplace=campaway&action=campaway_smile",
			"Smile at your Distant Woods Getaway.",
			"message"
		);
}

void remind_about_item_generators()
{
	if (!reminder_enabled("dailyRemindersItemGenerators"))
		return;

	if (get_campground()[$item[Source terminal]] > 0 && get_property("_sourceTerminalExtrudes").to_int() < 3)
		browser_notify(
			"daily-source-terminal-extrudes",
			(3 - get_property("_sourceTerminalExtrudes").to_int()) + " Source Terminal extrudes remain",
			"campground.php?action=terminal",
			"Use the Source Terminal's daily extrusions.",
			"message"
		);

	if (get_campground()[$item[spinning wheel]] > 0 && !get_property("_spinningWheel").to_boolean())
		browser_notify(
			"daily-spinning-wheel",
			"Your spinning-wheel use is available",
			"campground.php?action=spinningwheel",
			"Use the spinning wheel for its daily item.",
			"message"
		);

	if (available_amount($item[Chroner trigger]) > 0 && !get_property("_chronerTriggerUsed").to_boolean())
		browser_notify(
			"daily-chroner-trigger",
			"Your Chroner trigger is unused",
			"inventory.php?which=3",
			"Use the Chroner trigger for today's chroner.",
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
	remind_about_progression();
	remind_about_clan_freebies();
	remind_about_workshed();
	remind_about_voting();
	remind_about_campaway();
	remind_about_item_generators();
	remind_about_bounties();
}
