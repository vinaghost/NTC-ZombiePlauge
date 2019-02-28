#include <amxmodx>
#include <hamsandwich>
#include <zp50_weapon>

#include <cs_weap_models_api>

#define PLUGIN "[ZP] Weapon: Kinfe default"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new CrowBar, Machete, Axe
new h_CrowBar, h_Machete, h_Axe

new const v_CrowBar[] = "models/zombie_plague/v_crowbar.mdl"
new const p_CrowBar[] = "models/zombie_plague/p_crowbar.mdl"


new const v_Machete[] = "models/zombie_plague/v_machete.mdl"
new const p_Machete[] = "models/zombie_plague/v_machete.mdl"


new const v_Axe[] = "models/zombie_plague/v_axe.mdl"
new const p_Axe[] = "models/zombie_plague/p_axe.mdl"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_ham_TakeDamage")
	CrowBar = 
	zp_weapons_register("Crowbar", 0, ZP_KNIFE, ZP_WEAPON_AP)
	Machete = zp_weapons_register("Machete", 0, ZP_KNIFE, ZP_WEAPON_AP)
	Axe = zp_weapons_register("Axe", 0, ZP_KNIFE, ZP_WEAPON_AP)
}

public plugin_precache() {
	precache_model(v_CrowBar);
	precache_model(p_CrowBar);
	
	precache_model(v_Machete);
	precache_model(p_Machete);
	
	precache_model(v_Axe);
	precache_model(p_Axe);	
}

public zp_fw_wpn_select_post(id, itemid) {
	
	if( itemid == CrowBar) {
		
		Set_BitVar(h_CrowBar, id);
		cs_set_player_view_model(id, CSW_KNIFE, v_CrowBar)
		cs_set_player_weap_model(id, CSW_KNIFE, p_CrowBar)
		
	}
	else if( itemid == Machete) {
		
		Set_BitVar(h_Machete, id);
		cs_set_player_view_model(id, CSW_KNIFE, v_Machete)
		cs_set_player_weap_model(id, CSW_KNIFE, p_Machete)
		
	}
	else if( itemid == Axe) {
		
		Set_BitVar(h_Axe, id);
		cs_set_player_view_model(id, CSW_KNIFE, v_Axe)
		cs_set_player_weap_model(id, CSW_KNIFE, p_Axe)
		
	}
}

public zp_fw_wpn_remove(id, itemid) {
	
	if( itemid == CrowBar) {
		
		UnSet_BitVar(h_CrowBar, id);
		cs_reset_player_view_model(id, CSW_KNIFE)
		cs_reset_player_weap_model(id, CSW_KNIFE)
		
	}
	else if( itemid == Machete) {
		
		UnSet_BitVar(h_Machete, id);
		cs_reset_player_view_model(id, CSW_KNIFE)
		cs_reset_player_weap_model(id, CSW_KNIFE)
		
	}
	else if( itemid == Axe) {
		
		UnSet_BitVar(h_Axe, id);
		cs_reset_player_view_model(id, CSW_KNIFE)
		cs_reset_player_weap_model(id, CSW_KNIFE)
		
	}
	
	
}
public fw_ham_TakeDamage(victim, inflictor, attacker, Float:dmg, dmgbits)
{
	if( !is_user_alive(attacker) || zp_core_is_zombie(attacker) ) return;
	
	if( victim == attacker ) return;
	
	if( ( Get_BitVar(h_CrowBar, attacker)  || Get_BitVar(h_Machete, attacker) || Get_BitVar(h_Axe, attacker) )
		&& get_user_weapon(attacker) == CSW_KNIFE) 
			SetHamParamFloat(4, dmg * 6);
	

}
	
	
