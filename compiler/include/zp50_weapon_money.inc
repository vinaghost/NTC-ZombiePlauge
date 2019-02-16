#if defined _zp50_weapon_money_included
  #endinput
#endif
#define _zp50_weapon_money_included

#include <zp50_core>
#include <zp50_weapon_const>

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib zp50_weapon_money
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib zp50_weapon_money
	#endif
#else
	#pragma library zp50_weapon_money
#endif


/**
 * Registers a custom weapon which will be added.
 *
 * Note: The returned weapon ID can be later used to catch weapon
 * selection events for the zp_wpn_select_() forwards.
 *
 * @param name			Caption to display on the menu.
 * @param cost			Cost to display on the menu.
 * @param type			Type of weapon
 * @return				An internal weapon ID, or ZP_INVALID_WEAPON on failure.
 */
native zp_weapons_m_register(const name[], cost, type)

/**
 * Returns a weapon's ID.
 *
 * @param name		Weapon name to look for.
 * @return			Internal weapon ID, or ZP_INVALID_WEAPON if not found.
 */
native zp_weapons_m_get_id(const real_name[])

/**
 * Returns a weapon's name.
 *
 * @param itemid	A valid weapon ID.
 * @param name		The buffer to store the string in.
 * @param len		Character size of the output buffer.
 * @return			True on success, false otherwise.
 */
native zp_weapons_m_get_name(itemid, name[], len)

/**
 * Returns a weapon's real name (used when registering the weapon).
 *
 * @param classid	A valid weapon ID.
 * @param name		The buffer to store the string in.
 * @param len		Character size of the output buffer.
 * @return			True on success, false otherwise.
 */
native zp_weapons_m_get_realname(itemid, real_name[], len)

/**
 * Returns a weapon's cost.
 *
 * @param itemid		A valid weapon ID.
 * @return			Weapon's cost.
 */
native zp_weapons_m_get_cost(itemid)

/**
 * Forces a player to buy an extra weapon
 *
 * @param id			Player index.
 * @param itemid		A valid extra weapon ID.
 * @param ignorecost	If set, item's cost won't be deduced from player.
 * @return				True on success, false otherwise.
 */
native zp_weapons_m_force_buy(id, itemid, ignorecost = false)




native zp_weapons_m_remove(id, type)









/**
 * Called when determining whether a weapon should be available to a player.
 *
 * Possible return values are:
 *	- ZP_WEAPON_AVAILABLE (show in menu, allow selection)
 *	- ZP_WEAPON_NOT_AVAILABLE (show in menu, don't allow selection)
 *	- ZP_WEAPON_DONT_SHOW (don't show in menu, don't allow selection)
 *
 * @param id			Player index.
 * @param itemid		Internal weapon ID.
 * @param ignorecost	Whether weapon cost should be ignored.
 */
forward zp_fw_wpn_money_select_pre(id, itemid, ignorecost)

/**
 * Called after a player selected a weapon
 *
 * @param id			Player index.
 * @param itemid		Internal weapon ID.
 * @param ignorecost	Whether weapon cost should be ignored.
 */
forward zp_fw_wpn_money_select_post(id, itemid, ignorecost)

/**
 * Called when player buy another weapon
 *
 * @param id			Player index.
 * @param itemid		Internal weapon ID.
 */
forward zp_fw_wpn_money_remove(id, itemid)


