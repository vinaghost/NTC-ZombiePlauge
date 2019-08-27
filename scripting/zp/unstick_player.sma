
#include <amxmodx>
#include <fakemeta>
#include <cs_ham_bots_api>
#include <hamsandwich>
#include <zp50_colorchat>


#define START_DISTANCE  32   //  The first search distance for finding a free location in the map.
#define MAX_ATTEMPTS    128  //  How many times to search in an area for a free space.


#define MAX_CLIENTS     32

new Float:gf_LastCmdTime[ MAX_CLIENTS + 1 ];
new Float:gp_UnstuckFrequency = 4.0;


enum Coord_e { // Just for readability.
	Float:x,
	Float:y,
	Float:z
};


#define GetPlayerHullSize(%1)  ( ( pev ( %1, pev_flags ) & FL_DUCKING ) ? HULL_HEAD : HULL_HUMAN ) //  Macro.
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

// Safety
new g_IsConnected, g_IsAlive

public plugin_init ()
{
	register_plugin ( "Unstick Player", "1.0.2", "Arkshine" );

	//  Cvars.
	gp_UnstuckFrequency = register_cvar ( "amx_unstuck_frequency", "4.0" );

	//  Client command.
	register_clcmd ( "say_team /stuck"  , "ClientCommand_UnStick" );
	register_clcmd ( "say /stuck"       , "ClientCommand_UnStick" );
	register_clcmd ( "say_team /unstuck", "ClientCommand_UnStick" );
	register_clcmd ( "say /unstuck"     , "ClientCommand_UnStick" );
}


public ClientCommand_UnStick ( const id )
{
	new Float:f_ElapsedCmdTime = get_gametime () - gf_LastCmdTime[ id ];

	if ( f_ElapsedCmdTime < gp_UnstuckFrequency )
	{
		client_print ( id, print_chat, "[AMXX] You must wait %.1f seconds before trying to free yourself.", f_MinFrequency - f_ElapsedCmdTime );
		return PLUGIN_HANDLED;
	}

	gf_LastCmdTime[ id ] = get_gametime ();

	new i_Value;

	if ( ( i_Value = UTIL_UnstickPlayer ( id, START_DISTANCE, MAX_ATTEMPTS ) ) != 1 )
	{
		switch ( i_Value )
		{
			case 0  : client_print ( id, print_chat, "[AMXX] Couldn't find a free spot to move you too" );
			case -1 : client_print ( id, print_chat, "[AMXX] You cannot free yourself as dead player" );
		}
	}

	return PLUGIN_CONTINUE;
}


UTIL_UnstickPlayer ( const id, const i_StartDistance, const i_MaxAttempts )
{
		//  Not alive, ignore.
		if ( !is_user_alive ( id ) )  return -1

		static Float:vf_OriginalOrigin[ Coord_e ], Float:vf_NewOrigin[ Coord_e ];
		static i_Attempts, i_Distance;

		//  Get the current player's origin.
		pev ( id, pev_origin, vf_OriginalOrigin );

		i_Distance = i_StartDistance;

		while ( i_Distance < 1000 )
		{
			i_Attempts = i_MaxAttempts;

			while ( i_Attempts-- )
			{
				vf_NewOrigin[ x ] = random_float ( vf_OriginalOrigin[ x ] - i_Distance, vf_OriginalOrigin[ x ] + i_Distance );
				vf_NewOrigin[ y ] = random_float ( vf_OriginalOrigin[ y ] - i_Distance, vf_OriginalOrigin[ y ] + i_Distance );
				vf_NewOrigin[ z ] = random_float ( vf_OriginalOrigin[ z ] - i_Distance, vf_OriginalOrigin[ z ] + i_Distance );

				engfunc ( EngFunc_TraceHull, vf_NewOrigin, vf_NewOrigin, DONT_IGNORE_MONSTERS, GetPlayerHullSize ( id ), id, 0 );

				//  Free space found.
				if ( get_tr2 ( 0, TR_InOpen ) && !get_tr2 ( 0, TR_AllSolid ) && !get_tr2 ( 0, TR_StartSolid ) )
				{
					//  Set the new origin .
					engfunc ( EngFunc_SetOrigin, id, vf_NewOrigin );
					return 1;
				}
			}

			i_Distance += i_StartDistance;
		}

		//  Could not be found.
		return 0;
	}

public client_putinserver(id)
{
	Safety_Connected(id)
}

public client_disconnected(id)
{
	Safety_Disconnected(id)
}
/* ===============================
------------- SAFETY -------------
=================================*/
public Register_SafetyFunc()
{
	register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")

	RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
	RegisterHamBots(Ham_Spawn, "fw_Safety_Spawn_Post", 1)
	RegisterHamBots(Ham_Killed, "fw_Safety_Killed_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

public Safety_Connected(id)
{
	Set_BitVar(g_IsConnected, id)
	UnSet_BitVar(g_IsAlive, id)

	g_PlayerWeapon[id] = 0
}

public Safety_Disconnected(id)
{
	UnSet_BitVar(g_IsConnected, id)
	UnSet_BitVar(g_IsAlive, id)

	g_PlayerWeapon[id] = 0
}

public Safety_CurWeapon(id)
{
	if(!is_alive(id))
		return

	static CSW; CSW = read_data(2)
	if(g_PlayerWeapon[id] != CSW) g_PlayerWeapon[id] = CSW
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

public is_alive(id)
{
	if(!(1 <= id <= 32))
		return 0
	if(!Get_BitVar(g_IsConnected, id))
		return 0
	if(!Get_BitVar(g_IsAlive, id))
		return 0

	return 1
}

public is_connected(id)
{
	if(!(1 <= id <= 32))
		return 0
	if(!Get_BitVar(g_IsConnected, id))
		return 0

	return 1
}
