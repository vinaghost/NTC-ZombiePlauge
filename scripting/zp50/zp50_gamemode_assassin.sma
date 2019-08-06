/*================================================================================
	
	-------------------------------
	-*- [ZP] Game Mode: Assassin -*-
	-------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <amx_settings_api>
#include <cs_teams_api>
#include <zp50_gamemodes>
#include <zp50_class_assassin>
#include <zp50_deathmatch>

// Settings file
new const ZP_SETTINGS_FILE[] = "zombieplague.ini"

// Default sounds
new const sound_assassin[][] = { "zombie_plague/nemesis1.wav" , "zombie_plague/nemesis2.wav" }

#define SOUND_MAX_LENGTH 64

new Array:g_sound_assassin

// HUD messages
#define HUD_EVENT_X -1.0
#define HUD_EVENT_Y 0.17
#define HUD_EVENT_R 255
#define HUD_EVENT_G 20
#define HUD_EVENT_B 20

new g_MaxPlayers
new g_HudSync
new g_TargetPlayer
new g_LValue[2]

new cvar_assassin_chance, cvar_assassin_min_players
new cvar_assassin_show_hud, cvar_assassin_sounds
new cvar_assassin_allow_respawn

public plugin_precache()
{
	// Register game mode at precache (plugin gets paused after this)
	register_plugin("[ZP] Game Mode: Assassin", ZP_VERSION_STRING, "ZP Dev Team")
	zp_gamemodes_register("Assassin Mode")
	
	// Create the HUD Sync Objects
	g_HudSync = CreateHudSyncObj()
	
	g_MaxPlayers = get_maxplayers()
	
	cvar_assassin_chance = register_cvar("zp_assassin_chance", "20")
	cvar_assassin_min_players = register_cvar("zp_assassin_min_players", "0")
	cvar_assassin_show_hud = register_cvar("zp_assassin_show_hud", "1")
	cvar_assassin_sounds = register_cvar("zp_assassin_sounds", "1")
	cvar_assassin_allow_respawn = register_cvar("zp_assassin_allow_respawn", "0")
	
	// Initialize arrays
	g_sound_assassin = ArrayCreate(SOUND_MAX_LENGTH, 1)
	
	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ASSASSIN", g_sound_assassin)
	
	// If we couldn't load custom sounds from file, use and save default ones
	new index
	if (ArraySize(g_sound_assassin) == 0)
	{
		for (index = 0; index < sizeof sound_assassin; index++)
			ArrayPushString(g_sound_assassin, sound_assassin[index])
		
		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ASSASSIN", g_sound_assassin)
	}
	
	// Precache sounds
	new sound[SOUND_MAX_LENGTH]
	for (index = 0; index < ArraySize(g_sound_assassin); index++)
	{
		ArrayGetString(g_sound_assassin, index, sound, charsmax(sound))
		if (equal(sound[strlen(sound)-4], ".mp3"))
		{
			format(sound, charsmax(sound), "sound/%s", sound)
			precache_generic(sound)
		}
		else
			precache_sound(sound)
	}
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(id)
{
	// Respawning allowed?
	if (!get_pcvar_num(cvar_assassin_allow_respawn))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public zp_fw_core_spawn_post(id)
{
	// Always respawn as human on assassin rounds
	zp_core_respawn_as_zombie(id, false)
}

public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
	if (!skipchecks)
	{
		// Random chance
		if (random_num(1, get_pcvar_num(cvar_assassin_chance)) != 1)
			return PLUGIN_HANDLED;
		
		// Min players
		if (GetAliveCount() < get_pcvar_num(cvar_assassin_min_players))
			return PLUGIN_HANDLED;
	}
	
	// Game mode allowed
	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_post(game_mode_id, target_player)
{
	// Pick player randomly?
	g_TargetPlayer = (target_player == RANDOM_TARGET_PLAYER) ? GetRandomAlive(random_num(1, GetAliveCount())) : target_player
}

public zp_fw_gamemodes_start()
{	
	// Turn player into survivor
	zp_class_assassin_set(g_TargetPlayer)
	
	// Remaining players should be humans (CTs)
	new id
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		// Not alive
		if (!is_user_alive(id))
			continue;
		
		// This is our assassin
		if (zp_class_assassin_get(id))
			continue;
		
		// Switch to CT
		cs_set_player_team(id, CS_TEAM_CT)
	}
	
	// Play assassin sound
	if (get_pcvar_num(cvar_assassin_sounds))
	{
		new sound[SOUND_MAX_LENGTH]
		ArrayGetString(g_sound_assassin, random_num(0, ArraySize(g_sound_assassin) - 1), sound, charsmax(sound))
		PlaySoundToClients(sound)
	}
	
	if (get_pcvar_num(cvar_assassin_show_hud))
	{
		// Show assassin HUD notice
		new name[32]
		get_user_name(g_TargetPlayer, name, charsmax(name))
		set_hudmessage(HUD_EVENT_R, HUD_EVENT_G, HUD_EVENT_B, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_HudSync, "%L", LANG_PLAYER, "NOTICE_ASSASSIN", name)
	}

	// Setting Dark Lightning For The Mode
	get_cvar_string ( "zp_lighting", g_LValue , 2 )
	if ( !equali( "g_LValue" , "a" ) )
	{

		set_cvar_string ( "zp_lighting" , "a" )

	}
}

// Plays a sound on clients
PlaySoundToClients(const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(0, "spk ^"%s^"", sound)
}

// Get Alive Count -returns alive players number-
GetAliveCount()
{
	new iAlive, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
	
	return iAlive;
}

// Get Random Alive -returns index of alive player number target_index -
GetRandomAlive(target_index)
{
	new iAlive, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id))
			iAlive++
		
		if (iAlive == target_index)
			return id;
	}
	
	return -1;
}

public zp_fw_gamemodes_end()
{
	// Setting The lighting Settings as before the Mode.
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))

	server_cmd("exec %s/zombieplague.cfg", cfgdir)
}
