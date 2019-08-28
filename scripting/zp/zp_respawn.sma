#include <amxmodx>
#include <zombieplague>
#include <zp50_gamemodes>
#define validTeam(%1) (1 <= get_user_team(%1) <= 3)


public plugin_init()
{
	register_plugin("[ZP] Respawn", "1.1", "ILUSION");
}

public client_putinserver(id)
	set_task(5.0, "SpawnUser", id, _, _, "b");

public SpawnUser(id)
{
	if (!is_user_connected(id))
		remove_task(id);
	else if (!validTeam(id))
		return;
	else if (is_user_alive(id) || zp_is_nemesis_round() )
		remove_task(id);
	else
	{
		if( zp_gamemodes_get_current() == ZP_INVALID_GAME_MODE )
			zp_respawn_user(id, ZP_TEAM_HUMAN);
		else
			zp_respawn_user(id, ZP_TEAM_ZOMBIE);

		remove_task(id);
	}
}
