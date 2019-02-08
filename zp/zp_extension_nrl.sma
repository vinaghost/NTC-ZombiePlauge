/*================================================================================

	[ZP] Extension: Nemesis Rocket Launcher
	Copyright (C) 2009 by meTaLiCroSS, Viña del Mar, Chile
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.
	
	** Credits:
		
	- frk_14: Weapon and Rocket models
	- Asd': Tester
	- Arkshine: Help me with rocket Angles
	- G-Dog: Some code of his Bazooka
	- hlstriker: How to create a Flare
	- Mayor: Some "touch" code of his Bazooka Advanced
	- MeRcyLeZZ: is_user_valid_alive/connected Macros
	- jtp10181: Round End particle effect

=================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zombieplague>

/*================================================================================
 [Customizations]
=================================================================================*/

// Admin Flag (to access to the admin privileges)
const ACCESS_FLAG = ADMIN_BAN 

// Models
new const nrl_rocketmodel[] = 		"models/stinger_rocket_frk14.mdl" 	// Rocket Model

// Sprites
new const nrl_explosion_sprite[] = 	"sprites/zerogxplode.spr" 	// Explosion Sprite
new const nrl_ring_sprite[] = 		"sprites/shockwave.spr" 	// Ring Explosion Sprite
new const nrl_trail_sprite[] = 		"sprites/xbeam3.spr" 		// Rocket Follow Sprite

// Sounds
new const nrl_rocketlaunch_sound[][] = 	// Rocket Launch Sound
{ 
	"weapons/rocketfire1.wav" 
}

new const nrl_norockets_sound[][] = 	// When user doesn't have Rockets
{ 
	"weapons/dryfire1.wav" 
}

new const nrl_deploy_sound[][] = 	// Deploying user NRL
{
	"items/gunpickup3.wav",
	"items/gunpickup4.wav" 
}

new const nrl_explosion_sound[][] = 	// Rocket Explosion Sound
{
	"weapons/explode3.wav",
	"weapons/explode4.wav",
	"weapons/explode5.wav"
}

new const nrl_rocketfly_sound[][] = 	// Fly sound
{
	"weapons/rocket1.wav"
}

// Rocket Size
new Float:nrl_rocket_mins[] = 	{ 	-1.0,	-1.0,  	-1.0 	}
new Float:nrl_rocket_maxs[] = 	{ 	1.0, 	1.0, 	1.0 	}

// Colors (in RGB format)		R	G	B
new nrl_trail_colors[3] = 	{	255,	0,	0	}	// Rocket trail
new nrl_glow_colors[3] =	{	255,	0,	0	}	// Rocket glow
new nrl_dlight_colors[3] =	{	200,	200,	200	}	// Rocket dynamic light
new nrl_flare_colors[3] =	{	255,	0,	0	}	// Rocket flare
new nrl_ring_colors[3] =	{	200,	200,	200	}	// Rocket ring-explosion

/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

// Booleans
new bool:g_bHasNRL[33] = { false, ... }, bool:g_bHoldingNRL[33] = { false, ... }, bool:g_bKilledByRocket[33] = { false, ... }, 
bool:g_bIsAlive[33] = { false, ... }, bool:g_bIsConnected[33] = { false, ... }, bool:g_bRoundEnding = false

// Arrays
new Float:g_flLastDeployTime[33] = { 0.0, ...}, Float:g_flLastLaunchTime[33] = { 0.0, ...}, 
g_iRocketAmount[33] = { 0, ...}, g_iCurrentWeapon[33] = { 0, ...}, g_szStatusText[33][32]

// Game vars
new g_sprExplosion, g_sprRing, g_sprTrail,/* g_iSyncMsg,*/ g_iMaxPlayers

// Message IDs vars
new g_msgStatusText, g_msgAmmoPickup, g_msgScreenFade, g_msgScreenShake, g_msgSayText, g_msgCurWeapon

// Some constants
const FFADE_IN = 		0x0000
const UNIT_SECOND = 		(1<<12)
const EV_ENT_FLARE = 		EV_ENT_euser3
const AMMOID_HEGRENADE = 	12
const IMPULSE_SPRAYLOGO = 	201

// v_stinger_frk14 Model Anims
const NRL_ANIM_IDLE = 0
const NRL_ANIM_DRAW = 3
const NRL_ANIM_FIRE = 8

// Ring Z Axis addition
new Float:g_flRingZAxis_Add[3] = { 425.0 , 510.0, 595.0 }

// Cvar Pointers
new cvar_enable, cvar_bonushp, cvar_buyable, cvar_svvel, cvar_launchrate, cvar_launchpush,/* cvar_buyrockets, */
cvar_explo_radius, cvar_explo_damage, cvar_explo_rings, cvar_explo_dlight, cvar_damage_fade, cvar_damage_shake, 
cvar_rocket_vel, cvar_rocket_trail, cvar_rocket_glow, cvar_rocket_dlight, cvar_rocket_flare, cvar_rocket_grav,
cvar_player_rockets, cvar_player_apcost, cvar_player_rocketapcost, cvar_admin_features, cvar_admin_rockets, 
cvar_admin_apcost, cvar_admin_rocketapcost

// Cached Cvars
enum { iPlayers = 0, iAdmins }

new bool:g_bCvar_Enabled, bool:g_bCvar_GiveFree, /*bool:g_bCvar_BuyRockets,*/ bool:g_bCvar_AdminFeatures, 
g_iCvar_DefaultRockets[2], g_iCvar_APCost[2], g_iCvar_RocketAPCost[2]

// Plug info.
#define PLUG_VERSION "2.1.8"
#define PLUG_AUTH "meTaLiCroSS"

// Macros
#define is_user_valid_alive(%1) 	(1 <= %1 <= g_iMaxPlayers && g_bIsAlive[%1])
#define is_user_valid_connected(%1) 	(1 <= %1 <= g_iMaxPlayers && g_bIsConnected[%1])

/*================================================================================
 [Init, Precache and CFG]
=================================================================================*/

public plugin_init() 
{
	// Plugin Info
	register_plugin("[ZP] Extension: Nemesis Rocket Launcher", PLUG_VERSION, PLUG_AUTH)
	
	// Lang file
	//register_dictionary("zp_extension_nrl.txt")
	
	// Events
	register_event("CurWeapon", "event_CurWeapon", "be","1=1")	
	register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0")
	
	// Messages
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	
	// Fakemeta Forwards
	register_forward(FM_CmdStart, "fw_CmdStart")
	
	// Engine Forwards
	register_impulse(IMPULSE_SPRAYLOGO, "fw_Impulse")
	register_touch("nrl_rocket", "*", "fw_RocketTouch")
	
	// Ham Forwards
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_KnifePrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_KnifeSecondaryAttack")
	
	// CVARS - General
	cvar_enable = register_cvar("zp_nemesis_rocket_launcher", "1")
	cvar_bonushp = register_cvar("zp_nrl_health_bonus", "400")
	cvar_buyable = register_cvar("zp_nrl_give_free", "1")
	//cvar_buyrockets = register_cvar("zp_nrl_buy_rockets", "1")
	cvar_launchrate = register_cvar("zp_nrl_launch_rate", "2.0")
	cvar_launchpush = register_cvar("zp_nrl_launch_push_force", "60")
	
	// CVARS - Explosion
	cvar_explo_radius = register_cvar("zp_nrl_explo_radius", "500")
	cvar_explo_damage = register_cvar("zp_nrl_explo_maxdamage", "300")
	cvar_explo_rings = register_cvar("zp_nrl_explo_rings", "1")
	cvar_explo_dlight = register_cvar("zp_nrl_explo_dlight", "1")
	
	// CVARS - Damage
	cvar_damage_fade = register_cvar("zp_nrl_damage_screenfade", "1")
	cvar_damage_shake = register_cvar("zp_nrl_damage_screenshake", "1")
	
	// CVARS - Rocket
	cvar_rocket_vel = register_cvar("zp_nrl_rocket_speed", "1200")
	cvar_rocket_trail = register_cvar("zp_nrl_rocket_trail", "1")
	cvar_rocket_glow = register_cvar("zp_nrl_rocket_glow", "1")
	cvar_rocket_dlight = register_cvar("zp_nrl_rocket_dlight", "0")
	cvar_rocket_flare = register_cvar("zp_nrl_rocket_flare", "1")
	cvar_rocket_grav = register_cvar("zp_nrl_rocket_obeygravity", "0")
	
	// CVARS - Player Options
	cvar_player_rockets = register_cvar("zp_nrl_default_rockets", "2")
	cvar_player_apcost = register_cvar("zp_nrl_cost", "30")
	cvar_player_rocketapcost = register_cvar("zp_nrl_rocket_cost", "15")
	
	// CVARS - Admin Options
	cvar_admin_features = register_cvar("zp_nrl_admin_features_enable", "1")
	cvar_admin_rockets = register_cvar("zp_nrl_admin_default_rockets", "4")
	cvar_admin_apcost = register_cvar("zp_nrl_admin_cost", "20")
	cvar_admin_rocketapcost = register_cvar("zp_nrl_admin_rocket_cost", "8")
	
	// CVARS - Others
	cvar_svvel = get_cvar_pointer("sv_maxvelocity")
	
	static szCvar[30]
	formatex(szCvar, charsmax(szCvar), "v%s by %s", PLUG_VERSION, PLUG_AUTH)
	register_cvar("zp_extension_nrl", szCvar, FCVAR_SERVER|FCVAR_SPONLY)
	
	// Say commands
	register_say_command("nrlshop", "cmd_nrlshop")
	register_say_command("nrlhelp", "cmd_nrlhelp")

	// Vars
	//g_iSyncMsg = CreateHudSyncObj()
	g_iMaxPlayers = get_maxplayers()
	
	// Message IDs
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgStatusText = get_user_msgid("StatusText")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
}

public plugin_precache()
{
	// Models
	precache_model(nrl_rocketmodel)
	precache_model("sprites/animglow01.spr")
	precache_model("models/zombie_plague/v_stinger_frk14.mdl")
	precache_model("models/zombie_plague/p_stinger_frk14.mdl")
	
	// Sounds
	static i
	for(i = 0; i < sizeof nrl_rocketlaunch_sound; i++)
		precache_sound(nrl_rocketlaunch_sound[i])
	for(i = 0; i < sizeof nrl_norockets_sound; i++)
		precache_sound(nrl_norockets_sound[i])
	for(i = 0; i < sizeof nrl_deploy_sound; i++)	
		precache_sound(nrl_deploy_sound[i])
	for(i = 0; i < sizeof nrl_explosion_sound; i++)	
		precache_sound(nrl_explosion_sound[i])
	for(i = 0; i < sizeof nrl_rocketfly_sound; i++)	
		precache_sound(nrl_rocketfly_sound[i])
	
	precache_sound("items/gunpickup2.wav")
	precache_sound("ambience/particle_suck2.wav")
	
	// Sprites
	g_sprRing = precache_model(nrl_ring_sprite)
	g_sprExplosion = precache_model(nrl_explosion_sprite)
	g_sprTrail = precache_model(nrl_trail_sprite)
}

public plugin_cfg()
{
	// Now we can cache the cvars, because config file has read
	set_task(0.5, "cache_cvars")
}

/*================================================================================
 [Zombie Plague Forwards]
=================================================================================*/

public zp_user_infected_post(id, infector)
{
	// User is Nemesis
	if(zp_get_user_nemesis(id))
	{
		// Plugin enabled
		if(g_bCvar_Enabled) 
		{
			// Check cvar
			if(g_bCvar_GiveFree) // Free
			{
				// Give gun
				set_user_nrlauncher(id, 1)
			}
		}
	}
	// is Zombie
	else
	{
		// Reset Vars
		set_user_nrlauncher(id, 0)
	}
}

public zp_user_humanized_post(id)
{
	// Reset Vars
	set_user_nrlauncher(id, 0)
}

public zp_round_ended(team)
{
	// Remove all the rockets in the map
	// remove_rockets_in_map()
	set_task(0.1, "remove_rockets_in_map")
	
	// Update var
	g_bRoundEnding = true
}

/*================================================================================
 [Public Functions]
=================================================================================*/

public reset_user_knife(id)
{
	// Latest version support
	ExecuteHamB(Ham_Item_Deploy, find_ent_by_owner(FM_NULLENT, "weapon_knife", id)) // v4.3 Support
	
	// Updating Model
	engclient_cmd(id, "weapon_knife")
	emessage_begin(MSG_ONE, g_msgCurWeapon, _, id)
	ewrite_byte(1) // active
	ewrite_byte(CSW_KNIFE) // weapon
	ewrite_byte(0) // clip
	emessage_end()
}

public cache_cvars()
{
	// Cache some cvars
	g_bCvar_Enabled = bool:get_pcvar_num(cvar_enable)
	g_bCvar_AdminFeatures = bool:get_pcvar_num(cvar_admin_features)
	g_bCvar_GiveFree = bool:get_pcvar_num(cvar_buyable)
	//g_bCvar_BuyRockets = bool:get_pcvar_num(cvar_buyrockets)
	g_iCvar_DefaultRockets[iPlayers] = get_pcvar_num(cvar_player_rockets)
	g_iCvar_DefaultRockets[iAdmins] = get_pcvar_num(cvar_admin_rockets)
	g_iCvar_APCost[iPlayers] = get_pcvar_num(cvar_player_apcost)
	g_iCvar_APCost[iAdmins] = get_pcvar_num(cvar_admin_apcost)
	g_iCvar_RocketAPCost[iPlayers] = get_pcvar_num(cvar_player_rocketapcost)
	g_iCvar_RocketAPCost[iAdmins] = get_pcvar_num(cvar_admin_rocketapcost)
}

public status_text(id)
{
	// Format text
	formatex(g_szStatusText[id], charsmax(g_szStatusText[]), "Con %d qua rocket", g_iRocketAmount[id])
	
	// Show
	message_begin(MSG_ONE, g_msgStatusText, _, id)
	write_byte(0)
	write_string((zp_get_user_nemesis(id) && g_bIsAlive[id] && g_bHoldingNRL[id] && g_iCurrentWeapon[id] == CSW_KNIFE) ? g_szStatusText[id] : "")
	message_end()
}

/*================================================================================
 [Client Commands]
=================================================================================*/

public cmd_nrlshop(id)
{
	// Show shop menu
	//////show_buy_menu(id)
}

public cmd_nrlhelp(id)
{
	// Show help menu
	//show_help_menu(id)
}

/*================================================================================
 [Menus]
=================================================================================*/	
	/*	
			// Give 1 Rocket
			g_iRocketAmount[id]++
			
			// Flash ammo in hud
			message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
			write_byte(AMMOID_HEGRENADE) // ammo id
			write_byte(1) // ammo amount
			message_end()
			
			// Play clip purchase sound
			emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Set Ammopacks
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) - iRocketCost)
*/		
/*================================================================================
 [Tasks]
=================================================================================*/

public remove_rockets_in_map()
{
	// Remove Rockets, and a particle effect + sound is emited
	static iRocket 
	iRocket = FM_NULLENT
	
	// Make a loop searching for rockets
	while((iRocket = find_ent_by_class(FM_NULLENT, "nrl_rocket")) != 0)
	{
		// Get rocket origin
		static Float:flOrigin[3]
		entity_get_vector(iRocket, EV_VEC_origin, flOrigin)
		
		// Slow tracers
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
		write_byte(TE_IMPLOSION) // TE id
		engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
		engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
		engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
		write_byte(200) // radius
		write_byte(40) // count
		write_byte(45) // duration
		message_end()
		
		// Faster particles
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
		write_byte(TE_PARTICLEBURST) // TE id
		engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
		engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
		engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
		write_short(45) // radius
		write_byte(108) // particle color
		write_byte(10) // duration * 10 will be randomized a bit
		message_end()
		
		// Remove beam
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, _, iRocket)
		write_byte(TE_KILLBEAM) // TE id
		write_short(iRocket) // entity
		message_end()
		
		// Sound
		emit_sound(iRocket, CHAN_WEAPON, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(iRocket, CHAN_VOICE, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		// Remove Entity
		remove_entity(iRocket)
	}
	
	// Remove rocket Flares
	remove_entity_name("nrl_rocket_flare")
}

/*public nrl_hudmessage(id)
{
	set_hudmessage(255, 0, 0, -1.0, 0.25, 2, 6.0, 10.0)
	ShowSyncHudMsg(id, g_iSyncMsg, "%L^n^n%L", id, g_bCvar_GiveFree ? "NRL_HUDMSG_USE" : "NRL_HUDMSG_BUY", id, "NRL_HUDMSG_HELP")	
}
*/
/*================================================================================
 [Main Events/Messages]
=================================================================================*/

public event_CurWeapon(id)
{	
	// Not alive...
	if(!g_bIsAlive[id])
		return PLUGIN_CONTINUE
		
	// Updating weapon array
	g_iCurrentWeapon[id] = read_data(2)
	
	// Not nemesis
	if(!zp_get_user_nemesis(id))
		return PLUGIN_CONTINUE
		
	// Doesn't have a NRL
	if(!g_bHasNRL[id])
		return PLUGIN_CONTINUE;
		
	// Weaponid is Knife
	if(g_iCurrentWeapon[id] == CSW_KNIFE)
	{
		// User is holding a Rocket Launcher
		if(g_bHoldingNRL[id])
		{
			entity_set_string(id, EV_SZ_viewmodel, "models/zombie_plague/v_stinger_frk14.mdl")
			entity_set_string(id, EV_SZ_weaponmodel, "models/zombie_plague/p_stinger_frk14.mdl")
		}
	}
		
	return PLUGIN_CONTINUE
}

public event_RoundStart()
{
	// Remove all the rockets in the map (if exists anyone)
	remove_rockets_in_map()
	
	// Cache Cvars
	cache_cvars()
	
	// Update var
	g_bRoundEnding = false
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	// Some vars
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	// Get truncated weapon
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	// Get attacker and victim
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	// Non-player attacker or self kill
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
		
	// Killed by world, usually executing Ham_Killed and killed by an nrl_rocket
	if(equal(szTruncatedWeapon, "world") && g_bKilledByRocket[iVictim])
	{
		// We don't need this again
		g_bKilledByRocket[iVictim] = false
		
		// Change "world" with "nrl_rocket"
		set_msg_arg_string(4, "rocket")
	}
		
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public client_putinserver(id) 
{
	// Reset Vars
	set_user_nrlauncher(id, 0)
	
	// User is connected
	g_bIsConnected[id] = true
}
	
public client_disconnect(id) 
{
	// Reset Vars
	set_user_nrlauncher(id, 0)
	
	// Disconnected user is not alive and is not connected
	g_bIsAlive[id] = false
	g_bIsConnected[id] = false
}

public fw_CmdStart(id, handle, seed)
{
	// Valid alive, or isn't nemesis?
	if(!is_user_valid_alive(id) || !zp_get_user_nemesis(id))
		return FMRES_IGNORED;
		
	// Current weapon isn't knife?
	if(g_iCurrentWeapon[id] != CSW_KNIFE)
		return FMRES_IGNORED
		
	// Has this gun?
	if(!g_bHasNRL[id])
		return FMRES_IGNORED
		
	// Get buttons and game time
	static iButton, Float:flCurrentTime
	iButton = get_uc(handle, UC_Buttons)
	flCurrentTime = get_gametime()
	
	// User pressing +attack Button
	if(iButton & IN_ATTACK)
	{
		// Isn't holding NRL, or round is ending
		if(!g_bHoldingNRL[id] || g_bRoundEnding)
			return FMRES_IGNORED
			
		// Reset buttons
		set_uc(handle, UC_Buttons, iButton & ~IN_ATTACK)
		
		// Launch rate not over yet
		if(flCurrentTime - g_flLastLaunchTime[id] < get_pcvar_float(cvar_launchrate))
			return FMRES_IGNORED
			
		// User have Rockets
		if(g_iRocketAmount[id] > 0)
		{
			// Launch a Rocket
			launch_nrl_rocket(id)
			g_iRocketAmount[id]--
			
			// Rocket launch push effect
			launch_push(id, get_pcvar_num(cvar_launchpush))
		}
		else
		{
			// Weapon Animation
			set_user_weaponanim(id, NRL_ANIM_IDLE)
			
			// Message
			client_print(id, print_center, "Het dan .... Het dan ......")
			
			// Emit Sound
			emit_sound(id, CHAN_VOICE, nrl_norockets_sound[random_num(0, sizeof nrl_norockets_sound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		
		g_flLastLaunchTime[id] = flCurrentTime
		
	}
	// User pressing +attack2 Button
	else if(iButton & IN_ATTACK2)
	{
		// Deploy rate not over yet
		if(flCurrentTime - g_flLastDeployTime[id] < 1.0)
			return FMRES_IGNORED

		// To Knife / Rocket Launcher
		change_melee(id, g_bHoldingNRL[id])
		
		g_flLastDeployTime[id] = flCurrentTime
	}
	
	return FMRES_IGNORED;
}

public fw_RocketTouch(rocket, toucher)
{	
	// Valid entity
	if(is_valid_ent(rocket))
	{
		// Some vars
		static iVictim, iKills, iAttacker
		static Float:flDamage, Float:flMaxDamage, Float:flDistance, Float:flFadeAlpha, Float:flRadius, Float:flVictimHealth
		static Float:flEntityOrigin[3]
	
		// Radius
		flRadius = get_pcvar_float(cvar_explo_radius)
			
		// Max Damage
		flMaxDamage = get_pcvar_float(cvar_explo_damage)
		
		// Get entity origin
		entity_get_vector(rocket, EV_VEC_origin, flEntityOrigin)
		
		// Get attacker
		iAttacker = entity_get_edict(rocket, EV_ENT_owner)
	
		// Create Blast
		rocket_blast(rocket, flEntityOrigin)
	
		// Prepare vars
		iKills = 0
		iVictim = -1
		
		// Toucher entity is valid and isn't worldspawn?
		if((toucher > 0) && is_valid_ent(toucher))
		{
			// Get toucher classname
			static szTchClass[33]
			entity_get_string(toucher, EV_SZ_classname, szTchClass, charsmax(szTchClass))
	
			// Is a breakable entity?
			if(equal(szTchClass, "func_breakable"))
			{
				// Destroy entity
				force_use(rocket, toucher)
			}
		
			// Player entity
			else if(equal(szTchClass, "player") && is_user_valid_alive(toucher))
			{
				// An human, and not with Godmode
				if(!zp_get_user_zombie(toucher) && !zp_get_user_survivor(toucher) && entity_get_float(toucher, EV_FL_takedamage) != DAMAGE_NO)
				{
					// Victim have been killed by a nrl_rocket
					g_bKilledByRocket[toucher] = true
						
					// Instantly kill
					iKills++
					ExecuteHamB(Ham_Killed, toucher, iAttacker, 2)
				}
			}
		}
		
		// Process explosion
		while((iVictim = find_ent_in_sphere(iVictim, flEntityOrigin, flRadius)) != 0)
		{
			// Non-player entity
			if(!is_user_valid_connected(iVictim))
				continue;
				
			// Alive, zombie or with Godmode
			if(!g_bIsAlive[iVictim] || (zp_get_user_zombie(iVictim) && iVictim != iAttacker) || entity_get_float(iVictim, EV_FL_takedamage) == DAMAGE_NO)
				continue;
			
			// Get distance between Entity and Victim
			flDistance = entity_range(rocket, iVictim)
	
			// Process damage and Screenfade Alpha
			flDamage = floatradius(flMaxDamage, flRadius, flDistance)
			flFadeAlpha = floatradius(255.0, flRadius, flDistance)
			flVictimHealth = entity_get_float(iVictim, EV_FL_health)
			
			// Damage is more than 0
			if(flDamage > 0) 
			{
				// Be killed, or be damaged
				if(flVictimHealth <= flDamage) 
				{
					// Victim have been killed by a nrl_rocket
					g_bKilledByRocket[iVictim] = true
					
					// Instantly kill
					iKills++
					ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2)
				}	
				else
				{
					// Make damage (not using HamB)
					ExecuteHam(Ham_TakeDamage, iVictim, rocket, iAttacker, flDamage, DMG_BLAST)
					
					// Screenfade
					if(get_pcvar_num(cvar_damage_fade))
					{
						message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, iVictim)
						write_short(UNIT_SECOND*1) // duration
						write_short(UNIT_SECOND*1) // hold time
						write_short(FFADE_IN) // fade type
						write_byte(200) // r
						write_byte(0) // g
						write_byte(0) // b
						write_byte(floatround(flFadeAlpha)) // alpha
						message_end()
					}
					
					// Screenshake
					if(get_pcvar_num(cvar_damage_shake))
					{
						message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, iVictim)
						write_short(UNIT_SECOND*2) // amplitude
						write_short(UNIT_SECOND*2) // duration
						write_short(UNIT_SECOND*2) // frequency
						message_end() 
					}
				}
			}
		}
	
		// Valid connected, alive, more than 1 kill, and is nemesis.
		if(is_user_valid_connected(iAttacker) && g_bIsAlive[iAttacker] && iKills != 0 && zp_get_user_nemesis(iAttacker))
		{
			// Check Cvar
			if(get_pcvar_num(cvar_bonushp))
			{
				// Get health value
				static iMultValue
				iMultValue = iKills * get_pcvar_num(cvar_bonushp)
				
				// Give Health
				entity_set_float(iAttacker, EV_FL_health, entity_get_float(iAttacker, EV_FL_health) + iMultValue)
				
				// Get attacker Origin
				static iOrigin[3]
				get_user_origin(iAttacker, iOrigin)
				
				// Tracers
				message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
				write_byte(TE_IMPLOSION) // TE id
				write_coord(iOrigin[0]) // x
				write_coord(iOrigin[1])  // y
				write_coord(iOrigin[2])  // z
				write_byte(iKills * 100) // radius
				write_byte(iMultValue) // count
				write_byte(5) // duration
				message_end()
				
				// Message
				//client_print(iAttacker, print_center, "[NRL] %L", iAttacker, "NRL_CPRINT_HEALTH", iKills, iMultValue)
			}		
		}
	
		// Detect flare
		static iFlare
		iFlare = entity_get_edict(rocket, EV_ENT_FLARE)
			
		// Check and remove Flare
		if(is_valid_ent(iFlare)) 
			remove_entity(iFlare)
				
		// Remove rocket
		remove_entity(rocket)
	}
}

public client_PreThink(id)
{
	// Appear Status Text with rocket num
	if(g_bIsAlive[id] && zp_get_user_nemesis(id) && g_bHasNRL[id] && g_bHoldingNRL[id])
		status_text(id)
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	// Victim is not alive
	g_bIsAlive[victim] = false
	
	// Victim has holding the Rocket Launcher
	if(g_bHasNRL[victim]) 
	{
		// Only remove
		status_text(victim)
		
		// Reset Vars
		set_user_nrlauncher(victim, 0)
	}
}

public fw_KnifePrimaryAttack(knife)
{
	// Get Owner...
	static iOwner 
	iOwner = entity_get_edict(knife, EV_ENT_owner)
	
	// Block knife Slash when user is holding the Rocket Launcher
	if(zp_get_user_nemesis(iOwner) && g_bHoldingNRL[iOwner])
		return HAM_SUPERCEDE;
		
	return HAM_IGNORED
}

public fw_KnifeSecondaryAttack(knife)
{
	// Get Owner...
	static iOwner 
	iOwner = entity_get_edict(knife, EV_ENT_owner)
	
	// Block secondary attack
	if(zp_get_user_nemesis(iOwner) && g_bHasNRL[iOwner])
		return HAM_SUPERCEDE
		
	return HAM_IGNORED
}

public fw_PlayerSpawn_Post(id)
{
	// Not alive...
	if(!is_user_alive(id))
		return HAM_IGNORED
		
	// Player is alive
	g_bIsAlive[id] = true
	
	// Remove Rocket Launcher when user is spawned
	if(g_bHasNRL[id])
	{
		// Remove center text
		status_text(id)
		
		// Reset Vars
		set_user_nrlauncher(id, 0)
		
		// Attempt model to reset
		reset_user_knife(id)
	}
	
	return HAM_IGNORED
}

public fw_Impulse(id)
{
	// User press Spray Button
	/*if(zp_get_user_nemesis(id) && g_bIsAlive[id] && g_bCvar_Enabled)
	{
		// Show NRL Shop
		//show_buy_menu(id)
		
		// Block spray
		return PLUGIN_HANDLED
	}
*/
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Internal Functions]
=================================================================================*/

get_nrl_defrockets(id)
{
	return g_bCvar_AdminFeatures ? (get_user_flags(id) & ACCESS_FLAG ? g_iCvar_DefaultRockets[iAdmins] : g_iCvar_DefaultRockets[iPlayers]) : g_iCvar_DefaultRockets[iPlayers]
}

/*get_nrl_guncost(id)
{
	return g_bCvar_AdminFeatures ? (get_user_flags(id) & ACCESS_FLAG ? g_iCvar_APCost[iAdmins] : g_iCvar_APCost[iPlayers]) : g_iCvar_APCost[iPlayers]
}

get_nrl_rocketcost(id)
{
	return g_bCvar_AdminFeatures ? (get_user_flags(id) & ACCESS_FLAG ? g_iCvar_RocketAPCost[iAdmins] : g_iCvar_RocketAPCost[iPlayers]) : g_iCvar_RocketAPCost[iPlayers]
}
*/
launch_nrl_rocket(id)
{
	// Fire Effect
	entity_set_vector(id, EV_VEC_punchangle, Float:{ -10.5, 0.0, 0.0 })
	set_user_weaponanim(id, NRL_ANIM_FIRE) 
	
	// Some vars
	static Float:flOrigin[3], Float:flAngles[3], Float:flVelocity[3]
	
	// Get position from eyes (agreeing to rocket launcher model)
	get_user_eye_position(id, flOrigin)
	
	// Get View Angles
	entity_get_vector(id, EV_VEC_v_angle, flAngles)
	
	// Create the Entity
	new iEnt = create_entity("info_target")
	
	// Set Entity Classname
	entity_set_string(iEnt, EV_SZ_classname, "nrl_rocket")
	
	// Set Rocket Model
	entity_set_model(iEnt, nrl_rocketmodel)
	
	// Set Entity Size
	set_size(iEnt, nrl_rocket_mins, nrl_rocket_maxs)
	entity_set_vector(iEnt, EV_VEC_mins, nrl_rocket_mins)
	entity_set_vector(iEnt, EV_VEC_maxs, nrl_rocket_maxs)
	
	// Set Entity Origin
	entity_set_origin(iEnt, flOrigin)
	
	// Set Entity Angles (thanks to Arkshine)
	make_vector(flAngles)
	entity_set_vector(iEnt, EV_VEC_angles, flAngles)
	
	// Make a Solid Entity
	entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX)
	
	// Set a Movetype
	entity_set_int(iEnt, EV_INT_movetype, get_pcvar_num(cvar_rocket_grav) ? MOVETYPE_TOSS : MOVETYPE_FLY)
	
	// Gravity
	entity_set_float(iEnt, EV_FL_gravity, 0.1) // Gravity works only if entity movetype is MOVETYPE_TOSS (and anothers)
	
	// Set Entity Owner (Launcher)
	entity_set_edict(iEnt, EV_ENT_owner, id)
	
	// Emit Launch Sound
	emit_sound(iEnt, CHAN_VOICE, nrl_rocketfly_sound[random_num(0, sizeof nrl_rocketfly_sound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(iEnt, CHAN_WEAPON, nrl_rocketlaunch_sound[random_num(0, sizeof nrl_rocketlaunch_sound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Get velocity result
	static iVelocityResult
	iVelocityResult = clamp(get_pcvar_num(cvar_rocket_vel), 50, get_pcvar_num(cvar_svvel))
	
	// Set Entity Velocity
	velocity_by_aim(id, iVelocityResult, flVelocity)
	entity_set_vector(iEnt, EV_VEC_velocity, flVelocity)
	
	// Glow
	if(get_pcvar_num(cvar_rocket_glow))
		set_rendering(iEnt, kRenderFxGlowShell, nrl_glow_colors[0], nrl_glow_colors[1], nrl_glow_colors[2], kRenderNormal, 50)
		
	// Flare
	if(get_pcvar_num(cvar_rocket_flare))
		entity_set_edict(iEnt, EV_ENT_FLARE, create_flare(iEnt, nrl_flare_colors))
	
	// Dynamic Light
	if(get_pcvar_num(cvar_rocket_dlight))
		entity_set_int(iEnt, EV_INT_effects, entity_get_int(iEnt, EV_INT_effects) | EF_BRIGHTLIGHT)	
		
	// Trail
	if(get_pcvar_num(cvar_rocket_trail))
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(iEnt) // entity:attachment to follow
		write_short(g_sprTrail) // sprite index
		write_byte(30) // life in 0.1's
		write_byte(3) // line width in 0.1's
		write_byte(nrl_trail_colors[0]) // r
		write_byte(nrl_trail_colors[1]) // g
		write_byte(nrl_trail_colors[2]) // b
		write_byte(200) // brightness
		message_end()
	}
}

change_melee(id, bool:to_knife)
{
	// Update var
	g_bHoldingNRL[id] = !to_knife
	
	// Reset the User's knife (attempt model to reset)
	reset_user_knife(id)
	
	// Reset Status Text
	status_text(id)
	
	// Message
	client_print(id, print_center, "%s", to_knife ? "Cao nat doi hinh doi phuong" : "Ban nat doi hinh doi phuong")
	
	// Sound
	emit_sound(id, CHAN_VOICE, nrl_deploy_sound[random_num(0, sizeof nrl_deploy_sound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

create_flare(rocket, iRGB[3]) // Thanks to hlstriker for the code!
{
	// Entity
	new iEnt = create_entity("env_sprite")
	
	// Is a valid Entity
	if(!is_valid_ent(iEnt))
		return 0
		
	// Set Model
	entity_set_model(iEnt, "sprites/animglow01.spr")
	
	// Set Classname
	entity_set_string(iEnt, EV_SZ_classname, "nrl_rocket_flare")
	
	// Sprite Scale
	entity_set_float(iEnt, EV_FL_scale, 0.7)
		
	// Entity Spawn Flags
	entity_set_int(iEnt, EV_INT_spawnflags, SF_SPRITE_STARTON)
	
	// Solid style
	entity_set_int(iEnt, EV_INT_solid, SOLID_NOT)
	
	// Entity Movetype
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW)
	
	// Entity aiment
	entity_set_edict(iEnt, EV_ENT_aiment, rocket)
	
	// Animation frame rate
	entity_set_float(iEnt, EV_FL_framerate, 30.0)
	
	// Color
	set_rendering(iEnt, kRenderFxNone, iRGB[0], iRGB[1], iRGB[2], kRenderTransAdd, 255)
	
	// Now the entity need to be spawned
	DispatchSpawn(iEnt)

	return iEnt
}

rocket_blast(entity, Float:flOrigin[3])
{
	// Explosion
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte(TE_EXPLOSION) // TE id
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
	write_short(g_sprExplosion)	// sprite index
	write_byte(120)	// scale in 0.1's	
	write_byte(10)	// framerate	
	write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS) // flags
	message_end() 
	
	// Stop rocket fly sound with new explosion sound
	emit_sound(entity, CHAN_WEAPON, nrl_explosion_sound[random_num(0, sizeof nrl_explosion_sound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(entity, CHAN_VOICE, nrl_explosion_sound[random_num(0, sizeof nrl_explosion_sound - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// World Decal
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte(TE_WORLDDECAL) // TE id
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
	write_byte(random_num(46, 48)) // texture index of precached decal texture name
	message_end() 

	// Rings
	if(get_pcvar_num(cvar_explo_rings))
	{
		static j
		for(j = 0; j < 3; j++)
		{
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
			write_byte(TE_BEAMCYLINDER) // TE id
			engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
			engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
			engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
			engfunc(EngFunc_WriteCoord, flOrigin[0]) // x axis
			engfunc(EngFunc_WriteCoord, flOrigin[1]) // y axis
			engfunc(EngFunc_WriteCoord, flOrigin[2] + g_flRingZAxis_Add[j]) // z axis
			write_short(g_sprRing) // sprite
			write_byte(0) // startframe
			write_byte(0) // framerate
			write_byte(4) // life
			write_byte(60) // width
			write_byte(0) // noise
			write_byte(nrl_ring_colors[0]) // red
			write_byte(nrl_ring_colors[1]) // green
			write_byte(nrl_ring_colors[2]) // blue
			write_byte(200) // brightness
			write_byte(0) // speed
			message_end()
		}
	}
	
	// Colored Dynamic Light
	if(get_pcvar_num(cvar_explo_dlight))
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
		write_byte(TE_DLIGHT) // TE id
		engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
		engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
		engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
		write_byte(50) // radius
		write_byte(nrl_dlight_colors[0]) // red
		write_byte(nrl_dlight_colors[1]) // green
		write_byte(nrl_dlight_colors[2]) // blue
		write_byte(10) // life
		write_byte(45) // decay rate
		message_end()
	}
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock get_user_eye_position(id, Float:flOrigin[3])
{
	static Float:flViewOffs[3]
	entity_get_vector(id, EV_VEC_view_ofs, flViewOffs)
	entity_get_vector(id, EV_VEC_origin, flOrigin)
	xs_vec_add(flOrigin, flViewOffs, flOrigin)
}

stock make_vector(Float:flVec[3])
{
	flVec[0] -= 30.0
	engfunc(EngFunc_MakeVectors, flVec)
	flVec[0] = -(flVec[0] + 30.0)
}

stock set_user_weaponanim(id, iAnim)
{
	entity_set_int(id, EV_INT_weaponanim, iAnim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(entity_get_int(id, EV_INT_body))
	message_end()
}

stock set_user_nrlauncher(id, active)
{
	if(!active)
	{
		g_bHasNRL[id] = false
		g_bHoldingNRL[id] = false
		g_iRocketAmount[id] = 0
	}
	else
	{
		g_bHasNRL[id] = true
		g_bHoldingNRL[id] = false
		g_iRocketAmount[id] = get_nrl_defrockets(id)
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
		write_byte(AMMOID_HEGRENADE) // ammo id
		write_byte(g_iRocketAmount[id]) // ammo amount
		message_end()
		
		emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		//set_task(1.5, "nrl_hudmessage", id)
		//client_printcolor(id, "/g[ZP][NRL]/y %L", id, "NRL_PRINT_USE")
		//client_printcolor(id, "/g[ZP][NRL]/y %L", id, "NRL_PRINT_HELP")
	}
}

stock launch_push(id, velamount)
{
	static Float:flNewVelocity[3], Float:flCurrentVelocity[3]
	
	velocity_by_aim(id, -velamount, flNewVelocity)
	
	get_user_velocity(id, flCurrentVelocity)
	xs_vec_add(flNewVelocity, flCurrentVelocity, flNewVelocity)
	
	set_user_velocity(id, flNewVelocity)	
}

stock client_printcolor(id, const input[], any:...)
{
	static iPlayersNum[32], iCount; iCount = 1
	static szMsg[191]
	
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	replace_all(szMsg, 190, "/g", "^4") // green txt
	replace_all(szMsg, 190, "/y", "^1") // orange txt
	replace_all(szMsg, 190, "/ctr", "^3") // team txt
	replace_all(szMsg, 190, "/w", "^0") // team txt
	
	if(id) iPlayersNum[0] = id
	else get_players(iPlayersNum, iCount, "ch")
		
	for (new i = 0; i < iCount; i++)
	{
		if (g_bIsConnected[iPlayersNum[i]])
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, iPlayersNum[i])
			write_byte(iPlayersNum[i])
			write_string(szMsg)
			message_end()
		}
	}
}

stock register_say_command(const szCommand[], const szHandle[], const iFlags=-1, const szDescription[]="", const iFlagManager=-1)
{
	static szTemp[64];
	
	formatex(szTemp, 63, "say /%s", szCommand);
	register_clcmd(szTemp, szHandle, iFlags, szDescription, iFlagManager);
	
	formatex(szTemp, 63, "say .%s", szCommand);
	register_clcmd(szTemp, szHandle, iFlags, szDescription, iFlagManager);
	
	formatex(szTemp, 63, "say_team /%s", szCommand);
	register_clcmd(szTemp, szHandle, iFlags, szDescription, iFlagManager);
	
	formatex(szTemp, 63, "say_team .%s", szCommand);
	register_clcmd(szTemp, szHandle, iFlags, szDescription, iFlagManager);
}

stock Float:floatradius(Float:flMaxAmount, Float:flRadius, Float:flDistance)
{
	return floatsub(flMaxAmount, floatmul(floatdiv(flMaxAmount, flRadius), flDistance))
}
