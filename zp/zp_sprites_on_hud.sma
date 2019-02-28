/***************************************************************************\
		    ====================================		   
		     * || [ZP] Sprites On HUD v1.1 || *
		    ====================================
				*by @bdul!*

	-------------------
	 *||DESCRIPTION||*
	-------------------

	This plugins allows you to display a sprite on a user's HUD display
	It also features an easy-to-use API natives include file
	Animated sprites are also supported
	
	---------------
	 *||CREDITS||*
	---------------

	- MeRcyLeZZ -----------> For his awesome Zombie Plague Mod
	- Quim' / Conner ------> For helping me in vector calculations and
				 helping me with FM_AddToFullPack forward
	- Arkshine ------------> For helping me with animating sprites

	------------------
	 *||CHANGE LOG||*
	------------------
	
	v1.0 ====> Initial Release
	v1.1 ====> Added support for animated sprites
	
\***************************************************************************/

#include <amxmodx>
#include <fakemeta>
#include <xs>

// Distance at which the sprite is placed from the users screen
// DO NOT EDIT UNNECESSARILY!
#define DISTANCE 	12

new g_player_ent[33], g_bit_connected_user, g_stop_frame[33]

// Connected players macros
#define player_is_connected(%1)		(g_bit_connected_user |=  (1 << (%1 & 31)))
#define player_disconnected(%1)		(g_bit_connected_user &= ~(1 << (%1 & 31)))
#define is_player_connected(%1)		((1 <= %1 <= 32) && (g_bit_connected_user & (1 << (%1 & 31))))

public plugin_init() 
{
	// Register the plugin and the main forward
	register_plugin("[ZP] Addon: Sprites On HUD", "1.0", "@bdul!");
	register_forward(FM_AddToFullPack, "fm_add_to_fullpack", 1)
}

public plugin_natives()
{
	// Lets register some natives
	register_native("zp_display_hud_sprite", "native_display_hud_sprite", 1)
	register_native("zp_remove_hud_sprite", "native_remove_hud_sprite", 1)
}

public fm_add_to_fullpack(es, e, ent, host, host_flags, player, p_set)
{
	// Valid player ?
	if (!is_player_connected(host))
		return FMRES_IGNORED;
	
	// Player haves a valid sprite entity
	if (ent == g_player_ent[host])
	{
		static Float:origin[3], Float:forvec[3], Float:voffsets[3]
		
		// Retrieve player's origin
		pev(host, pev_origin, origin)
		pev(host, pev_view_ofs, voffsets)
		xs_vec_add(origin, voffsets, origin)
		
		// Get a forward vector in the direction of player's aim
		velocity_by_aim(host, DISTANCE, forvec)
		
		// Set the sprite on the new origin
		xs_vec_add(origin, forvec, origin)
		engfunc(EngFunc_SetOrigin, ent, origin)
		set_es(es, ES_Origin, origin)
		
		// Make the sprite visible
		set_es(es, ES_RenderMode, kRenderNormal)
		set_es(es, ES_RenderAmt, 200)
		
		// Sprite animation already stopped ?
		if (!g_stop_frame[host])
			return FMRES_IGNORED
		
		// Stop the animation at the desired frame
		if (pev(ent, pev_frame) == g_stop_frame[host])
		{
			set_pev(ent, pev_framerate, 0.0)
			g_stop_frame[host] = 0
		}
	}
	
	// Stupid compiler !!
	return FMRES_IGNORED
}

public client_putinserver(id)
{
	// Player connected
	player_is_connected(id)
	
	// Marks bots as disconnected players (so sprites are'nt displayed to them)
	if (is_user_bot(id)) player_disconnected(id)
	
	// Remove sprite entity if present
	if (pev_valid(g_player_ent[id]))
		remove_sprite_entity(id)
}

public client_disconnect(id)
{
	// Player disconnected
	player_disconnected(id)
	
	// Remove sprite entity if present
	if (pev_valid(g_player_ent[id]))
		remove_sprite_entity(id)
}

public native_display_hud_sprite(id, const sprite_name[], Float:sprite_size, sprite_stopframe, Float:sprite_framerate)
{
	// Invalid player ?
	if (!is_player_connected(id))
		return -1;
	
	// Already haves a sprite on his hud
	if (g_player_ent[id])
		return -1;
	
	// Strings passed byref
	param_convert(2)
	
	// Invalid sprite ?
	if (!sprite_name[0])
		return -1;
	
	// Create an entity for the player
	g_player_ent[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	// Invalid entity ?
	if (!pev_valid(g_player_ent[id]))
		return -1;
	
	// Set some basic properties
	set_pev(g_player_ent[id], pev_takedamage, 0.0)
	set_pev(g_player_ent[id], pev_solid, SOLID_NOT)
	set_pev(g_player_ent[id], pev_movetype, MOVETYPE_NONE)
	
	// Set the sprite model
	engfunc(EngFunc_SetModel, g_player_ent[id], sprite_name)
	
	// Set the rendering on the entity
	set_pev(g_player_ent[id], pev_rendermode, kRenderTransAlpha)
	set_pev(g_player_ent[id], pev_renderamt, 0.0)
	
	// Set the sprite size
	set_pev(g_player_ent[id], pev_scale, sprite_size)
	
	// Update sprite's stopping frame
	g_stop_frame[id] = sprite_stopframe
	
	// Allow animation of sprite ?
	if (g_stop_frame[id] && sprite_framerate > 0.0)
	{
		// Set the sprites animation time, framerate and stop frame
		set_pev(g_player_ent[id], pev_animtime, get_gametime())
		set_pev(g_player_ent[id], pev_framerate, sprite_framerate)
		
		// Spawn the sprite entity (necessary to play the sprite animations)
		set_pev(g_player_ent[id], pev_spawnflags, SF_SPRITE_STARTON)
		dllfunc(DLLFunc_Spawn, g_player_ent[id])
	}
	
	return g_player_ent[id];
}

public native_remove_hud_sprite(id)
{
	// Invalid player ?
	if (!is_player_connected(id))
		return -1;
	
	// Doesnt haves any sprite on his screen ?
	if (!pev_valid(g_player_ent[id]))
		return -1;
	
	// Remove sprite entity
	remove_sprite_entity(id)
	
	return 1;
}

// Removes a sprite entity from world
remove_sprite_entity(id)
{
	engfunc(EngFunc_RemoveEntity, g_player_ent[id])
	
	g_player_ent[id] = 0
	g_stop_frame[id] = 0
}
