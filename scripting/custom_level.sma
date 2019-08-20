
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <sqlx>
#include <engine>
#include <fun>
#include <zp50_core>
#include <zombieplague>
#include <cs_ham_bots_api>
#include <zp50_class_zombie>

new const VERSION[] = "3.2"
new const RANKS[][]= {
	"Binh nhì", // 0
	"Binh nhất", // 1
	"Hạ sĩ", // 2
	"Trung sĩ", // 3
	"Thiếu uý", // 4
	"Trung úy", // 5
	"Thượng uý", // 6
	"Đại úy", // 7
	"Thiếu tá", // 8
	"Trung tá", // 9
	"Thượng tá", // 10
	"Đại tá", // 12
	"Thiếu tướng", // 13
	"Trung tướng", // 14
	"Thượng tướng", //15
	"Đại tướng", // 16
	"Tư lệnh", // 17
	"Tổng tư lệnh" // 18
}
new const EXP[] = {
	0, // 0
	15, // 1
	100, // 2
	500, // 3
	700, // 4
	1000, // 5
	2000, // 6
	3000, // 7
	4000, // 8
	5000, // 9
	6000, // 10
	7000, // 11
	10000, // 12
	15000, // 13
	170000, // 14
	190000, // 15
	200000, // 16
	350000, // 17
	1000000 // 18
}

#define ADMIN_FLAG	ADMIN_IMMUNITY
#define MAXPLAYERS 32

#define IsPlayer(%1) ( 1 <= %1 <= g_iMaxPlayers )
#define IsUserAuthorized(%1) ( g_iPlayerData[ %1 ][ DATA_STATUS ] & FULL_STATUS == FULL_STATUS )

enum ( <<= 1 )
{
	CONNECTED = 1,
	AUTHORIZED
};

enum _:PLR_DATA
{
	DATA_INDEX,
	DATA_DMG[33],
	bool:DATA_KILLED[33],
	DATA_MAXHEALTH,
	DATA_XP,
	DATA_LEVEL,
	DATA_RANK,
	DATA_STATUS
};

const FULL_STATUS = CONNECTED | AUTHORIZED;

new g_iPlayerData[ 33 ][ PLR_DATA ];
new g_szSqlTable[] = "level_zp";

new Handle:g_hSqlTuple;

new g_iSprite[19]

new g_iZombieScore, g_iHumanScore
new g_msgSayText

new g_iCount

new ScoreHud

new AttackerHud, VictimHud;

new Float:xA[33]
new Float:yA[33]
new Float:xV[33]
new Float:yV[33];
public plugin_init()
{
	// Original plugin is by Excalibur007. ;)
	register_plugin("Custom Level", VERSION, "zmd94")

	register_clcmd("say /ranks", "show_stats")
	register_clcmd("say_team /ranks", "show_stats")

	register_clcmd("free_give","cl_give", ADMIN_FLAG, "Enable to give free EXP")

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	//register_event("Damage", "event_Damage", "be", "2!0", "3=0", "4!0")
	RegisterHamBots(Ham_TakeDamage, "event_Damage", 1);
	RegisterHam(Ham_TakeDamage, "player", "event_Damage", 1)
	register_event("DeathMsg", "event_DeathMsg", "a", "1>0")
	register_event("StatusValue", "event_StatusValue", "be", "1=2", "2!0")
	register_event("TextMsg", "event_Restart", "a", "2&#Game_C", "2&#Game_w")


	g_msgSayText = get_user_msgid("SayText")

	// Score Inform. ;)
	set_task(1.0, "ShowScore", 1112, _, _, "b")

	AttackerHud = CreateHudSyncObj()
	VictimHud = CreateHudSyncObj()

	ScoreHud = CreateHudSyncObj()

	set_task(2.0, "Init_MYSQL")
}
public plugin_natives() {
	register_native("zp_get_user_level", "native_get_user_level");
}
public plugin_precache()
{
	new szFile[35]
	for(new i = 0; i < sizeof(RANKS); i++)
	{
		formatex(szFile, charsmax(szFile), "sprites/zombie_plague/level/%i.spr", i)
		g_iSprite[i] = precache_model(szFile)
	}

}
public Init_MYSQL()
{
	g_hSqlTuple = SQL_MakeStdTuple()

	new g_Error[512]
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_hSqlTuple, ErrorCode, g_Error, charsmax(g_Error))
	if(SqlConnection == Empty_Handle) {
		set_fail_state(g_Error)
	}
	SQL_FreeHandle(SqlConnection);

	new szQuery[300];
	formatex(szQuery, charsmax(szQuery), "CREATE TABLE IF NOT EXISTS level_zp (Id int NOT NULL AUTO_INCREMENT, name CHAR(30) NOT NULL, exp INT NOT NULL DEFAULT 0, level INT NOT NULL DEFAULT 0, rank VARCHAR(33) NOT NULL DEFAULT '', PRIMARY KEY (Id), UNIQUE (name));")

	SQL_ThreadQuery( g_hSqlTuple, "HandleNullRoute", szQuery );

	server_print("[CUSTOM LEVEL] MYSQL connection succesful");
}
public plugin_end( )
{
	SQL_FreeHandle( g_hSqlTuple );
}

public client_authorized( id )
{
	if( ( g_iPlayerData[ id ][ DATA_STATUS ] |= AUTHORIZED ) & CONNECTED )
	{
		UserHasBeenAuthorized( id );
	}
}

public client_putinserver( id )
{
	if( ( g_iPlayerData[ id ][ DATA_STATUS ] |= CONNECTED ) & AUTHORIZED && !is_user_bot( id ) )
	{
		UserHasBeenAuthorized( id );
	}
}


public client_disconnected( id )
{
	g_iPlayerData[ id ][ DATA_INDEX  ] = 0;
	g_iPlayerData[ id ][ DATA_XP ] = 0;
	g_iPlayerData[ id ][ DATA_LEVEL ] = 0;
	g_iPlayerData[ id ][ DATA_STATUS ] = 0;

}


public native_get_user_level(iPlugin,iParams) {
	new id = get_param(1);

	return g_iPlayerData[ id ][ DATA_LEVEL ];
}

public addXP( iPlayer , xp )
{
	g_iPlayerData[ iPlayer ][ DATA_XP ] += xp;

	if( g_iPlayerData[ iPlayer ][ DATA_XP ] < 0 )
	{
		g_iPlayerData[ iPlayer ][ DATA_XP ] = 0;
	}
	ReviewLevel(iPlayer)
	new szQuery[ 128 ];
	formatex( szQuery, 127, "UPDATE `%s` SET `exp` = `exp` + '%i' WHERE `Id` = '%i'",
	         g_szSqlTable, xp, g_iPlayerData[ iPlayer ][ DATA_INDEX ] );

	new iData[ 2 ];
	iData[ 0 ] = iPlayer;
	iData[ 1 ] = xp;

	SQL_ThreadQuery( g_hSqlTuple, "HandleNullRoute", szQuery, iData, 2 );

	return true;
}

public setPoint( iPlayer, xp )
{
	g_iPlayerData[ iPlayer ][ DATA_XP ] = xp;

	new szQuery[ 128 ];
	formatex( szQuery, 127, "UPDATE `%s` SET `exp` = '%i' WHERE `Id` = '%i'",
	         g_szSqlTable, xp, g_iPlayerData[ iPlayer ][ DATA_INDEX ] );

	new iData[ 2 ];
	iData[ 0 ] = iPlayer;
	iData[ 1 ] = xp;

	SQL_ThreadQuery( g_hSqlTuple, "HandleNullRoute", szQuery, iData, 2 );
	ReviewLevel(iPlayer)
	return true;
}

public zp_round_ended(iTeam)
{
	new iPlayers[MAXPLAYERS], iPlayerCount, i, player

	switch(iTeam) {
		case WIN_ZOMBIES: {
			g_iZombieScore ++

			get_players(iPlayers, iPlayerCount, "ac")
			for(i = 0; i < iPlayerCount; i++) {
				player = iPlayers[i]
				if(zp_get_user_zombie(player)) {
					addXP(player, 1);
					//sChatColor(player, "^x04[NTC]^x03 %L", LANG_PLAYER, "CL_ZOMBIE_WIN", get_pcvar_num(g_iZombieWinEXP))

					ReviewLevel(player)
				}
			}

		}
		case WIN_HUMANS: {
			g_iHumanScore ++

			get_players(iPlayers, iPlayerCount, "ac")
			for(i = 0; i < iPlayerCount; i++) {
				player = iPlayers[i]
				if(!zp_get_user_zombie(player)) {
					addXP(player, 2);
					//sChatColor(player, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_HUMAN_WIN", get_pcvar_num(g_iHumanWinEXP))

					ReviewLevel(player)
				}
			}

		}
		case WIN_NO_ONE: {
			g_iHumanScore ++

			get_players(iPlayers, iPlayerCount, "ac")
			for(i = 0; i < iPlayerCount; i++) {
				player = iPlayers[i]
				if(!zp_get_user_zombie(player)) {
					addXP(player, 2);
					//sChatColor(player, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_HUMAN_WIN", get_pcvar_num(g_iHumanWinEXP))

					ReviewLevel(player)
				}
			}
		}
	}
}
public ShowScore()
{
	set_hudmessage(0, 255, 0, -1.0, 0.02, 0, 12.0, 12.0, 0.0, 0.0, -1)
	ShowSyncHudMsg(0, ScoreHud, "[Zombie] - [Human]^n[%s%d] ----- [%s%d]",g_iZombieScore >= 10 ? "" : "0", g_iZombieScore, g_iHumanScore >= 10 ? "" : "0", g_iHumanScore)
}

public cl_give(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new iTarget[32], iCount[32]
	read_argv(1, iTarget, charsmax(iTarget))
	read_argv(2, iCount, charsmax(iCount))

	new target_id, iName[32], iNameID[32]
	target_id = find_player("bl", iTarget)

	get_user_name(target_id, iName, charsmax(iName))
	get_user_name(id, iNameID, charsmax(iNameID))

	if(!target_id)
	{
		console_print(id, "Can't find that player")
		return PLUGIN_HANDLED
	}

	if(read_argc() != 3)
	{
		return PLUGIN_HANDLED
	}

	if(str_to_num(iCount) < (EXP[g_iPlayerData[ target_id ][ DATA_LEVEL ] + 1] - g_iPlayerData[ target_id ][DATA_XP]))
	{
		if(str_to_num(iCount) == 0)
		{
			console_print(id, "EXP for %s is %i / %i", iName,  g_iPlayerData[ target_id ][DATA_XP], EXP[g_iPlayerData[ target_id ][ DATA_LEVEL ] + 1])
		}
		else
		{
			console_print(id, "%s has been given %i EXP", iName, str_to_num(iCount))
			addXP(target_id, str_to_num(iCount));
		}
	}
	else
	{
		console_print(id, "Maximum EXP allowed for %s: %i", iName, (EXP[g_iPlayerData[ target_id ][ DATA_LEVEL ] + 1] - g_iPlayerData[ target_id ][DATA_XP]))
	}

	return PLUGIN_HANDLED;
}

public event_new_round()
{
	new iPlayers[MAXPLAYERS], iPlayerCount, i, player
	get_players(iPlayers, iPlayerCount, "a")
	for(i = 0; i < iPlayerCount; i++)
	{
		player = iPlayers[i]
		g_iPlayerData[player][DATA_DMG][player] = 0
	}
}

public event_Restart()
{
	g_iZombieScore = 0
	g_iHumanScore = 0

}

public event_Damage(iVictim, inflictor, iAttacker, Float:damage, bits)
{
	static iHit; iHit = floatround(damage)


	if(iAttacker == iVictim || !is_user_alive(iAttacker) || !is_user_alive(iVictim))
		return
	CheckPosition( iVictim, 0 )
	CheckPosition( iAttacker, 1 )

	set_hudmessage(255, 0, 0, xV[iVictim], yV[iVictim], 2, 0.1, 4.0, 0.1, 0.1, -1)
	ShowSyncHudMsg(iVictim, VictimHud, "%i^n", iHit)
	client_print(iAttacker, print_center, "HP: %d", pev(iVictim, pev_health));

	set_hudmessage(0, 100, 200, xA[iAttacker], yA[iAttacker], 2, 0.1, 4.0, 0.02, 0.02, -1)
	ShowSyncHudMsg(iAttacker, AttackerHud, "%i^n", iHit)


	Show_spectate(iVictim, iAttacker, iHit)

	if(zp_get_user_zombie(iVictim) && !zp_get_user_survivor(iAttacker))
	{
		g_iPlayerData[iAttacker][DATA_DMG][iVictim] += iHit

		if(g_iPlayerData[iAttacker][DATA_DMG][iVictim] >= 1300)
		{
			addXP(iAttacker, 2)

			//sChatColor(iAttacker, "^x04[CL]^x01 %L", LANG_PLAYER, "CL_DEALT_DAMAGE", get_pcvar_num(g_iDamageEXP), get_pcvar_num(g_iDamageAmount))
			g_iPlayerData[iAttacker][DATA_DMG][iVictim] = 0

		}

	}
}

public Show_spectate(iVictim, iAttacker, iHit)
{

	new Players[MAXPLAYERS], iPlayerCount, i, id
	get_players(Players, iPlayerCount, "bc")
	for (i = 0; i < iPlayerCount; i++)
	{
		id = Players[i]
		if (id != iVictim && entity_get_int(id, EV_INT_iuser2) == iVictim)
		{
			set_hudmessage(255, 0, 0, xV[iVictim], yV[iVictim], 2, 0.1, 4.0, 0.1, 0.1, -1)
			ShowSyncHudMsg(id, VictimHud, "%i^n", iHit)
		}

		if (id != iAttacker && entity_get_int(id, EV_INT_iuser2) == iAttacker)
		{
			set_hudmessage(0, 100, 200, xA[iAttacker], yA[iAttacker], 2, 0.1, 4.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(id, AttackerHud, "%i^n", iHit)
			client_print(id, print_center, "HP: %d", pev(iVictim, pev_health));

		}
	}
}

public event_DeathMsg()
{
	new iKiller; iKiller = read_data(1)
	new iVictim; iVictim = read_data(2)
	new iIsHeadshot; iIsHeadshot = read_data(3)

	if(iVictim == iKiller || !is_user_alive(iKiller)) {
		return
	}

	if(!zp_get_user_zombie(iKiller) || zp_get_user_survivor(iKiller))
	{
		if(zp_get_user_nemesis(iVictim))
		{
			addXP(iKiller, 1);
			//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL_NEMESIS", get_pcvar_num(g_iNemKillEXP))


		}
		else
		{
			if(iIsHeadshot)
			{
				addXP(iKiller, 5)
				//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_HEADSHOT_KILL", get_pcvar_num(g_iHeadShotEXP))
			}
			else
			{
				addXP(iKiller, 2)
				//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL", get_pcvar_num(g_iHumanEXP))
			}
			g_iPlayerData[iKiller][DATA_KILLED][iVictim] = true;
			ReviewLevel(iKiller)

			new iPlayers[MAXPLAYERS], iPlayerCount, i, id
			get_players(iPlayers, iPlayerCount, "ah")
			for(i = 0; i < iPlayerCount; i++)
			{
				id = iPlayers[i]
				if( g_iPlayerData[id][DATA_DMG][iVictim] >= g_iPlayerData[iVictim][DATA_MAXHEALTH]/5) {
					if(!g_iPlayerData[id][DATA_KILLED][iVictim] && !zp_core_is_zombie(id))
					{
						addXP(id, 1);

						//sChatColor(id, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_ASSIST", get_pcvar_num(g_iAssistEXP), RANKS[g_iLevel[iKiller]], szName)
						g_iPlayerData[id][DATA_DMG][iVictim] = 0
					}
					else
					{
						g_iPlayerData[id][DATA_KILLED][iVictim] = false
					}
				}
			}

		}
	}
	else if(zp_get_user_zombie(iKiller) || zp_get_user_nemesis(iKiller))
	{
		if(zp_get_user_survivor(iVictim))
		{
			addXP(iKiller, 9)
			//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL_SURVIVOR", get_pcvar_num(g_iSurKillEXP))
		}
		else
		{
			addXP(iKiller, 2)
			//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL_HUMAN", get_pcvar_num(g_iZombieEXP))
		}
	}
}

public ReviewLevel(id)
{
	while((g_iPlayerData[id][DATA_LEVEL] < 19 && g_iPlayerData[id][DATA_XP] >= EXP[g_iPlayerData[id][DATA_LEVEL] + 1]))
	{
		g_iPlayerData[id][DATA_LEVEL] += 1
		new name[33];
		get_user_name(id, name, charsmax(name));

		sChatColor(id, "^x04[NTC]^x03 %s ^x01đã lên rank ^x04%s", name, RANKS[g_iPlayerData[id][DATA_LEVEL] + 1])

		new szQuery[ 128 ];
		formatex( szQuery, 127, "UPDATE `%s` SET `level` = `level` + 1 WHERE `Id` = '%i'",
		         g_szSqlTable, g_iPlayerData[ id ][ DATA_INDEX ] );

		new iData[ 2 ];
		iData[ 0 ] = id;
		iData[ 1 ] = g_iPlayerData[id][DATA_LEVEL];

		SQL_ThreadQuery( g_hSqlTuple, "HandleNullRoute", szQuery, iData, 2 );
	}
}

public event_StatusValue(id)
{
	new pid = read_data(2)
	new pidlevel = g_iPlayerData[pid][DATA_LEVEL]

	if(!pev_valid(pid) || !is_user_alive(pid) || zp_get_user_zombie(pid))
	return


	Create_TE_PLAYERATTACHMENT(id, pid, 55, g_iSprite[pidlevel], 2)

}


public zp_fw_core_infect_post(id, attacker)
{
	if(zp_class_zombie_get_current(id) == ZP_INVALID_ZOMBIE_CLASS)
	return;

	g_iPlayerData[id][DATA_MAXHEALTH] = zp_class_zombie_get_max_health(id, zp_class_zombie_get_current(id))

	if (is_user_alive(attacker) && attacker != id)
	{
		addXP(attacker, 2)
		//sChatColor(attacker, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_INFECT", get_pcvar_num(g_iInfectEXP))
	}

}



public show_stats(id)
{
	new Data[ 1 ]
	Data[ 0 ] = id

	new szTemp[ 512 ]
	format( szTemp, charsmax( szTemp ), "SELECT COUNT(*) FROM level_zp WHERE exp >= %d", g_iPlayerData[id][DATA_XP] )

	SQL_ThreadQuery( g_hSqlTuple, "SkillRank_QueryHandler", szTemp, Data, 1 )

}
public SkillRank_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( !SQL_IsFail( FailState, Errcode, Error ) )
	{
		new id
		id = Data[ 0 ]

		g_iPlayerData[id][DATA_RANK] = SQL_ReadResult( Query, 0 )

		if( g_iPlayerData[id][DATA_RANK]== 0 )
		{
			g_iPlayerData[id][DATA_RANK] = 1
		}

		TotalRows( id )
	}
}

public TotalRows( id )
{
	new Data[ 1 ]
	Data[ 0 ] = id

	new szTemp[ 128 ]
	format( szTemp, charsmax( szTemp ), "SELECT COUNT(*) FROM level_zp")

	SQL_ThreadQuery( g_hSqlTuple, "TotalRows_QueryHandler", szTemp, Data, 1 )
}

public TotalRows_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( !SQL_IsFail( FailState, Errcode, Error ) )
	{
		new id
		id = Data[ 0 ]

		g_iCount = SQL_ReadResult( Query, 0 )

		sChatColor( id, "!g[NTC]!n Đang ở vị trí %d/%d", g_iPlayerData[id][DATA_RANK], g_iCount )
		sChatColor(id, "^x04[NTC]^x03 Rank hiện tại %d, cần %d để lên cấp", RANKS[g_iPlayerData[id][DATA_LEVEL]], (EXP[g_iPlayerData[id][DATA_LEVEL] + 1] -g_iPlayerData[id][DATA_XP]))

	}
}

stock Create_TE_PLAYERATTACHMENT(id, entity, vOffset, iSprite, life)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_PLAYERATTACHMENT)
	write_byte(entity)
	write_coord(vOffset)
	write_short(iSprite)
	write_short(life)
	message_end()
}

stock sChatColor(const id, const input[], any:...)
{
	new count = 1, players[32], i, player
	static msg[191]

	if(numargs() == 2)
	copy(msg, 190, input)
	else
	vformat(msg, 190, input, 3)

	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")

	if(id) {
		if(!is_user_connected(id)) return
		players[0] = id
	}
	else get_players(players, count, "ch")

	for(i = 0; i < count; i++)
	{
		player = players[i]

		message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
		write_byte(player)
		write_string(msg)
		message_end()
	}
}

// SQL Related
// ====================================
UserHasBeenAuthorized( const id )
{
	new szName[ 32 ], szQuery[ 128 ];
	get_user_name( id, szName, charsmax(szName));
	formatex( szQuery, charsmax(szQuery), "SELECT `Id`, `exp`, `level` FROM `%s` WHERE `name` = '%s'", g_szSqlTable, szName );

	new iData[ 1 ];
	iData[ 0 ] = id;

	SQL_ThreadQuery( g_hSqlTuple, "HandlePlayerConnect", szQuery, iData, 1 );
}

public HandleNullRoute( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iSize, Float:flQueueTime )
{
	if( SQL_IsFail( iFailState, iError, szError ) && iSize == 2 ){
	}
}

public HandlePlayerConnect( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iSize, Float:flQueueTime )
{
	if( SQL_IsFail( iFailState, iError, szError ) )
	return;

	new id = iData[ 0 ];

	if( !IsUserAuthorized( id ) )
	return;

	if( SQL_NumResults( hQuery ) )
	{
		g_iPlayerData[ id ][ DATA_INDEX  ] = SQL_ReadResult( hQuery, 0 );
		g_iPlayerData[ id ][ DATA_XP ] = SQL_ReadResult( hQuery, 1 );
		g_iPlayerData[ id ][ DATA_LEVEL ] = SQL_ReadResult( hQuery, 2 );
	}
	else
	{
		new szName[ 32 ], szQuery[ 128 ];
		get_user_name( id, szName, 31 );
		formatex( szQuery, 127, "INSERT INTO `%s` (`Name`, `rank`) VALUES ('%s', '%s' )", g_szSqlTable, szName, RANKS[0] );

		SQL_ThreadQuery( g_hSqlTuple, "HandlePlayerInsert", szQuery, iData, 1 );
	}
}

public HandlePlayerInsert( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iSize, Float:flQueueTime )
{
	if( SQL_IsFail( iFailState, iError, szError ) )
	return;

	new id = iData[ 0 ];

	if( !IsUserAuthorized( id ) )
	return;

	g_iPlayerData[ id ][ DATA_INDEX  ] = SQL_GetInsertId( hQuery );
	g_iPlayerData[ id ][ DATA_XP ] = 0;
	g_iPlayerData[ id ][ DATA_LEVEL ] = 0;

}

stock bool:SQL_IsFail( const iFailState, const iError, const szError[ ] )
{
	if( iFailState == TQUERY_CONNECT_FAILED )
	{
		log_amx( "[POINTS] Could not connect to SQL database: %s", szError );
		return true;
	}
	else if( iFailState == TQUERY_QUERY_FAILED )
	{
		log_amx( "[POINTS] Query failed: %s", szError );
		return true;
	}
	else if( iError )
	{
		log_amx( "[POINTS] Error on query: %s", szError );
		return true;
	}

	return false;
}


iRefreshHudPosition( id )
{
	yA[ id ] = -0.50
	xA[ id ] = -0.70

	yV[ id ] = -0.45
	xV[ id ] = -0.30
}

CheckPosition( id, Attacker ) {
	if( Attacker )
	{
		switch( xA[ id ] )
		{
			case -0.70: // First attack
			{
				xA[ id ] = -0.575
				yA[ id ] = -0.60
			}
			case -0.575: // Second
			{
				xA[ id ] = -0.50
				yA[ id ] = -0.625
			}
			case -0.50: // Third
			{
				xA[ id ] = -0.425
				yA[ id ] = -0.60
			}
			case -0.425: // Fourth
			{
				xA[ id ] = -0.30
				yA[ id ] = -0.50
			}
			case -0.30: // Last
			{
				xA[ id ] = -0.70
			}
			default: iRefreshHudPosition( id )
		}
	}
	else
	{
		switch( xV[ id ] )
		{
			case -0.30: // First attack
			{
				xV[ id ] = -0.425
				yV[ id ] = -0.35
			}
			case -0.425: // Second
			{
				xV[ id ] = -0.50
				yV[ id ] = -0.30
			}
			case -0.50: // Third
			{
				xV[ id ] = -0.575
				yV[ id ] = -0.35
			}
			case -0.575: // fourth
			{
				xV[ id ] = -0.70
				yV[ id ] = -0.45
			}
			case -0.70: // Last
			{
				xV[ id ] = -0.30
			}
			default: iRefreshHudPosition( id )
		}
	}
}
