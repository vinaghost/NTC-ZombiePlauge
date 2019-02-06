#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <zp50_class_zombie>

#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>

#include <cs_maxspeed_api>

#define PLUGIN "[ZP] Class: Banshee"
#define VERSION "1.0"
#define AUTHOR "Dias"


#define PULLING_COOLDOWN_ORIGIN 20

#define TASK_DELAY_ANIM 2312321

// Zombie Configs
new zclass_name[24] = "Banshee"
new zclass_desc[24] = "Pulling & Chaos"
new zclass_desc1[24] = "Pulling"
new const zclass_model[] = "Banshee"
new const zclass_clawsmodel[] = "zombie_plauge/zombie/v_knife_Banshee"
new const Float:zclass_gravity = 0.80
new const Float:zclass_speed = 280.0
new const Float:zclass_knockback = 1.5
new const zclass_health = 1200

new const Target_Sound[] = "zombie_plauge/human_surprise.wav"

// Bat
#define BAT_CREATETIME 1.0

#define PULLING_CLAWANIM 1
#define PULLING_CLAWANIM_LOOP 2
#define PULLING_PLAYERANIM 151
#define PULLING_PLAYERANIM_LOOP 152

#define BAT_CLASSNAME "bat"
#define BAT_MODEL "models/zombie_plauge/bat_witch.mdl"
#define BAT_FLYSOUND "zombie_plauge/zombie/banshee_pulling_fire.wav"
#define BAT_PULLINGSOUND "zombie_plauge/zombie/zombi_banshee_laugh.wav"
#define BAT_EXPSOUND "zombie_plauge/zombie/skill/bat_exp.wav"
#define BAT_EXPSPR "sprites/zombie_plauge/ef_bat.spr"

#define BAT_SPEED 600
#define BAT_MAXDISTANCE 700
#define BAT_LIVETIME 15

// HardCore
const pev_state = pev_iuser1
const pev_user = pev_iuser2
const pev_livetime = pev_fuser1
const pev_maxdistance = pev_fuser2
const pev_hittime = pev_fuser3

enum
{
	BAT_STATE_NONE = 0,
	BAT_STATE_TARGETING,
	BAT_STATE_RETURNING
}

new g_BatExp_SprId

// Main Var
new g_Zombie_Banshee
new g_TempingAttack, g_Pulling
new g_Msg_Shake

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")  
	
	register_think(BAT_CLASSNAME, "fw_Bat_Think")
	register_touch(BAT_CLASSNAME, "*", "fw_Bat_Touch")
	
	register_forward(FM_TraceLine, "fw_TraceLine")
	register_forward(FM_TraceHull, "fw_TraceHull")		
	register_forward(FM_EmitSound, "fw_EmitSound")
	
	g_Msg_Shake = get_user_msgid("ScreenShake")
}

public plugin_precache()
{
	
	g_Zombie_Banshee = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed, zclass_gravity)
	zp_class_zombie_register_kb(g_Zombie_Banshee, zclass_knockback)
	zp_class_zombie_register_model(g_Zombie_Banshee, zclass_model)
	zp_class_zombie_register_claw(g_Zombie_Banshee, zclass_clawsmodel)
	zp_class_zombie_register_1(g_Zombie_Banshee, zclass_desc1, 30)
	
	engfunc(EngFunc_PrecacheModel, BAT_MODEL)
	engfunc(EngFunc_PrecacheSound, BAT_EXPSOUND)
	engfunc(EngFunc_PrecacheSound, BAT_FLYSOUND)
	engfunc(EngFunc_PrecacheSound, BAT_PULLINGSOUND)
	
	engfunc(EngFunc_PrecacheSound, Target_Sound)
	
	g_BatExp_SprId = engfunc(EngFunc_PrecacheModel, BAT_EXPSPR)
}
public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}

public module_filter(const module[])
{
	if (equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id) {
	if(Get_BitVar(g_Pulling, id))
		UnSet_BitVar(g_Pulling, id)
}

public zp_fw_zombie_skill1_active(id)
{
	if(Get_BitVar(g_Pulling, id))
		return
	if(!(pev(id, pev_flags) & FL_ONGROUND))
	{
		return
	}
	if(pev(id, pev_flags) & FL_DUCKING)
	{
		return
	}
		
	Do_Pulling(id)
}

public Do_Pulling(id)
{
	Set_BitVar(g_Pulling, id)

	Do_FakeAttack(id)
	
	set_weapons_timeidle(id, 9999.0)
	set_player_nextattack(id, 9999.0)

	set_weapon_anim(id, PULLING_CLAWANIM)
	set_pev(id, pev_framerate, 0.35)
	set_pev(id, pev_sequence, PULLING_PLAYERANIM)
	
	cs_set_player_maxspeed(id, 1.0)

	emit_sound(id, CHAN_ITEM, BAT_PULLINGSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Start Stamping
	set_task(BAT_CREATETIME, "Create_Bat", id)
}

public Do_FakeAttack(id)
{
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_KNIFE)
	if(!pev_valid(Ent)) return
	
	Set_BitVar(g_TempingAttack, id)
	ExecuteHamB(Ham_Weapon_PrimaryAttack, Ent)	
	UnSet_BitVar(g_TempingAttack, id)
}

public Create_Bat(id)
{
	if(!is_user_alive(id))
		return
	if(!zp_core_is_zombie(id))
		return
	
	Do_FakeAttack(id)
	
	set_weapons_timeidle(id, 9999.0)
	set_player_nextattack(id, 9999.0)
	
	set_weapon_anim(id, PULLING_CLAWANIM_LOOP)
	
	set_pev(id, pev_framerate, 0.5)
	set_pev(id, pev_sequence, PULLING_PLAYERANIM_LOOP)
	
	set_task(1.0, "Delay_Anim", id+TASK_DELAY_ANIM)
	
	static Bat; Bat = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Bat)) return
	
	// Origin & Angles
	static Float:Origin[3]; get_position(id, 40.0, 0.0, 0.0, Origin)
	static Float:Angles[3]; pev(id, pev_v_angle, Angles)
	
	set_pev(Bat, pev_origin, Origin)
	set_pev(Bat, pev_angles, Angles)
	
	// Set Bat Data
	set_pev(Bat, pev_takedamage, DAMAGE_NO)
	set_pev(Bat, pev_health, 1000.0)
	
	set_pev(Bat, pev_classname, BAT_CLASSNAME)
	engfunc(EngFunc_SetModel, Bat, BAT_MODEL)
	
	set_pev(Bat, pev_movetype, MOVETYPE_FLY)
	set_pev(Bat, pev_solid, SOLID_BBOX)
	set_pev(Bat, pev_gamestate, 1)
	
	static Float:mins[3]; mins[0] = -5.0; mins[1] = -5.0; mins[2] = -5.0
	static Float:maxs[3]; maxs[0] = 5.0; maxs[1] = 5.0; maxs[2] = 5.0
	engfunc(EngFunc_SetSize, Bat, mins, maxs)
	
	// Set State
	set_pev(Bat, pev_state, BAT_STATE_TARGETING)
	set_pev(Bat, pev_user, id)
	set_pev(Bat, pev_maxdistance, float(BAT_MAXDISTANCE))
	set_pev(Bat, pev_livetime, get_gametime() + (float(BAT_LIVETIME)))
	
	// Anim
	Set_Entity_Anim(Bat, 0)
	
	// Set Next Think
	set_pev(Bat, pev_nextthink, get_gametime() + 0.1)
	
	// Set Speed
	static Float:TargetOrigin[3], Float:Velocity[3]
	get_position(id, 4000.0, 0.0, 0.0, TargetOrigin)
	get_speed_vector(Origin, TargetOrigin, float(BAT_SPEED), Velocity)
	
	emit_sound(id, CHAN_BODY, BAT_FLYSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	set_pev(Bat, pev_velocity, Velocity)
}

public Delay_Anim(id)
{
	id -= TASK_DELAY_ANIM
	
	if(!is_user_alive(id))
		return
	if(!zp_core_is_zombie(id))
		return
	if(!Get_BitVar(g_Pulling, id))
		return
		
	Do_FakeAttack(id)
	
	set_weapons_timeidle(id, 9999.0)
	set_player_nextattack(id, 9999.0)
	
	set_weapon_anim(id, PULLING_CLAWANIM_LOOP)
	
	set_pev(id, pev_framerate, 0.5)
	set_pev(id, pev_sequence, PULLING_PLAYERANIM_LOOP)
	
	set_task(1.0, "Delay_Anim", id+TASK_DELAY_ANIM)
}

public fw_Bat_Think(Ent)
{
	if(!pev_valid(Ent))
		return
		
	static Owner; Owner = pev(Ent, pev_user)
	if(!is_user_alive(Owner) ||  !zp_core_is_zombie(Owner))
	{
		Bat_Explosion(Ent)
		return
	}
	if(entity_range(Owner, Ent) > pev(Ent, pev_maxdistance))
	{
		Bat_Explosion(Ent)
		return
	}
	if(pev(Ent, pev_livetime) <= get_gametime())
	{
		Bat_Explosion(Ent)
		return
	}
	if(pev(Ent, pev_state) == BAT_STATE_RETURNING)
	{
		static Victim; Victim = pev(Ent, pev_enemy)
		if(!is_user_alive(Victim))
		{
			Bat_Explosion(Ent)
			return
		}
		if(entity_range(Owner, Victim) <= 48.0)
		{
			Bat_Explosion(Ent)
			return
		}
		
		static Float:Origin[3]
		pev(Owner, pev_origin, Origin)
		
		HookEnt(Victim, Origin, float(BAT_SPEED) / 3.0, 1.0, 1)
	}
	
	set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
}

public fw_Bat_Touch(Ent, Id)
{
	if(!pev_valid(Ent))
		return
		
	static Owner; Owner = pev(Ent, pev_user)
	if(!is_user_alive(Owner) ||  !zp_core_is_zombie(Owner))
	{
		Bat_Explosion(Ent)
		return
	}	
	if(is_user_alive(Id) && Owner != Id) // We got a player
	{
		Capture_Victim(Ent, Id)
	} else {
		Bat_Explosion(Ent)
	}
}

public Capture_Victim(Ent, Id)
{
	static Owner; Owner = pev(Ent, pev_user)
	if(!is_user_alive(Owner) || !zp_core_is_zombie(Owner))
	{
		Bat_Explosion(Ent)
		return
	}
	
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(Id) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(Id))
	{
		Bat_Explosion(Ent)
		return
	}
	
	if(!zp_core_is_zombie(Id))
	{
		emit_sound(Id, CHAN_ITEM, Target_Sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	set_pev(Ent, pev_state, BAT_STATE_RETURNING)
	set_pev(Ent, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(Ent, pev_solid, SOLID_NOT)
	
	set_pev(Ent, pev_enemy, Id)
	set_pev(Ent, pev_aiment, Id)
}

public Bat_Explosion(Ent)
{
	static Float:Origin[3]
	pev(Ent, pev_origin, Origin)
	
	// Exp Spr
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_BatExp_SprId)
	write_byte(20)
	write_byte(30)
	write_byte(14)
	message_end()	
	
	// Reset Owner
	Reset_Owner(Ent)
	
	// Sound
	emit_sound(Ent, CHAN_BODY, BAT_EXPSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Remove
	if(pev_valid(Ent)) engfunc(EngFunc_RemoveEntity, Ent)
}

public Reset_Owner(Ent)
{
	static Id; Id = pev(Ent, pev_user)
	if(!is_user_alive(Id) || !zp_core_is_zombie(Id))
		return
		
	UnSet_BitVar(g_Pulling, Id)
		
	set_weapons_timeidle(Id, 0.75)
	set_player_nextattack(Id, 0.75)
	set_weapon_anim(Id, 3)
	
	set_pev(Id, pev_framerate, 1.0)
	
	cs_set_player_maxspeed(Id, zclass_speed)
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

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock Set_Entity_Anim(Ent, Anim)
{
	set_pev(Ent, pev_animtime, get_gametime())
	set_pev(Ent, pev_sequence, Anim)
	set_pev(Ent, pev_framerate, 1.0)
	set_pev(Ent, pev_frame, 0.0)
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

stock PlaySound(id, const sound[])
{
	if(equal(sound[strlen(sound)-4], ".mp3")) client_cmd(id, "mp3 play ^"sound/%s^"", sound)
	else client_cmd(id, "spk ^"%s^"", sound)
}

public ScreenShake(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_Msg_Shake, _, id)
	write_short(255<<14)
	write_short(10<<14)
	write_short(255<<14)
	message_end()
}