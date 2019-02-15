#include <amxmodx>
#include <zp50_core>
#include <zp50_weapon>
#include <zp50_weapon_money>
#include <zp50_ammopacks>

native cs_get_user_money_ul(id)
native cs_set_user_money_ul(id, money)

public plugin_init()
{
	register_plugin("[ZP] Weapon Checker", ZP_VERSION_STRING, "ZP Dev Team")
}


public zp_fw_wpn_select_pre( id, itemid, ignorecost)
{
	// Ignore item costs?
	if (ignorecost)
		return ZP_WEAPON_AVAILABLE;
		
	// Get current and required ammo packs
	new current_ammopacks = zp_ammopacks_get(id)
	new required_ammopacks = zp_weapons_get_cost(itemid)
	
	// Not enough ammo packs
	if (current_ammopacks < required_ammopacks)
		return ZP_WEAPON_NOT_AVAILABLE;
	
	return ZP_WEAPON_AVAILABLE;
}

public zp_fw_wpn_select_post(id, itemid, ignorecost)
{
	// Ignore item costs?
	if (ignorecost)
		return;
	
	// Get current and required ammo packs
	new current_ammopacks = zp_ammopacks_get(id)
	new required_ammopacks = zp_weapons_get_cost(itemid)
	
	// Deduct item's ammo packs after purchase event
	zp_ammopacks_set(id, current_ammopacks - required_ammopacks)
}
public zp_fw_wpn_money_select_pre( id, itemid, ignorecost)
{
	// Ignore item costs?
	if (ignorecost)
		return ZP_WEAPON_AVAILABLE;
		
	// Get current and required ammo packs
	new current_money = cs_get_user_money_ul(id)
	new required_money = zp_weapons_m_get_cost(itemid)
	
	// Not enough ammo packs
	if (current_money < required_money)
		return ZP_WEAPON_NOT_AVAILABLE;
	
	return ZP_WEAPON_AVAILABLE;
}

public zp_fw_wpn_money_post(id, itemid, ignorecost)
{
	// Ignore item costs?
	if (ignorecost)
		return;
	
	// Get current and required ammo packs
	new current_money = cs_get_user_money_ul(id)
	new required_money = zp_weapons_m_get_cost(itemid)
	
	// Deduct item's ammo packs after purchase event
	cs_set_user_money_ul(id, current_money - required_money)
}
