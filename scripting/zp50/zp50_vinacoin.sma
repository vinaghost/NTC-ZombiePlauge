#include <amxmodx>
#include <sqlx>

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
	DATA_PASS[9],
	DATA_COIN,
	DATA_STATUS
};

const FULL_STATUS = CONNECTED | AUTHORIZED;

new g_iPlayerData[ 33 ][ PLR_DATA ];
new g_szSqlTable[] = "vinacoin";

new Handle:g_hSqlTuple;
new g_iMaxPlayers;

new passfield[] = "_coin";
public plugin_init()
{
	// credit: xPaw for his point system
	register_plugin("VINACOIN", "1.0", "VINAGHOST")

	set_task(1.0, "Init_MYSQL")
}
public plugin_natives() {

	register_native("zp_get_user_coin", "NativeGetPoints");
	register_native("zp_add_user_coin", "NativeSetPoints");
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
	formatex(szQuery, charsmax(szQuery), "CREATE TABLE IF NOT EXISTS %s (Id int NOT NULL AUTO_INCREMENT, name CHAR(30) NOT NULL, pass CHAR(5) NOT NULL, vinacoin INT NOT NULL DEFAULT 0, PRIMARY KEY (Id), UNIQUE (name));", g_szSqlTable)

	SQL_ThreadQuery( g_hSqlTuple, "HandleNullRoute", szQuery );

	g_iMaxPlayers = get_maxplayers();

	server_print("[VINACOIN] MYSQL connection succesful");
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
	g_iPlayerData[ id ][ DATA_STATUS ] = 0;
	g_iPlayerData[ id ][ DATA_PASS ][0] = 0;
	g_iPlayerData[ id ][ DATA_COIN ] = 0;
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

    g_iPlayerData[ iPlayer ][ DATA_COIN ] = iPoints;


    new szQuery[ 128 ];
    formatex( szQuery, 127, "UPDATE `%s` SET `vinacoin` = '%i' WHERE `Id` = '%i'",
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

    return g_iPlayerData[ iPlayer ][ DATA_COIN ];
}
// SQL Related
// ====================================
UserHasBeenAuthorized( const id )
{
	new szName[ 32 ], szQuery[ 128 ];
	get_user_name( id, szName, charsmax(szName));
	formatex( szQuery, charsmax(szQuery), "SELECT `Id`,  `pass`, `vinacoin` FROM `%s` WHERE `name` = '%s'", g_szSqlTable, szName );

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
		SQL_ReadResult( hQuery, 1 , g_iPlayerData[ id ][ DATA_PASS ], charsmax(g_iPlayerData[  ][ DATA_PASS ]) );
		g_iPlayerData[ id ][ DATA_COIN ] = SQL_ReadResult( hQuery, 2 );

		new password[8];
		get_user_info(id, passfield, password, charsmax(password))

		if (!equal(g_iPlayerData[ id ][ DATA_PASS ], password)) {
			server_cmd("kick #%d ^"Tai khoan nay co VINACOIN. Xem console ( ~ )^"", get_user_userid(id));
			client_print(id, print_console, "Tài khoản này có VINACOIN. Đề nghị nhập password như hướng dẫn cua VINA");
		}

	}
}


stock bool:SQL_IsFail( const iFailState, const iError, const szError[ ] )
{
	if( iFailState == TQUERY_CONNECT_FAILED )
	{
		log_amx( "[VINACOIN] Could not connect to SQL database: %s", szError );
		return true;
	}
	else if( iFailState == TQUERY_QUERY_FAILED )
	{
		log_amx( "[VINACOIN] Query failed: %s", szError );
		return true;
	}
	else if( iError )
	{
		log_amx( "[VINACOIN] Error on query: %s", szError );
		return true;
	}

	return false;
}

