#include <amxmodx>
#include <amxmisc>

#include <cs_maxspeed_api>

#include <zp50_class_zombie>

#define PLUGIN "[ZP] Class: Chinese"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new zclass_name[24] = "Chinese" 
new zclass_desc[32] = "Chay nhanh"
new zclass_desc1[32] = "Chay nhanh"
new zclass_desc2[32] = ""
new const zclass_model[] = "Chinese"
new const zclass_clawsmodel[] = "models/zombie_plague/v_knife_chinese.mdl"

new const zclass_health = 1500;
new const Float:zclass_gravity = 0.84;
new const Float:zclass_speed = 1.1;
new const Float:zclass_speed_skill = 2.0;
new const Float:zclass_knockback = 1.3;

new msg_ScreenFade

new g_Chinese
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	msg_ScreenFade = get_user_msgid( "ScreenFade")
	
	
}
public plugin_precache()
{
	// Register Zombie Class
	g_Chinese = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed ,zclass_gravity)
	
	zp_class_zombie_register_kb(g_Chinese, zclass_knockback);
	zp_class_zombie_register_model(g_Chinese, zclass_model)
	zp_class_zombie_register_claw(g_Chinese, zclass_clawsmodel)
	
	zp_class_zombie_register_1(g_Chinese, zclass_desc1, 50, 10)
	zp_class_zombie_register_2(g_Chinese, zclass_desc2, 0)
}
public zp_fw_zombie_skill1_active(id, classid) {
	
	if( classid != g_Chinese ) return;
 	
	ScreenFade(id, 10.0, 0, 225, 0, 40)
	
	cs_reset_player_maxspeed(id)
	cs_set_player_maxspeed_auto(id, zclass_speed_skill);
	
}

public zp_fw_zombie_skill1_activing(id, classid) {
	
	if( classid != g_Chinese ) return;
	
	cs_reset_player_maxspeed(id)
	cs_set_player_maxspeed_auto(id, zclass_speed);
}
stock ScreenFade(plr, Float:fDuration, red, green, blue, alpha)
{
	
	message_begin(MSG_ONE_UNRELIABLE, msg_ScreenFade, {0, 0, 0}, plr);
	write_short(floatround(4096.0 * fDuration, floatround_round));
	write_short(floatround(4096.0 * fDuration, floatround_round));
	write_short(4096);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
	
	return 1;
}
