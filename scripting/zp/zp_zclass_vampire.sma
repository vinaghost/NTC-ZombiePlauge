#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>

// Plugin stuff
new const PLUGIN[] = "[ZP] Zombie Class: Vampire Zombie"
new const VERSION[] = "1.0"
new const AUTHOR[] = "NiHiLaNTh"

// Zombie parametres
new const zclass_name[] = { "Vampire Zombie" } // name
new const zclass_info[] = { "Gain health with each hit" } // description
new const zclass_model[] = { "zombie_source" } // player model
new const zclass_clawmodel[] = { "v_knife_zombie.mdl" } // claw model
const zclass_health = 1500 // health
const zclass_speed = 220 // speed
const Float:zclass_gravity = 0.7 // gravity
const Float:zclass_knockback = 1.5 // knockback

// Class ID
new g_zclass_vampire;

// CVAR pointers
new pcv_multi;

// Zombie classes must be registered on plugin precache
public plugin_precache()
{
	g_zclass_vampire = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback);
}

// Plugin initialization
public plugin_init()
{
	// Register our plugin
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Forward
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	// CVAR
	pcv_multi = register_cvar("zp_vampire_multi", "2") // additional health multiplier
}

// Target has been injected...
public zp_user_infected_post(id, infector, nemesis)
{
	// Our zm class
	if (zp_get_user_zombie_class(id) == g_zclass_vampire)
	{
		client_print(id, print_chat, "[ZP] Damage or infect someone to get additional health.");
		VampireInit(id);
	}
	
	// Vampire zombie cannot damage anyone on Single/Multi infection rounds so...
	if (zp_get_user_zombie_class(infector) == g_zclass_vampire)
	{
		set_pev(infector, pev_health, float(pev(infector, pev_health) + 1000))
	}
}

// Victim took damage from entity
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Not alive
	if (!is_user_alive(victim))
		return;
		
	if (!zp_get_user_zombie(attacker) || !zp_get_user_nemesis(attacker))
		return;
	
	if (zp_get_user_zombie_class(attacker) == g_zclass_vampire)
	{
		// Calculate additional health
		static ExtraHealth;
		ExtraHealth = floatround(damage * get_pcvar_num(pcv_multi))
		
		// Set new health
		set_pev(attacker, pev_health, float(pev(attacker, pev_health) + ExtraHealth))
	}
}		

// Vampire zombie was born...
public VampireInit(id)
{
	// Not alive
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	// Not our zombie class
	if (zp_get_user_zombie_class(id) != g_zclass_vampire)
		return PLUGIN_CONTINUE;
	
	return PLUGIN_CONTINUE;
}
	
