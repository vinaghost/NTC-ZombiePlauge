/* Plugin generated by AMXX-Studio */

#include <amxmodx>

#include <zp50_items>
#include <zp50_gamemodes>
#include <zp50_colorchat>

//#define LIBRARY_NEMESIS "zp50_class_nemesis"
//#include <zp50_class_nemesis>

#define PLUGIN "[ZP] Item: Buy Nemesis"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new g_Nem, index
new g_Nem_Mode

new countdown_timer, cvar_countdown_sound;
new g_msgsync;
const TASK_ID = 1603;

new speak[16][] = {
    "fvox/biohazard_detected.wav",
    "fvox/one.wav",
    "fvox/two.wav",
    "fvox/three.wav",
    "fvox/four.wav",
    "fvox/five.wav",
    "fvox/six.wav",
    "fvox/seven.wav",
    "fvox/eight.wav",
    "fvox/nine.wav",
    "fvox/ten.wav",
    "fvox/eleven.wav",
    "fvox/twelve.wav",
    "fvox/thirteen.wav",
    "fvox/fourteen.wav",
    "fvox/fifteen.wav"
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")

	g_Nem = zp_money_items_register("Mua Nemesis round sau" , 80000);
	index = 0

	//needed for smooth countdown display
	g_msgsync = CreateHudSyncObj();

	//cvars
	cvar_countdown_sound = register_cvar("countdown_sound", "1"); //1 to enable, 0 to disable
}
public plugin_precache()
{
    precache_sound("fvox/biohazard_detected.wav");
    precache_sound("fvox/one.wav");
    precache_sound("fvox/two.wav");
    precache_sound("fvox/three.wav");
    precache_sound("fvox/four.wav");
    precache_sound("fvox/five.wav");
    precache_sound("fvox/six.wav");
    precache_sound("fvox/seven.wav");
    precache_sound("fvox/eight.wav");
    precache_sound("fvox/nine.wav");
    precache_sound("fvox/ten.wav");
    precache_sound("fvox/eleven.wav");
    precache_sound("fvox/twelve.wav");
    precache_sound("fvox/thirteen.wav");
    precache_sound("fvox/fourteen.wav");
    precache_sound("fvox/fifteen.wav");
}

public plugin_cfg() {
	g_Nem_Mode = zp_gamemodes_get_id("Nemesis Mode");
}
public event_new_round() {
	if( index ) {
		set_task(1.0, "SetNem");

	}
	else {
		//bugfix
		remove_task(TASK_ID);

		countdown_timer = get_cvar_num("zp_gamemode_delay") - 1;
		set_task(1.0, "countdown", TASK_ID);
	}
}

public countdown()
{


	if (countdown_timer > 1)
	{
		//emit_sound(0, CHAN_VOICE, speak[countdown_timer-1], 1.0, ATTN_NORM, 0, PITCH_NORM);
		if (cvar_countdown_sound != 0)
			client_cmd(0, "spk %s", speak[countdown_timer-1]);

		set_hudmessage(179, 0, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1, 10);
		if (countdown_timer != 1)
			ShowSyncHudMsg(0, g_msgsync, "Virus V phát bệnh trong %d giây", countdown_timer-1); //the new way
	}
	--countdown_timer;

	if(countdown_timer >= 1)
        set_task(1.0, "countdown", TASK_ID);
	else
		remove_task(TASK_ID);
}

public SetNem()
{
	zp_gamemodes_start(g_Nem_Mode, index)
	index = 0;
}
public zp_fw_money_items_select_pre(id, itemid) {
	if( itemid != g_Nem ) return ZP_ITEM_AVAILABLE;
	if (zp_core_get_zombie_count() < 1)		return ZP_ITEM_DONT_SHOW;

	if( index ) return ZP_ITEM_NOT_AVAILABLE;

	return ZP_ITEM_AVAILABLE;
}
public zp_fw_money_items_select_post(id, itemid) {
	if( itemid != g_Nem ) return;

	index = id;

	new name[33]
	get_user_name(id, name, charsmax(name))
	zp_colored_print(0, "%s đã mua ^x04Nemesis^x01, không thể mua được nữa", name);

}

public client_disconnected(id) {
	if( id == index ) {
		index = 0;
	}
}

