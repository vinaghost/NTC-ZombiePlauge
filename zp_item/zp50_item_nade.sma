#include <amxmodx>
#include <cstrike>
#include <fun>
#include <zp50_core>
#include <zp50_items>
#include <zp50_colorchat>


#define PLUGIN "[ZP] Extra Item: Nade"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new g_He, g_Forst;
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_He = zp_money_items_register("HE grenade", 3000);
	g_Forst = zp_money_items_register("Forst bomb", 5000);
}
public zp_fw_money_items_select_pre(id, itemid) {
	if( itemid == g_He || itemid == g_Forst) 
	{
		if( zp_core_is_zombie(id) ) return ZP_ITEM_DONT_SHOW;
		
		return ZP_ITEM_AVAILABLE
	}
	
	return ZP_ITEM_AVAILABLE;
}
public zp_fw_money_items_select_post(id, itemid) {
	if( itemid == g_He ) {
		new ammo = cs_get_user_bpammo(id , CSW_HEGRENADE);

		if(!ammo)
			give_item(id, "weapon_hegrenade")
		else
			give_nade(id, CSW_HEGRENADE)
	}
	else if( itemid == g_Forst) {
		new ammo = cs_get_user_bpammo(id , CSW_FLASHBANG);

		if(!ammo)
			give_item(id, "weapon_flashbang")
		else
			give_nade(id, CSW_FLASHBANG)
	}
}
public give_nade(id , grenade) 
{
	new ammo = cs_get_user_bpammo(id , grenade);
	cs_set_user_bpammo(id , grenade , ammo + 1);
}