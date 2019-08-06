#include <amxmodx>
#include <zp50_core>
#include <zp50_weapon>
#include <zp50_ammopacks>
#include <cstrike>

public plugin_init()
{
	register_plugin("[ZP] Weapon Checker", ZP_VERSION_STRING, "ZP Dev Team")
}


public zp_fw_wpn_select_pre( id, itemid, ignorecost)
{
	// Ignore item costs?
	if (ignorecost)
		return ZP_WEAPON_AVAILABLE;
	new current,  required = zp_weapons_get_cost(itemid);

	new type_cost = zp_weapons_get_cost_type(itemid)

	if( type_cost == ZP_WEAPON_AP )
		current = zp_ammopacks_get(id)
	else
		current = cs_get_user_money(id)

	if (current < required)
		return ZP_WEAPON_NOT_AVAILABLE;

	return ZP_WEAPON_AVAILABLE;
}

public zp_fw_wpn_select_post(id, itemid, ignorecost)
{
	// Ignore item costs?
	if (ignorecost)
		return;

	new current;
	new required = zp_weapons_get_cost(itemid);
	new type_cost = zp_weapons_get_cost_type(itemid)
	if( type_cost == ZP_WEAPON_AP) {
		current = zp_ammopacks_get(id)
		zp_ammopacks_set(id, current - required)
	}
	else {
		current = cs_get_user_money(id)
		cs_set_user_money(id, current - required)
	}

}
