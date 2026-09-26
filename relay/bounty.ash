string bounty_html_escape(string value)
{
	value = replace_string(value, "&", "&amp;");
	value = replace_string(value, "\"", "&quot;");
	value = replace_string(value, "<", "&lt;");
	value = replace_string(value, ">", "&gt;");
	return value;
}

string bounty_indicator(bounty target)
{
	boolean unlocked = can_adventure(target.location);
	string square = unlocked ? "🟩" : "🟥";
	string status = unlocked ? "unlocked" : "locked";

	return "<span title=\"" + bounty_html_escape(target.location) + " is " + status +
		"\" style=\"cursor:help; margin-right:3px;\">" + square + "</span>";
}

string current_bounty(string tier)
{
	string item_name = get_property("current" + tier + "BountyItem");

	if (item_name == "")
		item_name = get_property("_untaken" + tier + "BountyItem");

	return item_name;
}

string decorate_bounty(string page, string tier)
{
	bounty target = to_bounty(current_bounty(tier));

	if (target == $bounty[none] || target.plural == "")
		return page;

	return replace_string(
		page,
		target.plural,
		bounty_indicator(target) + target.plural
	);
}

void main()
{
	/* Fetch first so KoLmafia refreshes today's bounty properties. */
	string page = visit_url().to_string();

	page = decorate_bounty(page, "Easy");
	page = decorate_bounty(page, "Hard");
	page = decorate_bounty(page, "Special");

	write(page);
}
