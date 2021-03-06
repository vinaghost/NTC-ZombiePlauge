#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>
#include <zp50_gamemodes>

new const PLUGIN_VERSION[] = "1.0.0"

new g_IsInfectionRound

new g_ItemID, g_Double
public plugin_init()
{
	register_plugin("[ZP 5.0] New Infection Method", PLUGIN_VERSION, "Excalibur.007")

	RegisterHam(Ham_TakeDamage, "player", "OnPlayerTakeDamagePost", 1)
}


public OnPlayerTakeDamagePost(victim, attacker)
{
	if(!g_IsInfectionRound)
		return HAM_IGNORED

	if(!zp_core_is_zombie(victim) && !zp_core_is_last_human(victim) && is_user_alive(victim) &&  attacker > 0 && attacker  < 33 )
	{
		zp_core_infect(victim, attacker);
	}

	return HAM_IGNORED
}


