#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_stocks>
#include <cstrike>
#include <fun>

native is_alive(id)
native is_connected(id)
native get_progress()
native set_progress(progress)

#define Get_BitVar(%1,%2)		(%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2)		(%1 |= (1 << (%2 & 31)));
#define UnSet_BitVar(%1,%2)		(%1 &= ~(1 << (%2 & 31)));

enum _: {
	WAITING = 0,
	COUNTDOWN,
	START
}


forward bc_progress(progress)
forward bc_last(id)
forward bc_spawn(id)
forward bc_use_pre(id)
forward bc_use_post(id)
//forward bc_takedmg(victim, attacker, Float:damage)
