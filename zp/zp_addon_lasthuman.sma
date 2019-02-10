#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <zp50_core>

#define PLUGIN "[ZP] Addon: Last human"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TakeDamage, "player", "Damaged")
}

public Damaged(victim, inflictor, attacker, Float:damage, bits) 
{
	if( !is_user_alive(victim) ) return;
	
	if( victim == attacker) return;
	
	if( !zp_core_is_last_human(victim) ) return;
	
	twist(victim, damage);
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
