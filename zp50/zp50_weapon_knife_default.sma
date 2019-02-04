#include <amxmodx>
#include <hamsandwich>
#include <zp50_weapon>

#include <cs_weap_models_api>

#define PLUGIN "[ZP] Weapon: Kinfe default"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new Keris, Hammer
new p_Keris, p_Hammer;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_ham_TakeDamage")
	Keris = zp_weapons_register("Keris", 0, ZP_KNIFE)
	Hammer = zp_weapons_register("Hammer", 0, ZP_KNIFE)
}

public plugin_precache() {
	precache_model("models/v_hammer.mdl");
	precache_model("models/v_knife_keris.mdl");
}

public zp_fw_wpn_select_post(id, itemid) {
	
	if( itemid == Keris) 
	{
		Set_BitVar(p_Keris, id);
		cs_set_player_view_model(id, CSW_KNIFE, "models/v_knife_keris.mdl")
	}
		
	else if( itemid == Hammer) {
		Set_BitVar(p_Hammer, id);
		cs_set_player_view_model(id, CSW_KNIFE, "models/v_hammer.mdl")
	}
}

public zp_fw_wpn_remove(id, itemid) {
	
	if( itemid == Keris) {
		
		UnSet_BitVar(p_Keris, id);
		cs_reset_player_view_model(id, CSW_KNIFE)
	}
	else if( itemid == Hammer) {
		UnSet_BitVar(p_Hammer, id);
		cs_reset_player_view_model(id, CSW_KNIFE)
	}
	
	
}
public fw_ham_TakeDamage(victim, inflictor, attacker, Float:dmg, dmgbits)
{
	if( !is_user_alive(attacker) || zp_core_is_zombie(attacker) ) return;
	
	if( victim == attacker ) return;
	
	if ( zp_core_is_last_human(attacker) ) return;
	
	if( Get_BitVar(p_Keris, attacker) ) SetHamParamFloat(4, dmg * 5);
	
	if( Get_BitVar(p_Hammer, attacker) ) SetHamParamFloat(4, dmg * 7);
	
}
	
	
