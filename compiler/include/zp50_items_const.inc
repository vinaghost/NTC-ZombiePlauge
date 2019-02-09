#if defined _zp50_items_const_included
  #endinput
#endif
#define _zp50_items_const_included

/* Item ID constants */
#define ZP_INVALID_ITEM -1

/* Item selection constants */
#define ZP_ITEM_AVAILABLE 0
#define ZP_ITEM_NOT_AVAILABLE 1
#define ZP_ITEM_DONT_SHOW 2

#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))
