#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <cs_maxspeed_api>

#include <zp50_class_zombie>
#include <zp50_class_sniper>
#include <zp50_class_survivor>
#include <zp50_items>

#define PLUGIN "[ZP] Class: Ninja"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new zclass_name[24] = "Ninja"
new zclass_desc[32] = "Tốc biến + Làm choáng"
new zclass_desc1[32] = "Tốc biến"
new zclass_desc2[32] = "Làm choáng"
new const zclass_model[] = "ntc_ninjazombie"
new const zclass_clawsmodel[] = "models/zombie_plague/v_knife_ninjazombie.mdl"

new const zclass_health = 2800 ;
new const Float:zclass_gravity = 0.84;
new const Float:zclass_speed = 1.6;
new const Float:zclass_knockback = 1.2;

new g_Ninja
new g_ItemID
new p_ninja;

new msg_ScreenFade;
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	msg_ScreenFade = get_user_msgid( "ScreenFade")
	g_ItemID = zp_ap_items_register("Unlock Zombie Ninja", 7)

}
public plugin_precache()
{
	// Register Zombie Class
	g_Ninja = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed ,zclass_gravity)

	zp_class_zombie_register_kb(g_Ninja, zclass_knockback);
	zp_class_zombie_register_model(g_Ninja, zclass_model)
	zp_class_zombie_register_claw(g_Ninja, zclass_clawsmodel)

	zp_class_zombie_register_1(g_Ninja, zclass_desc1, 20, 0)
	zp_class_zombie_register_2(g_Ninja, zclass_desc2, 30, 0)
}
public zp_fw_money_items_select_pre(id, itemid)
{
	if( itemid != g_ItemID )
		return ZP_ITEM_AVAILABLE;

	if( Get_BitVar(p_ninja, id) )
		return ZP_ITEM_DONT_SHOW;

	return ZP_ITEM_AVAILABLE
}
public zp_fw_ap_items_select_post(id, itemid) {
	if( itemid != g_ItemID ) return;

	Set_BitVar(p_ninja, id);

}

public client_putinserver(id) {
	UnSet_BitVar(p_ninja, id);
}
public zp_fw_class_zombie_select_pre(id, classid) {
	if( classid != g_Ninja ) return ZP_CLASS_AVAILABLE;

	if( !Get_BitVar(p_ninja, id) )
		return ZP_CLASS_NOT_AVAILABLE;

	return ZP_CLASS_AVAILABLE;

}
public zp_fw_zombie_skill1_active(id, classid) {

	if( classid != g_Ninja ) return ZP_CLASS_SKILL_ACTIVE;

	if(pev(id, pev_maxspeed) < 2.0) return ZP_CLASS_SKILL_CANT_ACTIVE;

	ScreenFade(id, 2.0, 255, 253, 111, 40);
	leap(id);

	return ZP_CLASS_SKILL_ACTIVE;
}

public zp_fw_zombie_skill2_active(id, classid) {

	if( classid != g_Ninja ) return ZP_CLASS_SKILL_ACTIVE;

	new target , iBodyPart;
	get_user_aiming( id , target , iBodyPart );

	if ( !is_user_alive( target )) return ZP_CLASS_SKILL_CANT_ACTIVE;

	if( zp_core_is_zombie(target) ) return ZP_CLASS_SKILL_CANT_ACTIVE;

	//if( zp_class_sniper_get(target) || zp_class_survivor_get(target) ) return ZP_CLASS_SKILL_CANT_ACTIVE;

	ScreenFade(target, 5.0, 255, 255, 255, 255);

	ScreenFade(id, 2.0, 116, 184, 138, 40);

	twist(target, 90.0);

	return ZP_CLASS_SKILL_ACTIVE;
}

public leap(id) {

	new Float:fVelocity[3]
	velocity_by_aim(id, 6000, fVelocity) // phía trước
	fVelocity[2] = 300.0                // phía trên
	set_pev(id, pev_velocity, fVelocity)
}

public twist(id, Float:dmg)
{

	new Float:val = dmg * 0.5
	new Float:maxdeg = (val * 0.6)
	new Float:mindeg = (val * 0.35)

	new Float:pLook[3]
	for (new i = 0; i <= 2; i++)
	{
		if (random_num(0,1) == 1)
			pLook[i] = random_float(mindeg,maxdeg)
		else
			pLook[i] = random_float(mindeg,maxdeg) * -1
	}

	set_pev(id, pev_punchangle, pLook)
	set_pev(id, pev_fixangle, 1 )

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
