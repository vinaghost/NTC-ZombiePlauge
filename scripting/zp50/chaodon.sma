#include <amxmodx>
#include <amxmisc>
#include <zp50_colorchat>
#include <json>
#include <curl>
#include <bimat>

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

new curl_slist:g_cURLHeaders, g_szHostname[129], g_szNetAddress[22];
new starting;
new g_bot;

public plugin_init() {
	register_plugin("Chao don", "1.0", "VINAGHOST");
}
public plugin_cfg() {

	set_task(10.0, "plugin_cfg_delayed");
}
public plugin_cfg_delayed() {
	get_cvar_string("hostname", g_szHostname, charsmax(g_szHostname));
	get_cvar_string("net_address", g_szNetAddress, charsmax(g_szNetAddress));
	starting = 1;
}
public client_putinserver(id) {
	if( is_user_bot(id) || is_user_hltv(id) ) {
		flag_set(g_bot, id)
	}

	if( starting ) {
		postChat(id, 0);
	}
}

public client_disconnected(id) {
	if( starting && !flag_get_boolean(g_bot, id) ) {
		postChat(id, 1);
	}
}
public plugin_end()
{
	if (g_cURLHeaders)
	{
		curl_slist_free_all(g_cURLHeaders);
		g_cURLHeaders = curl_slist:0;
	}
}
public _fixName(name[])
{
	new i = 0;
	while (name[i] != 0)
	{
		if (!(0 <= name[i] <= 255))
		{
			name[i] = '.';
		}
		i++;
	}
}
public postChat(id, leave) {
	static szName[32], szBuffer[129], JSON:jEmbeds[1], JSON:jEmbed, JSON:jWebhook;
	get_user_name(id, szName, charsmax(szName));
	_fixName(szName);


	jEmbed = json_create();
	formatex(szBuffer, charsmax(szBuffer), "IP: %s", g_szNetAddress);
	json_set_string(jEmbed, "description", szBuffer);
	jEmbeds[0] = jEmbed;

	jWebhook = json_create();
	if( leave ) {
		formatex(szBuffer, charsmax(szBuffer), "%s đã rời khỏi server %s", szName, g_szHostname);
	}
	else {
		formatex(szBuffer, charsmax(szBuffer), "%s đã kết nối tới server %s", szName, g_szHostname);
	}
	json_set_string(jWebhook, "content", szBuffer);
	json_set_array(jWebhook, "embeds", jEmbeds, sizeof(jEmbeds), _, JSON_Object);


	postJSON(g_chaodon, jWebhook);
	json_destroy(jWebhook);

}
public postJSON(const link[], JSON:jObject)
{
	new CURL:g_cURLHandle;
	if (!(g_cURLHandle = curl_easy_init()))
	{
		log_amx("[Fatal Error] Cannot Init cURL Handle.");
		pause("d");
		return;
	}
	if (!g_cURLHeaders)
	{

		g_cURLHeaders = curl_slist_append(g_cURLHeaders, "Content-Type: application/json");
		curl_slist_append(g_cURLHeaders, "User-Agent: 822_AMXX_PLUGIN/1.0");
		curl_slist_append(g_cURLHeaders, "Connection: Keep-Alive");
	}


	curl_easy_setopt(g_cURLHandle, CURLOPT_SSL_VERIFYPEER, 0);
	curl_easy_setopt(g_cURLHandle, CURLOPT_SSL_VERIFYHOST, 0);
	curl_easy_setopt(g_cURLHandle, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);
	curl_easy_setopt(g_cURLHandle, CURLOPT_FAILONERROR, 0);
	curl_easy_setopt(g_cURLHandle, CURLOPT_FOLLOWLOCATION, 0);
	curl_easy_setopt(g_cURLHandle, CURLOPT_FORBID_REUSE, 0);
	curl_easy_setopt(g_cURLHandle, CURLOPT_FRESH_CONNECT, 0);
	curl_easy_setopt(g_cURLHandle, CURLOPT_CONNECTTIMEOUT, 10);
	curl_easy_setopt(g_cURLHandle, CURLOPT_TIMEOUT, 10);
	curl_easy_setopt(g_cURLHandle, CURLOPT_HTTPHEADER, g_cURLHeaders);
	curl_easy_setopt(g_cURLHandle, CURLOPT_POST, 1);


	static szPostdata[513];
	json_encode(jObject, szPostdata, charsmax(szPostdata));



	curl_easy_setopt(g_cURLHandle, CURLOPT_URL, link);
	curl_easy_setopt(g_cURLHandle, CURLOPT_COPYPOSTFIELDS, szPostdata);

	curl_easy_perform(g_cURLHandle, "postJSON_done");
}

public postJSON_done(CURL:curl, CURLcode:code)
{
	if (code == CURLE_OK)
	{
		static statusCode;
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, statusCode);
		if (statusCode >= 400)
		{
			log_amx("[Error] HTTP Error: %d", statusCode);
		}
	}
	else
	{
		log_amx("[Error] cURL Error: %d", code);

	}
	curl_easy_cleanup(curl);
	curl = CURL:0;
}
