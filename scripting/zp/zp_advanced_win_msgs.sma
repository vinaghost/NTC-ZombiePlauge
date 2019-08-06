#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <zp_dsohud>
#include <zombieplague>

// Win sprites dirs'
new const g_zombie_win[] = "sprites/zombie_plague/zombie_win.spr"
new const g_human_win[] = "sprites/zombie_plague/human_win.spr"

new g_maxplayers

public plugin_init()
{
	register_plugin("[ZP] Advanced Win Msgs.", "1.0", "@bdul!");
	
	// Round start event
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	// Retrieve max players
	g_maxplayers = get_maxplayers()
}

// Prechache the sprites
public plugin_precache()
{
	precache_model(g_zombie_win)
	precache_model(g_human_win)
}

// Remove win sprites on new round
public event_round_start()
{
	static id
	for (id = 1; id <= g_maxplayers; id++)
		zp_remove_hud_sprite(id)
}

public zp_round_ended(win_team)
{
	// No one won ?
	if (win_team == WIN_NO_ONE)
		return
	
	// Set the sprites on players HUD
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (win_team == WIN_HUMANS)
			zp_display_hud_sprite(id, g_human_win, 0.04)
		else
			zp_display_hud_sprite(id, g_zombie_win, 0.05)
	}
}