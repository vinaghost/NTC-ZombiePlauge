#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cs_ham_bots_api>
#include <zp50_weapon>
#include <vip>
#include <engine>
#include <cs_maxspeed_api>
#include <cs_weap_models_api>


#define PLUGIN "[ZP] Weapon: Kinfe default"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

#define extra_offset_weapon     4
#define m_pPlayer           	41
#define m_flTimeWeaponIdle      48
new const v_knife[][] = {
	"models/zombie_plague/v_knife_karambit.mdl",
	"models/zombie_plague/v_knife_navaja.mdl",
	"models/zombie_plague/v_knife_shadow.mdl",
	"models/zombie_plague/v_knife_talon.mdl"
}
new const name_knife[][] = {
	"Karambit",
	"Navaja",
	"Shadow",
	"Talon"
}

new const Float:time_knfie[][] = {
	{ 4.56, 4.56, 4.56 },
	{ 4.76, 4.56, 4.56 },
	{ 4.69, 4.69, 4.69 },
	{ 4.86, 2.7, 2.7 }
}
new g_knife[4];
new p_knife[4];
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_TakeDamage, "player", "fw_ham_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fw_ham_TakeDamage")

	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "fw_Weapon_WeaponIdle")


	for( new i = 0; i < 4; i++ ) {
		g_knife[i] = zp_weapons_register(name_knife[i], 0, ZP_KNIFE, ZP_WEAPON_AP);
	}
}

public plugin_precache() {

	for(new i = 0; i < 4; i++) {
		precache_model(v_knife[i]);
	}
}

public fw_Weapon_WeaponIdle(iItem) {
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)
	if( is_user_vip(iPlayer)) {
		for(new i = 0; i < 4; i ++) {
			if( Get_BitVar(p_knife[i], iPlayer)) {
				Weapon_OnIdle(iItem, i, iPlayer)
				continue;
			}
		}
	}

	return HAM_SUPERCEDE
}
Weapon_OnIdle(iItem, i, iPlayer) {
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iItem)

	if(get_pdata_float(iItem, m_flTimeWeaponIdle, extra_offset_weapon) > 0.0)
		return;
	static num; num = random_num(0, 2);
	set_pdata_float(iItem, m_flTimeWeaponIdle, time_knfie[i][num], extra_offset_weapon)
	Weapon_SendAnim(iPlayer, iItem, 8 + num)


}
public zp_fw_wpn_select_post(id, itemid) {
	for(new i = 0; i < 4; i ++) {
		if( itemid == g_knife[i]) {
			Set_BitVar(p_knife[i], id);
			cs_set_player_view_model(id, CSW_KNIFE, v_knife[i])
			continue;
		}
	}
}

public zp_fw_wpn_remove(id, itemid) {
	for(new i = 0; i < 4; i ++) {
		if( itemid == g_knife[i]) {
			UnSet_BitVar(p_knife[i], id);
			cs_reset_player_view_model(id, CSW_KNIFE)
			continue;
		}
	}
}
public fw_ham_TakeDamage(victim, inflictor, attacker, Float:dmg, dmgbits)
{
	if( !is_user_alive(attacker) || zp_core_is_zombie(attacker) ) return;

	if( victim == attacker ) return;

	if( get_user_weapon(attacker) != CSW_KNIFE) return;

	for(new i = 0; i < 4; i ++) {
		if( Get_BitVar(p_knife[i], attacker)) {
			SetHamParamFloat(4, dmg * 5);
			continue;
		}
	}
}


stock Weapon_SendAnim(iPlayer, iItem, iAnim) {
    set_pev(iPlayer, pev_weaponanim, iAnim)

    message_begin(MSG_ONE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, iPlayer)
    write_byte(iAnim)
    write_byte(pev(iItem, pev_body))
    message_end()
}
