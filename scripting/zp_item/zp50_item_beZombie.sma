#define ITEM_NAME "Tu bien thanh Zombie"
#define ITEM_COST 15000

#include <amxmodx>
#include <zp50_items>
#include <zp50_gamemodes>

new g_ItemID
new g_GameModeInfectionID
new g_GameModeMultiID
new cvar_deathmatch, cvar_respawn_after_last_human

public plugin_init()
{
	register_plugin("[ZP] Item: Be Zombie", ZP_VERSION_STRING, "ZP Dev Team")
		
	g_ItemID = zp_money_items_register(ITEM_NAME, ITEM_COST)
}

public plugin_cfg()
{
	g_GameModeInfectionID = zp_gamemodes_get_id("Infection Mode")
	g_GameModeMultiID = zp_gamemodes_get_id("Multiple Infection Mode")
	cvar_deathmatch = get_cvar_pointer("zp_deathmatch")
	cvar_respawn_after_last_human = get_cvar_pointer("zp_respawn_after_last_human")
}

public zp_fw_money_items_select_pre(id, itemid, ignorecost)
{
	if (itemid != g_ItemID)
		return ZP_ITEM_AVAILABLE;
	
	new current_mode = zp_gamemodes_get_current()
	if (current_mode != g_GameModeInfectionID && current_mode != g_GameModeMultiID)
		return ZP_ITEM_DONT_SHOW;
	
	if (zp_core_is_zombie(id))
		return ZP_ITEM_DONT_SHOW;
		
	if (zp_core_get_zombie_count() == 1)
		return ZP_ITEM_NOT_AVAILABLE;
	
	if (cvar_deathmatch && get_pcvar_num(cvar_deathmatch) && cvar_respawn_after_last_human
	&& !get_pcvar_num(cvar_respawn_after_last_human) && zp_core_get_human_count() == 1)
		return ZP_ITEM_NOT_AVAILABLE;
		
	return ZP_ITEM_AVAILABLE;
}

public zp_fw_money_items_select_post(id, itemid, ignorecost)
{
	if (itemid != g_ItemID)
		return;
	
	
	zp_core_force_infect(id)
}
