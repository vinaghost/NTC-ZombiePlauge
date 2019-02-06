/*================================================================================
	
	--------------------------
	-*- [ZP] Items Manager -*-
	--------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <amx_settings_api>
#include <zp50_ammopacks>
#include <zp50_colorchat>
#include <zp50_core_const>
#include <zp50_items_const>

// Extra Items file
new const ZP_AP_EXTRAITEMS_FILE[] = "zp_ap_extraitems.ini"
new const ZP_MONEY_EXTRAITEMS_FILE[] = "zp_money_extraitems.ini"


#define MAXPLAYERS 32

// CS Player PData Offsets (win32)
const OFFSET_CSMENUCODE = 205

enum _:TOTAL_FORWARDS
{
	FW_ITEM_SELECT_PRE = 0,
	FW_ITEM_SELECT_POST
}

new m_Forwards[TOTAL_FORWARDS]
new a_Forwards[TOTAL_FORWARDS]
new g_ForwardResult

// Items data
new Array:m_ItemRealName
new Array:m_ItemName
new Array:m_ItemCost
new m_ItemCount

new Array:a_ItemRealName
new Array:a_ItemName
new Array:a_ItemCost
new a_ItemCount

#define MENU_AP_PAGE_ITEMS a_menu_data[id]
new a_menu_data[MAXPLAYERS+1]

#define MENU_MONEY_PAGE_ITEMS m_menu_data[id]
new m_menu_data[MAXPLAYERS+1]

public plugin_init()
{
	register_plugin("[ZP] Items Manager", ZP_VERSION_STRING, "ZP Dev Team")
		
	a_Forwards[FW_ITEM_SELECT_PRE] = CreateMultiForward("zp_fw_ap_items_select_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	a_Forwards[FW_ITEM_SELECT_POST] = CreateMultiForward("zp_fw_ap_items_select_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	
	m_Forwards[FW_ITEM_SELECT_PRE] = CreateMultiForward("zp_fw_money_items_select_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	m_Forwards[FW_ITEM_SELECT_POST] = CreateMultiForward("zp_fw_money_items_select_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
}
public plugin_natives()
{
	register_library("zp50_items")
	
	
	register_native("zp_ap_items_register", "native_ap_items_register")
	register_native("zp_ap_items_get_id", "native_ap_items_get_id")
	register_native("zp_ap_items_get_name", "native_ap_items_get_name")
	register_native("zp_ap_items_get_realname", "native_ap_items_get_realname")
	register_native("zp_ap_items_get_cost", "native_ap_items_get_cost")
	register_native("zp_ap_items_show_menu", "native_ap_items_show_menu")
	register_native("zp_ap_force_buy", "native_ap_items_force_buy")
	
	
	register_native("zp_money_items_register", "native_money_items_register")
	register_native("zp_money_items_get_id", "native_money_items_get_id")
	register_native("zp_money_items_get_name", "native_money_items_get_name")
	register_native("zp_money_items_get_realname", "native_money_items_get_realname")
	register_native("zp_money_items_get_cost", "native_money_items_get_cost")
	register_native("zp_money_items_show_menu", "native_money_items_show_menu")
	register_native("zp_money_force_buy", "native_money_items_force_buy")
	
	
	
	// Initialize dynamic arrays
	a_ItemRealName = ArrayCreate(32, 1)
	a_ItemName = ArrayCreate(32, 1)
	a_ItemCost = ArrayCreate(1, 1)
	
	m_ItemRealName = ArrayCreate(32, 1)
	m_ItemName = ArrayCreate(32, 1)
	m_ItemCost = ArrayCreate(1, 1)
}

public client_disconnect(id)
{
	// Reset remembered menu pages
	MENU_AP_PAGE_ITEMS = 0
	
	MENU_MONEY_PAGE_ITEMS = 0
}

// AmmoPack

public native_ap_items_register(plugin_id, num_params)
{
	new name[32], cost = get_param(2);
	get_string(1, name, charsmax(name))
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register item with an empty name")
		return ZP_INVALID_ITEM;
	}
	
	new index, item_name[32]
	for (index = 0; index < a_ItemCount; index++)
	{
		ArrayGetString(a_ItemRealName, index, item_name, charsmax(item_name))
		if (equali(name, item_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP] Item already registered (%s)", name)
			return ZP_INVALID_ITEM;
		}
	}
	
	// Load settings from extra items file
	new real_name[32]
	copy(real_name, charsmax(real_name), name)
	ArrayPushString(a_ItemRealName, real_name)
	
	// Name
	if (!amx_load_setting_string(ZP_AP_EXTRAITEMS_FILE, real_name, "NAME", name, charsmax(name)))
		amx_save_setting_string(ZP_AP_EXTRAITEMS_FILE, real_name, "NAME", name)
	ArrayPushString(a_ItemName, name)
	
	// Cost
	if (!amx_load_setting_int(ZP_AP_EXTRAITEMS_FILE, real_name, "COST", cost))
		amx_save_setting_int(ZP_AP_EXTRAITEMS_FILE, real_name, "COST", cost)
		
	ArrayPushCell(a_ItemCost, cost)
	
	a_ItemCount++
	return a_ItemCount - 1;
}

public native_ap_items_get_id(plugin_id, num_params)
{
	new real_name[32]
	get_string(1, real_name, charsmax(real_name))
	
	// Loop through every item
	new index, item_name[32]
	for (index = 0; index < a_ItemCount; index++)
	{
		ArrayGetString(a_ItemRealName, index, item_name, charsmax(item_name))
		if (equali(real_name, item_name))
			return index;
	}
	
	return ZP_INVALID_ITEM;
}

public native_ap_items_get_name(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= a_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new name[32]
	ArrayGetString(a_ItemName, item_id, name, charsmax(name))
	
	new len = get_param(3)
	set_string(2, name, len)
	return true;
}

public native_ap_items_get_realname(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= a_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new real_name[32]
	ArrayGetString(a_ItemRealName, item_id, real_name, charsmax(real_name))
	
	new len = get_param(3)
	set_string(2, real_name, len)
	return true;
}

public native_ap_items_get_cost(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= a_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return -1;
	}
	
	return ArrayGetCell(a_ItemCost, item_id);
}

public native_ap_items_show_menu(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	ap_items(id)
	return true;
}

public native_ap_items_force_buy(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	new item_id = get_param(2)
	
	if (item_id < 0 || item_id >= a_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new ignorecost = get_param(3)
	
	buy_ap_item(id, item_id, ignorecost)
	return true;
}

//MONEY

public native_money_items_register(plugin_id, num_params)
{
	new name[32], cost = get_param(2)
	get_string(1, name, charsmax(name))
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register item with an empty name")
		return ZP_INVALID_ITEM;
	}
	
	new index, item_name[32]
	for (index = 0; index < m_ItemCount; index++)
	{
		ArrayGetString(m_ItemRealName, index, item_name, charsmax(item_name))
		if (equali(name, item_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP] Item already registered (%s)", name)
			return ZP_INVALID_ITEM;
		}
	}
	
	// Load settings from extra items file
	new real_name[32]
	copy(real_name, charsmax(real_name), name)
	ArrayPushString(m_ItemRealName, real_name)
	
	// Name
	if (!amx_load_setting_string(ZP_MONEY_EXTRAITEMS_FILE, real_name, "NAME", name, charsmax(name)))
		amx_save_setting_string(ZP_MONEY_EXTRAITEMS_FILE, real_name, "NAME", name)
	ArrayPushString(m_ItemName, name)
	
	// Cost
	if (!amx_load_setting_int(ZP_MONEY_EXTRAITEMS_FILE, real_name, "COST", cost))
		amx_save_setting_int(ZP_MONEY_EXTRAITEMS_FILE, real_name, "COST", cost)
	ArrayPushCell(m_ItemCost, cost)
		
	m_ItemCount++
	return m_ItemCount - 1;
}

public native_money_items_get_id(plugin_id, num_params)
{
	new real_name[32]
	get_string(1, real_name, charsmax(real_name))
	
	// Loop through every item
	new index, item_name[32]
	for (index = 0; index < m_ItemCount; index++)
	{
		ArrayGetString(m_ItemRealName, index, item_name, charsmax(item_name))
		if (equali(real_name, item_name))
			return index;
	}
	
	return ZP_INVALID_ITEM;
}

public native_money_items_get_name(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= m_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new name[32]
	ArrayGetString(m_ItemName, item_id, name, charsmax(name))
	
	new len = get_param(3)
	set_string(2, name, len)
	return true;
}

public native_money_items_get_realname(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= m_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new real_name[32]
	ArrayGetString(m_ItemRealName, item_id, real_name, charsmax(real_name))
	
	new len = get_param(3)
	set_string(2, real_name, len)
	return true;
}

public native_money_items_get_cost(plugin_id, num_params)
{
	new item_id = get_param(1)
	
	if (item_id < 0 || item_id >= m_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return -1;
	}
	
	return ArrayGetCell(m_ItemCost, item_id);
}

public native_money_items_show_menu(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	money_items(id)
	return true;
}

public native_money_items_force_buy(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	new item_id = get_param(2)
	
	if (item_id < 0 || item_id >= m_ItemCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item id (%d)", item_id)
		return false;
	}
	
	new ignorecost = get_param(3)
	
	buy_money_item(id, item_id, ignorecost)
	return true;
}



public ap_items(id)
{
	// Player dead
	if (!is_user_alive(id))
		return;
	
	show_ap_items_menu(id)
}

public money_items(id)
{
	// Player dead
	if (!is_user_alive(id))
		return;
	
	show_money_items_menu(id)
}

// Items Menu
show_ap_items_menu(id)
{
	static menu[128], name[32], cost;
	new menuid, index, itemdata[2]
	
	// Title
	formatex(menu, charsmax(menu), "Nang cap vat pham^nBạn đang có %d AP", zp_ammopacks_get(id)
);
	
	menuid = menu_create(menu, "menu_ap_extraitems")
	
	// Item List
	for (index = 0; index < a_ItemCount; index++)
	{
		ExecuteForward(a_Forwards[FW_ITEM_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult == ZP_ITEM_DONT_SHOW)
			continue;
		
		ArrayGetString(a_ItemName, index, name, charsmax(name))
		cost = ArrayGetCell(a_ItemCost, index)
		
		if (g_ForwardResult == ZP_ITEM_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y%d", name, cost)
		
		itemdata[0] = index
		itemdata[1] = 0
		menu_additem(menuid, menu, itemdata)
	}
	
	// No items to display?
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "%L", id, "NO_EXTRA_ITEMS")
		menu_destroy(menuid)
		return;
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_AP_PAGE_ITEMS = min(MENU_AP_PAGE_ITEMS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	set_pdata_int(id, OFFSET_CSMENUCODE, 0)
	menu_display(id, menuid, MENU_AP_PAGE_ITEMS)
}

// Items Menu
public menu_ap_extraitems(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		MENU_AP_PAGE_ITEMS = 0
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember items menu page
	MENU_AP_PAGE_ITEMS = item / 7
	
	// Dead players are not allowed to buy items
	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve item id
	new itemdata[2], dummy, itemid
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	
	// Attempt to buy the item
	buy_ap_item(id, itemid)
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Buy Item
buy_ap_item(id, itemid, ignorecost = 0)
{
	// Execute item select attempt forward
	ExecuteForward(a_Forwards[FW_ITEM_SELECT_PRE], g_ForwardResult, id, itemid, ignorecost)
	
	// Item available to player?
	if (g_ForwardResult >= ZP_ITEM_NOT_AVAILABLE)
		return;
	
	// Execute item selected forward
	ExecuteForward(a_Forwards[FW_ITEM_SELECT_POST], g_ForwardResult, id, itemid, ignorecost)
}


show_money_items_menu(id)
{
	static menu[128], name[32], cost
	new menuid, index, itemdata[2]
	
	// Title
	formatex(menu, charsmax(menu), "Shop Item Extra^nBạn đang có $ %d", cs_get_user_money(id));
	menuid = menu_create(menu, "menu_money_extraitems")
	
	// Item List
	for (index = 0; index < m_ItemCount; index++)
	{
		ExecuteForward(m_Forwards[FW_ITEM_SELECT_PRE], g_ForwardResult, id, index, 0)
		
		if (g_ForwardResult >= ZP_ITEM_DONT_SHOW)
			continue;
		
		ArrayGetString(m_ItemName, index, name, charsmax(name))
		cost = ArrayGetCell(m_ItemCost, index)
				
		// Item available to player?
		if (g_ForwardResult >= ZP_ITEM_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s \R%d", name, cost)
		else
			formatex(menu, charsmax(menu), "%s \R\y%d", name, cost)
		
		itemdata[0] = index
		itemdata[1] = 0
		menu_additem(menuid, menu, itemdata)
	}
	
	// No items to display?
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "%L", id, "NO_EXTRA_ITEMS")
		menu_destroy(menuid)
		return;
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_MONEY_PAGE_ITEMS = min(MENU_MONEY_PAGE_ITEMS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	set_pdata_int(id, OFFSET_CSMENUCODE, 0)
	menu_display(id, menuid, MENU_MONEY_PAGE_ITEMS)
}

// Items Menu
public menu_money_extraitems(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		MENU_MONEY_PAGE_ITEMS = 0
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember items menu page
	MENU_MONEY_PAGE_ITEMS = item / 7
	
	// Dead players are not allowed to buy items
	if (!is_user_alive(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve item id
	new itemdata[2], dummy, itemid
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	itemid = itemdata[0]
	
	// Attempt to buy the item
	buy_money_item(id, itemid)
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}
// Buy Item
buy_money_item(id, itemid, ignorecost = 0)
{
	// Execute item select attempt forward
	ExecuteForward(m_Forwards[FW_ITEM_SELECT_PRE], g_ForwardResult, id, itemid, ignorecost)
	
	// Item available to player?
	if (g_ForwardResult >= ZP_ITEM_NOT_AVAILABLE)
		return;
	
	// Execute item selected forward
	ExecuteForward(m_Forwards[FW_ITEM_SELECT_POST], g_ForwardResult, id, itemid, ignorecost)
}
