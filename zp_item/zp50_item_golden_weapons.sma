/*================================================================================
 
			----------------------------------
			[ZP:CN] Extra Item: Golden Weapons
			----------------------------------

		Golden Weapons
		Copyright (C) 2017 by Crazy

		-------------------
		-*- Description -*-
		-------------------

		This plugin add cool golden weapons as an extra items into your
		zombie plague crazy night mod.

		A golden beam effect follow the bullet shoot by these weapons,
		this bullet can inflict a powerfull 'golden' damage into Zombies.

		------------------
		-*- Change Log -*-
		------------------

		* v1.0: (Jun 2017)
			- First release;

		---------------
		-*- Credits -*-
		---------------

		* Crazy: Zombie Plague - Crazy Night / plugin code.
		* AlejandroSk: Golden beam effect (Golden ak-47).
		* Alex: golden weapons models.

=================================================================================*/

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <cs_ham_bots_api>
#include <zp50_weapon>

// Plugin version
new const PLUGIN_VERSION[] = "v1.0";

// MaxPlayers
const MAXPLAYERS = 32;

// CS Weapon CBase Offsets (win32)
const OFFSET_WEAPONOWNER = 41;

// weapon offsets are only 4 steps higher on Linux
const OFFSET_LINUX_WEAPONS = 4;

// Weapon enum
enum _:WeaponData
{
	WeaponName[32],
	WeaponCost,
	WeaponEnt[32],
	Float:WeaponDamage,
	WeaponCSW,
	WeaponImpulse,
};

// Model enum
enum _:ModelData
{
	V_MODEL[64],
	P_MODEL[64],
	W_MODEL[64],
	W_OLD_MODEL[64],
};

// Golden weapons attributes
new WPNDATA[][WeaponData] = {
	{ "Golden Deagle", 5000, "weapon_deagle", 4.0, CSW_DEAGLE, 879238 },
	{ "Golden Ak-47", 8000, "weapon_ak47", 3.5, CSW_AK47, 879234 },
	{ "Golden M4A1", 8000, "weapon_m4a1", 3.9, CSW_M4A1, 879235 },
	{ "Golden XM1014", 10000, "weapon_xm1014", 4.0, CSW_XM1014, 879236 },
	{ "Golden M249", 13000, "weapon_m249", 3.0, CSW_M249, 879237 }
};

// Golden weapons models
new MODELDATA[][ModelData] = {
	{ "models/zp_crazynight/items/v_golden_deagle.mdl", "models/zp_crazynight/items/p_golden_deagle.mdl", "models/zp_crazynight/items/w_golden_deagle.mdl", "models/w_deagle.mdl" },
	{ "models/zp_crazynight/items/v_golden_ak47.mdl", "models/zp_crazynight/items/p_golden_ak47.mdl", "models/zp_crazynight/items/w_golden_ak47.mdl", "models/w_ak47.mdl" },
	{ "models/zp_crazynight/items/v_golden_m4a1.mdl", "models/zp_crazynight/items/p_golden_m4a1.mdl", "models/zp_crazynight/items/w_golden_m4a1.mdl", "models/w_m4a1.mdl" },
	{ "models/zp_crazynight/items/v_golden_xm1014.mdl", "models/zp_crazynight/items/p_golden_xm1014.mdl", "models/zp_crazynight/items/w_golden_xm1014.mdl", "models/w_xm1014.mdl" },
	{ "models/zp_crazynight/items/v_golden_m249.mdl", "models/zp_crazynight/items/p_golden_m249.mdl", "models/zp_crazynight/items/w_golden_m249.mdl", "models/w_m249.mdl" }
}

// Weapons Bitsum
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

// Global vars
new g_beam_sprite, g_has_item[MAXPLAYERS+1][sizeof WPNDATA], g_clipammo[MAXPLAYERS+1];

// Native give item (from fun.inc)
native give_item(id, const item[])

new g_wpn_gold[5]
// Plugin init
public plugin_init()
{
	register_plugin("[ZP:CN] Extra Item: Golden Weapons", PLUGIN_VERSION, "Crazy");

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		
		//zpcn_register_extra_item(WPNDATA[i][WeaponName], WPNDATA[i][WeaponCost], WPNDATA[i][WeaponEnt], ZPCN_TEAM_HUMAN, 2);
		RegisterHam(Ham_Item_Deploy, WPNDATA[i][WeaponEnt], "fw_Item_Deploy_Post", 1);
		RegisterHam(Ham_Item_AddToPlayer, WPNDATA[i][WeaponEnt], "fw_Item_AddToPlayer_Post", 1);
		RegisterHam(Ham_Weapon_PrimaryAttack, WPNDATA[i][WeaponEnt], "fw_PrimaryAttack");
		RegisterHam(Ham_Weapon_PrimaryAttack, WPNDATA[i][WeaponEnt], "fw_PrimaryAttack_Post", 1);
	}
	g_wpn_gold[0] = zp_weapons_register(WPNDATA[0][WeaponName], WPNDATA[0][WeaponCost], ZP_SECONDAYRY, ZP_WEAPON_MONEY)
	g_wpn_gold[1] = zp_weapons_register(WPNDATA[1][WeaponName], WPNDATA[1][WeaponCost], ZP_PRIMARY, ZP_WEAPON_MONEY)
	g_wpn_gold[2] = zp_weapons_register(WPNDATA[2][WeaponName], WPNDATA[2][WeaponCost], ZP_PRIMARY, ZP_WEAPON_MONEY)
	g_wpn_gold[3] = zp_weapons_register(WPNDATA[3][WeaponName], WPNDATA[3][WeaponCost], ZP_PRIMARY, ZP_WEAPON_MONEY)
	g_wpn_gold[4] = zp_weapons_register(WPNDATA[4][WeaponName], WPNDATA[4][WeaponCost], ZP_PRIMARY, ZP_WEAPON_MONEY)
	
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage");

	register_forward(FM_SetModel, "fw_SetModel");
}

// Plugin precache
public plugin_precache()
{
	g_beam_sprite = precache_model("sprites/dot.spr");

	for (new i = 0; i < sizeof MODELDATA; i++)
	{
		engfunc(EngFunc_PrecacheModel, MODELDATA[i][V_MODEL]);
		engfunc(EngFunc_PrecacheModel, MODELDATA[i][P_MODEL]);
		engfunc(EngFunc_PrecacheModel, MODELDATA[i][W_MODEL]);
	}
}

// New round event
public event_new_round()
{
	new players[32], pnum, id;
	get_players(players, pnum);

	for (--pnum; pnum >= 0; pnum--)
	{
		id = players[pnum];

		for (new i = 0; i < sizeof WPNDATA; i++)
			g_has_item[id][i] = false;
	}
}

// Client put in server
public client_putinserver(id)
{
	for (new i = 0; i < sizeof WPNDATA; i++)
		g_has_item[id][i] = false;
}

// Forward zpcn user infected post
public zp_fw_core_infect_post(id)
{
	for (new i = 0; i < sizeof WPNDATA; i++)
		g_has_item[id][i] = false;
}

// Forward zpcn user humanized post
public zp_fw_core_cure_post(id)
{
	for (new i = 0; i < sizeof WPNDATA; i++)
		g_has_item[id][i] = false;
}
public is_item(itemid) {
	for( new i = 0; i < 5; i++ ) {
		if( itemid == g_wpn_gold[i])
			return 1;
	}
	return 0;
}
public had_item(id, itemid)  {
	for( new i = 0; i < 5; i++ ) {
		if( itemid == g_wpn_gold[i] && g_has_item[id][i])
			return 1;
	}
	return 0;
}
public zp_fw_wpn_select_pre(id, itemid) {
	
	if( !is_item(itemid) ) return ZP_WEAPON_AVAILABLE;
	
	if( zp_core_is_zombie(id) ) return ZP_WEAPON_DONT_SHOW;
	
	if( had_item(id, itemid) ) return ZP_WEAPON_DONT_SHOW;
	
	return ZP_WEAPON_AVAILABLE;
}
 
public zp_fw_wpn_select_post(id, itemid) {
	
	if( itemid == g_wpn_gold[0] ) weapon_deagle(id)
	else if( itemid == g_wpn_gold[1]) weapon_ak47(id)
	else if( itemid == g_wpn_gold[2]) weapon_m4a1(id)
	else if( itemid == g_wpn_gold[3]) weapon_xm1014(id)
	else if( itemid == g_wpn_gold[4]) weapon_m249(id)
}
	
// Golden Deagle
public weapon_deagle(id)
{
	drop_user_weapons(id, 2);

	g_has_item[id][0] = true;

	give_item(id, "weapon_deagle");
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
}

// Golden Ak-47
public weapon_ak47(id)
{
	drop_user_weapons(id, 1);

	g_has_item[id][1] = true;

	give_item(id, "weapon_ak47");
	cs_set_user_bpammo(id, CSW_AK47, 90);
}

// Golden M4A1
public weapon_m4a1(id)
{
	drop_user_weapons(id, 1);

	g_has_item[id][2] = true;

	give_item(id, "weapon_m4a1");
	cs_set_user_bpammo(id, CSW_M4A1, 90);
}

// Golden XM1014
public weapon_xm1014(id)
{
	drop_user_weapons(id, 1);

	g_has_item[id][3] = true;

	give_item(id, "weapon_xm1014");
	cs_set_user_bpammo(id, CSW_XM1014, 32);
}

// Golden M249
public weapon_m249(id)
{
	drop_user_weapons(id, 1);

	g_has_item[id][4] = true;

	give_item(id, "weapon_m249");
	cs_set_user_bpammo(id, CSW_M249, 200);
}

// Ham Take Damage
public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (!is_user_alive(victim) || !is_user_alive(attacker))
		return HAM_IGNORED;

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		if (get_user_weapon(attacker) != WPNDATA[i][WeaponCSW])
			continue;

		if (!g_has_item[attacker][i])
			return HAM_IGNORED;
		
		SetHamParamFloat(4, damage * 7.0);
		return HAM_IGNORED;
	}

	return HAM_IGNORED;
}

// Ham Item Deploy Post
public fw_Item_Deploy_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		if (cs_get_weapon_id(entity) != WPNDATA[i][WeaponCSW])
			continue;

		if (!g_has_item[id][i])
			return HAM_IGNORED;

		entity_set_string(id, EV_SZ_viewmodel, MODELDATA[i][V_MODEL]);
		entity_set_string(id, EV_SZ_weaponmodel, MODELDATA[i][P_MODEL]);

		return HAM_IGNORED;
	}

	return HAM_IGNORED;
}

// Ham Item Add To Player Post
public fw_Item_AddToPlayer_Post(entity, id)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	if (!is_user_alive(id))
		return HAM_IGNORED;

	new impulse = entity_get_int(entity, EV_INT_impulse);

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		if (cs_get_weapon_id(entity) != WPNDATA[i][WeaponCSW])
			continue;

		if (impulse != WPNDATA[i][WeaponImpulse])
			return HAM_IGNORED;

		g_has_item[id][i] = true;
		entity_set_int(entity, EV_INT_impulse, 0);

		return HAM_IGNORED;
	}

	return HAM_IGNORED;
}

// Ham Weapon Primary Attack
public fw_PrimaryAttack(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		if (cs_get_weapon_id(entity) != WPNDATA[i][WeaponCSW])
			continue;

		if (!g_has_item[id][i])
			return HAM_IGNORED;

		break;
	}

	g_clipammo[id] = cs_get_weapon_ammo(entity);

	return HAM_IGNORED;
}

// Ham Weapon Primary Attack Post
public fw_PrimaryAttack_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		if (cs_get_weapon_id(entity) != WPNDATA[i][WeaponCSW])
			continue;

		if (!g_has_item[id][i])
			return HAM_IGNORED;

		break;
	}

	if (!g_clipammo[id])
		return HAM_IGNORED;

	new origin[3], end[3];
	get_user_origin(id, origin, 1);
	get_user_origin(id, end, 3);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(end[0])
	write_coord(end[1])
	write_coord(end[2])
	write_short(g_beam_sprite)
	write_byte(1)
	write_byte(5)
	write_byte(2)
	write_byte(10)
	write_byte(0)
	write_byte(255)
	write_byte(200)
	write_byte(0)
	write_byte(200)
	write_byte(150)
	message_end()

	return HAM_IGNORED;
}

// Forward set model
public fw_SetModel(entity, const model[])
{
	if (!is_valid_ent(entity))
		return FMRES_IGNORED;

	static classname[32];
	entity_get_string(entity, EV_SZ_classname, classname, charsmax(classname));

	if (!equal(classname, "weaponbox"))
		return FMRES_IGNORED;

	static itemid, owner, weapon;
	owner = entity_get_edict(entity, EV_ENT_owner);

	for (new i = 0; i < sizeof WPNDATA; i++)
	{
		if (!g_has_item[owner][i])
			continue;

		weapon = find_ent_by_owner(-1, WPNDATA[i][WeaponEnt], entity);

		if (!is_valid_ent(weapon))
			continue;

		if (cs_get_weapon_id(weapon) != WPNDATA[i][WeaponCSW])
			continue;

		if (!equal(model, MODELDATA[i][W_OLD_MODEL]))
			return FMRES_IGNORED;

		itemid = i;
		break;
	}

	if (!is_valid_ent(weapon) || !g_has_item[owner][itemid])
		return FMRES_IGNORED;

	static w_model[64], impulse;

	copy(w_model, charsmax(w_model), MODELDATA[itemid][W_MODEL]);

	impulse = WPNDATA[itemid][WeaponImpulse];

	g_has_item[owner][itemid] = false;

	entity_set_int(weapon, EV_INT_impulse, impulse);

	entity_set_model(entity, w_model);

	return FMRES_SUPERCEDE;
}

// Stock drop user weapons
stock drop_user_weapons(id, slot)
{
	new weapons[32], num, i, weaponid;
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i];
		
		if ((slot == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (slot == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			static wname[32];
			get_weaponname(weaponid, wname, charsmax(wname));
			
			engclient_cmd(id, "drop", wname);
			cs_set_user_bpammo(id, weaponid, 0);
		}
	}
}
