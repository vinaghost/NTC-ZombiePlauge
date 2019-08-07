#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_core>
#include <zp50_items>
#include <zp50_colorchat>

#define TASK_HUD 5345634
#define TASK_REMOVE 2423423

#define SPRAY 201

new has_item
new using_item

new sync_hud1
new cvar_deadlyshot_time

new g_deadlyshot

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Deadly Shot (Human)", "1.0", "Dias")

	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	RegisterHam(Ham_TraceAttack, "player", "fw_traceattack")

	cvar_deadlyshot_time = register_cvar("ds_time", "10.0")

	//register_clcmd("drop", "active")

	sync_hud1 = CreateHudSyncObj(random_num(1, 10))
	g_deadlyshot = zp_ap_items_register("Deadly Shot", 15)
}

public event_newround(id)
{
	remove_ds(id)
}
public zp_fw_ap_items_select_pre(id, itemid) {
	if(itemid != g_deadlyshot)
		return ZP_ITEM_AVAILABLE;

	if( zp_core_is_zombie(id) ) return ZP_ITEM_DONT_SHOW;

	if(!Get_BitVar(has_item,id) || Get_BitVar(using_item,id) )
		return ZP_ITEM_AVAILABLE

	return ZP_ITEM_NOT_AVAILABLE;
}
public zp_fw_ap_items_select_post(id, itemid)
{
	if(itemid != g_deadlyshot)
		return PLUGIN_HANDLED

	if(!Get_BitVar(has_item,id) || Get_BitVar(using_item,id) )
	{
		zp_colored_print(id, "Đã mua ^x04DEADLY SHOT^x01. Nhấn [T] để kích hoạt");

		Set_BitVar(has_item,id)
		UnSet_BitVar(using_item,id)

		set_task(0.1, "show_hud", id+TASK_HUD, _, _, "b")
	}

	return PLUGIN_CONTINUE
}

public zp_fw_core_infect_post(id)
{
	remove_ds(id)
}

public show_hud(id)
{
	id -= TASK_HUD


	if(Get_BitVar(has_item,id))
	{
		set_hudmessage(0, 255, 0, -1.0, 0.88, 0, 2.0, 1.0)
		ShowSyncHudMsg(id, sync_hud1, "[T] Deadly Shot")
	}
	else if(Get_BitVar(using_item,id)) {
		set_hudmessage(0, 0, 255, -1.0, 0.88, 0, 2.0, 1.0)
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
	if(Get_BitVar(has_item,id) && !Get_BitVar(using_item,id) )
	{
		UnSet_BitVar(has_item,id)
		Set_BitVar(using_item,id)

		set_task(get_pcvar_float(cvar_deadlyshot_time), "remove_headshot_mode", id+TASK_REMOVE)
	}

}

public fw_traceattack(victim, attacker, Float:damage, direction[3], traceresult, dmgbits)
{
	if(Get_BitVar(using_item,attacker))
	{
		set_tr2(traceresult, TR_iHitgroup, HIT_HEAD)
	}
}

public remove_ds(id)
{
	if(Get_BitVar(has_item,id) || Get_BitVar(using_item,id) )
	{
		UnSet_BitVar(has_item,id)
		UnSet_BitVar(using_item,id)

		if(task_exists(id+TASK_HUD)) remove_task(id+TASK_HUD)
		if(task_exists(id+TASK_REMOVE)) remove_task(id+TASK_REMOVE)
	}
}

public remove_headshot_mode(id)
{
	id -= TASK_REMOVE

	UnSet_BitVar(has_item,id)
	UnSet_BitVar(using_item,id)

	if(task_exists(id+TASK_HUD)) remove_task(id+TASK_HUD)
}
