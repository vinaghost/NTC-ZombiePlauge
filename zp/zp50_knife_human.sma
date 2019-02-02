#include <amxmodx>
#include <hamsandwich>
#include <zp50_core>
#include <cs_ham_bots_api>

#define PLUGIN "[ZP] Human knife"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDamge_Pre")
	RegisterHamBots(Ham_TakeDamage, "fw_PlayerTakeDamge_Pre")
}

public fw_PlayerTakeDamge_Pre(victim, inflictor, attacker, Float:damage, bits) 
{
	if( attacker == victim) return;
	
	if( !zp_core_is_zombie(attacker) && get_user_weapon(attacker) == CSW_KNIFE ) 
		SetHamParamFloat(4, damage * 8)
}