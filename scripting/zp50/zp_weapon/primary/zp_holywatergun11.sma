/*
[ZP] Extra Item: Holy Water Gun
Team: Humans

Description: A water gun filled with Holy Water, for the Humans.
Weapon Cost: 55

Features:
- This weapon do more damage
- Launch Lasers
- This weapon has unlimited bullets

Cvars:


- zp_holywater_dmg_multiplier <4> - Damage Multiplier for watergun
- zp_holywater_blue_bullets <1|0> - Blue bullets?
- zp_holywater_custom_model <1|0> - Custom watergun model
- zp_holywater_unlimited_clip <1|0> - Unlimited ammo

*/



#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <zombieplague> 

#define is_valid_player(%1) (1 <= %1 <= 32)

new HW_V_MODEL[64] = "models/zombie_plague/v_holywater.mdl"
new HW_P_MODEL[64] = "models/zombie_plague/p_holywater.mdl"

/* Pcvars */
new cvar_dmgmultiplier, cvar_bluebullets,  cvar_custommodel, cvar_uclip

// Item ID
new g_itemid

new bool:g_HasHw[33]

new bullets[ 33 ]

// Sprite
new m_spriteTexture

const Wep_FAMAS = ((1<<CSW_FAMAS))

public plugin_init()
{
	
	/* CVARS */
	cvar_dmgmultiplier = register_cvar("zp_holywater_dmg_multiplier", "4")
	cvar_custommodel = register_cvar("zp_holywater_custom_model", "1")
	cvar_bluebullets = register_cvar("zp_holywater_blue_bullets", "1")
	cvar_uclip = register_cvar("zp_holywater_unlimited_clip", "1")
	
	// Register The Plugin
	register_plugin("[ZP] Extra: Holy Water Gun", "1.1", ".lambda")
	// Register Zombie Plague extra item
	g_itemid = zp_register_extra_item("Holy Water Gun", 55, ZP_TEAM_HUMAN)
	// Death Msg
	register_event("DeathMsg", "Death", "a")
	// Weapon Pick Up
	register_event("WeapPickup","checkModel","b","1=19")
	// Current Weapon Event
	register_event("CurWeapon","checkWeapon","be","1=1")
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
	// Ham TakeDamage
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward( FM_CmdStart, "fw_CmdStart" )
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
	
}

public client_connect(id)
{
	g_HasHw[id] = false
}

public client_disconnect(id)
{
	g_HasHw[id] = false
}

public Death()
{
	g_HasHw[read_data(2)] = false
}

public fwHamPlayerSpawnPost(id)
{
	g_HasHw[id] = false
}

public plugin_precache()
{
	precache_model(HW_V_MODEL)
	precache_model(HW_P_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")

}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id))
	{
		g_HasHw[id] = false
	}
}

public checkModel(id)
{
	if ( zp_get_user_zombie(id) )
		return PLUGIN_HANDLED
	
	new szWeapID = read_data(2)
	
	if ( szWeapID == CSW_FAMAS && g_HasHw[id] == true && get_pcvar_num(cvar_custommodel) )
	{
		set_pev(id, pev_viewmodel2, HW_V_MODEL)
		set_pev(id, pev_weaponmodel2, HW_P_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	
	if (plrWeapId == CSW_FAMAS && g_HasHw[id])
	{
		checkModel(id)
	}
	else 
	{
		return PLUGIN_CONTINUE
	}
	
	if (plrClip == 0 && get_pcvar_num(cvar_uclip))
	{
		// If the user is out of ammo..
		get_weaponname(plrWeapId, plrWeap, 31)
		// Get the name of their weapon
		give_item(id, plrWeap)
		engclient_cmd(id, plrWeap) 
		engclient_cmd(id, plrWeap)
		engclient_cmd(id, plrWeap)
	}
	return PLUGIN_HANDLED
}


//Thank you bartek93tbg :)
public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
    if(is_valid_player(attacker) && get_user_weapon(attacker) == CSW_FAMAS && g_HasHw[attacker])
    {
        if(random_num(1,100) <= 5)
        {
            if(!zp_get_user_nemesis(victim))
            {
                zp_disinfect_user(victim)
                return HAM_SUPERCEDE
            }
        }

        SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmgmultiplier))
    }

    return HAM_IGNORED
}

public make_tracer(id)
{
	if (get_pcvar_num(cvar_bluebullets))
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		new pteam[16]
		
		get_user_team(id, pteam, 15)
		
		if ((bullets[id] > clip) && (wpnid == CSW_FAMAS) && g_HasHw[id]) 
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
			
			
			//BEAMENTPOINTS
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short( m_spriteTexture )
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte( 30 )     // r, g, b
			write_byte( 144 )       // r, g, b
			write_byte( 255 )       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
	
		bullets[id] = clip
	}
	
}

public zv_extra_item_selected(player, itemid)
{
	if ( itemid == g_itemid )
	{
		if ( user_has_weapon(player, CSW_FAMAS) )
		{
			drop_prim(player)
		}
		
		give_item(player, "weapon_famas")
		client_print(player, print_chat, "[ZP] You bought Holy Water Gun!")
		g_HasHw[player] = true;
	}
}

stock drop_prim(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) {
		if (Wep_FAMAS & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
