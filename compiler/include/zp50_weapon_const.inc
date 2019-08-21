#if defined _zp50_weapons_const_included
  #endinput
#endif
#define _zp50_weapons_const_included

/* Item ID constants */
#define ZP_INVALID_WEAPON -1

/* Item selection constants */
#define ZP_WEAPON_AVAILABLE 0
#define ZP_WEAPON_NOT_AVAILABLE 1
#define ZP_WEAPON_DONT_SHOW 2

#define ZP_PRIMARY 0
#define ZP_SECONDARY 1
#define ZP_KNIFE 2

#define ZP_WEAPON_AP 0
#define ZP_WEAPON_MONEY 1

#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))
