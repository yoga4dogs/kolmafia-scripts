string bn_escape(string s)
{
	s = replace_string(s, "&", "&amp;");
	s = replace_string(s, "\"", "&quot;");
	s = replace_string(s, "'", "&#39;");
	s = replace_string(s, "<", "&lt;");
	s = replace_string(s, ">", "&gt;");
	return s;
}

void main()
{
	// Fetch the normal KoL main page.
	buffer original = visit_url();
	string page = original.to_string();

	// Re-evaluate dynamic notices whenever the main map is loaded.
	cli_execute("daily_reminders.ash");

	string raw = get_property("_browserNotifications");

	string[int] notices = split_string(raw, "\n");

	string notification_html = "";
	if (raw != "")
		notification_html = "<div id=\"mafia-custom-notifications\" style=\"width:95%; margin:6px auto;\">";

	foreach i, notice in notices
	{
		if (notice == "")
			continue;

		string[int] fields = split_string(notice, "\\|\\|\\|");

		if (count(fields) < 5)
			continue;

		string id      = fields[0];
		string type    = fields[1];
		string url     = fields[2];
		string message = fields[3];
		string tooltip = fields[4];

		string background = "#ffdddd";
		string border = "#cc0000";

		if (type == "message")
		{
			background = "#eeeeff";
			border = "#4444aa";
		}

		notification_html +=
			"<div style=\"" +
			"border:1px solid " + border + ";" +
			"background:" + background + ";" +
			"padding:6px 8px;" +
			"margin-bottom:4px;" +
			"text-align:center;" +
			"font-weight:bold;" +
			"\">";

		if (url != "")
		{
			notification_html +=
				"<a href=\"" + bn_escape(url) + "\" " +
				"title=\"" + bn_escape(tooltip) + "\" " +
				"style=\"color:inherit; text-decoration:none;\">" +
				bn_escape(message) +
				"</a>";
		}
		else
		{
			notification_html +=
				"<span title=\"" + bn_escape(tooltip) + "\">" +
				bn_escape(message) +
				"</span>";
		}

		notification_html += "</div>";
	}

	string goals_link =
		"<div style=\"border:1px solid #b77900; background:#fff0c2; padding:6px 8px; margin-bottom:4px; text-align:center; font-weight:bold;\">" +
		"<a href=\"long_term_goals.php\" style=\"color:inherit; text-decoration:none;\" title=\"Browse permanent unlocks, useful skills, major content, and historical rewards\">Long-Term Goals</a></div>";
	if (raw == "")
		notification_html = "<div id=\"mafia-custom-notifications\" style=\"width:95%; margin:6px auto;\">";
	notification_html += goals_link + "</div>" +
		/* Daily Deeds run in KoLmafia rather than in the relay browser. When the
		   player returns to the browser, rebuild the map so notices reflect any
		   preferences changed by a deed without requiring a manual refresh. */
		"<script>(function(){" +
		"var host=window.top;" +
		"host.__mafiaReminderRefresh=function(){window.location.reload();};" +
		"if(host.__mafiaReminderFocusHook){return;}" +
		"host.__mafiaReminderFocusHook=true;" +
		"var away=false;" +
		"function refresh(){if(!away){return;}away=false;host.__mafiaReminderRefresh();}" +
		"host.addEventListener('blur',function(){away=true;});" +
		"host.addEventListener('focus',refresh);" +
		"host.document.addEventListener('visibilitychange',function(){" +
		"if(host.document.hidden){away=true;}else{refresh();}" +
		"});" +
		"})();</script>";

	string custom_html = notification_html;
	if (custom_html == "")
	{
		write(page);
		return;
	}

	/*
		Insert immediately after the opening BODY tag.

		Don't assume it is literally "<body>" -- KoL may put
		attributes on it.
	*/
	matcher body_tag = create_matcher(
		"(?i)(<body[^>]*>)",
		page
	);

	if (body_tag.find())
	{
		page = body_tag.replace_first(
			body_tag.group(1) + custom_html
		);
	}
	else
	{
		/*
			Fallback: insert before </html>.
		Still produces valid enough output if KoL changes markup.
		*/
		if (index_of(page, "</html>") >= 0)
			page = replace_string(
				page,
				"</html>",
				custom_html + "</html>"
			);
		else
			page += custom_html;
	}

	write(page);
}
