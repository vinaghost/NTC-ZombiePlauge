#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>

new const paramodel[] = "models/parachutes.mdl"

new bool:has_parachute[33], para_ent[33];

enum pcvar
{
	fallspeed,
	detach
}

new pcvars[pcvar]

public plugin_init()
{
	register_plugin("[ZP] Sub-Plugin: Parachute", "1.1", "Random1, 93()|29!/<")
	pcvars[fallspeed] =	register_cvar("zp_parachute_fallspeed", "75")
	pcvars[detach] =	register_cvar("zp_parachute_detach", "1")
	
	register_forward(FM_PlayerPreThink, "fw_PreThink")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
}

public plugin_precache()
	engfunc(EngFunc_PrecacheModel, paramodel)

public client_connect(id)
	parachute_reset(id)

public client_disconnect(id)
	parachute_reset(id)

parachute_reset(id, keep = 0)
{
	if(para_ent[id] > 0) 
		if (pev_valid(para_ent[id])) 
			engfunc(EngFunc_RemoveEntity, para_ent[id]);
	
	if (!keep)
		has_parachute[id] = false;
	
	para_ent[id] = 0
	
	if (!has_parachute[id])
		has_parachute[id] = true;
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	engfunc(EngFunc_RemoveEntity, para_ent[victim]);
	para_ent[victim] = 0;
}

public fw_PreThink(id)
{
	//Parachute model animation information
	//0 - deploy - 84 frames
	//1 - idle - 39 frames
	//2 - detach - 29 frames
	
	if (!is_user_alive(id) || !has_parachute[id] ||  zp_core_is_zombie(id) )
		return;
	
	new Float:fallingspeed = get_pcvar_float(pcvars[fallspeed]) * -1.0;
	new Float:frame;
	
	new button = pev(id, pev_button);
	new oldbutton = pev(id, pev_oldbuttons);
	new flags = pev(id, pev_flags);
	
	if (para_ent[id] > 0 && (flags & FL_ONGROUND))
	{
		if (get_pcvar_num(pcvars[detach]))
		{
			if (pev(para_ent[id],pev_sequence) != 2)
			{
				set_pev(para_ent[id], pev_sequence, 2);
				set_pev(para_ent[id], pev_gaitsequence, 1);
				set_pev(para_ent[id], pev_frame, 0.0);
				set_pev(para_ent[id], pev_fuser1, 0.0);
				set_pev(para_ent[id], pev_animtime, 0.0);
				return;
			}
			
			pev(para_ent[id],pev_fuser1, frame);
			frame += 2.0;
			set_pev(para_ent[id],pev_fuser1,frame);
			set_pev(para_ent[id],pev_frame,frame);

			if (frame > 254.0)
			{
				engfunc(EngFunc_RemoveEntity, para_ent[id]);
				para_ent[id] = 0;
			}
		}
		else
		{
			engfunc(EngFunc_RemoveEntity, para_ent[id]);
			para_ent[id] = 0;
		}
		
		return;
	}

	if (button & IN_USE)
	{

		new Float:velocity[3];
		pev(id, pev_velocity, velocity);

		if (velocity[2] < 0.0)
		{
			if(para_ent[id] <= 0)
			{
				para_ent[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
				
				if(para_ent[id] > 0)
				{
					set_pev(para_ent[id],pev_classname,"parachute");
					set_pev(para_ent[id], pev_aiment, id)
					set_pev(para_ent[id], pev_owner, id);
					set_pev(para_ent[id], pev_movetype, MOVETYPE_FOLLOW);
					engfunc(EngFunc_SetModel, para_ent[id], paramodel);
					set_pev(para_ent[id], pev_sequence, 0);
					set_pev(para_ent[id], pev_gaitsequence, 1);
					set_pev(para_ent[id], pev_frame, 0.0);
					set_pev(para_ent[id], pev_fuser1, 0.0);
				}
			}
			
			if (para_ent[id] > 0)
			{
				set_pev(id, pev_sequence, 3)
				set_pev(id, pev_gaitsequence, 1)
				set_pev(id, pev_frame, 1.0)
				set_pev(id, pev_framerate, 1.0)

				velocity[2] = (velocity[2] + 40.0 < fallingspeed) ? velocity[2] + 40.0 : fallingspeed
				set_pev(id, pev_velocity, velocity)

				if (pev(para_ent[id],pev_sequence) == 0)
				{

					pev(para_ent[id],pev_fuser1, frame);
					frame += 1.0;
					set_pev(para_ent[id],pev_fuser1,frame);
					set_pev(para_ent[id],pev_frame,frame);

					if (frame > 100.0)
					{
						set_pev(para_ent[id], pev_animtime, 0.0);
						set_pev(para_ent[id], pev_framerate, 0.4);
						set_pev(para_ent[id], pev_sequence, 1);
						set_pev(para_ent[id], pev_gaitsequence, 1);
						set_pev(para_ent[id], pev_frame, 0.0);
						set_pev(para_ent[id], pev_fuser1, 0.0);
					}
				}
			}
		}
		else if (para_ent[id] > 0)
		{
			engfunc(EngFunc_RemoveEntity, para_ent[id]);
			para_ent[id] = 0;
		}
	}
	else if ((oldbutton & IN_USE) && para_ent[id] > 0)
	{
		engfunc(EngFunc_RemoveEntity, para_ent[id]);
		para_ent[id] = 0;
	}
}


public zp_user_human_post(id, survivor)
{
	
	engfunc(EngFunc_RemoveEntity, para_ent[id]);
	para_ent[id] = 0;
}
