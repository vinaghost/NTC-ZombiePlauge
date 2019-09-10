/*================================================================================

----------------------
-*- [ZP] Main Menu -*-
----------------------

This plugin is part of Zombie Plague Mod and is distributed under the
terms of the GNU General Public License. Check ZP_ReadMe.txt for details.

================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#define LIBRARY_BUYMENUS "zp50_buy_menus"
#include <zp50_buy_menus>
#define LIBRARY_ZOMBIECLASSES "zp50_class_zombie"
#include <zp50_class_zombie>
#define LIBRARY_HUMANCLASSES "zp50_class_human"
#include <zp50_class_human>
#define LIBRARY_ITEMS "zp50_items"
#include <zp50_items>
#define LIBRARY_ADMIN_MENU "zp50_admin_menu"
#include <zp50_admin_menu>
#define LIBRARY_RANDOMSPAWN "zp50_random_spawn"
#include <zp50_random_spawn>
#include <zp50_colorchat>
#include <zombieplague>
#include <cstrike>
#include <vinacoin>
#include <zp50_ammopacks>
#include <json>
#include <curl>
#include <bimat>

// CS Player PData Offsets (win32)
const OFFSET_CSMENUCODE = 205


#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))


#define TI_LE_AP 7
#define TI_LE_MONEY 10000

new vinacoin_trans[] = {
	1, 2, 5, 10, 20, 50, 100
}

new curl_slist:g_cURLHeaders


public plugin_init() {
	register_plugin("[ZP] Main Menu", ZP_VERSION_STRING, "ZP Dev Team")

	register_clcmd("chooseteam", "clcmd_chooseteam")

	register_clcmd("say /menu", "clcmd_zpmenu")
	register_clcmd("say menu", "clcmd_zpmenu")

}

public plugin_natives() {
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[]) {
	if (equal(module, LIBRARY_BUYMENUS) || equal(module, LIBRARY_ZOMBIECLASSES) || equal(module, LIBRARY_HUMANCLASSES) || equal(module, LIBRARY_ITEMS) || equal(module, LIBRARY_ADMIN_MENU) || equal(module, LIBRARY_RANDOMSPAWN))
	return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap) {
	if (!trap)
	return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}


public clcmd_chooseteam(id) {

client_cmd(id, "say /menu"); //chong spam khung chat voi lenh menu ._.
return PLUGIN_HANDLED_MAIN;

}

public clcmd_zpmenu(id) {
	show_menu_main(id)
}

// Main Menu
public show_menu_main(id) {
// Title
new menu = menu_create( "Main menu:", "menu_handler" );

menu_additem(menu, "Chọn Zombie"); //0

menu_additem(menu, "Chọn Skin Human");

menu_additem(menu, "Shop [ tác dụng 1 map ]"); //1

menu_additem(menu, "Shop [ tác dụng 1 round ]"); //2

menu_additem(menu, "Đổi VinaCoin^n");

menu_additem(menu, "Gỡ kẹt");
menu_additem(menu, "Ra Spec");
menu_additem(menu, "Exciter Zone");


set_pdata_int(id, OFFSET_CSMENUCODE, 0)
menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
menu_display( id, menu, 0 );
}


public menu_handler( id, menu, item ) {
// Player disconnected?
if (!is_user_connected(id))
return PLUGIN_HANDLED;

switch (item)
{
	case 0:
	{
		zp_class_zombie_show_menu(id)
	}
	case 1:
	{
		zp_class_human_show_menu(id)
	}
	case 2:
	{
		show_Upgrade_menu(id)
	}
	case 3:
	{
		show_Item_menu(id)
	}
	case 4:
	{
		showTrans_vinacoin_menu(id)
	}
	case 5:
	{
		fix_ket(id);
	}
	case 6:
	{
		spec(id);
	}
	case 7:
	{
		//show_admin_menu(id);
	}
}

menu_destroy(menu);

return PLUGIN_HANDLED;
}

public show_Upgrade_menu(id) {
	if( !is_user_alive(id) ) return;

	new menuid = menu_create("[NTC] Nâng cấp ( 1 map )", "Upgrade_menu");

	menu_additem(menuid, "Súng chính");
	menu_additem(menuid, "Súng phụ");
	menu_additem(menuid, "Vũ khí cận chiến");
	menu_additem(menuid, "Vật phẩm"); //Extra items

	menu_display(id, menuid, 0)
}
public Upgrade_menu(id, menuid, item) {
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	switch (item) {
		case 0:
		client_cmd(id, "say /pri");
		case 1:
		client_cmd(id, "say /sec");
		case 2:
		client_cmd(id, "say /knife")
		case 3:
		zp_ap_items_show_menu(id)
	}

	menu_destroy(menuid);
	return PLUGIN_HANDLED;
}
public show_Item_menu(id) {
	if( !is_user_alive(id) ) return;

	new menuid = menu_create("[NTC] Nâng cấp (1 round)", "Item_menu");

	menu_additem(menuid, "Súng chính");
	menu_additem(menuid, "Súng phụ");
	menu_additem(menuid, "Vũ khí cận chiến");
	menu_additem(menuid, "Vật phẩm"); //Extra items

	menu_display(id, menuid, 0)
}
public Item_menu(id, menuid, item) {
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	switch (item) {
		case 0:
		client_cmd(id, "say /pri_m");
		case 1:
		client_cmd(id, "say /sec_m");
		case 2:
		client_cmd(id, "say /knife_m")
		case 3:
		zp_money_items_show_menu(id)
	}

	menu_destroy(menuid);
	return PLUGIN_HANDLED;
}

public spec(id) {
	if( !is_user_connected(id)) return;
	cs_set_user_team(id, CS_TEAM_SPECTATOR);
	user_silentkill(id);
	zp_colored_print(id, "Đã chuyển sang Spec");
}

public fix_ket(id) {
	if( !is_user_alive(id) ) {
		zp_colored_print(id, "Chết thì không thể kẹt");
		return;
	}

	if( zp_core_is_zombie(id) ) {
		zp_respawn_user(id, ZP_TEAM_ZOMBIE);
	}
	else {
		zp_respawn_user(id, ZP_TEAM_HUMAN);
	}

}
public showTrans_vinacoin_menu(id) {
	if( !is_user_connected(id) ) return;

	new menuid = menu_create("[NTC] Đổi VinaCoin", "Trans_vinacoin_menu");

	menu_additem(menuid, "Sang AP");
	menu_additem(menuid, "Sang $");

	menu_display(id, menuid, 0)
}

public Trans_vinacoin_menu(id, menuid, item) {

	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	switch (item) {
		case 0:
		showAPTrans_menu(id)
		case 1:
		showMoneyTrans_menu(id)
	}

	menu_destroy(menuid);
	return PLUGIN_HANDLED;
}


public showAPTrans_menu(id) {
	if( !is_user_connected(id) ) return;

	new text[33];

	new coin = zp_get_user_coin(id);
	formatex(text, charsmax(text), "[NTC] Đổi VinaCoin sang AP. Đang có %d VinaCoin", coin)
	new menuid = menu_create("[NTC] Đổi VinaCoin sang AP", "APTrans_menu");

	new coin_need;
	for( new i = 0; i < sizeof(vinacoin_trans); i++) {
		coin_need = vinacoin_trans[i];
		formatex(text, charsmax(text), "%d VinaCoin -> %d AP", coin_need > coin ? "\d" : "", coin_need,  coin_need * TI_LE_AP);
		menu_additem(menuid, text);
	}

	menu_display(id, menuid, 0)
}

public APTrans_menu(id, menuid, item) {

	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	new coin = zp_get_user_coin(id);
	new coin_need = vinacoin_trans[item];
	if( coin_need > coin ) {
		menu_display(id, menuid, 0);
		return PLUGIN_HANDLED;
	}

	zp_add_user_coin(id, -coin_need);
	zp_ammopacks_set(id, zp_ammopacks_get(id) + coin_need * TI_LE_AP);

	menu_destroy(menuid);
	return PLUGIN_HANDLED;

}

public showMoneyTrans_menu(id) {
	if( !is_user_connected(id) ) return;

	new text[33];

	new coin = zp_get_user_coin(id);
	formatex(text, charsmax(text), "[NTC] Đổi VinaCoin sang $. Đang có %d VinaCoin", coin)
	new menuid = menu_create("[NTC] Đổi VinaCoin sang $", "MoneyTrans_menu");

	new coin_need;
	for( new i = 0; i < sizeof(vinacoin_trans); i++) {
		coin_need = vinacoin_trans[i];
		formatex(text, charsmax(text), "%d VinaCoin -> $%d", coin_need > coin ? "\d" : "", coin_need,  coin_need * TI_LE_MONEY);
		menu_additem(menuid, text);
	}

	menu_display(id, menuid, 0)
}

public MoneyTrans_menu(id, menuid, item) {

	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}

	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	new coin = zp_get_user_coin(id);
	new coin_need = vinacoin_trans[item];
	if( coin_need > coin ) {
		menu_display(id, menuid, 0);
		return PLUGIN_HANDLED;
	}

	zp_add_user_coin(id, -coin_need);
	cs_set_user_money(id, cs_get_user_money(id) + coin_need * TI_LE_MONEY);

	menu_destroy(menuid);
	return PLUGIN_HANDLED;

}

public send(id, vinacoin, amount)
{
	static szName[32], szAuthId[35], szBuffer[129], JSON:jWebhook;
	get_user_name(id, szName, charsmax(szName));
	get_user_authid(id, szAuthId, charsmax(szAuthId));
	_fixName(szName);

	jWebhook = json_create();
	json_set_string(jWebhook, "username", "[NTC] Anh ghi chép");
	json_set_string(jWebhook, "avatar_url", "http://vinaworld.dynu.net:27013/note-2389227_640.png");

	formatex(szBuffer, charsmax(szBuffer), "^"%s^" <%s> đã chuyển %d VinaCoin sang %d %s", szName, szAuthId, vinacoin, amount, amount > 1000 ? "$" : "AP" );
	zp_colored_print(0, "%s đã đổi %d VinaCoin sang %d %s", szName, vinacoin, amount, amount > 1000 ? "$" : "AP" );
	json_set_string(jWebhook, "content", szBuffer);

	postJSON(g_doiCoin, jWebhook);
	json_destroy(jWebhook);

	return PLUGIN_HANDLED;
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
public postJSON(const link[], JSON:jObject)
{
	new CURL:g_cURLHandle

	if (!(g_cURLHandle = curl_easy_init()))
	{
		log_amx("[Fatal Error] Cannot Init cURL Handle.");
		pause("d");
		return;
	}
	if (!g_cURLHeaders)
	{
		/* Init g_cURLHeaders with "Content-Type: application/json" */
		g_cURLHeaders = curl_slist_append(g_cURLHeaders, "Content-Type: application/json");
		curl_slist_append(g_cURLHeaders, "User-Agent: 822_AMXX_PLUGIN/1.0"); // User-Agent
		curl_slist_append(g_cURLHeaders, "Connection: Keep-Alive"); // Keep-Alive
	}

	/* Static Options*/
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
	//log_amx("[DEBUG] POST: %s", szPostdata);

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
