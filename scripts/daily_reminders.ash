import <browser_notify.ash>;

/*
	Login reminders for long-term daily progress.

	Settings (set them with `set name = value` in the gCLI):

	  dailyRemindersNeverendingParty = true
	  dailyRemindersBounties = true

	Each setting defaults to true. The script only queues reminders; it never
	accepts a quest or spends a turn.
*/

boolean reminder_enabled(string property)
{
	string value = get_property(property);

	if (value == "")
		return true;

	return value.to_boolean();
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

boolean bounty_available(string tier)
{
	return get_property("_untaken" + tier + "BountyItem") != "" ||
		get_property("_unknown" + tier + "BountyItem") != "";
}

int filthy_lucre_owned()
{
	int total = available_amount($item[filthy lucre]);

	/* Include Hagnk's while storage is inaccessible in Hardcore or Ronin. */
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

	remind_about_neverending_party();
	remind_about_bounties();
}
