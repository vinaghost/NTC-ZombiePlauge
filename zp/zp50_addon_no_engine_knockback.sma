/*================================================================================
	
		****************************************************
		*********** [No engine knockback 1.1.0] ************
		****************************************************
	
	----------------------
	-*- Licensing Info -*-
	----------------------
	
	No engine knockback
	by schmurgel1983(@msn.com)
	Copyright (C) 2010-2011 Stefan "schmurgel1983" Focke
	
	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.
	
	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
	Public License for more details.
	
	You should have received a copy of the GNU General Public License along
	with this program. If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.
	
	No warranties of any kind. Use at your own risk.
	
	-------------------
	-*- Description -*-
	-------------------
	
	This plugin disable the cs/cz engine knockback, but not the ZP knockback.
	The cs/cz engine knockback is little but noticeable.
	
	---------------------
	-*- Configuration -*-
	---------------------
	
	zp_nek_nemesis 1 // Nemesis don't have engine knockback [0-disabled / 1-enabled]
	zp_nek_zombies 0 // Zombies don't have engine knockback [0-disabled / 1-enabled]
	
	--------------------
	-*- Requirements -*-
	--------------------
	
	* Mods: Counter-Strike 1.6 or Condition-Zero
	* AMXX: Version 1.8.0 or later
	* Module: fakemeta, hamsandwich
	
	-----------------
	-*- Changelog -*-
	-----------------
	
	* v1.0.0:
	   - Initial release Privat (13th Aug 2010)
	   - Initial release Alliedmodders (4th Feb 2011)
	
	* v1.1.0:
	   - Added: cvars for nemesis and zombies,
	      human and survivor don't need to
		  disable the engine knockback
	
=================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <xs>

#if AMXX_VERSION_NUM < 180
	#assert AMX Mod X v1.8.0 or later library required!
#endif

#include <hamsandwich>

/*================================================================================
 [Zombie Plague 5.0 Includes]
=================================================================================*/

#include <cs_ham_bots_api>
#include <zp50_class_zombie>
#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>

/*================================================================================
 [Constants, Offsets, Macros]
=================================================================================*/

// Plugin Version
new const PLUGIN_VERSION[] = "1.1.0 (zp50)"

/*================================================================================
 [Global Variables]
=================================================================================*/

// Player vars
new Float:g_Knockback[33][3] // velocity from your knockback position
new g_bEnable[33] // disabled engine knockback is enable

// Cvar pointers
new cvar_Nemesis, cvar_Zombies

/*================================================================================
 [Precache and Init]
=================================================================================*/

public plugin_precache()
{
	register_plugin("[ZP] Addon : No Engine Knockback", PLUGIN_VERSION, "schmurgel1983")
}

public plugin_init()
{
	// HAM Forwards
	RegisterHam(Ham_TakeDamage, "player", "fwd_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fwd_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "fwd_TakeDamage_Post", 1)
	RegisterHamBots(Ham_TakeDamage, "fwd_TakeDamage_Post", 1)
	
	cvar_Nemesis = register_cvar("zp_nek_nemesis", "1")
	cvar_Zombies = register_cvar("zp_nek_zombies", "0")
	
	register_cvar("NoEngineKnockback_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("NoEngineKnockback_version", PLUGIN_VERSION)
}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}

public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

// Ham Take Damage Forward
public fwd_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!g_bEnable[victim]) return;
	
	// Engine Knockback disabled
	pev(victim, pev_velocity, g_Knockback[victim])
}

// Ham Take Damage Post Forward
public fwd_TakeDamage_Post(victim)
{
	if (!g_bEnable[victim]) return;
	
	// Engine Knockback disabled
	static Float:push[3]
	pev(victim, pev_velocity, push)
	xs_vec_sub(push, g_Knockback[victim], push)
	xs_vec_mul_scalar(push, 0.0, push)
	xs_vec_add(push, g_Knockback[victim], push)
	set_pev(victim, pev_velocity, push)
}

public zp_fw_core_cure_post(id) g_bEnable[id] = false

public zp_fw_core_infect_post(id, attacker)
{
	new nemesis = (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(id)) ? 1 : 0;
	
	if (nemesis && get_pcvar_num(cvar_Nemesis))
		g_bEnable[id] = 1
	else if (!nemesis)
		g_bEnable[id] = get_pcvar_num(cvar_Zombies)
	else
		g_bEnable[id] = 0
}
