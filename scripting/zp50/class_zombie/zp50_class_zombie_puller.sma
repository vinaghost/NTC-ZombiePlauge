#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>
#include <engine>
#include <msgstocks>

#include <zp50_class_zombie>
#include <zp50_class_sniper>
#include <zp50_class_survivor>
#include <zp50_items>

#define PLUGIN "[ZP] Class: Puller"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

#define POWER 9

new zclass_name[24] = "Puller"
new zclass_desc[32] = "Kéo Human"
new zclass_desc1[32] = "Kéo Human"
new zclass_desc2[32] = ""
new const zclass_model[] = "ntc_hoker"
new const zclass_clawsmodel[] = "models/zombie_plague/v_knife_hoker.mdl"

new const zclass_health = 2500 ;
new const Float:zclass_gravity = 0.9;
new const Float:zclass_speed = 1.4;
new const Float:zclass_knockback = 1.4;

new g_Puller
new g_ItemID
new p_puller;

new msg_ScreenFade;
new beamsprite
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	msg_ScreenFade = get_user_msgid( "ScreenFade")
	g_ItemID = zp_ap_items_register("Unlock Zombie Puller", 7)

}
public plugin_precache()
{
	// Register Zombie Class
	g_Puller = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed ,zclass_gravity)

	zp_class_zombie_register_kb(g_Puller, zclass_knockback);
	zp_class_zombie_register_model(g_Puller, zclass_model)
	zp_class_zombie_register_claw(g_Puller, zclass_clawsmodel)

	zp_class_zombie_register_1(g_Puller, zclass_desc1, 20, 0)
	zp_class_zombie_register_2(g_Puller, zclass_desc2, 0, 0)

	beamsprite = precache_model("sprites/dot.spr")
}
public zp_fw_money_items_select_pre(id, itemid)
{
	if( itemid != g_ItemID )
	return ZP_ITEM_AVAILABLE;

	if( Get_BitVar(p_puller, id) )
	return ZP_ITEM_DONT_SHOW;

	return ZP_ITEM_AVAILABLE
}
public zp_fw_ap_items_select_post(id, itemid) {
	if( itemid != g_ItemID ) return;

	Set_BitVar(p_puller, id);
}

public client_putinserver(id) {
	UnSet_BitVar(p_puller, id);
}
public zp_fw_class_zombie_select_pre(id, classid) {
	if( classid != g_Puller ) return ZP_CLASS_AVAILABLE;

	if( !Get_BitVar(p_puller, id) )
	return ZP_CLASS_NOT_AVAILABLE;

	return ZP_CLASS_AVAILABLE;

}
public zp_fw_zombie_skill1_active(id, classid) {

	if( classid != g_Puller ) return ZP_CLASS_SKILL_ACTIVE;

	new target , iBodyPart;
	get_user_aiming( id , target , iBodyPart );

	if ( !is_user_alive( target )) return ZP_CLASS_SKILL_CANT_ACTIVE;

	if( zp_core_is_zombie(target) ) return ZP_CLASS_SKILL_CANT_ACTIVE;

	if( zp_class_sniper_get(target) || zp_class_survivor_get(target) ) return ZP_CLASS_SKILL_CANT_ACTIVE;

	ScreenFade(target, 5.0, 255, 255, 255, 255);

	ScreenFade(id, 2.0, 116, 184, 138, 40);

	/*static Float:fVelocity[3]
	static Float:fOriginI[3];
	static Float:fOriginT[3];
	pev( id, pev_origin, fOriginI )
	pev( target, pev_origin, fOriginT )

	for(new i = 0; i < 2; i++) {
		fVelocity[i] = (fOriginI[i] - fOriginT[i])
	}*/
	static Float:Origin[3]
	pev(id, pev_origin, Origin)
	HookEnt(target, Origin, 2000.0, 1.0, 1)

	static iOrigin[3], iOriginT[3];
	get_user_origin(id, iOrigin);
	get_user_origin(target, iOriginT);
	te_create_beam_between_points(iOrigin, iOriginT, beamsprite, 1, 1, 2, 5, 0, 2255, 0, 0, 200, 0)
	/*
	//Create red beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(1)		//TE_BEAMENTPOINT
	write_short(id)		// start entity
	write_coord(floatround(Origin[0]))
	write_coord(floatround(Origin[1]))
	write_coord(floatround(Origin[2]))
	write_short(beamsprite)
	write_byte(1)		// framestart
	write_byte(1)		// framerate
	write_byte(10)		// life in 0.1's
	write_byte(5)		// width
	write_byte(0)		// noise
	write_byte(255)		// red
	write_byte(0)		// green
	write_byte(0)		// blue
	write_byte(200)		// brightness
	write_byte(0)		// speed
	message_end()
	*/

	return ZP_CLASS_SKILL_ACTIVE;
}

stock HookEnt(ent, Float:VicOrigin[3], Float:speed, Float:multi, type)
{
	static Float:fl_Velocity[3]
	static Float:EntOrigin[3]
	static Float:EntVelocity[3]

	pev(ent, pev_velocity, EntVelocity)
	pev(ent, pev_origin, EntOrigin)
	static Float:distance_f
	distance_f = get_distance_f(EntOrigin, VicOrigin)

	static Float:fl_Time; fl_Time = distance_f / speed
	static Float:fl_Time2; fl_Time2 = distance_f / (speed * multi)

	if(type == 1)
	{
		fl_Velocity[0] = ((VicOrigin[0] - EntOrigin[0]) / fl_Time2) * 1.5
		fl_Velocity[1] = ((VicOrigin[1] - EntOrigin[1]) / fl_Time2) * 1.5
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
	} else if(type == 2) {
		fl_Velocity[0] = ((EntOrigin[0] - VicOrigin[0]) / fl_Time2) * 1.5
		fl_Velocity[1] = ((EntOrigin[1] - VicOrigin[1]) / fl_Time2) * 1.5
		fl_Velocity[2] = (EntOrigin[2] - VicOrigin[2]) / fl_Time
	}

	xs_vec_add(EntVelocity, fl_Velocity, fl_Velocity)
	set_pev(ent, pev_velocity, fl_Velocity)
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
