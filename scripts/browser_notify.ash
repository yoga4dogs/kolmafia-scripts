void browser_notify(
	string id,
	string message,
	string url,
	string tooltip,
	string type
)
{
	// Avoid delimiters used by our storage format.
	message = replace_string(message, "|||", "");
	url = replace_string(url, "|||", "");
	tooltip = replace_string(tooltip, "|||", "");

	string entry =
		id + "|||" +
		type + "|||" +
		url + "|||" +
		message + "|||" +
		tooltip;

	string existing = get_property("_browserNotifications");

	if (existing != "")
		existing += "\n";

	set_property("_browserNotifications", existing + entry);
}