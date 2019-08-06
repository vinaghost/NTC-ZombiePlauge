#include <amxmodx>
#include <colorchat>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <cs_maxspeed_api>
#include <zp50_core>
#include <zp50_class_nemesis>
#include <zp50_class_survivor>

new g_bitAlivePlayers, g_bitUserAllowed
#define MarkUserAlive(%0)   	g_bitAlivePlayers |= (1 << (%0 & 31))
#define ClearUserAlive(%0)  	g_bitAlivePlayers &= ~(1 << (%0 & 31))
#define IsUserAlive(%0)		g_bitAlivePlayers & (1 << (%0 & 31))

#define MarkUserAllow(%0)   	g_bitUserAllowed |= (1 << (%0 & 31))
#define ClearUserAllow(%0)  	g_bitUserAllowed &= ~(1 << (%0 & 31))
#define IsUserAllow(%0)		g_bitUserAllowed & (1 << (%0 & 31))

#define PLUGIN "[ZP] Class: Smoker"
#define VERSION "1.2"
#define AUTHOR "Lambda"

#define TASK_REMOVE_SPEED 1322

new g_zclass_smoker, g_Line, stunTime, breakDamage

new g_sndMiss[] = "zombie_plague/eqtonguemiss.wav"
new g_sndDrag[] = "zombie_plague/eqtonguehit.wav"

new g_hooked[33], g_ovr_dmg[33]
new Float:g_lastHook[33]

new const zclass_name[] = { "Smoker" }
new const zclass_info[] = { "Keo human" }
new const zclass_model[][] = { "eqsmoker" }
new const zclass_clawmodel[][] = { "models/zombie_plague/v_smoker_hands.mdl" }
const zclass_health = 2300
const Float:zclass_speed = 270.0
const Float:zclass_gravity = 0.75
const Float:zclass_knockback = 1.0


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_Spawn, "player", "fwd_Ham_Spawn_post", 1);
	register_event("DeathMsg", "smoker_death", "a")
	register_forward(FM_CmdStart, "fwd_CmdStart")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	stunTime = register_cvar("zp_smoker_stun", "2.0")
	breakDamage = register_cvar("zp_smoker_break", "100")
}

public plugin_precache()
{
	g_zclass_smoker = zp_class_zombie_register(zclass_name, zclass_info, zclass_health, zclass_speed, zclass_gravity)

	new index
	zp_class_zombie_register_kb(g_zclass_smoker, zclass_knockback)
	for (index = 0; index < sizeof zclass_model; index++)
		zp_class_zombie_register_model(g_zclass_smoker, zclass_model[index])
	for (index = 0; index < sizeof zclass_clawmodel; index++)
		zp_class_zombie_register_claw(g_zclass_smoker, zclass_clawmodel[index])

	precache_sound(g_sndDrag)
	precache_sound(g_sndMiss)
	g_Line = precache_model("sprites/zbeam4.spr")
}

public zp_fw_core_spawn_post(id)
{
	if(is_user_alive(id))
		MarkUserAlive(id)
}

public client_putinserver(id)
{
	ClearUserAlive(id)
	ClearUserAllow(id)
}

public client_disconnect(id)
{
	ClearUserAlive(id)

	if (g_hooked[id])
		drag_end(id)
}

public fw_ClientDisconnect_Post(id)
	ClearUserAllow(id)

public smoker_death()
{
	new id = read_data(2)
	
	ClearUserAlive(id)
	beam_remove(id)

	if (g_hooked[id])
		drag_end(id)
}

public zp_fw_core_cure_post(id)
	ClearUserAllow(id)

public zp_fw_core_infect_post(id)
{
	if(zp_class_zombie_get_current(id) != g_zclass_smoker || zp_class_nemesis_get(id))
		ClearUserAllow(id)
	else
	{
		MarkUserAllow(id)
		g_lastHook[id] = 0.0
	}
}

public fwd_CmdStart(id, handle)
{
	if (~IsUserAlive(id) || ~IsUserAllow(id))
		return
	
	static button, oldbutton
	button = get_user_button(id)
	oldbutton = get_user_oldbutton(id)

	if (!(oldbutton & IN_RELOAD) && (button & IN_RELOAD))
		drag_start(id)
	
	if ((oldbutton & IN_RELOAD) && !(button & IN_RELOAD))
		drag_end(id)
}

public fwd_Ham_Spawn_post(id)
{
    if (IsUserAlive(id))
	{
		if (g_hooked[id])
			drag_end(id)
	}

    return HAM_IGNORED;
}

public drag_start(id) 
{
	if (~IsUserAllow(id))
		return

	static Float:cdown
	cdown = 50.0

	if (get_gametime() - g_lastHook[id] < cdown)
	{
		ColorChat(id, GREEN, "^1[^4NTC^1] You must wait ^4%.f0^1s", cdown - (get_gametime() - g_lastHook[id]))
		return
	}
	else
	{
		g_lastHook[id] = get_gametime()
		new hooktarget, body
		get_user_aiming(id, hooktarget, body)

		if (IsUserAlive(hooktarget)) 
		{
			if (!zp_core_is_zombie(hooktarget))
			{
				if (zp_class_survivor_get(hooktarget)) 
				{
					return
				}

				g_hooked[id] = hooktarget
				emit_sound(hooktarget, CHAN_BODY, g_sndDrag, 1.0, ATTN_NORM, 0, PITCH_HIGH)
			}
			else
			{
				return
			}

			new parm[2]
			parm[0] = id
			parm[1] = hooktarget
			
			cs_set_player_maxspeed_auto(id, 0.01)
			cs_set_player_maxspeed_auto(hooktarget, 0.01)

			set_task(0.1, "smoker_reelin", id, parm, 2, "b")
			if(get_pcvar_float(stunTime) > 0.0)
				set_task(get_pcvar_float(stunTime), "RemoveSpeed", hooktarget+TASK_REMOVE_SPEED)
			harpoon_target(parm)

			g_ovr_dmg[id] = 0
		}
		else 
		{
			g_hooked[id] = 33
			noTarget(id)
			emit_sound(hooktarget, CHAN_BODY, g_sndMiss, 1.0, ATTN_NORM, 0, PITCH_HIGH)
		}
	}
}

public RemoveSpeed(hooktarget)
{
	hooktarget -= TASK_REMOVE_SPEED
	
	if (IsUserAlive(hooktarget))
		cs_set_player_maxspeed_auto(hooktarget, 1.0)
}

public smoker_reelin(parm[])
{
	new id = parm[0]
	new victim = parm[1]

	if (!g_hooked[id] || ~IsUserAlive(victim))
	{
		drag_end(id)
		return
	}

	new Float:fl_Velocity[3]
	new idOrigin[3], vicOrigin[3]

	get_user_origin(victim, vicOrigin)
	get_user_origin(id, idOrigin)

	new distance = get_distance(idOrigin, vicOrigin)

	if (distance > 5)
	{
		new Float:fl_Time = distance / 180.0

		fl_Velocity[0] = (idOrigin[0] - vicOrigin[0]) / fl_Time
		fl_Velocity[1] = (idOrigin[1] - vicOrigin[1]) / fl_Time
		fl_Velocity[2] = (idOrigin[2] - vicOrigin[2]) / fl_Time
	}
	else
	{
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
		drag_end(id)
	}

	entity_set_vector(victim, EV_VEC_velocity, fl_Velocity)
}

public drag_end(id)
{
	g_hooked[id] = 0
	
	beam_remove(id)
	
	cs_set_player_maxspeed_auto(id, 1.0)
	
	remove_task(id)
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (~IsUserAlive(attacker) || ~IsUserAllow(victim))
		return HAM_IGNORED

	g_ovr_dmg[victim] += floatround(damage)

	if (g_ovr_dmg[victim] >= get_pcvar_num(breakDamage))
	{
		g_ovr_dmg[victim] = 0
		drag_end(victim)
	}

	return HAM_IGNORED
}

public harpoon_target(parm[])
{
	new id = parm[0]
	new hooktarget = parm[1]

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(8)		// TE_BEAMENTS
	write_short(id)
	write_short(hooktarget)
	write_short(g_Line)	// sprite index
	write_byte(0)		// start frame
	write_byte(0)		// framerate
	write_byte(200)		// life
	write_byte(8)		// width
	write_byte(1)		// noise
	write_byte(155)		// r
	write_byte(155)		// g
	write_byte(55)		// b
	write_byte(90)		// brightness
	write_byte(10)		// speed
	message_end()
}

public noTarget(id)
{
	new endorigin[3]
	get_user_origin(id, endorigin, 3)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte( TE_BEAMENTPOINT ); 	// TE_BEAMENTPOINT
	write_short(id)
	write_coord(endorigin[0])
	write_coord(endorigin[1])
	write_coord(endorigin[2])
	write_short(g_Line) 		// sprite index
	write_byte(0)			// start frame
	write_byte(0)			// framerate
	write_byte(200)			// life
	write_byte(8)			// width
	write_byte(1)			// noise
	write_byte(155)			// r
	write_byte(155)			// g
	write_byte(55)			// b
	write_byte(75)			// brightness
	write_byte(0)			// speed
	message_end()
}

public beam_remove(id)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)			//TE_KILLBEAM
	write_short(id)			//entity
	message_end()
}
