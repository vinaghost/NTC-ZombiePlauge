#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <amx_settings_api>
#include <zp50_core>
#include <zp50_ammopacks>
#include <zp50_colorchat>
#include <zp50_weapon_const>

#include <zp50_weapon>

#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>

#define PLUGIN "[ZP] Weapon money"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

new const ZP_EXTRAWEAPON_FILE[] = "zp_extraweapons_money.ini"

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const GRENADES_WEAPONS_BIT_SUM = (1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)

enum _:TOTAL_FORWARDS
{
	FW_WPN_SELECT_PRE = 0,
	FW_WPN_SELECT_POST,
	FW_WPN_REMOVE
}

new g_Forwards[TOTAL_FORWARDS]
new g_ForwardResult

new Array:g_WeaponRealName
new Array:g_WeaponName
new Array:g_WeaponCost
new Array:g_WeaponType
//new Array:g_WeaponFree
new g_WeaponCount

new p_Weapon[3][33]
//new p_AutoWeapon

//new g_MaxPlayer;

native cs_get_user_money_ul(id)

//new g_DoubleFrost, h_DoubleFrost;
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_Forwards[FW_WPN_SELECT_PRE] = CreateMultiForward("zp_fw_wpn_money_select_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_Forwards[FW_WPN_SELECT_POST] = CreateMultiForward("zp_fw_wpn_money_select_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_Forwards[FW_WPN_REMOVE] = CreateMultiForward("zp_fw_wpn_money_remove", ET_IGNORE, FP_CELL, FP_CELL)
	
	//g_MaxPlayer = get_maxplayers()
	
	register_clcmd("say /pri_m", "show_buy_pri_menu")
	register_clcmd("say /sec_m", "show_buy_sec_menu")
	register_clcmd("say /knife_m", "show_buy_knife_menu")
}
public plugin_natives()
{
	register_library("zp50_weapon_money")
	
	register_native("zp_weapons_m_register", "native_weapons_register")
	register_native("zp_weapons_m_get_id", "native_weapons_get_id")
	register_native("zp_weapons_m_get_name", "native_weapons_get_name")
	register_native("zp_weapons_m_get_realname", "native_weapons_get_realname")
	register_native("zp_weapons_m_get_cost", "native_weapons_get_cost")
	register_native("zp_weapons_m_get_type", "native_weapons_get_type")
	register_native("zp_weapons_m_force_buy", "native_weapons_force_buy")
	register_native("zp_weapons_m_remove", "native_weapons_m_remove")
	
	//register_native("zp_weapons_main_menu", "native_weapons_main_menu")
	//register_native("zp_weapons_buy_menu", "native_weapons_buy_menu")
	
	set_module_filter("module_filter")
	set_native_filter("native_filter")
	
	g_WeaponRealName = ArrayCreate(32, 1)
	g_WeaponName = ArrayCreate(32, 1)
	g_WeaponCost = ArrayCreate(1, 1)
	g_WeaponType = ArrayCreate(1,1)
	//g_WeaponFree = ArrayCreate(1,1)
	
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public zp_fw_core_cure_pre(id, attacker) {
	
	p_Weapon[ZP_PRIMARY][id] = ZP_INVALID_WEAPON;
	p_Weapon[ZP_SECONDAYRY][id] = ZP_INVALID_WEAPON;
	p_Weapon[ZP_KNIFE][id] = ZP_INVALID_WEAPON;
	
}
public show_buy_pri_menu(id) {
	
	if( !is_user_alive(id) || zp_core_is_zombie(id) ) return;
	
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id))
		return;
		
	new title[64];
	formatex(title, charsmax(title), "Mua sung chinh^nDang co $%d ", cs_get_user_money_ul(id)) 
	new menuid = menu_create(title, "buy_pri_menu");
	
	static menu[128], name[32], cost, type;
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		if( index == p_Weapon[ZP_PRIMARY][id] ) continue;
		
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
					
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_PRIMARY) 
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		cost = ArrayGetCell(g_WeaponCost, index)
		
		
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R$%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y$%d", name, cost)
			
		itemdata[0] = index
		itemdata[1] = g_ForwardResult
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public buy_pri_menu(id, menuid, item){
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_CONTINUE;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_CONTINUE;
	}
	
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id)) {
		menu_destroy(menuid)
		return PLUGIN_CONTINUE
	}
	
	new itemdata[2], dummy, itemid;
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	
	ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, itemid, 0)
	
	if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
	{
		show_buy_pri_menu(id)
	}
	else 
	{
		zp_weapons_ap_remove(id, ZP_PRIMARY);
		//strip_weapons(id, ZP_PRIMARY)
		
		if( p_Weapon[ZP_PRIMARY][id] != ZP_INVALID_WEAPON)
			ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_PRIMARY][id])
		
		buy_weapon(id, itemid)
	}
	
	return PLUGIN_HANDLED;
}

public show_buy_sec_menu(id) {
	if( !is_user_alive(id) || zp_core_is_zombie(id) ) return;
	
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id))
		return;
		
	new title[64];
	formatex(title, charsmax(title), "Mua sung phu^nDang co $%d", cs_get_user_money_ul(id)) 
	new menuid = menu_create(title, "buy_sec_menu");
	
	static menu[128], name[32], cost, type;
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
					
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_SECONDAYRY) 
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		cost = ArrayGetCell(g_WeaponCost, index)
		
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R$%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y$%d", name, cost)
			
		itemdata[0] = index
		itemdata[1] = g_ForwardResult
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public buy_sec_menu(id, menuid, item){
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_CONTINUE;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_CONTINUE;
	}
	
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id)) {
		menu_destroy(menuid)
		return PLUGIN_CONTINUE
	}
	
	new itemdata[2], dummy, itemid;
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	
	ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, itemid, 0)
	
	if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
	{
		show_buy_sec_menu(id)
	}
	else 
	{
		zp_weapons_ap_remove(id, ZP_SECONDAYRY);
		//strip_weapons(id, ZP_PRIMARY)
		
		if( p_Weapon[ZP_SECONDAYRY][id] != ZP_INVALID_WEAPON)
			ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_SECONDAYRY][id])
		
		
		buy_weapon(id, itemid)
	}
	
	return PLUGIN_HANDLED;
}
public show_buy_knife_menu(id) {
	if( !is_user_alive(id) || zp_core_is_zombie(id) ) return;
	
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id))
		return;
		
	new title[64];
	formatex(title, charsmax(title), "Mua dao va cac vu khi khong phong ra dan^nDang co $%d", cs_get_user_money_ul(id)) 
	new menuid = menu_create(title, "buy_knife_menu");
	
	static menu[128], name[32], cost, type;
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
					
			
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_KNIFE) 
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		cost = ArrayGetCell(g_WeaponCost, index)
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R$%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y$%d", name, cost)
			
		itemdata[0] = index
		itemdata[1] = g_ForwardResult
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public buy_knife_menu(id, menuid, item){
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_CONTINUE;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_CONTINUE;
	}
	
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id)) {
		menu_destroy(menuid)
		return PLUGIN_CONTINUE
	}
	
	
	
	new itemdata[2], dummy, itemid;
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	
	ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, itemid, 0)
	
	if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
	{
		show_buy_pri_menu(id)
	}
	else 
	{
		//strip_weapons(id, ZP_PRIMARY)
		
		zp_weapons_ap_remove(id, ZP_KNIFE);
		//strip_weapons(id, ZP_PRIMARY)
		
		if( p_Weapon[ZP_PRIMARY][id] != ZP_INVALID_WEAPON)
			ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_KNIFE][id])
		
		
		buy_weapon(id, itemid)
	}
	
	return PLUGIN_HANDLED;
}
	
	
public native_weapons_register(plugin_id, num_params)
{
	new name[32], cost = get_param(2), type = get_param(3);
	get_string(1, name, charsmax(name))
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register weapon with an empty name")
		return ZP_INVALID_WEAPON;
	}
	
	new index, item_name[32]
	for (index = 0; index < g_WeaponCount; index++)
	{
		ArrayGetString(g_WeaponRealName, index, item_name, charsmax(item_name))
		if (equali(name, item_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP] Weapons already registered (%s)", name)
			return ZP_INVALID_WEAPON;
		}
	}
	
	// Load settings from extra items file
	new real_name[32]
	copy(real_name, charsmax(real_name), name)
	ArrayPushString(g_WeaponRealName, real_name)
	
	// Name
	if (!amx_load_setting_string(ZP_EXTRAWEAPON_FILE, real_name, "NAME", name, charsmax(name)))
		amx_save_setting_string(ZP_EXTRAWEAPON_FILE, real_name, "NAME", name)
	ArrayPushString(g_WeaponName, name)
	
	// Cost
	if (!amx_load_setting_int(ZP_EXTRAWEAPON_FILE, real_name, "COST", cost))
		amx_save_setting_int(ZP_EXTRAWEAPON_FILE, real_name, "COST", cost)
		
	ArrayPushCell(g_WeaponCost, cost)
	
	if (!amx_load_setting_int(ZP_EXTRAWEAPON_FILE, real_name, "TYPE", type))
		amx_save_setting_int(ZP_EXTRAWEAPON_FILE, real_name, "TYPE", type)
		
	ArrayPushCell(g_WeaponType, type)
	

	g_WeaponCount++
	return g_WeaponCount - 1;
}

public native_weapons_get_id(plugin_id, num_params)
{
	new real_name[32]
	get_string(1, real_name, charsmax(real_name))
	
	// Loop through every item
	new index, item_name[32]
	for (index = 0; index < g_WeaponCount; index++)
	{
		ArrayGetString(g_WeaponRealName, index, item_name, charsmax(item_name))
		if (equali(real_name, item_name))
			return index;
	}
	
	return ZP_INVALID_WEAPON;
}

public native_weapons_get_name(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= g_WeaponCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid weapon id (%d)", item_id)
		return false;
	}
	
	new name[32]
	ArrayGetString(g_WeaponName, item_id, name, charsmax(name))
	
	new len = get_param(3)
	set_string(2, name, len)
	return true;
}

public native_weapons_get_realname(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= g_WeaponCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid weapon id (%d)", item_id)
		return false;
	}
	
	new real_name[32]
	ArrayGetString(g_WeaponRealName, item_id, real_name, charsmax(real_name))
	
	new len = get_param(3)
	set_string(2, real_name, len)
	return true;
}

public native_weapons_get_cost(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= g_WeaponCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid weapon id (%d)", item_id)
		return -1;
	}
	
	return ArrayGetCell(g_WeaponCost, item_id);
}
public native_weapons_get_type(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= g_WeaponCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid weapon id (%d)", item_id)
		return -1;
	}
	
	return ArrayGetCell(g_WeaponType, item_id);
}
public native_weapons_force_buy(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	new item_id = get_param(2)
	
	if (item_id < 0 || item_id >= g_WeaponCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new ignorecost = get_param(3)
	
	buy_weapon(id, item_id, ignorecost)
	return true;
}

public native_weapons_m_remove(plugin_id, num_parmas)
{
	new id = get_param(1)
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	new type = get_param(2);
	
	if( type != ZP_KNIFE)
		strip_weapons(id, type)
		
		
	new itemid = p_Weapon[type][id];
	
	ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, itemid)
	return true;
}

buy_weapon(id, itemid, ignorecost = 0)
{
	ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, itemid, ignorecost)
	
	if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
		return;
	
	new type = ArrayGetCell(g_WeaponType, itemid)
	
	
	if( type != ZP_KNIFE)
		strip_weapons(id, type)
		
		
	ExecuteForward(g_Forwards[FW_WPN_SELECT_POST], g_ForwardResult, id, itemid, ignorecost)
	
}
// Strip primary/secondary/grenades
stock strip_weapons(id, stripwhat)
{
	// Get user weapons
	new weapons[32], num_weapons, index, weaponid
	get_user_weapons(id, weapons, num_weapons)
	
	// Loop through them and drop primaries or secondaries
	for (index = 0; index < num_weapons; index++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[index]
		
		if ((stripwhat == ZP_PRIMARY && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		|| (stripwhat == ZP_SECONDAYRY && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)) )
		{
			// Get weapon name
			new wname[32]
			get_weaponname(weaponid, wname, charsmax(wname))
			
			// Strip weapon and remove bpammo
			ham_strip_weapon(id, wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

stock ham_strip_weapon(index, const weapon[])
{
	// Get weapon id
	new weaponid = get_weaponid(weapon)
	if (!weaponid)
		return false;
	
	// Get weapon entity
	new weapon_ent = fm_find_ent_by_owner(-1, weapon, index)
	if (!weapon_ent)
		return false;
	
	// If it's the current weapon, retire first
	new current_weapon_ent = fm_cs_get_current_weapon_ent(index)
	new current_weapon = pev_valid(current_weapon_ent) ? cs_get_weapon_id(current_weapon_ent) : -1
	if (current_weapon == weaponid)
		ExecuteHamB(Ham_Weapon_RetireWeapon, weapon_ent)
	
	// Remove weapon from player
	if (!ExecuteHamB(Ham_RemovePlayerItem, index, weapon_ent))
		return false;
	
	// Kill weapon entity and fix pev_weapons bitsum
	ExecuteHamB(Ham_Item_Kill, weapon_ent)
	set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))
	return true;
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM);
}
