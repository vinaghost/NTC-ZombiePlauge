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
#include <register_system>
#define LIBRARY_REGISTER_SYSTEM "register_system"

#define TASK_WELCOMEMSG 100

// CS Player PData Offsets (win32)
const OFFSET_CSMENUCODE = 205


#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))




public plugin_init()
{
	register_plugin("[ZP] Main Menu", ZP_VERSION_STRING, "ZP Dev Team")
		
	register_clcmd("chooseteam", "clcmd_chooseteam")
	
	register_clcmd("say /menu", "clcmd_zpmenu")
	register_clcmd("say menu", "clcmd_zpmenu")
	
}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_BUYMENUS) || equal(module, LIBRARY_ZOMBIECLASSES) || equal(module, LIBRARY_HUMANCLASSES) || equal(module, LIBRARY_ITEMS) || equal(module, LIBRARY_ADMIN_MENU) || equal(module, LIBRARY_RANDOMSPAWN) || equal(module,LIBRARY_REGISTER_SYSTEM ))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Welcome Message Task
public task_welcome_msg()
{
	zp_colored_print(0, "==== ^x04Zombie Plague %s^x01 ====", ZP_VERSION_STR_LONG)
	zp_colored_print(0, "%L", LANG_PLAYER, "NOTICE_INFO1")
}

public clcmd_chooseteam(id)
{
	
	client_cmd(id, "say /menu"); //chong spam khung chat voi lenh menu ._.
	return PLUGIN_HANDLED_MAIN;

}

public clcmd_zpmenu(id)
{
	show_menu_main(id)
}

// Main Menu
show_menu_main(id)
{	
	// Title
	new menu = menu_create( "Main menu:", "menu_handler" );
	
	menu_additem(menu, "Chon Zombie"); //0
	
	menu_additem(menu, "Nang cap vat pham"); //1
	
	//menu_additem(menu, "Nang cap sung va vu khi khong ban ra dan");
	
	menu_additem(menu, "Mua do bang $ ( 1 round )"); //2
	
	menu_additem(menu, "Doi mat khau"); //3
	
	menu_additem(menu, "Bang xep hang"); // 4
	
	menu_additem(menu, "Update rank"); // 5
	
	menu_additem(menu, "Giao luu voi Mod (* chua lam luon .-. *)"); //6
	
	menu_additem(menu, "Chon nhan vat cho VIP (* tat nhien la chua roi *)"); //7

	
	set_pdata_int(id, OFFSET_CSMENUCODE, 0)
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

// Main Menu
 public menu_handler( id, menu, item )
{
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
			show_Upgrade_menu(id)
		}
		case 2:
		{
			show_Item_menu(id)
		}
		case 3: 
		{
			if(LibraryExists(LIBRARY_REGISTER_SYSTEM, LibType_Library) && get_cant_change_pass_time(id) > 0 )
			{
				zp_colored_print(id, "Khong the doi pass trong %d", get_cant_change_pass_time(id))
			}
			else
				client_cmd(id, "messagemode CHANGE_PASS_NEW")
		}
		
		case 4:
		{
			client_cmd(id, "say /top");
		}
		case 5: 
		{
			client_cmd(id, "say /save");
			
			client_cmd(id, "say /ranks");
			
		}
		case 6:
		{
			zp_colored_print(id, "[Thong bao] Da bao la chua lam xong ma =='")
		}
		case 7: // Admin Menu
		{
			zp_colored_print(id, "[Thong bao] Da bao la chua lam xong ma =='")
		}
	}
	
	return PLUGIN_HANDLED;
}

public show_Upgrade_menu(id) {
	if( !is_user_alive(id) ) return;
	
	new menuid = menu_create("[NTC] Nang cap vat pham", "Upgrade_menu");
	
	menu_additem(menuid, "Sung chinh");
	menu_additem(menuid, "Sung phu");
	menu_additem(menuid, "Dao va cac loai vu khi khong ban ra dan");
	menu_additem(menuid, "Vat pham ho tro"); //Extra items
	
	menu_display(id, menuid, 0)
}
public Upgrade_menu(id, menuid, item)
{
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
	
	new menuid = menu_create("[NTC] Vat pham dung 1 round", "Item_menu");
	
	menu_additem(menuid, "Sung chinh");
	menu_additem(menuid, "Sung phu");
	menu_additem(menuid, "Dao va cac loai vu khi khong ban ra dan");
	menu_additem(menuid, "Vat pham ho tro"); //Extra items
	
	menu_display(id, menuid, 0)
}
public Item_menu(id, menuid, item)
{
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
	
	