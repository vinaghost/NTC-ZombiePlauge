#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <zombieplague>
#include <zp50_items>

#define PLUGIN "[ZP] Extra Item: Confused Bomb (for Zombie)"
#define VERSION "1.3"
#define AUTHOR "Dias" // Special Thank to sontung0 (For help me about the AddToFullPack forward)

#define CLASSNAME_FAKE_PLAYER "fake_player"
#define TASK_REMOVE_ILLUSION 111111
#define TASK_CONFUSED_SPR 434343

#define pev_nade_type        pev_flTimeStepSound
#define NADE_TYPE_CONFUSED    121314
#define MAX_PLAYER 32

new g_iEntFake[MAX_PLAYER+1]
new g_confusing[MAX_PLAYER+1]
new bool:has_confused_bomb[MAX_PLAYER+1]
new g_exploSpr

new cvar_distance, cvar_time_hit
new g_ItemID

new const v_model[] = "models/zombie_plague/v_zombibomb.mdl"
new const p_model[] = "models/zombie_plague/p_zombibomb.mdl"
new const w_model[] = "models/zombie_plague/w_zombibomb.mdl"

new const confusion_exp[] = "zombie_plague/zombi_bomb_exp.wav"
new const confusing[] = "zombie_plague/zombi_banshee_confusion_keep.wav"
new const confusion_spr[] = "sprites/zb_confuse.spr"

new g_iCurrentWeapon[33]
new confuse_spr_id

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_forward(FM_AddToFullPack, "Forward_AddToFullPack_Post", 1)

	register_event("CurWeapon", "EV_CurWeapon", "be", "1=1", "2=9")
	register_event("DeathMsg", "EV_DeathMsg", "a")

	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_GrenadeThink")
	RegisterHam(Ham_Touch, "grenade", "fw_GrenadeTouch")

	g_ItemID = zp_money_items_register("Bom ảo giác", 6000);

	cvar_distance = register_cvar("zp_confused_bomb_distance", "200.0")
	cvar_time_hit = register_cvar("zp_confused_bomb_time_hit", "15.0")

	// This thing will make the bot throw bomb ^^!
	register_clcmd("switch_to_smoke", "switch_to_smoke") // Make the bot switch to smokegrenade
	register_clcmd("set_weapon_shoot", "set_weapon_shoot") // Make the bot throw bomb
}

public plugin_precache()
{
	precache_model(v_model)
	precache_model(p_model)
	precache_model(w_model)

	precache_sound(confusion_exp)
	precache_sound(confusing)

	confuse_spr_id = precache_model(confusion_spr)

	g_exploSpr = engfunc(EngFunc_PrecacheModel, "sprites/zombiebomb.spr")
}

public EV_CurWeapon(id)
{
	if (!is_user_alive ( id ) || !zp_get_user_zombie(id))
		return PLUGIN_CONTINUE

	g_iCurrentWeapon[id] = read_data(2)

	if (has_confused_bomb[id] && g_iCurrentWeapon[id] == CSW_SMOKEGRENADE)
	{
		set_pev (id, pev_viewmodel2, v_model)
		set_pev (id, pev_weaponmodel2, p_model)
	}

	return PLUGIN_CONTINUE
}

public EV_DeathMsg()
{
	new iVictim = read_data(2)

	if (!is_user_connected(iVictim))
		return

	has_confused_bomb[iVictim] = false
}

public fw_SetModel(ent, const Model[])
{
	if (ent < 0)
		return FMRES_IGNORED

	if (pev(ent, pev_dmgtime) == 0.0)
		return FMRES_IGNORED

	new iOwner = pev(ent, pev_owner)

	if (has_confused_bomb[iOwner] && equal(Model[7], "w_sm", 4))
	{
		entity_set_model(ent, w_model)

		// Reset any other nade
		set_pev (ent, pev_nade_type, 0 )
		set_pev (ent, pev_nade_type, NADE_TYPE_CONFUSED)

		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public zp_extra_item_selected(id, item)
{
	if(item == g_confusedbomb)
	{
		has_confused_bomb[id] = true
		fm_give_item(id, "weapon_smokegrenade")

		client_print(id, print_chat, "[ZP] You bought Confused Bomb. That can make victim see zombies as humans :) !!!")
	}
}

public event_newround(id)
{
	g_confusing[id] = false

	if(task_exists(id+TASK_REMOVE_ILLUSION)) remove_task(id+TASK_REMOVE_ILLUSION)
	if(task_exists(id+TASK_CONFUSED_SPR)) remove_task(id+TASK_CONFUSED_SPR)
}

public fw_GrenadeThink(ent)
{
	if(!pev_valid(ent))
		return HAM_IGNORED

	static Float:dmg_time
	pev(ent, pev_dmgtime, dmg_time)

	if(dmg_time > get_gametime())
		return HAM_IGNORED

	static id
	id = pev(ent, pev_owner)

	if(pev(ent, pev_nade_type) == NADE_TYPE_CONFUSED)
	{
		if(has_confused_bomb[id])
		{
			has_confused_bomb[id] = false
			confuse_bomb_exp(ent, id)

			engfunc(EngFunc_RemoveEntity, ent)

			return HAM_SUPERCEDE
		}
	}

	return HAM_HANDLED
}

public fw_GrenadeTouch(bomb)
{
	if(!pev_valid(bomb))
		return HAM_IGNORED

	static id
	id = pev(bomb, pev_owner)

	if(zp_get_user_zombie(id) && pev(bomb, pev_nade_type) == NADE_TYPE_CONFUSED)
	{
		if(has_confused_bomb[id])
		{
			set_pev(bomb, pev_dmgtime, 0.0)
		}
	}

	return HAM_HANDLED
}

public Forward_AddToFullPack_Post(es_handled, inte, ent, host, hostflags, player, pSet)
{
	if (!is_user_alive(host))
		return FMRES_IGNORED

	if(!g_confusing[host])
		return FMRES_IGNORED

	if ((1 < ent < MAX_PLAYER))
	{
		if(is_user_connected(ent) && zp_get_user_zombie(ent))
		{
			set_es(es_handled, ES_RenderMode, kRenderTransAdd)
			set_es(es_handled, ES_RenderAmt, 0.0)

			new iEntFake = find_ent_by_owner(-1, CLASSNAME_FAKE_PLAYER, ent)
			if(!iEntFake || !pev_valid(ent))
			{
				iEntFake = create_fake_player(ent)
			}

			g_iEntFake[ent] = iEntFake
		}
	}

	else if (ent >= g_iEntFake[32])
	{
		if(!is_valid_ent(ent))
			return FMRES_IGNORED

		static ent_owner
		ent_owner = pev(ent, pev_owner)

		if((1 < ent_owner < MAX_PLAYER) && zp_get_user_zombie(ent_owner))
		{
			set_es(es_handled, ES_RenderMode, kRenderNormal)
			set_es(es_handled, ES_RenderAmt, 255.0)

			//set_es(es_handled, ES_ModelIndex, pev(host, pev_modelindex))
		}
	}

	return FMRES_IGNORED
}

public zp_user_infected_post(id)
{
	if(g_confusing[id])
	{
		g_confusing[id] = false
		if(task_exists(id+TASK_REMOVE_ILLUSION)) remove_task(id+TASK_REMOVE_ILLUSION)
	}
}

public confuse_bomb_exp(ent, owner)
{
	static Float:Origin[3]
	pev(ent, pev_origin, Origin)

	EffectZombieBomExp(ent)
	emit_sound(ent, CHAN_VOICE, confusion_exp, 1.0, ATTN_NORM, 0, PITCH_NORM)

	// Make Hit Human
	static victim = -1
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, Origin, get_pcvar_float(cvar_distance))) != 0)
	{
		if(!is_user_alive(victim) || !is_user_connected(victim) || g_confusing[victim] || zp_get_user_zombie(victim))
			continue

		g_confusing[victim] = 1
		client_print(victim, print_center, "You are Confused !!!")

		set_task(0.1, "makespr", victim+TASK_CONFUSED_SPR)
		emit_sound(victim, CHAN_VOICE, confusing, 1.0, ATTN_NORM, 0, PITCH_NORM)

		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, victim)
		write_short(10)
		write_short(10)
		write_short(0x0000)
		write_byte(100)
		write_byte(100)
		write_byte(100)
		write_byte(255)
		message_end()

		set_task(get_pcvar_float(cvar_time_hit), "remove_confuse", victim+TASK_REMOVE_ILLUSION)
	}
}

EffectZombieBomExp(id)
{
	static Float:Origin[3]
	pev(id, pev_origin, Origin)

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Origin, 0)
	write_byte(TE_EXPLOSION); // TE_EXPLOSION
	engfunc(EngFunc_WriteCoord, Origin[0]); // origin x
	engfunc(EngFunc_WriteCoord, Origin[1]); // origin y
	engfunc(EngFunc_WriteCoord, Origin[2]); // origin z
	write_short(g_exploSpr); // sprites
	write_byte(40); // scale in 0.1's
	write_byte(30); // framerate
	write_byte(14); // flags
	message_end(); // message end
}

public remove_confuse(taskid)
{
	new id = taskid - TASK_REMOVE_ILLUSION
	g_confusing[id] = 0

	if(task_exists(id+TASK_CONFUSED_SPR)) remove_task(id+TASK_CONFUSED_SPR)
}

public makespr(taskid)
{
	new id = taskid - TASK_CONFUSED_SPR

	if(zp_get_user_zombie(id) || !is_user_alive(id))
		return

	static Float:Origin[3]
	pev(id, pev_origin, Origin)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord,Origin[0])
	engfunc(EngFunc_WriteCoord,Origin[1])
	engfunc(EngFunc_WriteCoord,Origin[2]+25.0)
	write_short(confuse_spr_id)
	write_byte(8)
	write_byte(255)
	message_end()

	set_task(0.1,"makespr",id+TASK_CONFUSED_SPR)
}

create_fake_player(id)
{
	new iEntFake = create_entity("info_target")
	set_pev(iEntFake, pev_classname, CLASSNAME_FAKE_PLAYER)
	set_pev(iEntFake, pev_modelindex, pev(id, pev_modelindex) )
	set_pev(iEntFake, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(iEntFake, pev_solid, SOLID_NOT)
	set_pev(iEntFake, pev_aiment, id)
	set_pev(iEntFake, pev_owner, id)

	// an? fake player
	set_pev(iEntFake, pev_rendermode, kRenderTransAdd)
	set_pev(iEntFake, pev_renderamt, 0.0)

	return iEntFake
}
