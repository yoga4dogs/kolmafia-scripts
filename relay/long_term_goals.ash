import <long_term_goal_data.ash>;

string lt_escape(string value)
{
	value = replace_string(value, "&", "&amp;");
	value = replace_string(value, "<", "&lt;");
	value = replace_string(value, ">", "&gt;");
	value = replace_string(value, "\"", "&quot;");
	return value;
}

string entry_icon(LongTermEntry entry)
{
	string image = "debug.gif";
	if (entry.kind == "skill")
		image = entry.skill_value.image;
	else if (entry.kind == "item")
		image = entry.item_value.image;
	return "/images/itemimages/" + image;
}

string entry_description(LongTermEntry entry)
{
	string url = "";
	if (entry.kind == "item")
		url = "desc_item.php?whichitem=" + entry.item_value.descid;
	else if (entry.kind == "skill")
		url = "desc_skill.php?whichskill=" + entry.skill_value.to_int().to_string();

	if (url == "")
		return "";
	return "<iframe class=\"game-description\" loading=\"lazy\" src=\"" + url + "\" title=\"In-game description for " + lt_escape(entry.name) + "\"></iframe>";
}

string render_entry(LongTermEntry entry)
{
	string state_class = entry.complete ? " completed" : "";
	string badge = entry.complete ? "complete" : entry.status;
	return "<details class=\"entry" + state_class + "\"><summary>" +
		"<img src=\"" + entry_icon(entry) + "\" alt=\"\">" +
		"<span class=\"entry-name\">" + lt_escape(entry.name) + "</span>" +
		"<span class=\"status\">" + lt_escape(badge) + "</span></summary>" +
		"<div class=\"criteria\"><strong>Unlock criteria:</strong> " + lt_escape(entry.criteria) + "</div>" +
		entry_description(entry) + "</details>";
}

void main()
{
	string body = "";
	string last_category = "";
	string last_group = "";
	foreach i, entry in long_term_entries
	{
		if (entry.category != last_category)
		{
			if (last_group != "") body += "</div>";
			if (last_category != "") body += "</section>";
			body += "<section><h2>" + lt_escape(entry.category) + "</h2>";
			last_category = entry.category;
			last_group = "";
		}
		if (entry.group != last_group)
		{
			if (last_group != "") body += "</div>";
			body += "<div class=\"group\"><h3>" + lt_escape(entry.group) + "</h3>";
			last_group = entry.group;
		}
		body += render_entry(entry);
	}
	if (last_group != "") body += "</div>";
	if (last_category != "") body += "</section>";

	write("<!doctype html><html><head><meta charset=\"utf-8\"><title>Long-Term Goals</title><style>" +
		"body{font:14px Arial,sans-serif;background:#f4f1e8;color:#222;margin:0;padding:18px}main{max-width:1050px;margin:auto}" +
		"header{background:#3b2b1d;color:#fff;padding:18px 22px;border-radius:8px}h1{margin:0 0 5px}header p{margin:0;color:#eadfcf}" +
		".toolbar{margin:14px 0;padding:10px 14px;background:#fff;border:1px solid #c9bea9;border-radius:6px}" +
		"section{background:#fff;border:1px solid #c9bea9;border-radius:7px;margin:14px 0;padding:0 14px 14px}h2{margin:0 -14px 12px;padding:9px 14px;background:#ded3bf;border-radius:6px 6px 0 0}" +
		".group{margin:12px 0}.group h3{margin:0;padding:7px 9px;background:#f1eadf;border-left:4px solid #80633e}" +
		"details.entry{border-bottom:1px solid #e4ded3}.entry summary{display:flex;align-items:center;gap:9px;padding:7px;cursor:pointer;list-style:none}.entry summary::-webkit-details-marker{display:none}" +
		".entry summary:after{content:'▸';order:4;color:#777}.entry[open] summary:after{content:'▾'}.entry img{width:30px;height:30px;object-fit:contain}.entry-name{font-weight:bold;flex:1}" +
		".status{font-size:11px;text-transform:uppercase;background:#f1c46b;padding:3px 6px;border-radius:9px}.completed .status{background:#9bd29b}.criteria{padding:4px 46px 11px;color:#514b43}" +
		".game-description{display:block;width:calc(100% - 92px);height:250px;margin:0 46px 12px;border:1px solid #d8d1c5;background:#fff}" +
		"body:not(.show-completed) .completed{display:none}a{color:#5c3b13}</style></head><body><main>" +
		"<header><h1>Long-Term Goals</h1><p>Permanent unlocks, useful skills, major content, and durable account rewards.</p></header>" +
		"<div class=\"toolbar\"><label><input id=\"show-completed\" type=\"checkbox\"> Show completed</label> &nbsp; <a href=\"main.php\">Back to main</a></div>" + body +
		"</main><script>document.getElementById('show-completed').addEventListener('change',function(){document.body.classList.toggle('show-completed',this.checked);});</script></body></html>");
}
