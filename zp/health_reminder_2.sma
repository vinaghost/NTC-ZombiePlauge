#include <amxmodx>
#include <zombieplague>

#define TASK_HEALTH 1994

new g_iSyncHud

public plugin_init() 
{
	register_plugin("[ZP] Health Reminder (4 in 1)", "1.0", "zmd94")
	
	register_event("DeathMsg", "event_death", "a", "1>0")
		
	g_iSyncHud = CreateHudSyncObj()
}

public zp_round_started(gamemode, id)
{
	set_task(1.0, "ShowHealth", id + TASK_HEALTH, _, _, "b")
}

public event_death(id) 
	remove_task(id+TASK_HEALTH)
	
public ShowHealth(id)
{
	id -= TASK_HEALTH
	if(is_user_alive(id))
	{
		set_hudmessage(0, 255, 0, -1.0, 0.20, 0, 6.0, 2.0, 0.0, 0.0, -1)
		
		if(zp_get_user_nemesis(id))
		{
			ShowSyncHudMsg(0, g_iSyncHud, "Nemesis: %d HP", get_user_health(id))
		}
		else if (zp_get_user_survivor(id))
		{
			ShowSyncHudMsg(0, g_iSyncHud, "Survivor: %d HP", get_user_health(id))
		}
		else if (zp_get_user_sniper(id))
		{
			ShowSyncHudMsg(0, g_iSyncHud, "Sniper: %d HP", get_user_health(id))
		}
	}
}
