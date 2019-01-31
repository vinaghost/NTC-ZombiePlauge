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
	
	client_cmd(id, "say menu");
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
	
	menu_additem(menu, "Chon Zombie");
	
	menu_additem(menu, "Nang cap vat pham");
	
	menu_additem(menu, "Doi mat khau");
	
	menu_additem(menu, "Mua do bang $ ( 1 round )");
	
	menu_additem(menu, "Bang xep hang (* chua lam ._. *)");
	
	menu_additem(menu, "Event/Su kien: (* chua lam not ._, *)");
	
	menu_additem(menu, "Giao luu voi Mod (* chua lam luon .-. *)");
	
	menu_additem(menu, "Chon nhan vat cho VIP (* tat nhien la chua roi *)");

	
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
			if (LibraryExists(LIBRARY_ITEMS, LibType_Library))
			{
				if (is_user_alive(id))
					zp_ap_items_show_menu(id)
				else
					zp_colored_print(id, "%L", id, "CANT_BUY_ITEMS_DEAD")
			}
			else
				zp_colored_print(id, "%L", id, "CMD_NOT_EXTRAS")
		}
		case 2: 
		{
			if(LibraryExists(LIBRARY_REGISTER_SYSTEM, LibType_Library) && get_cant_change_pass_time(id) > 0 )
			{
				zp_colored_print(id, "Khong the doi pass trong %d", get_cant_change_pass_time(id))
			}
			else
				client_cmd(id, "messagemode CHANGE_PASS_NEW")
		}
		case 3: // Human Classes
		{
			if (LibraryExists(LIBRARY_ITEMS, LibType_Library))
			{
				if (is_user_alive(id))
					zp_money_items_show_menu(id)
				else
					zp_colored_print(id, "%L", id, "CANT_BUY_ITEMS_DEAD")
			}
			else
				zp_colored_print(id, "%L", id, "CMD_NOT_EXTRAS")
		}
		case 4:
		{
			zp_colored_print(id, "[Thong bao] Da bao la chua lam xong ma =='")
		}
		case 5: 
		{
			zp_colored_print(id, "[Thong bao] Da bao la chua lam xong ma =='")
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
