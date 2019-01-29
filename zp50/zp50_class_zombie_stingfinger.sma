#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>

#include <zp50_colorchat>
#include <zp50_class_zombie>

#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>

#define PLUGIN "[ZP] Class: Sting Finger"
#define VERSION "1.0"
#define AUTHOR "Dias"


// Zombie Configs
new zclass_name[24] = "Sting Finger"
new zclass_desc[32] = "Gomu gomu no pistol"
new zclass_desc1[32] = "Gomu gomu no pistol"
new const zclass_model[] = "StingFinger"
new const zclass_clawsmodel[] = "models/zombie_plague/v_knife_stingFinger.mdl"

new const zclass_health = 1500;
new const Float:zclass_gravity = 0.84;
new const Float:zclass_speed = 1.1;
new const Float:zclass_knockback = 1.3;
new const DeathSound[] = "zombie_plague/zombie/resident_death.wav"
new const HurtSound[2][] = 
{
	"zombie_plague/zombie/resident_hurt1.wav",
	"zombie_plague/zombie/resident_hurt2.wav"
}
new const HealSound[] = "zombie_plague/StingFinger_heal.wav"
new const EvolSound[] = "zombie_plague/zombie/StingFinger_evolution.wav"

#define PENETRATE_SOUND "zombie_plague/zombie/skill/StingFinger_skill1.wav"
#define HEAVENLYJUMP_SOUND "zombie_plague/zombie/skill/StingFinger_skill2.wav"

// Penetrate
#define PENETRATE_ANIM 8
#define PENETRATE_PLAYERANIM 91

#define PENETRATE_COOLDOWN 30.0
#define PENETRATE_DISTANCE 140.0


#define SHOWSKILL 83
#define TASKID 84

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_StingFinger
new g_CanPenetrate, g_CanHeal, g_TempingAttack
new g_Msg_Fov, g_MaxPlayers, g_synchud1, g_synchud2

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_TraceLine, "fw_TraceLine")
	register_forward(FM_TraceHull, "fw_TraceHull")		
	register_forward(FM_EmitSound, "fw_EmitSound")	
	
	register_clcmd("drop", "active_drop")
	
	g_MaxPlayers = get_maxplayers()
	
	g_synchud1 = CreateHudSyncObj()
	g_synchud2 = CreateHudSyncObj()
	
	
}

public plugin_precache()
{	
	// Register Zombie Class
	g_StingFinger = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed ,zclass_gravity)
	
	zp_class_zombie_register_kb(g_StingFinger, zclass_knockback);
	zp_class_zombie_register_model(g_StingFinger, zclass_model)
	zp_class_zombie_register_claw(g_StingFinger, zclass_clawsmodel)
	
	
	// Precache Sound
	engfunc(EngFunc_PrecacheSound, PENETRATE_SOUND)
	engfunc(EngFunc_PrecacheSound, HEAVENLYJUMP_SOUND)
}

public client_connect(id) {
	set_task(1.0, "skill_show", id + SHOWSKILL);
}
public zp_fw_core_infect_post(id, attacker) 
{
	if( zp_core_is_zombie(id) ) return;
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(id)) return;
	if(zp_class_zombie_get_current(id) != g_StingFinger)
		return;
			
	Set_BitVar(g_CanPenetrate, id)
	UnSet_BitVar(g_TempingAttack, id)
	
}
public zp_fw_core_cure_post(id) {
	
	if( zp_core_is_zombie(id) ) return;
	if(zp_class_zombie_get_current(id) != g_StingFinger)
		return;
		
	reset_skill(id)
}
public zp_fw_core_spawn_post(id) {
	
	if( zp_core_is_zombie(id) ) return;
	if(zp_class_zombie_get_current(id) != g_StingFinger)
	{
		reset_skill(id)
		return;
	}
		
	Set_BitVar(g_CanPenetrate, id)
	UnSet_BitVar(g_TempingAttack, id)
}
public zp_fw_class_zombie_select_post(id, ClassID)
{
	if(ClassID != g_StingFinger)
		return	

	zp_colored_print(id, "Da chon ^x04Zombie Sting Finger")
}

public reset_skill(id)
{
	UnSet_BitVar(g_CanPenetrate, id)	
}

public active_drop(id/*, ClassID*/)
{
	/*if(ClassID != g_ZombieClass_Resident)
		return*/
	if(!Get_BitVar(g_CanPenetrate, id))
		return
		
	Do_Penetrate(id)
}

public skill_show(id)
{
	id -= SHOWSKILL;
	if(zp_class_zombie_get_current(id) != g_StingFinger)
		return 	
		
	Show_SkillPenetrate(id)
}

/*public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !zbheroex_get_user_zombie(id))
		return
	if(zbheroex_get_user_zombie_class(id) != g_ZombieClass_Resident)
		return
		
	static CurButton, OldButton
	
	CurButton = get_uc(uc_handle, UC_Buttons)
	OldButton = pev(id, pev_oldbuttons)
	
	if((CurButton & IN_RELOAD) && !(OldButton & IN_RELOAD))
		Skill2_Handle(id)
}*/

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

public Show_SkillPenetrate(id)
{
	
	if(!Get_BitVar(g_CanPenetrate, id) )
	{
		set_hudmessage(255, 0, 0, -1.0, 0.10, 0, 1.5, 1.5)
		ShowSyncHudMsg(id, g_synchud1, "[G] %s", zclass_desc1)
		
	} 
	/*else if(percent2 >= 50 && percent < 100) {
		
		set_hudmessage(255, 255, 0, -1.0, 0.10, 0, 1.5, 1.5)
		ShowSyncHudMsg(id, g_synchud1, "[G] %s", zclass_desc1)
		
	} */
	else 
	{
		
		set_hudmessage(0, 255, 0, -1.0, 0.10, 0, 1.5, 1.5)
		ShowSyncHudMsg(id, g_synchud1, "[G] %s", zclass_desc1)
		
	}	
	
}

public Do_Penetrate(id)
{
	UnSet_BitVar(g_CanPenetrate, id)

	Do_FakeAttack(id)
	
	set_weapons_timeidle(id, 1.5)
	set_player_nextattack(id, 1.5)

	set_weapon_anim(id, PENETRATE_ANIM)
	set_pev(id, pev_sequence, PENETRATE_PLAYERANIM)
	EmitSound(id, CHAN_ITEM, PENETRATE_SOUND)
	
	set_task(PENETRATE_COOLDOWN, "Cooldown_off_1", id + TASKID)
	
	// Check Penetrate
	Penetrating(id)
}

public Cooldown_off_1(id) {
	id -= TASKID;
	
	Set_BitVar(g_CanPenetrate, id)
	
	zp_colored_print(id, "%s da hoi phuc", zclass_desc1)
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
		|| get_distance_f(VicOrigin, Point[3]) <= 32.0)
		{
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
