/*================================================================================

	------------------------
	-*- [ZP] Human Armor -*-
	------------------------

	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.

	================================================================================*/

	#include <amxmodx>
	#include <cstrike>
	#include <fakemeta>
	#include <hamsandwich>
	#include <cs_ham_bots_api>
	#include <zp50_core>
	#define LIBRARY_NEMESIS "zp50_class_nemesis"
	#include <zp50_class_nemesis>
	#define LIBRARY_ASSASSIN "zp50_class_assassin"
	#include <zp50_class_assassin>
	#define LIBRARY_SURVIVOR "zp50_class_survivor"
	#include <zp50_class_survivor>
	#define LIBRARY_SNIPER "zp50_class_sniper"
	#include <zp50_class_sniper>
	#include <zp50_gamemodes>
	#include <zp50_items>
	#include <zp50_items_const>
	#include <zp50_colorchat>
// CS Player PData Offsets (win32)
const OFFSET_PAINSHOCK = 108 // ConnorMcLeod

// Some constants
const DMG_HEGRENADE = (1<<24)

// CS sounds
new const g_sound_armor_hit[] = "player/bhit_helmet-1.wav"

new cvar_human_armor_protect, cvar_human_armor_default
new cvar_armor_protect_nemesis, cvar_survivor_armor_protect,
cvar_armor_protect_assassin, cvar_sniper_armor_protect

new g_IsInfectionRound

new g_ItemID, p_Armor;

public plugin_init()
{
	register_plugin("[ZP] Human Armor", ZP_VERSION_STRING, "ZP Dev Team")

	cvar_human_armor_protect = register_cvar("zp_human_armor_protect", "1")
	cvar_human_armor_default = register_cvar("zp_human_armor_default", "0")

	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	cvar_armor_protect_nemesis = register_cvar("zp_armor_protect_nemesis", "1")
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	cvar_armor_protect_assassin = register_cvar("zp_armor_protect_assassin", "1")
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	cvar_survivor_armor_protect = register_cvar("zp_survivor_armor_protect", "1")
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	cvar_sniper_armor_protect = register_cvar("zp_sniper_armor_protect", "1")

	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage")


	g_ItemID = zp_money_items_register("Giáp chống Zombie xịn", 6000);

}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS) || equal(module, LIBRARY_ASSASSIN) || equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER))
	return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
	return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public plugin_precache()
{
	precache_sound(g_sound_armor_hit)
}
public client_disconnected(id) {

	UnSet_BitVar(p_Armor, id);

}
public zp_fw_money_items_select_pre(id, itemid, ignorecost)
{
	if (itemid != g_ItemID)
	return ZP_ITEM_AVAILABLE;

	if( zp_core_is_zombie(id)  ) return ZP_ITEM_DONT_SHOW;

	if( Get_BitVar(p_Armor, id) ) {
		return ZP_ITEM_NOT_AVAILABLE;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_money_items_select_post(id, itemid, ignorecost)
{
	// This is not our item
	if (itemid != g_ItemID)
		return;

	Set_BitVar(p_Armor, id);
	set_pev(id, pev_armorvalue, 100);

	emit_sound(id, CHAN_ITEM, "items/ammopickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	zp_colored_print(id, "Đã trang bị Giáp chống zombie loại Xịn");
}
public zp_fw_core_cure_post(id, attacker)
{
	new Float:armor
	pev(id, pev_armorvalue, armor)

	if (armor < get_pcvar_float(cvar_human_armor_default))
	set_pev(id, pev_armorvalue, get_pcvar_float(cvar_human_armor_default))
}
public zp_fw_core_infect_post(id, attacker)
{
	if( Get_BitVar(p_Armor, id) ) {
		UnSet_BitVar(p_Armor, id)
		zp_colored_print(id, "Phát hiện zombie - Giáp chống Zombie loại xịn tự động huỷ");
	}
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_alive(attacker))
	return HAM_IGNORED;

	// Zombie attacking human...
	if (zp_core_is_zombie(attacker) && !zp_core_is_zombie(victim))
	{
		// Ignore damage coming from a HE grenade (bugfix)
		if (damage_type & DMG_HEGRENADE)
		return HAM_IGNORED;

		// Does human armor need to be reduced before infecting/damaging?
		if (!get_pcvar_num(cvar_human_armor_protect))
		return HAM_IGNORED;

		// Should armor protect against nemesis attacks?
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && !get_pcvar_num(cvar_armor_protect_nemesis) && zp_class_nemesis_get(attacker))
		return HAM_IGNORED;

		// Should armor protect against assassin attacks?
		if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && !get_pcvar_num(cvar_armor_protect_assassin) && zp_class_assassin_get(attacker))
		return HAM_IGNORED;

		// Should armor protect survivor too?
		if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && !get_pcvar_num(cvar_survivor_armor_protect) && zp_class_survivor_get(victim))
		return HAM_IGNORED;

		// Should armor protect sniper too?
		if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && !get_pcvar_num(cvar_sniper_armor_protect) && zp_class_sniper_get(victim))
		return HAM_IGNORED;

		if( Get_BitVar(p_Armor, victim) ) {
			// Get victim armor
			static Float:armor
			pev(victim, pev_armorvalue, armor)

			// If he has some, block damage and reduce armor instead
			if (armor > 0.0)
			{
				emit_sound(victim, CHAN_BODY, g_sound_armor_hit, 1.0, ATTN_NORM, 0, PITCH_NORM)

				if (armor - damage > 0.0) {
					set_pev(victim, pev_armorvalue, armor - damage)
				}
				else {
					UnSet_BitVar(p_Armor, victim);
					cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
					zp_colored_print(victim, "Giáp chống Zombie loại xịn đã bị phá huỷ");
				}

				// Block damage, but still set the pain shock offset
				set_pdata_float(victim, OFFSET_PAINSHOCK, 0.5)
				return HAM_SUPERCEDE;
			}
		}
		else {
			if(g_IsInfectionRound) {

				if(!zp_core_is_last_human(victim) && is_user_alive(victim))
				{
					zp_core_infect(victim, attacker);
				}
			}
		}
	}

	return HAM_IGNORED;
}
public zp_fw_gamemodes_start(game_mode_id)
{
	g_IsInfectionRound = false
	p_Armor = 0;
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
