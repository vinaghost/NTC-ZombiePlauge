#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <cs_ham_bots_api>

#define PLUGIN "Advanced Bullet Damage"
#define VERSION "1.0"
#define AUTHOR "Sn!ff3r"

new g_hudmsg1, g_hudmsg2
new Float:xA[33]
new Float:yA[33]
new Float:xV[33]
new Float:yV[33];
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	//register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0");
	RegisterHam(Ham_TakeDamage, "player", "fw_Player_TakeDamage_post", 1);
	RegisterHamBots(Ham_TakeDamage, "fw_Player_TakeDamage_post", 1);


	g_hudmsg1 = CreateHudSyncObj()
	g_hudmsg2 = CreateHudSyncObj()
}
public fw_Player_TakeDamage_post(id, Inflictor, attacker, Float:Damage, DamageBits) {

	static iPlayers[32], iNum;
	get_players(iPlayers, iNum, "bch");

	static damage; damage = floatround(Damage);

	if(is_user_connected(attacker)) {

		CheckPosition( attacker, 1 )

		set_hudmessage(0, 100, 200, xA[attacker], yA[attacker], 2, 0.1, 4.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(attacker, g_hudmsg1, "%i^n", damage)

		for(new i = 0, Spectator = iPlayers[0]; i < iNum; Spectator = iPlayers[i++]) {
			if(entity_get_int(Spectator, EV_INT_iuser2) == attacker) {
				set_hudmessage(0, 100, 200, xA[attacker], yA[attacker], 2, 0.1, 4.0, 0.02, 0.02, -1)
				ShowSyncHudMsg(Spectator, g_hudmsg1, "%i^n", damage)
			}
		}
	}
	if(is_user_connected(id)) {

		CheckPosition( id, 0 )

		set_hudmessage(255, 0, 0, xV[id], yV[id], 2, 0.1, 4.0, 0.1, 0.1, -1)
		ShowSyncHudMsg(id, g_hudmsg2, "%i^n", damage)

		for(new i = 0, Spectator = iPlayers[0]; i < iNum; Spectator = iPlayers[i++]) {

			if(entity_get_int(Spectator, EV_INT_iuser2) == id) {
				set_hudmessage(255, 0, 0, xV[id], yV[id], 2, 0.1, 4.0, 0.1, 0.1, -1)
				ShowSyncHudMsg(Spectator, g_hudmsg2, "%i^n", damage)
			}
		}
	}
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


