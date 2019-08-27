#include < amxmodx >
#include < fun >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < hamsandwich >
#include <zombieplague>
#include <zp50_weapon>
#include <cs_ham_bots_api>

#define WEAPON_BITSUM ((1<<CSW_GALIL))

new const VERSION[] = "1.1";

new const V_GUITAR_MDL[64] = "models/zombie_plague/v_rock_guitar.mdl";
new const P_GUITAR_MDL[64] = "models/zombie_plague/p_rock_guitar.mdl";
new const W_GUITAR_MDL[64] = "models/zombie_plague/w_rock_guitar.mdl";
new const OLD_W_MDL[64] = "models/w_galil.mdl";

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new const GUITAR_SOUNDS[][] = {"weapons/gt_clipin.wav", "weapons/gt_clipon.wav", "weapons/gt_clipout.wav", "weapons/gt_draw.wav"}

new const ZOOM_SOUND[] = "weapons/zoom.wav";
new const SHOT_SOUND[] = "weapons/rguitar.wav";

new g_itemid , g_has_guitar, g_hamczbots , g_clip_ammo[33] , g_has_zoom , blood_spr[2] , cvar_rockguitar_damage_x , cvar_rockguitar_clip , cvar_rockguitar_bpammo , cvar_rockguitar_shotspd , cvar_botquota;
new g_IsConnected, g_IsAlive
public plugin_init()
{
	// Plugin Register
	register_plugin("[ZP] Extra Item: Rock Guitar", VERSION, "CrazY");

	Register_SafetyFunc()

	// Extra Item Register
	g_itemid = zp_weapons_register("Rock Guitar", 25, ZP_PRIMARY, ZP_WEAPON_AP);

	// Cvars Register
	cvar_rockguitar_damage_x = register_cvar("zp_rockguitar_damage_x", "3.5");
	cvar_rockguitar_clip = register_cvar("zp_rockguitar_clip", "40");
	cvar_rockguitar_bpammo = register_cvar("zp_rockguitar_bpammo", "200");
	cvar_rockguitar_shotspd = register_cvar("zp_rockguitar_shot_speed", "0.11");

	// Cvar Pointer
	cvar_botquota = get_cvar_pointer("bot_quota");

	// Events
	register_event("CurWeapon", "event_CurWeapon", "b", "1=1");

	// Forwards
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1);
	register_forward(FM_CmdStart, "fw_CmdStart");

	// Hams
	RegisterHam(Ham_Item_PostFrame, "weapon_galil", "fw_ItemPostFrame");
	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_AddToPlayer");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_PrimaryAttack_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
}

public plugin_precache()
{
	// Models
	precache_model(V_GUITAR_MDL);
	precache_model(P_GUITAR_MDL);
	precache_model(W_GUITAR_MDL);
	precache_model(OLD_W_MDL);

	// Blood Sprites
	blood_spr[0] = precache_model("sprites/blood.spr");
	blood_spr[1] = precache_model("sprites/bloodspray.spr");

	// Sounds
	for(new i = 0; i < sizeof GUITAR_SOUNDS; i++) precache_sound(GUITAR_SOUNDS[i]);
	precache_sound(ZOOM_SOUND);
	precache_sound(SHOT_SOUND);
}

public client_putinserver(id)
{
	UnSet_BitVar(g_has_guitar, id);

	if (is_user_bot(id) && !g_hamczbots && cvar_botquota)
	{
		set_task(0.1, "register_ham_czbots", id);
	}
}

public client_disconnected(id)
{
	UnSet_BitVar(g_has_guitar, id);
}

public client_connect(id)
{
	UnSet_BitVar(g_has_guitar, id);
}

public zp_fw_core_infect_post(id)
{
	UnSet_BitVar(g_has_guitar, id);
}

public register_ham_czbots(id)
{
	if (g_hamczbots || !is_user_bot(id) || !get_pcvar_num(cvar_botquota))
		return;

	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage");

	g_hamczbots = true;
}

public zp_fw_wpn_select_post(player, itemid)
{
	if(itemid != g_itemid)
		return;

	if(user_has_weapon(player, CSW_GALIL))
	{
		drop_primary(player);
	}
	Set_BitVar(g_has_guitar, player);
	new wpnid = give_item(player, "weapon_galil");
	cs_set_weapon_ammo(wpnid, get_pcvar_num(cvar_rockguitar_clip));
	cs_set_user_bpammo(player, CSW_GALIL, get_pcvar_num(cvar_rockguitar_bpammo));
}
public zp_fw_wpn_remove(id, ItemID )
{
    if(ItemID == g_itemid) UnSet_BitVar(g_has_guitar, id);
}
public event_CurWeapon(id)
{
	if (!is_user_alive(id) || zp_core_is_zombie(id)) return PLUGIN_HANDLED;

	if (read_data(2) == CSW_GALIL && Get_BitVar(g_has_guitar, id))
	{
		set_pev(id, pev_viewmodel2, V_GUITAR_MDL);
		set_pev(id, pev_weaponmodel2, P_GUITAR_MDL);
	}
	return PLUGIN_CONTINUE;
}


public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity) || !equal(model, OLD_W_MDL)) return FMRES_IGNORED;

	static szClassName[33]; pev(entity, pev_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, "weaponbox")) return FMRES_IGNORED;

	static owner, wpn;
	owner = pev(entity, pev_owner);
	wpn = find_ent_by_owner(-1, "weapon_galil", entity);

	if(Get_BitVar(g_has_guitar, owner) && pev_valid(wpn))
	{
		UnSet_BitVar(g_has_guitar, owner);
		set_pev(wpn, pev_impulse, 43555);
		engfunc(EngFunc_SetModel, entity, W_GUITAR_MDL);

		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(is_user_alive(id) && get_user_weapon(id) == CSW_GALIL && Get_BitVar(g_has_guitar, id))
	{
		set_cd(cd_handle, CD_flNextAttack, halflife_time () + 0.001);
	}
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(is_user_alive(id) &&  get_user_weapon(id) == CSW_GALIL && Get_BitVar(g_has_guitar, id))
	{
		if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2))
		{
			if(!Get_BitVar(g_has_zoom, id))
			{
				Set_BitVar(g_has_zoom, id)
				cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 1);
				emit_sound(id, CHAN_ITEM, ZOOM_SOUND, 0.20, 2.40, 0, 100);
			}
			else
			{
				UnSet_BitVar(g_has_zoom, id)
				cs_set_user_zoom(id, CS_RESET_ZOOM, 0);
			}
		}

		if (Get_BitVar(g_has_zoom, id) && (pev(id, pev_button) & IN_RELOAD))
		{
			UnSet_BitVar(g_has_zoom, id)
			cs_set_user_zoom(id, CS_RESET_ZOOM, 0);
		}
	}
}

public fw_ItemPostFrame(weapon_entity)
{
	new id = pev(weapon_entity, pev_owner);

	if(Get_BitVar(g_has_guitar, id) && is_user_alive(id))
	{
		static iClipExtra; iClipExtra = get_pcvar_num(cvar_rockguitar_clip);

		new Float:flNextAttack = get_pdata_float(id, 83, 5);

		new iBpAmmo = cs_get_user_bpammo(id, CSW_GALIL);
		new iClip = get_pdata_int(weapon_entity, 51, 4);

		new fInReload = get_pdata_int(weapon_entity, 54, 4);

		if(fInReload && flNextAttack <= 0.0)
		{
			new Clp = min(iClipExtra - iClip, iBpAmmo);
			set_pdata_int(weapon_entity, 51, iClip + Clp, 4);
			//cs_set_user_bpammo(id, CSW_GALIL, iBpAmmo-Clp);
			set_pdata_int(weapon_entity, 54, 0, 4);
	    }
    }
}

public fw_AddToPlayer(weapon_entity, id)
{
	if(pev_valid(weapon_entity) && is_user_connected(id) && pev(weapon_entity, pev_impulse) == 43555)
	{
		Set_BitVar(g_has_guitar, id);
		set_pev(weapon_entity, pev_impulse, 0);
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public fw_PrimaryAttack(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4);

	if(Get_BitVar(g_has_guitar, id))
	{
		g_clip_ammo[id] = cs_get_weapon_ammo(weapon_entity);
	}
}

public fw_PrimaryAttack_Post(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4);

	if (Get_BitVar(g_has_guitar, id) && g_clip_ammo[id])
	{
		set_pdata_float(weapon_entity, 46, get_pcvar_float(cvar_rockguitar_shotspd), 4);
		emit_sound(id, CHAN_WEAPON, SHOT_SOUND[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		UTIL_PlayWeaponAnimation(id, random_num(3, 5));
		UTIL_MakeBloodAndBulletHoles(id);
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if(is_user_alive(attacker) && get_user_weapon(attacker) == CSW_GALIL && Get_BitVar(g_has_guitar, attacker))
	{
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_rockguitar_damage_x));
	}
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(pev(Player, pev_body));
	message_end();
}

stock UTIL_MakeBloodAndBulletHoles(id)
{
	new aimOrigin[3], target, body;
	get_user_origin(id, aimOrigin, 3);
	get_user_aiming(id, target, body);

	if(target > 0 && target <= get_maxplayers() && zp_core_is_zombie(target))
	{
		new Float:fStart[3], Float:fEnd[3], Float:fRes[3], Float:fVel[3];
		pev(id, pev_origin, fStart);

		velocity_by_aim(id, 64, fVel);

		fStart[0] = float(aimOrigin[0]);
		fStart[1] = float(aimOrigin[1]);
		fStart[2] = float(aimOrigin[2]);
		fEnd[0] = fStart[0]+fVel[0];
		fEnd[1] = fStart[1]+fVel[1];
		fEnd[2] = fStart[2]+fVel[2];

		new res;
		engfunc(EngFunc_TraceLine, fStart, fEnd, 0, target, res);
		get_tr2(res, TR_vecEndPos, fRes);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BLOODSPRITE);
		write_coord(floatround(fStart[0]));
		write_coord(floatround(fStart[1]));
		write_coord(floatround(fStart[2]));
		write_short(blood_spr[1]);
		write_short(blood_spr[0]);
		write_byte(70);
		write_byte(random_num(1,2));
		message_end();


	}
	else if(!is_user_connected(target))
	{
		if(target)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_DECAL);
			write_coord(aimOrigin[0]);
			write_coord(aimOrigin[1]);
			write_coord(aimOrigin[2]);
			write_byte(GUNSHOT_DECALS[random_num(0, sizeof GUNSHOT_DECALS -1)]);
			write_short(target);
			message_end();
		}
		else
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_WORLDDECAL);
			write_coord(aimOrigin[0]);
			write_coord(aimOrigin[1]);
			write_coord(aimOrigin[2]);
			write_byte(GUNSHOT_DECALS[random_num(0, sizeof GUNSHOT_DECALS -1)]);
			message_end()
		}

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_GUNSHOTDECAL);
		write_coord(aimOrigin[0]);
		write_coord(aimOrigin[1]);
		write_coord(aimOrigin[2]);
		write_short(id);
		write_byte(GUNSHOT_DECALS[random_num(0, sizeof GUNSHOT_DECALS -1 )]);
		message_end();
	}
}

stock drop_primary(id)
{
	new weapons[32], num;
	get_user_weapons(id, weapons, num);
	for (new i = 0; i < num; i++)
	{
		if (WEAPON_BITSUM & (1<<weapons[i]))
		{
			static wname[32];
			get_weaponname(weapons[i], wname, sizeof wname - 1);
			engclient_cmd(id, "drop", wname);
		}
	}
}

/* ===============================
------------- SAFETY -------------
=================================*/
public Register_SafetyFunc()
{

    RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
    RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)

    RegisterHamBots(Ham_Spawn, "fw_Safety_Spawn_Post", 1)
    RegisterHamBots(Ham_Killed, "fw_Safety_Killed_Post", 1)

}

public Safety_Connected(id)
{
    Set_BitVar(g_IsConnected, id)
    UnSet_BitVar(g_IsAlive, id)
}

public Safety_Disconnected(id)
{
    UnSet_BitVar(g_IsConnected, id)
    UnSet_BitVar(g_IsAlive, id)
}

public fw_Safety_Spawn_Post(id)
{
    if(!is_user_alive(id))
        return

    Set_BitVar(g_IsAlive, id)
}

public fw_Safety_Killed_Post(id)
{
    UnSet_BitVar(g_IsAlive, id)
}

public is_player(id, IsAliveCheck)
{
    if(!(1 <= id <= 32))
        return 0
    if(!Get_BitVar(g_IsConnected, id))
        return 0
    if(IsAliveCheck)
    {
        if(Get_BitVar(g_IsAlive, id)) return 1
        else return 0
    }

    return 1
}

/* ===============================
--------- End of SAFETY ----------
=================================*/
