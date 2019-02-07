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

#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>

#define PLUGIN "[ZP] Weapon"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

new const ZP_EXTRAWEAPON_FILE[] = "zp_extraweapons.ini"

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
new Array:g_WeaponFree
new g_WeaponCount

new p_Weapon[3][33]
new p_AutoWeapon

new g_MaxPlayer;
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_Forwards[FW_WPN_SELECT_PRE] = CreateMultiForward("zp_fw_wpn_select_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_Forwards[FW_WPN_SELECT_POST] = CreateMultiForward("zp_fw_wpn_select_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_Forwards[FW_WPN_REMOVE] = CreateMultiForward("zp_fw_wpn_remove", ET_IGNORE, FP_CELL, FP_CELL)
	
	g_MaxPlayer = get_maxplayers()
	
	
	register_clcmd("say /buy", "show_buy_menu")
	register_clcmd("say buy", "show_buy_menu")
	register_clcmd("say /guns", "show_buy_menu")
	register_clcmd("say guns", "show_buy_menu")
}
public plugin_natives()
{
	register_library("zp50_weapon")
	
	register_native("zp_weapons_register", "native_weapons_register")
	register_native("zp_weapons_get_id", "native_weapons_get_id")
	register_native("zp_weapons_get_name", "native_weapons_get_name")
	register_native("zp_weapons_get_realname", "native_weapons_get_realname")
	register_native("zp_weapons_get_cost", "native_weapons_get_cost")
	register_native("zp_weapons_get_type", "native_weapons_get_type")
	register_native("zp_weapons_force_buy", "native_weapons_force_buy")
	
	
	register_native("zp_weapons_main_menu", "native_weapons_main_menu")
	register_native("zp_weapons_buy_menu", "native_weapons_buy_menu")
	
	set_module_filter("module_filter")
	set_native_filter("native_filter")
	
	g_WeaponRealName = ArrayCreate(32, 1)
	g_WeaponName = ArrayCreate(32, 1)
	g_WeaponCost = ArrayCreate(1, 1)
	g_WeaponType = ArrayCreate(1,1)
	g_WeaponFree = ArrayCreate(1,1)
	
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

public zp_fw_core_cure_post(id, attacker)
{
	set_task(0.1, "show_menu_main", id)
}
public zp_fw_core_infect_pre(id, attacker) {
	
	if(p_Weapon[ZP_PRIMARY][id] != ZP_INVALID_WEAPON ) {
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_PRIMARY][id])
	}
	
	if(p_Weapon[ZP_SECONDAYRY][id] != ZP_INVALID_WEAPON ) {
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_SECONDAYRY][id])
	}
	
	if(p_Weapon[ZP_KNIFE][id] != ZP_INVALID_WEAPON ) {
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_KNIFE][id])
	}
	

}
public client_connect(id) {
	UnSet_BitVar(p_AutoWeapon,id) 
	
	p_Weapon[ZP_PRIMARY][id] = ZP_INVALID_WEAPON;
	p_Weapon[ZP_SECONDAYRY][id] = ZP_INVALID_WEAPON;
	p_Weapon[ZP_KNIFE][id] = ZP_INVALID_WEAPON;
}
public client_disconnect(id) {
	if(p_Weapon[ZP_PRIMARY][id] != ZP_INVALID_WEAPON ) {
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_PRIMARY][id])
	}
	
	if(p_Weapon[ZP_SECONDAYRY][id] != ZP_INVALID_WEAPON ) {
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_SECONDAYRY][id])
	}
	
	if(p_Weapon[ZP_KNIFE][id] != ZP_INVALID_WEAPON ) {
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, p_Weapon[ZP_KNIFE][id])
	}
	
	p_Weapon[ZP_PRIMARY][id] = ZP_INVALID_WEAPON;
	p_Weapon[ZP_SECONDAYRY][id] = ZP_INVALID_WEAPON;
	p_Weapon[ZP_KNIFE][id] = ZP_INVALID_WEAPON;
	
	UnSet_BitVar(p_AutoWeapon,id)
}
public show_menu_main(id) {
	if (!is_user_alive(id) || zp_core_is_zombie(id))
		return;
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id))
		return;
	
	new title[64];
	formatex(title, charsmax(title), "Chon vu khi^nDang co %d AP", zp_ammopacks_get(id)) 
	new menu = menu_create(title, "menu_main");
	
	menu_additem(menu, "\yNANG CAP SUNG !!!")
	
	new item[128];
	if( Get_BitVar(p_AutoWeapon, id) )
	{
		new primary[32], secondary[32], knife[32];
		ArrayGetString(g_WeaponName, p_Weapon[ZP_PRIMARY][id], primary, charsmax(primary))
		ArrayGetString(g_WeaponName, p_Weapon[ZP_SECONDAYRY][id], secondary, charsmax(secondary))
		ArrayGetString(g_WeaponName, p_Weapon[ZP_KNIFE][id], knife, charsmax(knife))
		
		formatex(item, charsmax(item), "CHON LAI VU KHI^n- %s^n- %s^n- %s",  primary, secondary, knife);
	}
	else
		formatex(item, charsmax(item), "\dCHON LAI VU KHI^n-  ^n-  ^n-  ");
		
	menu_additem(menu, item);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	
	menu_display(id, menu)
}

public menu_main( id, menu, item )
{
	if( !is_user_alive(id) || zp_core_is_zombie(id) ) return PLUGIN_CONTINUE;
	
	strip_weapons(id, ZP_PRIMARY)
	strip_weapons(id, ZP_SECONDAYRY)
	
	switch (item) {
		case 0: {
			show_primary_menu(id)
		}
			
		case 1:  {
			if( Get_BitVar(p_AutoWeapon, id) )
				auto_take_weapons(id)
			else
				show_menu_main(id)
			}
	}
	
	return PLUGIN_HANDLED
}
public auto_take_weapons(id) {
	if( !is_user_alive(id) ) return
	
	buy_weapon(id, p_Weapon[ZP_PRIMARY][id], 1)
	buy_weapon(id, p_Weapon[ZP_SECONDAYRY][id], 1)
	buy_weapon(id, p_Weapon[ZP_KNIFE][id], 1)
}

public show_primary_menu(id) {
	if( !is_user_alive(id) || zp_core_is_zombie(id) ) return;
	
	new title[64];
	formatex(title, charsmax(title), "Chon vu khi chinh^nDang co %d AP", zp_ammopacks_get(id)) 
	new menuid = menu_create(title, "primary_menu");
	
	static menu[128], name[32], cost, free, type;
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
		
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_PRIMARY) 
			continue;
			
		free = ArrayGetCell(g_WeaponFree, index)	
		if(!Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		
		formatex(menu, charsmax(menu), "%s", name)
		
		itemdata[0] = index
		itemdata[1] = 1
		
		menu_additem(menuid, menu, itemdata)
	}
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
		
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_PRIMARY) 
			continue;
			
		free = ArrayGetCell(g_WeaponFree, index)	
		if(Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		cost = ArrayGetCell(g_WeaponCost, index)	
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y%d", name, cost)
			
			
		itemdata[0] = index
		itemdata[1] = 0
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public primary_menu(id, menuid, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	new itemdata[2], dummy, itemid, free
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	free = itemdata[1]
	
	buy_weapon(id, itemid, free)
	
	p_Weapon[ZP_PRIMARY][id] = itemid;
	show_secondary_menu(id)
		
	return PLUGIN_HANDLED;
}	


public show_secondary_menu(id) {
	if( !is_user_alive(id) ) return;
	
	new title[64];
	formatex(title, charsmax(title), "Chon vu khi phu^nDang co %d AP", zp_ammopacks_get(id)) 
	new menuid = menu_create(title, "secondary_menu");
	
	static menu[128], name[32], cost, free, type;
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
		
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_SECONDAYRY) 
			continue;
			
		free = ArrayGetCell(g_WeaponFree, index)	
		if(!Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		
		formatex(menu, charsmax(menu), "%s", name)
		
		itemdata[0] = index
		itemdata[1] = 1
		
		menu_additem(menuid, menu, itemdata)
	}
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
		
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_SECONDAYRY) 
			continue;
			
		free = ArrayGetCell(g_WeaponFree, index)	
		if(Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		
		cost = ArrayGetCell(g_WeaponCost, index)
		
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y%d", name, cost)
			
			
		itemdata[0] = index
		itemdata[1] = 0
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public secondary_menu(id, menuid, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	new itemdata[2], dummy, itemid, free
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	free = itemdata[1]
	
	
	buy_weapon(id, itemid, free)
	
	
	
	p_Weapon[ZP_SECONDAYRY][id] = itemid
	show_knife_menu(id)
		
		
	return PLUGIN_HANDLED;
}


public show_knife_menu(id) {
	if( !is_user_alive(id) ) return;
	
	new title[64];
	formatex(title, charsmax(title), "Chon dao^nDang co %d AP", zp_ammopacks_get(id)) 
	new menuid = menu_create(title, "knife_menu");
	
	static menu[128], name[32], cost, free, type;
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
		
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_KNIFE ) 
			continue;
			
		free = ArrayGetCell(g_WeaponFree, index)	
		if(!Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		
		formatex(menu, charsmax(menu), "%s", name)
		
		itemdata[0] = index
		itemdata[1] = 1
		
		menu_additem(menuid, menu, itemdata)
	}
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
		
		type = ArrayGetCell(g_WeaponType, index)
		if( type != ZP_KNIFE) 
			continue;
			
		free = ArrayGetCell(g_WeaponFree, index)	
		if(Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
		
		cost = ArrayGetCell(g_WeaponCost, index)
		
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y%d", name, cost)
			
			
		itemdata[0] = index
		itemdata[1] = 0
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public knife_menu(id, menuid, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	new itemdata[2], dummy, itemid, free
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	free = itemdata[1]
	
	
	buy_weapon(id, itemid, free)
	
	p_Weapon[ZP_KNIFE][id] = itemid
	menu_destroy(menuid)

	Set_BitVar(p_AutoWeapon,id)
	return PLUGIN_HANDLED;
}	

public show_buy_menu(id) {
	if( !is_user_alive(id) || zp_core_is_zombie(id) ) return;
	
	new title[64];
	formatex(title, charsmax(title), "Chon dao^nDang co %d AP", zp_ammopacks_get(id)) 
	new menuid = menu_create(title, "buy_menu");
	
	static menu[128], name[32], cost, free
	new index, itemdata[2]
	
	for (index = 0; index < g_WeaponCount; index++)
	{
		ExecuteForward(g_Forwards[FW_WPN_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_WEAPON_DONT_SHOW)
			continue;
					
		free = ArrayGetCell(g_WeaponFree, index)	
		if(Get_BitVar(free, id) )
			continue;
		
		ArrayGetString(g_WeaponName, index, name, charsmax(name))
			
		if (g_ForwardResult >= ZP_WEAPON_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y%d", name, cost)
			
		itemdata[0] = index
		itemdata[1] = g_ForwardResult
		menu_additem(menuid, menu, itemdata)
	}
	
	menu_display(id, menuid, 0)
}

public buy_menu(id, menuid, item){
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
		
	if (!is_user_alive(id) || zp_core_is_zombie(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	
	new itemdata[2], dummy, itemid, allow
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	allow = itemdata[1]
	
	
	
	if( !allow ) {
		
		new type = ArrayGetCell(g_WeaponType, itemid)
		
		if( type != ZP_KNIFE ) {
			strip_weapons(id, type)
		}
		
		ExecuteForward(g_Forwards[FW_WPN_REMOVE], g_ForwardResult, id, itemid)
	}
	
	buy_weapon(id, itemid)
	
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
	
	
	new free = 0;
	if( !cost ) 
	{
		for(new i = 1; i <= g_MaxPlayer; i++) {
			Set_BitVar(free, i);
		}
	}
	ArrayPushCell(g_WeaponFree, free)
	
	
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

	
public native_weapons_main_menu(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	show_menu_main(id)
	
	return true;
}
public native_weapons_buy_menu(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	show_buy_menu(id)
	
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
	
	new free = ArrayGetCell(g_WeaponFree, itemid)
	if( !Get_BitVar(free, id) )
		Set_BitVar(free, id)
	
	ArraySetCell(g_WeaponFree, itemid, free)
	
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
