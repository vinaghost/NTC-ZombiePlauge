#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <zombieplague>

#define TASK_REGENERATION 	134926
#define TASK_BLOCK_REGEN 	151718
#define ID_REGEN 		(taskid - TASK_REGENERATION)
#define ID_BLOCK_REGEN 		(taskid - TASK_BLOCK_REGEN)

new g_endround, g_maxplayers, g_connected[33], g_alive[33], g_zombie[33], g_blockregen[33], g_maxhealth[33]
new cvar_regen_max, cvar_regen_add, cvar_regen_interval, cvar_regen_dmgdelay
new chaceRegenAdd, Float:chaceRegenMax, Float:chaceRegenInterval, Float:chaceRegenDmgDelay
new g_hamczbots, cvar_botquota
new const sound_regen[] = "zombie_plague/zombi_heal.wav"

#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_connected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_alive[%1])
#define is_user_valid_zombie(%1) (1 <= %1 <= g_maxplayers && g_zombie[%1])
#define is_user_valid_blockregen(%1) (1 <= %1 <= g_maxplayers && g_blockregen[%1])

public plugin_precache()
{
	precache_sound(sound_regen)
}

public plugin_init()
{
	register_plugin("ZP Zombie Regen V2", "1.0.2", "yokomo")
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	RegisterHam(Ham_Spawn, "player", "ham_spawn_post", 1)
	RegisterHam(Ham_Killed, "player", "ham_player_killed")
	RegisterHam(Ham_TakeDamage, "player", "ham_take_damage")
	
	cvar_regen_max = register_cvar("zp_regen_max", "1.0")
	cvar_regen_add = register_cvar("zp_regen_add", "200")
	cvar_regen_interval = register_cvar("zp_regen_interval", "5.0")
	cvar_regen_dmgdelay = register_cvar("zp_regen_dmg_delay", "2.5")
	
	cvar_botquota = get_cvar_pointer("bot_quota")
	
	g_maxplayers = get_maxplayers()
}

public client_putinserver(id)
{
	g_connected[id] = true
	g_zombie[id] = false
	
	if (is_user_bot(id) && !g_hamczbots && cvar_botquota) set_task(0.1, "register_ham_czbots", id);	
}

public register_ham_czbots(id)
{
	if (g_hamczbots || !is_user_connected(id) || !get_pcvar_num(cvar_botquota))
		return;
		
	RegisterHamFromEntity(Ham_Spawn, id, "ham_spawn_post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "ham_player_killed")
	RegisterHamFromEntity(Ham_TakeDamage, id, "ham_take_damage")	
	
	g_hamczbots = true
	
	if (is_user_alive(id)) ham_spawn_post(id);
}

public client_disconnect(id)
{
	g_connected[id] = false
	g_alive[id] = false
}

public event_round_start()
{
	g_endround = false
	
	chaceRegenMax = get_pcvar_float(cvar_regen_max)
	chaceRegenAdd = get_pcvar_num(cvar_regen_add)
	chaceRegenInterval = get_pcvar_float(cvar_regen_interval)
	chaceRegenDmgDelay = get_pcvar_float(cvar_regen_dmgdelay)	
}

public zp_round_ended()
{
	g_endround = true
}

public ham_spawn_post(id)
{
	if(!is_user_alive(id)) return;
	
	g_alive[id] = true
	
	if(zp_get_user_zombie(id) && !zp_get_user_nemesis(id))
	{
		g_zombie[id] = true
	}
	else g_zombie[id] = false
}

public ham_player_killed(victim, attacker, shouldgib)
{
	g_alive[victim] = false
}

public ham_take_damage(iVictim, iInflictor, iAttacker, Float:fDamage, iDmgBits)
{
	if(is_user_valid_connected(iVictim) && is_user_valid_alive(iVictim) && is_user_valid_zombie(iVictim))
	{	
		g_blockregen[iVictim] = true
		
		remove_task(iVictim+TASK_BLOCK_REGEN)
		set_task(chaceRegenDmgDelay, "RemoveBlockRegen", iVictim+TASK_BLOCK_REGEN)
	}
}

public zp_user_infected_post(victim, infector, nemesis)
{
	if(!nemesis)
	{
		g_zombie[victim] = true
		g_maxhealth[victim] = zp_get_zombie_maxhealth(victim)
	}
}

public zp_user_humanized_post(id)
{
	g_zombie[id] = false
}

public RemoveBlockRegen(taskid)
{
	g_blockregen[ID_BLOCK_REGEN] = false
	
	remove_task(ID_BLOCK_REGEN+TASK_REGENERATION)
	set_task(chaceRegenInterval, "RegenHpProcess", ID_BLOCK_REGEN+TASK_REGENERATION)
}

public RegenHpProcess(taskid)
{
	if(g_endround) return;
	
	if(!is_user_valid_blockregen(ID_REGEN) && is_user_valid_alive(ID_REGEN) && is_user_valid_zombie(ID_REGEN))
	{
		if(g_maxhealth[ID_REGEN] != -1)
		{
			new iMaxRegen = floatround(g_maxhealth[ID_REGEN] * chaceRegenMax)
			new iCurHealth = get_user_health(ID_REGEN)
			if (iCurHealth < iMaxRegen)
			{
				new iNewHealth = iCurHealth + chaceRegenAdd
				if(iNewHealth > iMaxRegen) set_user_health(ID_REGEN, iMaxRegen);
				else set_user_health(ID_REGEN, iNewHealth);
								
				client_cmd(ID_REGEN, "spk %s", sound_regen);
				
				set_task(chaceRegenInterval, "RegenHpProcess", ID_REGEN+TASK_REGENERATION)
			}
		}
	}
}
