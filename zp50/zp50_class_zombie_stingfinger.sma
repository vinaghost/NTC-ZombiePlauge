#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>

#include <zp50_class_zombie>



#define PLUGIN "[ZP] Class: Sting Finger"
#define VERSION "1.0"
#define AUTHOR "Dias"


// Zombie Configs
new zclass_name[24] = "Sting Finger"
new zclass_desc[32] = "Gomu gomu no pistol + Heal"
new zclass_desc1[32] = "Gomu gomu no pistol"
new zclass_desc2[32] = "Heal"
new const zclass_model[] = "StingFinger"
new const zclass_clawsmodel[] = "models/zombie_plague/v_knife_stingFinger.mdl"

new const zclass_health = 1500;
new const Float:zclass_gravity = 0.84;
new const Float:zclass_speed = 1.1;
new const Float:zclass_knockback = 1.3;

#define PENETRATE_SOUND "zombie_plague/zombie/skill/StingFinger_skill1.wav"
#define HEAL_SOUND "zombie_plague/zombie/StingFinger_heal.wav"

// Penetrate
#define PENETRATE_ANIM 8
#define PENETRATE_PLAYERANIM 91

#define PENETRATE_COOLDOWN 30.0
#define PENETRATE_DISTANCE 140.0

//Heal

#define HEAL_ANIM 10
#define HEAL_PLAYERANIM 98

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_StingFinger
new g_TempingAttack
new g_MaxPlayers
new msg_ScreenFade 
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_TraceLine, "fw_TraceLine")
	register_forward(FM_TraceHull, "fw_TraceHull")		
	register_forward(FM_EmitSound, "fw_EmitSound")	
	
	g_MaxPlayers = get_maxplayers()
	msg_ScreenFade = get_user_msgid( "ScreenFade")
	
}

public plugin_precache()
{	
	// Register Zombie Class
	g_StingFinger = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed ,zclass_gravity)
	
	zp_class_zombie_register_kb(g_StingFinger, zclass_knockback);
	zp_class_zombie_register_model(g_StingFinger, zclass_model)
	zp_class_zombie_register_claw(g_StingFinger, zclass_clawsmodel)
	
	zp_class_zombie_register_1(g_StingFinger, zclass_desc1, 20)
	zp_class_zombie_register_2(g_StingFinger, zclass_desc2, 10)
	
	// Precache Sound
	engfunc(EngFunc_PrecacheSound, PENETRATE_SOUND)
	engfunc(EngFunc_PrecacheSound, HEAL_SOUND)
}


public zp_fw_class_zombie_select_post(id, ClassID)
{
	if(ClassID != g_StingFinger)
		return	
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	if(Get_BitVar(g_TempingAttack, id))
	{
		if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
		{
			if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a')
				return FMRES_SUPERCEDE
			if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
			{
				if(sample[17] == 'w') return FMRES_SUPERCEDE
				else return FMRES_SUPERCEDE
			}
			if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
				return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_HANDLED
}

public fw_TraceLine(Float:vector_start[3], Float:vector_end[3], ignored_monster, id, handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(!zp_core_is_zombie(id))
		return FMRES_IGNORED
	if(!Get_BitVar(g_TempingAttack, id))
		return FMRES_IGNORED
	
	static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]
	
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(fOrigin, view_ofs, vecStart)
	pev(id, pev_v_angle, v_angle)
	
	engfunc(EngFunc_MakeVectors, v_angle)
	get_global_vector(GL_v_forward, v_forward)
	
	xs_vec_mul_scalar(v_forward, 0.0, v_forward)
	xs_vec_add(vecStart, v_forward, vecEnd)
	
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, ignored_monster, id, handle)
	
	return FMRES_SUPERCEDE
}

public fw_TraceHull(Float:vector_start[3], Float:vector_end[3], ignored_monster, hull, id, handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(!zp_core_is_zombie(id))
		return FMRES_IGNORED
	if(!Get_BitVar(g_TempingAttack, id))
		return FMRES_IGNORED
	
	static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]
	
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(fOrigin, view_ofs, vecStart)
	pev(id, pev_v_angle, v_angle)
	
	engfunc(EngFunc_MakeVectors, v_angle)
	get_global_vector(GL_v_forward, v_forward)
	
	xs_vec_mul_scalar(v_forward, 0.0, v_forward)
	xs_vec_add(vecStart, v_forward, vecEnd)
	
	engfunc(EngFunc_TraceHull, vecStart, vecEnd, ignored_monster, hull, id, handle)
	
	return FMRES_SUPERCEDE
}

public zp_fw_zombie_skill1_active(id , classid) {
	if( classid != g_StingFinger ) return;
	
	Do_Penetrate(id)
}
public zp_fw_zombie_skill2_active(id , classid) {
	if( classid != g_StingFinger ) return;
	
	Do_Heal(id)
}

public Do_Heal(id)
{	
	set_weapons_timeidle(id, 1.5)
	set_player_nextattack(id, 1.5)
	
	set_weapon_anim(id, HEAL_ANIM)
	set_pev(id, pev_sequence, HEAL_PLAYERANIM)
	EmitSound(id, CHAN_ITEM, HEAL_SOUND)
	
	ScreenFade(id, 1.5, 0, 255, 0, 40)
	new newHealth = get_user_health(id) + 500;
	
	if( newHealth > zclass_health )
		set_user_health(id, newHealth)
	else
		set_user_health(id, get_user_health(id) + 500)
}

public Do_Penetrate(id)
{
	Do_FakeAttack(id)
	
	set_weapons_timeidle(id, 1.5)
	set_player_nextattack(id, 1.5)
	
	set_weapon_anim(id, PENETRATE_ANIM)
	set_pev(id, pev_sequence, PENETRATE_PLAYERANIM)
	EmitSound(id, CHAN_ITEM, PENETRATE_SOUND)
	
	// Check Penetrate
	Penetrating(id)
}

public Penetrating(id)
{
	#define MAX_POINT 4
	static Float:Max_Distance, Float:Point[MAX_POINT][3], Float:TB_Distance
	
	Max_Distance = PENETRATE_DISTANCE
	TB_Distance = Max_Distance / float(MAX_POINT)
	
	static Float:VicOrigin[3], Float:MyOrigin[3]
	pev(id, pev_origin, MyOrigin)
	
	for(new i = 0; i < MAX_POINT; i++) get_position(id, TB_Distance * (i + 1), 0.0, 0.0, Point[i])
	for(new i = 0; i < g_MaxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue
		if(zp_core_is_zombie(i))
			continue
		if(entity_range(id, i) > Max_Distance)
			continue
		
		pev(i, pev_origin, VicOrigin)
		if(is_wall_between_points(MyOrigin, VicOrigin, id))
			continue
		
		if(get_distance_f(VicOrigin, Point[0]) <= 32.0 
		|| get_distance_f(VicOrigin, Point[1]) <= 32.0
		|| get_distance_f(VicOrigin, Point[2]) <= 32.0
		|| get_distance_f(VicOrigin, Point[3]) <= 32.0) 	{
			ExecuteHamB(Ham_TakeDamage, i, fm_get_user_weapon_entity(id, CSW_KNIFE), id, 125.0, DMG_SLASH)
		}
		
	}	
}



public Do_FakeAttack(id)
{
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
	if(!pev_valid(Ent)) return
	
	Set_BitVar(g_TempingAttack, id)
	ExecuteHamB(Ham_Weapon_PrimaryAttack, Ent)	
	UnSet_BitVar(g_TempingAttack, id)
}

stock is_wall_between_points(Float:start[3], Float:end[3], ignore_ent)
{
	static ptr
	ptr = create_tr2()
	
	engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ignore_ent, ptr)
	
	static Float:EndPos[3]
	get_tr2(ptr, TR_vecEndPos, EndPos)
	
	return floatround(get_distance_f(end, EndPos))
} 

stock EmitSound(id, chan, const file_sound[])
{
	if(!is_user_connected(id))
		return
	
	emit_sound(id, chan, file_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

stock set_weapon_anim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(anim)
	write_byte(0)
	message_end()	
}

stock set_weapons_timeidle(id, Float:TimeIdle)
{
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
	if(pev_valid(Ent)) set_pdata_float(Ent, 48, TimeIdle, 4)
}

stock set_player_nextattack(id, Float:nexttime)
{
	set_pdata_float(id, 83, nexttime, 5)
}

stock get_position(id, Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
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
