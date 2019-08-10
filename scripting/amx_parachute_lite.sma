#include <amxmodx>
#include <cstrike>
#include <fakemeta>

#include <zp50_items>
#include <zp50_colorchat>

#define PLUGIN  "[AMX] Parachute (Lite)"
#define VERSION "1.0"
#define AUTHOR  "Celena Luna"

#define NAME "Bay"
#define COST 5

new cvar_parachute_speed

new g_parachute
new h_parachute

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_CmdStart, "fw_CmdStart")

	cvar_parachute_speed = register_cvar("para_speed", "60")

	g_parachute = zp_ap_items_register(NAME, COST)
}

public zp_fw_ap_items_select_pre(id, itemid) {
	if( itemid != g_parachute ) return ZP_ITEM_AVAILABLE;
	if( Get_BitVar(h_parachute, id) )
		return ZP_ITEM_DONT_SHOW;

	return ZP_ITEM_AVAILABLE;
}
public zp_fw_ap_items_select_post(id, itemid) {
	if( itemid != g_parachute ) return;

	Set_BitVar(h_parachute, id) ;
	zp_colored_print(id, "Kích hoạt ^x04BAY ^x01thành công cho ^x04ZOMBE");
}
public client_disconnected(id) {
	UnSet_BitVar(h_parachute, id);
}
public fw_CmdStart(id, uc_handle, seed) {
	if(!is_user_alive(id))
		return

	static NewButton; NewButton = get_uc(uc_handle, UC_Buttons)
	static flags; flags = pev(id, pev_flags)
	static speed; speed = -get_pcvar_num(cvar_parachute_speed)

	if( ( zp_core_is_zombie(id) && Get_BitVar(h_parachute, id) ) || !zp_core_is_zombie(id) )
	{
		if(NewButton & IN_USE)
		{
			if(!(flags & FL_ONGROUND))
			{
				new Float:velocity[3]
				pev(id, pev_velocity, velocity)
				if(velocity[2] < 0.0)
				{
					velocity[2] = (velocity[2] + 40.0 < float(speed)) ? velocity[2] + 80.0 : float(speed)
					set_pev(id, pev_velocity, velocity)
				}

			}
		}
	}
}
