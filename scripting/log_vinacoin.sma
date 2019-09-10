#include <amxmodx>
#include <json>
#include <curl>

new const g_szURL[] = "https://discordapp.com/api/webhooks/620089875714277396/0FfIjSj3tBGclxwVqG37cPVQrwMV0s11mrUdNzdDTjxQ8FE4e0ci3kbvImGrt79fsAQl";
new const g_iTimeBetweenCalls = 30;

new g_iLastCall, bool:g_bIsWorking, CURL:g_cURLHandle, curl_slist:g_cURLHeaders, g_szHostname[129], g_szNetAddress[22];

public plugin_init()
{
    register_plugin("[cURL] Discord !admin Webhook", "1.0", "Th3-822");

    register_clcmd("say /admin", "cmd_admincall");
}

public plugin_cfg()
{
    // Add a delay to wait for the values for g_szHostname and g_szNetAddress
    g_iLastCall = get_systime();
    set_task(10.0, "plugin_cfg_delayed");
}

public plugin_cfg_delayed()
{
    get_cvar_string("hostname", g_szHostname, charsmax(g_szHostname));
    get_cvar_string("net_address", g_szNetAddress, charsmax(g_szNetAddress));
}

public plugin_end()
{
    if (g_cURLHandle)
    {
        curl_easy_cleanup(g_cURLHandle);
        g_cURLHandle = CURL:0;
    }
    if (g_cURLHeaders)
    {
        curl_slist_free_all(g_cURLHeaders);
        g_cURLHeaders = curl_slist:0;
    }
}

// Replace MB Chars with "."
_fixName(name[])
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

public cmd_admincall(id)
{
    static iCurTime;

    if (!g_bIsWorking && ((iCurTime = get_systime()) - g_iLastCall) > g_iTimeBetweenCalls)
    {
        g_iLastCall = iCurTime;

        static szName[32], szAuthId[35], szBuffer[129], JSON:jEmbeds[1], JSON:jEmbed, JSON:jWebhook;
        get_user_name(id, szName, charsmax(szName));
        get_user_authid(id, szAuthId, charsmax(szAuthId));
        _fixName(szName);

        // Create array of embed objects
        jEmbed = json_create();
        json_set_string(jEmbed, "title", g_szHostname);
        formatex(szBuffer, charsmax(szBuffer), "Click to enter on the server: steam://connect/%s", g_szNetAddress);
        json_set_string(jEmbed, "description", szBuffer);
        jEmbeds[0] = jEmbed;

        // Create webhook request object
        jWebhook = json_create();
        formatex(szBuffer, charsmax(szBuffer), "@here ^"%s^" <%s> is calling an Admin.", szName, szAuthId);
        json_set_string(jWebhook, "content", szBuffer);
        json_set_array(jWebhook, "embeds", jEmbeds, sizeof(jEmbeds), _, JSON_Object);

        // Send It
        postJSON(g_szURL, jWebhook);
        json_destroy(jWebhook);
        // json_destroy(jEmbed); // Destroyed in chain
    }
    else client_print(id, print_chat, " ** Admins Can Be Called Once Each %d Seconds **", g_iTimeBetweenCalls);

    return PLUGIN_HANDLED;
}

postJSON(const link[], JSON:jObject)
{
    if (!g_cURLHandle)
    {
        if (!(g_cURLHandle = curl_easy_init()))
        {
            log_amx("[Fatal Error] Cannot Init cURL Handle.");
            pause("d");
            return;
        }
        if (!g_cURLHeaders)
        {
            // Init g_cURLHeaders with "Content-Type: application/json"
            g_cURLHeaders = curl_slist_append(g_cURLHeaders, "Content-Type: application/json");
            curl_slist_append(g_cURLHeaders, "User-Agent: 822_AMXX_PLUGIN/1.0"); // User-Agent
            curl_slist_append(g_cURLHeaders, "Connection: Keep-Alive"); // Keep-Alive
        }

        // Static Options
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
    }

    static szPostdata[513];
    json_encode(jObject, szPostdata, charsmax(szPostdata));
    //log_amx("[DEBUG] POST: %s", szPostdata);

    curl_easy_setopt(g_cURLHandle, CURLOPT_URL, link);
    curl_easy_setopt(g_cURLHandle, CURLOPT_COPYPOSTFIELDS, szPostdata);

    g_bIsWorking = true;
    curl_easy_perform(g_cURLHandle, "postJSON_done");
}

public postJSON_done(CURL:curl, CURLcode:code)
{
    g_bIsWorking = false;
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
        curl_easy_cleanup(g_cURLHandle);
        g_cURLHandle = CURL:0;
    }
}
