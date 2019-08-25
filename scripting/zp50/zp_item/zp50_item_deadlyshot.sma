#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>
#include <zp50_items>
#include <zp50_colorchat>

#define TASK_HUD 534
#define TASK_REMOVE 242
#define TASK_COOLDOWN 241

#define SPRAY 201

new g_has;
new g_activing, g_active;

new sync_hud1
new cvar_deadlyshot_time
new cvar_deadlyshot_cooldown

new g_deadlyshot
const PEV_SPEC_TARGET = pev_iuser2

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Deadly Shot (Human)", "1.0", "Dias")
	RegisterHam(Ham_TraceAttack, "player", "fw_traceattack")

	cvar_deadlyshot_time = register_cvar("ds_time", "10.0")
	cvar_deadlyshot_cooldown = register_cvar("ds_cooldown", "60.0")

	//register_clcmd("drop", "active")

	sync_hud1 = CreateHudSyncObj()
	g_deadlyshot = zp_ap_items_register("Deadly Shot", 15)
}

public zp_fw_ap_items_select_pre(id, itemid) {
	if(itemid != g_deadlyshot)
		return ZP_ITEM_AVAILABLE;

	if( zp_core_is_zombie(id) ) return ZP_ITEM_DONT_SHOW;

	if(!Get_BitVar(g_has,id) )
		return ZP_ITEM_AVAILABLE

	return ZP_ITEM_NOT_AVAILABLE;
}
public zp_fw_ap_items_select_post(id, itemid)
{
	if(itemid != g_deadlyshot)
		return PLUGIN_HANDLED

	Set_BitVar(g_has,id);
	Set_BitVar(g_active,id);

	set_task(1.5, "Show_Skill", id+TASK_HUD, _, _, "b")


	return PLUGIN_CONTINUE
}

public Show_Skill(taskid)
{
	new player = taskid - TASK_HUD;

	// Player dead?
	if (!is_user_alive(player))
	{
		// Get spectating target
		player = pev(player, PEV_SPEC_TARGET)

		// Target not alive
		if (!is_user_alive(player))
			return;
	}

	if (!zp_core_is_zombie(player)) // zombies
	{
		Show_Skill_Player(player)
	}

}

public Show_Skill_Player(id)
{
	if( Get_BitVar(g_has, id ) )
	{
		if( Get_BitVar(g_activing, id) ) {
			set_hudmessage(0, 0, 255, 0.1, 0.19, 0, 1.5, 1.5, 0.0, 0.0, -1)
		}
		else if(Get_BitVar(g_active, id)) {
			set_hudmessage(0, 255, 0, 0.1, 0.19, 0, 1.5, 1.5, 0.0, 0.0, -1)
		}
		else {
			set_hudmessage(255, 0, 0, 0.1, 0.19, 0, 1.5, 1.5, 0.0, 0.0, -1)
		}

		ShowSyncHudMsg(id, sync_hud1, "[T] Deadly Shot")
	}
}

public client_impulse(id, impulse)
{
	if(impulse == SPRAY)
	{
		active(id)
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
public active(id)
{
	if(Get_BitVar(g_has,id) && Get_BitVar(g_active, id) )
	{
		UnSet_BitVar(g_active,id)
		Set_BitVar(g_activing,id)

		set_task(get_pcvar_float(cvar_deadlyshot_time), "remove_headshot_mode", id+TASK_REMOVE)
		set_task(get_pcvar_float(cvar_deadlyshot_cooldown), "remove_cooldown", id+TASK_COOLDOWN)
	}

}

public fw_traceattack(victim, attacker, Float:damage, direction[3], traceresult, dmgbits)
{
	if(Get_BitVar(g_has,attacker) && Get_BitVar(g_activing,attacker))
	{
		set_tr2(traceresult, TR_iHitgroup, HIT_HEAD)
	}
}

public remove_cooldown(id) {
	id -= TASK_COOLDOWN

	Set_BitVar(g_active,id)
}
public remove_headshot_mode(id)
{
	id -= TASK_REMOVE

	UnSet_BitVar(g_activing,id)
}
