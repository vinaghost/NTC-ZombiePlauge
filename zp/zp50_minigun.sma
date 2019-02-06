#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <xs>

#include <zp50_core>
#include <zombieplague>

#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>

#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

// Plugin information
new const PLUGIN[] = "[ZP] Minigun"
new const VERSION[] = "1.00"
new const AUTHOR[] = "lambda"


new hasMinigun = 0
new Float:cl_pushangle[33][3]

new cvar_minigun_speed, cvar_minigun_damage

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon","event_curweapon","be", "1=1")
	register_event("DeathMsg", "event_DeathMsg", "a", "1>0")
	
	RegisterHam(Ham_TakeDamage, "player", "player_TakeDamage")
	
	new szWeapon[32];
	get_weaponname(CSW_M249, szWeapon, charsmax(szWeapon))
	RegisterHam(Ham_Weapon_PrimaryAttack, szWeapon, "fw_primary_attack" ) 
	RegisterHam(Ham_Weapon_PrimaryAttack, szWeapon, "fw_primary_attack_post", 1 )
	
	cvar_minigun_speed = register_cvar("zp_minigun_speed", "0.6")
	cvar_minigun_damage = register_cvar("zp_minigun_damage", "0.8")
}
public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_SURVIVOR))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public zp_round_started(gamemode, id)
{
	if( LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id) )
		Set_BitVar(hasMinigun,id )
	
}
public zp_fw_core_spawn_post(id) {
	
	if( Get_BitVar(hasMinigun, id) ) 
		UnSet_BitVar(hasMinigun, id) 
}
public event_curweapon(id)
{
	if(!Get_BitVar(hasMinigun, id) || !is_user_alive(id) || !is_user_connected(id))
		return
	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo)
	
	if(weapon == CSW_M249)
	{
		new ent = fm_find_ent_by_owner(-1,"weapon_m249",id)

		new Float:N_Speed
		if(ent) 
		{
			N_Speed = get_pcvar_float(cvar_minigun_speed)
			new Float:Delay = get_pdata_float( ent, 46, 4) * N_Speed	
			set_pdata_float( ent, 46, Delay, 4)
		}
	}
}	

public player_TakeDamage(victim, inflictor, attacker, Float:damage, damagetype)
{
	if(!is_user_alive(attacker) || !is_user_connected(attacker) || !is_user_alive(victim) || !is_user_connected(victim))
		return HAM_IGNORED
	
	if(Get_BitVar(hasMinigun, attacker) && attacker != victim)
	{
		damage = (damage * get_pcvar_float(cvar_minigun_damage))
		SetHamParamFloat(4, damage)
		return HAM_IGNORED
	} 
	return HAM_IGNORED
}

public fw_primary_attack(iEnt)
{
	new id = pev(iEnt,pev_owner)

	if(!Get_BitVar(hasMinigun, id) || !is_user_alive(id) || !is_user_connected(id))
		return HAM_IGNORED

	pev(id,pev_punchangle,{ 0.0,0.0,0.0 }) 

	return HAM_IGNORED 
}

public fw_primary_attack_post(iEnt) 
{ 
	new id = pev(iEnt,pev_owner)

	if(!Get_BitVar(hasMinigun, id) || !is_user_alive(id) || !is_user_connected(id))
		return HAM_IGNORED
	
	new Float:push[3]
	pev(id,pev_punchangle,{ 0.0,0.0,0.0 })
	xs_vec_sub(push,cl_pushangle[id],push)

	new Float:noRecoilNum = 0.0
	xs_vec_mul_scalar(push,noRecoilNum,push)
	xs_vec_add(push,cl_pushangle[id],push)
	set_pev(id,pev_punchangle,{ 0.0,0.0,0.0 })
	return HAM_IGNORED
}
