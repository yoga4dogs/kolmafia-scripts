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

	if (target == $bounty[none] || target.location == $location[none])
		return page;

	/*
		The location displayed by KoL is not always KoLmafia's location name
		("Mt. McLargeHuge" vs. "Lair of the Ninja Snowmen", for example).
		The bounty image is stable and uniquely identifies the description.
	*/
	int image_offset = index_of(page, target.image);
	if (image_offset < 0)
		return page;

	string after_image = substring(page, image_offset);
	int image_cell_end = index_of(after_image, "</td>");
	if (image_cell_end < 0)
		return page;

	int description_cell_end = index_of(
		substring(after_image, image_cell_end + 5),
		"</td>"
	);
	if (description_cell_end < 0)
		return page;

	int insertion = image_offset + image_cell_end + 5 + description_cell_end;
	return substring(page, 0, insertion) + "&nbsp;" + bounty_indicator(target) +
		substring(page, insertion);
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
