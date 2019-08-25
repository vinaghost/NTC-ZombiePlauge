
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
public NativeSetPoints( const iPlugin, const iParams ) {
    if( iParams != 2 )
    {
        log_error( AMX_ERR_PARAMS, "Wrong parameters" );
        return false;
    }

    new iPlayer = get_param( 1 );

    if( !IsPlayer( iPlayer ) )
    {
        log_error( AMX_ERR_PARAMS, "Not a player (%i)", iPlayer );
        return false;
    }
    else if( !IsUserAuthorized( iPlayer ) || !g_iPlayerData[ iPlayer ][ DATA_INDEX ] )
    {
        log_error( AMX_ERR_PARAMS, "Player is not authorized (%i)", iPlayer );
        return false;
    }

    new iPoints = get_param( 2 );

    if( iPoints <= 0 )
    {
        log_error( AMX_ERR_PARAMS, "Tried to force points less than a zero (%i)", iPoints );
        return false;
    }

    g_iPlayerData[ iPlayer ][ DATA_POINTS ] = iPoints;
    cs_set_user_money(iPlayer, iPoints);


    new szQuery[ 128 ];
    formatex( szQuery, 127, "UPDATE `%s` SET `point` = '%i' WHERE `Id` = '%i'",
        g_szSqlTable, iPoints, g_iPlayerData[ iPlayer ][ DATA_INDEX ] );

    new iData[ 2 ];
    iData[ 0 ] = iPlayer;
    iData[ 1 ] = iPoints;

    SQL_ThreadQuery( g_hSqlTuple, "HandleNullRoute", szQuery, iData, 2 );

    return true;
}

public NativeGetPoints( const iPlugin, const iParams ) {
    if( iParams != 1 )
    {
        log_error( AMX_ERR_PARAMS, "Wrong parameters" );
        return 0;
    }

    new iPlayer = get_param( 1 );

    if( !IsPlayer( iPlayer ) )
    {
        log_error( AMX_ERR_PARAMS, "Not a player (%i)", iPlayer );
        return 0;
    }

    return g_iPlayerData[ iPlayer ][ DATA_POINTS ];
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
