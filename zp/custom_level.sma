/*

Copyright(C). 2014. zmd94 ;)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
// Uncomment 'IM_USING_ZP50' if your server is running ZP50 and above
#define IM_USING_ZP50

// if you are using this Custom Level for ZPA, 
// just change line below into #include <zombie_plague_advance> 
#include <zombieplague> 

//Uncomment 'CUSTOM_CHAT' if your want to use custom chat
//#define CUSTOM_CHAT

//Uncomment 'DATA_EXPIRED' if your want to enable data expired function
//#define DATA_EXPIRED

//Uncomment 'CHANGE_NAME' if your want to enable player to change their name
//#define CHANGE_NAME

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <sqlx>
#include <engine>
#include <fun>
#if defined IM_USING_ZP50
#include <zp50_core>
#include <zp50_class_zombie>
#endif

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
#define TOPLEVEL 15
#define TASK_INFO 2399

#define CONNECT_TASK	1024
// Bool
new bool:g_bKilledZombie[MAXPLAYERS+1][33]

// String
new g_szMotd[1536]
new g_sName[MAXPLAYERS+1][32]

// Variables
new g_iRank[MAXPLAYERS+1] 
new g_iLevel[MAXPLAYERS+1], g_iXP[MAXPLAYERS+1] 
new g_iDamage[MAXPLAYERS+1][33], g_iSprite[MAXPLAYERS+1]

new g_iZombieScore, g_iHumanScore
new g_msgSayText

new g_iMaxHealth[MAXPLAYERS+1]

new Handle:g_SqlTuple, g_iCount

new ScoreHud

public plugin_init()
{
	// Original plugin is by Excalibur007. ;)
	register_plugin("Custom Level", VERSION, "zmd94")
	
	register_clcmd("say /rank", "show_stats")
	register_clcmd("say_team /rank", "show_stats")
	register_clcmd("say /top", "show_global_top")
	register_clcmd("say_team /top", "show_global_top")
	register_clcmd("say /save", "save_data")
	register_clcmd("say_team /save", "save_data")
	
	register_clcmd("free_give","cl_give", ADMIN_FLAG, "Enable to give free EXP")
	
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	register_event("Damage", "event_Damage", "be", "2!0", "3=0", "4!0")
	register_event("DeathMsg", "event_DeathMsg", "a", "1>0")
	register_event("StatusValue", "event_StatusValue", "be", "1=2", "2!0")
	register_event("TextMsg", "event_Restart", "a", "2&#Game_C", "2&#Game_w")
	
	
	g_msgSayText = get_user_msgid("SayText")
	
	// Score Inform. ;)
	set_task(1.0, "ShowScore", 0, _, _, "b")
	
	ScoreHud = CreateHudSyncObj()
	
	set_task(0.5, "Init_MYSQL")
}
public plugin_natives() {
	register_native("zp_get_user_level", "native_get_user_level");
	register_native("zp_get_user_rank", "native_get_user_level")
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
	g_SqlTuple = SQL_MakeStdTuple()
	new g_Error[ 512 ]
	new ErrorCode
	new Handle:SqlConnection = SQL_Connect( g_SqlTuple, ErrorCode, g_Error, charsmax( g_Error ) )
	
	if( SqlConnection == Empty_Handle )
	{
		set_fail_state( g_Error )
	}
	
	new Handle:Queries
	Queries = SQL_PrepareQuery( SqlConnection, "CREATE TABLE IF NOT EXISTS level_zp (name CHAR(30) NOT NULL, exp INT NOT NULL DEFAULT 0, level INT NOT NULL DEFAULT 0, PRIMARY KEY (name));")
	
	if( !SQL_Execute( Queries ) )
	{
		SQL_QueryError( Queries, g_Error, charsmax( g_Error ) )
		set_fail_state( g_Error )
	}
	
	SQL_FreeHandle( Queries )
	SQL_FreeHandle( SqlConnection )
	
	server_print("[CUSTOM LEVEL] MYSQL connection succesful")
	MakeTop15( )
}
public plugin_end( )
{
	SQL_FreeHandle( g_SqlTuple )
}

public client_authorized( id )
{
	set_task( 4.0, "Delayed_client_authorized", id + CONNECT_TASK )	
}

public Delayed_client_authorized( id )
{	
	id -= CONNECT_TASK
	
	get_user_info( id, "name", g_sName[ id ], charsmax( g_sName[ ] ) )
	
	replace_all( g_sName[ id ], charsmax( g_sName[ ] ), "'", "*" )
	replace_all( g_sName[ id ], charsmax( g_sName[ ] ), "^"", "*" )
	replace_all( g_sName[ id ], charsmax( g_sName[ ] ), "`", "*" )
	replace_all( g_sName[ id ], charsmax( g_sName[ ] ), "�", "*" )
	
	g_iLevel[id] = 0
	g_iXP[id] = 0
	
	LoadData( id )
}

public client_disconnect( id )
{	
	SaveData(id)
	if( task_exists( id+TASK_INFO ) )
	{
		remove_task( id+TASK_INFO)
	}
	
	if( task_exists( id + CONNECT_TASK ) )
	{
		remove_task( id + CONNECT_TASK )
	}
	
	g_iLevel[id] = 0
	g_iXP[id] = 0
}
public native_get_user_level(iPlugin,iParams) {
	new id = get_param(1);
	
	return g_iLevel[id];
}
public native_get_user_rank(iPlugin,iParams) {
	new id = get_param(1);
	new str[33];
	formatex(str, charsmax(str), "%s", RANKS[g_iLevel[id]])
	set_string(2, str, get_param(3) )
}

public show_global_top(id) {
	show_motd( id, g_szMotd, "Trum server" )
}
public zp_round_ended(iTeam)
{
	new iPlayers[MAXPLAYERS], iPlayerCount, i, player
	
	switch(iTeam)
	{
		case WIN_ZOMBIES: 
		{
			g_iZombieScore ++ 
			
			
			
			get_players(iPlayers, iPlayerCount, "ac") 
			for(i = 0; i < iPlayerCount; i++)
			{
				player = iPlayers[i]
				if(zp_get_user_zombie(player))
				{
					g_iXP[player] += 1
					//sChatColor(player, "^x04[NTC]^x03 %L", LANG_PLAYER, "CL_ZOMBIE_WIN", get_pcvar_num(g_iZombieWinEXP))
					
					ReviewLevel(player)
				}
			}
			
		}
		case WIN_HUMANS: 
		{
			
			g_iHumanScore ++ 
			
			
			
			get_players(iPlayers, iPlayerCount, "ac") 
			for(i = 0; i < iPlayerCount; i++)
			{	
				player = iPlayers[i]
				if(!zp_get_user_zombie(player))
				{
					g_iXP[player] += 2
					//sChatColor(player, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_HUMAN_WIN", get_pcvar_num(g_iHumanWinEXP))
					
					ReviewLevel(player)
				}
			}
			
		}
		case WIN_NO_ONE: 
		{
			
			g_iHumanScore ++
			
			get_players(iPlayers, iPlayerCount, "ac") 
			for(i = 0; i < iPlayerCount; i++)
			{
				player = iPlayers[i]
				if(!zp_get_user_zombie(player))
				{
					g_iXP[player] += 2
					//sChatColor(player, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_HUMAN_SURVIVE", get_pcvar_num(g_iHumanWinEXP))
					
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
	
	if(str_to_num(iCount) < (EXP[g_iLevel[target_id] + 1] - g_iXP[target_id]))
	{
		if(str_to_num(iCount) == 0)
		{
			console_print(id, "EXP for %s is %i / %i", iName, g_iXP[target_id], EXP[g_iLevel[target_id] + 1])
		}
		else
		{
			console_print(id, "%s has been given %i EXP", iName, str_to_num(iCount))
			g_iXP[target_id] += str_to_num(iCount)
		}
	}
	else
	{
		console_print(id, "Maximum EXP allowed for %s: %i", iName, (EXP[g_iLevel[target_id] + 1] - g_iXP[target_id]))
	}
	
	return PLUGIN_HANDLED;
}

public save_data(id)
{
	if(is_user_alive(id))
	{
		SaveData(id)
		sChatColor(id, "^x04[NTC]^x03 Đã save exp và rank")
	}
}

public event_new_round()
{
	new iPlayers[MAXPLAYERS], iPlayerCount, i, player
	get_players(iPlayers, iPlayerCount, "a") 
	for(i = 0; i < iPlayerCount; i++)
	{
		player = iPlayers[i]
		g_iDamage[player][player] = 0
	}
	MakeTop15( )
}

public event_Restart()
{
	g_iZombieScore = 0
	g_iHumanScore = 0
	
}

public event_Damage(iVictim)
{
	static iAttacker; iAttacker = get_user_attacker(iVictim)
	static iHit; iHit = read_data(2)
	
	new AttackerHud = CreateHudSyncObj()
	new VictimHud = CreateHudSyncObj()
	
	if(iAttacker == iVictim || !is_user_alive(iAttacker) || !is_user_alive(iVictim))
		return
	
	set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
	ShowSyncHudMsg(iVictim, VictimHud, "%i^n", iHit)	
	
	
	set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
	ShowSyncHudMsg(iAttacker, AttackerHud, "%i^n", iHit)
	
	
	Show_spectate(iVictim, iAttacker, iHit)
	
	if(zp_get_user_zombie(iVictim) && !zp_get_user_survivor(iAttacker))
	{
		g_iDamage[iAttacker][iVictim] += read_data(2)
		
		if(g_iDamage[iAttacker][iVictim] >= 1300)
		{	
			g_iXP[iAttacker] += 2
			
			//sChatColor(iAttacker, "^x04[CL]^x01 %L", LANG_PLAYER, "CL_DEALT_DAMAGE", get_pcvar_num(g_iDamageEXP), get_pcvar_num(g_iDamageAmount))
			g_iDamage[iAttacker][iVictim] = 0
			
			ReviewLevel(iAttacker)
		}
		
	}
}

public Show_spectate(iVictim, iAttacker, iHit)
{
	new AttackerSpecHud = CreateHudSyncObj()
	new VictimSpecHud = CreateHudSyncObj()
	
	new Players[MAXPLAYERS], iPlayerCount, i, id
	get_players(Players, iPlayerCount, "bc") 
	for (i = 0; i < iPlayerCount; i++) 
	{
		id = Players[i]
		if (id != iVictim && entity_get_int(id, EV_INT_iuser2) == iVictim)
		{
			set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
			ShowSyncHudMsg(id, VictimSpecHud, "%i^n", iHit)
		}
		
		if (id != iAttacker && entity_get_int(id, EV_INT_iuser2) == iAttacker)
		{
			set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(id, AttackerSpecHud, "%i^n", iHit)			
		}
	}
}

public event_DeathMsg()
{
	new iKiller; iKiller = read_data(1)
	new iVictim; iVictim = read_data(2)
	new iIsHeadshot; iIsHeadshot = read_data(3)
	
	if(iVictim == iKiller || !is_user_alive(iKiller))
		return
	
	if(!zp_get_user_zombie(iKiller) || zp_get_user_survivor(iKiller))
	{
		if(zp_get_user_nemesis(iVictim))
		{
			g_iXP[iKiller] += 1
			//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL_NEMESIS", get_pcvar_num(g_iNemKillEXP))
			
			ReviewLevel(iKiller)
			
		}
		else
		{
			if(iIsHeadshot)
			{
				g_bKilledZombie[iKiller][iVictim] = true
				
				g_iXP[iKiller] += 2
				//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_HEADSHOT_KILL", get_pcvar_num(g_iHeadShotEXP))
			}
			else
			{
				g_bKilledZombie[iKiller][iVictim] = true
				
				g_iXP[iKiller] += 1
				//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL", get_pcvar_num(g_iHumanEXP))
			}
			
			ReviewLevel(iKiller)
			
			new iPlayers[MAXPLAYERS], iPlayerCount, i, id
			get_players(iPlayers, iPlayerCount, "ah") 
			for(i = 0; i < iPlayerCount; i++)
			{
				id = iPlayers[i]
				
				if(g_iDamage[id][iVictim] >= g_iMaxHealth[iVictim]/ 5)
				{	
					if(!g_bKilledZombie[id][iVictim] && !zp_core_is_zombie(id))
					{
						g_iXP[id] += 1
						
						new szName[32]
						get_user_name(iKiller, szName, charsmax(szName))
						//sChatColor(id, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_ASSIST", get_pcvar_num(g_iAssistEXP), RANKS[g_iLevel[iKiller]], szName)
						
						ReviewLevel(id)
						
						g_iDamage[id][iVictim] = 0
					}
					else
					{
						g_bKilledZombie[id][iVictim] = false
					}
				}
			}
			
		}
	}
	else if(zp_get_user_zombie(iKiller) || zp_get_user_nemesis(iKiller))
	{
		if(zp_get_user_survivor(iVictim))
		{
			
			g_iXP[iKiller] += 3
			//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL_SURVIVOR", get_pcvar_num(g_iSurKillEXP))
			
			ReviewLevel(iKiller)
			
		}
		else
		{
			g_iXP[iKiller] += 2
			//sChatColor(iKiller, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_KILL_HUMAN", get_pcvar_num(g_iZombieEXP))
			
			ReviewLevel(iKiller)
		}
	}
}

public ReviewLevel(id)
{
	while((g_iLevel[id] < 18 && g_iXP[id] >= EXP[g_iLevel[id] + 1]))
	{
		g_iLevel[id] += 1
		new name[33];
		get_user_name(id, name, charsmax(name));
		
		sChatColor(id, "^x04[NTC]^x03 %s ^x01đã lên rank ^x04%s", name, RANKS[g_iLevel[id]])
	}
}

public event_StatusValue(id)
{	
	new pid = read_data(2)
	new pidlevel = g_iLevel[pid]
	
	if(!pev_valid(pid) || !is_user_alive(pid) || zp_get_user_zombie(pid))
		return
	
	
	Create_TE_PLAYERATTACHMENT(id, pid, 55, g_iSprite[pidlevel], 2)
	
}


public zp_fw_core_infect_post(id, attacker)
{
	if(zp_class_zombie_get_current(id) == ZP_INVALID_ZOMBIE_CLASS)
		return;
	
	g_iMaxHealth[id] = zp_class_zombie_get_max_health(id, zp_class_zombie_get_current(id))
	
	if (is_user_alive(attacker) && attacker != id)
	{
		g_iXP[attacker] += 2
		//sChatColor(attacker, "^x04[CL]^x03 %L", LANG_PLAYER, "CL_INFECT", get_pcvar_num(g_iInfectEXP))
		
		ReviewLevel(id)
	}
	
}

SaveData(id) {
	
	new szTemp[ 512 ]
	formatex( szTemp, charsmax( szTemp ),"DELETE FROM level_zp WHERE name = '%s'", g_sName[id])
	SQL_ThreadQuery( g_SqlTuple, "IgnoreHandle", szTemp )
	
	formatex( szTemp, charsmax( szTemp ),"INSERT INTO level_zp ( name, exp, level) VALUES( '%s', '%d', '%d')", g_sName[id], g_iXP[id], g_iLevel[id])
	SQL_ThreadQuery( g_SqlTuple, "IgnoreHandle", szTemp )
}

LoadData(id) {
	new Data[ 1 ]
	Data[ 0 ] = id
	
	new szTemp[ 512 ]
	format( szTemp, charsmax( szTemp ),"SELECT exp, level FROM level_zp WHERE name = '%s'", g_sName[ id ] )
	
	SQL_ThreadQuery( g_SqlTuple, "LoadPoints_QueryHandler", szTemp, Data, 1 )
}
public LoadPoints_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	new id
	id = Data[ 0 ]
	
	if( !SQL_IsFail( FailState, Errcode, Error ) )
	{
		if( SQL_NumResults( Query ) < 1 )
		{
			new szTemp[ 512 ]
			format( szTemp, charsmax( szTemp ),"INSERT INTO level_zp ( name, exp, level) VALUES( '%s', '%d', '%d')", g_sName[id], g_iXP[id], g_iLevel[id] )
			
			SQL_ThreadQuery( g_SqlTuple, "IgnoreHandle", szTemp )
		} 
		
		else
		{
			g_iXP[ id ] = SQL_ReadResult( Query, 0 )
			g_iLevel[ id ] = SQL_ReadResult( Query, 1 )
		}
	}
}

public IgnoreHandle( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	SQL_FreeHandle( Query )
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error)
		return
	}
	
	
}

public show_stats(id)
{		
	new Data[ 1 ]
	Data[ 0 ] = id
	
	new szTemp[ 512 ]
	format( szTemp, charsmax( szTemp ), "SELECT COUNT(*) FROM level_zp WHERE exp >= %d", g_iXP[ id ] )
	
	SQL_ThreadQuery( g_SqlTuple, "SkillRank_QueryHandler", szTemp, Data, 1 )
	
}
public SkillRank_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( !SQL_IsFail( FailState, Errcode, Error ) )
	{
		new id
		id = Data[ 0 ]
		
		g_iRank[ id ] = SQL_ReadResult( Query, 0 )
		
		if( g_iRank[ id ] == 0 )
		{
			g_iRank[ id ] = 1
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
	
	SQL_ThreadQuery( g_SqlTuple, "TotalRows_QueryHandler", szTemp, Data, 1 )
}

public TotalRows_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( !SQL_IsFail( FailState, Errcode, Error ) )
	{
		new id
		id = Data[ 0 ]
		
		g_iCount = SQL_ReadResult( Query, 0 )
		
		sChatColor( id, "!g[NTC]!n Dang o rank %d/%d", g_iRank[ id ], g_iCount )
		sChatColor(id, "^x04[NTC]^x03 Exp hiện tại %d, cần %d để lên cap", RANKS[g_iLevel[id]], (EXP[g_iLevel[id] + 1] - g_iXP[id]))
		
	}
}

public MakeTop15( )
{	
	new szQuery[ 512 ]
	formatex( szQuery, charsmax( szQuery ),"SELECT name, level FROM level_zp ORDER BY exp DESC LIMIT 10")
	
	SQL_ThreadQuery( g_SqlTuple, "MakeTop15_QueryHandler", szQuery )
}

public MakeTop15_QueryHandler( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if( !SQL_IsFail( FailState, Errcode, Error ) )
	{
		new szName[ 33 ]
		
		new iLevel
		
		new iLen
		iLen = formatex( g_szMotd, charsmax( g_szMotd ),
		"<html><head><meta charset=^"UTF-8^"></head><body bgcolor=#A4BED6>\
		<table width=100%% cellpadding=2 cellspacing=0 border=0>\
		<tr align=center bgcolor=#52697B>\
		<th width=4%%>#\
		<th width=30%% align=left>Ten\
		<th width=20%%>Level\
		<th width=46%%>Cap bac" )
		
		new i = 1
		while( SQL_MoreResults( Query ) )
		{
			SQL_ReadResult( Query, 0, szName, charsmax( szName ) )
			
			iLevel = SQL_ReadResult( Query, 1 )
			
			replace_all( szName, charsmax( szName ), "<", "[" )
			replace_all( szName, charsmax( szName ), ">", "]" )
			
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<tr align=center>" )
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<td>%i", i )
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<td align=left>%s", szName )
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<td>%d", iLevel)
			iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "<td>%s", RANKS[iLevel] )
			
			i++
			
			SQL_NextRow( Query )
		}
		
		iLen += formatex( g_szMotd[ iLen ], charsmax( g_szMotd ) - iLen, "</table></body></html>" )
	}
}

SQL_IsFail( FailState, Errcode, Error[ ] ) {
	if( FailState == TQUERY_CONNECT_FAILED )
	{
		log_amx( "[Error] Could not connect to SQL database: %s", Error )
		return true
	}
	
	if( FailState == TQUERY_QUERY_FAILED )
	{
		log_amx( "[Error] Query failed: %s", Error )
		return true
	}
	
	if( Errcode )
	{
		log_amx( "[Error] Error on query: %s", Error )
		return true
	}
	
	return false
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
