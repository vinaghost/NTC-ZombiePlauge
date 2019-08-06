
#if defined _ZHELL_CONST_
  #endinput
#endif

#define _ZHELL_CONST_


#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

enum {
	ZHELL_ZOMBIE,
	ZHELL_HUMAN

}

enum {
	ZP_INVALID_WEAPON = -1,
	ZHELL_PRIMARY,
	ZHELL_SECONDAYRY,
	ZHELL_KNIFE
}

enum {
	ZHELL_WEAPON_AVAILABLE,
	ZHELL_WEAPON_NOT_AVAILABLE,
	ZHELL_WEAPON_DONT_SHOW
}
#define g_szSqlTable "user"

stock getHuman(players[32], &num) {
	get_players(players, num, "ae", "CT");
}
stock getZombie(players[32], &num) {
	get_players(players, num, "ae", "TERRORIST");
}

stock PlaySoundToClients(const sound[], stop_sounds_first = 0)
{
	if (stop_sounds_first)
	{
		if (equal(sound[strlen(sound)-4], ".mp3"))
			client_cmd(0, "stopsound; mp3 play ^"%s^"", sound)
		else
			client_cmd(0, "mp3 stop; stopsound; spk ^"%s^"", sound)
	}
	else
	{
		if (equal(sound[strlen(sound)-4], ".mp3"))
			client_cmd(0, "mp3 play ^"%s^"", sound)
		else
			client_cmd(0, "spk ^"%s^"", sound)
	}
}
