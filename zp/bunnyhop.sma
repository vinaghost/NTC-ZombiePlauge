/*
 *
 *	Author:		Cheesy Peteza
 *	Date:		22-Apr-2004 (updated 2-March-2005)
 *
 *
 *	Description:	Enable bunny hopping in Counter-Strike.
 *
 *	Cvars:
 *			bh_enabled		1 to enable this plugin, 0 to disable.
 *			bh_autojump		If set to 1 players just need to hold down jump to bunny hop (no skill required)
 *			bh_showusage		If set to 1 it will inform joining players that bunny hopping has been enabled
 *						and how to use it if bh_autojump enabled.
 *
 *	Requirements:	AMXModX 0.16 or greater
 *
 *
 */

#include <amxmodx>
#include <engine>
#include <zp50_core>

public plugin_init() {
	register_plugin("Super Bunny Hopper", "1.2", "Cheesy Peteza")
}

public client_PreThink(id) {
	if ( !is_user_alive(id) ) return PLUGIN_CONTINUE
	if ( zp_core_is_zombie(id) ) return PLUGIN_CONTINUE

	entity_set_float(id, EV_FL_fuser2, 0.0)		// Disable slow down after jumping
	return PLUGIN_HANDLED
}
