import <browser_notify.ash>;

string strip_html(string s)
{
	matcher tags = create_matcher("<[^>]+>", s);
	return tags.replace_all("");
}

string clean_text(string s)
{
	s = replace_string(s, "&nbsp;", " ");
	s = replace_string(s, "&quot;", "\"");
	s = replace_string(s, "&#39;", "'");
	s = replace_string(s, "&amp;", "&");

	s = replace_string(s, "<br>", " ");
	s = replace_string(s, "<br/>", " ");
	s = replace_string(s, "<br />", " ");
	s = replace_string(s, "<p>", " ");
	s = replace_string(s, "</p>", " ");

	s = strip_html(s);

	matcher whitespace = create_matcher("\\s+", s);
	s = whitespace.replace_all(" ");

	matcher edges = create_matcher("^\\s+|\\s+$", s);
	s = edges.replace_all("");

	return s;
}

string get_item_description(string descid, string fallback)
{
	buffer page = visit_url(
		"desc_item.php?whichitem=" + descid,
		false
	);

	if (page.length() == 0)
		return fallback;

	string html = page.to_string();

	/*
		Try to isolate the descriptive text between the item header
		and the Type: line.
	*/
	matcher description = create_matcher(
		"(?s)</b>\\s*</td>\\s*</tr>.*?<blockquote>(.*?)</blockquote>",
		html
	);

	if (description.find())
	{
		string result = clean_text(description.group(1));

		if (result != "")
			return result;
	}

	/*
		Fallback for item description pages without a blockquote.
		Take the text before the Type: metadata.
	*/
	matcher fallback_match = create_matcher(
		"(?s)<body[^>]*>(.*?)Type:",
		html
	);

	if (fallback_match.find())
	{
		string result = clean_text(fallback_match.group(1));

		/*
			Remove common junk from the beginning.
		*/
		result = replace_string(result, "Item Description", "");

		matcher spaces = create_matcher("\\s+", result);
		result = spaces.replace_all(" ");

		matcher edges = create_matcher("^\\s+|\\s+$", result);
		result = edges.replace_all("");

		if (result != "")
			return result;
	}

	return fallback;
}

void main()
{
	/*
		If we've already generated today's notification,
		don't do the network requests again.
	*/
	if (get_property("_raffleReminderGenerated") == "true")
		return;

	buffer raffle_page = visit_url("raffle.php", false);

	if (raffle_page.length() == 0)
	{
		print("Raffle reminder: could not load raffle.php.", "red");
		return;
	}

	/*
		Example current markup:

		Today's Raffle Prize:
		...
		First Prize:
		...
		onclick='descitem(377804923);'
		...
		<b>Libram of BRICKOs</b>
	*/
	matcher first_prize = create_matcher(
		"(?s)Today's Raffle Prize:.*?" +
		"First Prize:.*?" +
		"descitem\\(([0-9]+)\\).*?" +
		"<b>([^<]+)</b>",
		raffle_page
	);

	if (!first_prize.find())
	{
		print("Raffle reminder: could not determine today's first prize.", "red");
		return;
	}

	string descid = first_prize.group(1);
	string prize_name = clean_text(first_prize.group(2));

	string description = get_item_description(
		descid,
		prize_name
	);

	browser_notify(
		"raffle",
		"Today's raffle: " + prize_name,
		"raffle.php",
		description,
		"alert"
	);

	set_property("_raffleReminderGenerated", "true");
}