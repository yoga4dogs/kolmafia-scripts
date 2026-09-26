void browser_notify(
	string id,
	string message,
	string url,
	string tooltip,
	string type
)
{
	// Avoid delimiters used by our line-based storage format.
	id = replace_string(id, "|||", "");
	type = replace_string(type, "|||", "");
	message = replace_string(message, "|||", "");
	url = replace_string(url, "|||", "");
	tooltip = replace_string(tooltip, "|||", "");

	id = replace_string(id, "\r", " ");
	id = replace_string(id, "\n", " ");
	type = replace_string(type, "\r", " ");
	type = replace_string(type, "\n", " ");
	message = replace_string(message, "\r", " ");
	message = replace_string(message, "\n", " ");
	url = replace_string(url, "\r", "");
	url = replace_string(url, "\n", "");
	tooltip = replace_string(tooltip, "\r", " ");
	tooltip = replace_string(tooltip, "\n", " ");

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
