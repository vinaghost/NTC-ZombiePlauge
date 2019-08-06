#include <amxmodx>
#include <hamsandwich>
#include <zp50_gamemodes>

#define PLUGIN "[ZP 5.0] RESPAWN ZOMBIE"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new g_IsInfectionRound
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Killed, "player", "OnPlayerKilledPost", 1)
}

public OnPlayerKilledPost(victim, attacker)
{
	if(!g_IsInfectionRound)
		return HAM_IGNORED
		
	zp_core_respawn_as_zombie(victim)
		
	set_task(3.0, "Respawn", victim + 1338);
	
	return HAM_IGNORED
}

public Respawn(id)
{
	id -= 1338;
	
	if( is_user_alive(id)) return;
	
	ExecuteHam(Ham_CS_RoundRespawn, id);
}
	
public zp_fw_gamemodes_start(game_mode_id)
{
	g_IsInfectionRound = false
	
	if(IsInfectionRound())
	{
		zp_gamemodes_set_allow_infect(false)
		
		g_IsInfectionRound = true
	}
}

IsInfectionRound()
{
	if(zp_gamemodes_get_allow_infect())
		return true
	
	return false
}
