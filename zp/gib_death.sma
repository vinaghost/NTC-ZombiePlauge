/*
---------------------------------------------------------
   #  #  #    #===    ###    ##    #
  #    ##     #===   #      #  #    #
   #   #      #===    ###    ##    #
---------------------------------------------------------
Gib Death 2.1

Plugin made by <VeCo>
Special thanks to:
 - IMBA : for removing the death bodies.
 - hateYou : for the optimization
 - papyrus_kn : for the video of the plugin
 - alan_el_more : for using Ham_Spawn instead of ResetHUD
 - Nextra : for the optimization
 - Arkshine : for fixing the bugs in version 1.7 and HLSDK
	      constants

If you modify the code, please DO NOT change the author!
---------------------------------------------------------
Contacts:
e-mail: veco.kn@gmail.com
skype: veco_kn
---------------------------------------------------------
Changes log:
 -> v 1.0 = First release!
 -> v 1.1 = Optimization.
 -> v 1.2 = Fixed bug with spectators.
 	    Fixed bug with some of materials.
            Plugin needs fun module.
	    Added two new materials.
 -> v 1.3 = Fixed part of code for removing 
	    the death bodies.
	    Plugin doesn't needs engine module.
	    Added new material.
 -> v 1.4 = Changed ResetHUD to Ham_Spawn.
            Plugin needs hamsandwich module.
	    Removed fun module.
 -> v 1.5 = Optimization.
            Added new material.
 -> v 1.6 = Added CVAR for changing the spread of the gibs.
            Optimization.
	    Added new material.
 -> v 1.7 = Fixed a lot of bugs.
	    Plugin doesn't need fakemeta module.
	    Plugin needs engine and fun modules.
 -> v 2.0 = Rewritten code.
	    Added better method for hiding dead bodies.
	    CVAR "gib_type" now uses flags, allowing users
	    to enable/disable gibs by their own choice.
	    Added "gib_count" and "gib_life" CVARs.
	    Removed usage of fun module.
	    Tweaked gib velocity values a bit.
 -> v 2.1 = Added "Zombie Plague" support (see USE_ZP define).
---------------------------------------------------------
Don't forget to visit http://www.amxmodxbg.org :)
---------------------------------------------------------
*/

#include <amxmodx>
#include <hamsandwich>
#include <engine>

#define USE_ZP // uncomment this line to use Zombie Plague mode (gib effects apply only to zombies)

#if defined USE_ZP
#include <zombieplague>
#endif

#define BREAK_GLASS       0x01
#define BREAK_METAL       0x02
#define BREAK_FLESH       0x04
#define BREAK_WOOD        0x08
#define BREAK_CONCRETE    0x40

new const g_sz_Const_GibModels[][] =
{
	"models/hgibs.mdl",
	"models/glassgibs.mdl",
	"models/woodgibs.mdl",
	"models/metalplategibs.mdl",
	"models/cindergibs.mdl",
	"models/ceilinggibs.mdl",
	"models/computergibs.mdl",
	"models/rockgibs.mdl",
	"models/bookgibs.mdl",
	"models/garbagegibs.mdl",
	"models/bonegibs.mdl",
	"models/cactusgibs.mdl",
	"models/webgibs.mdl"
}

new const g_i_Const_GibMaterials[sizeof g_sz_Const_GibModels] =
{
	BREAK_FLESH,
	BREAK_GLASS,
	BREAK_WOOD,
	BREAK_METAL,
	BREAK_CONCRETE,
	BREAK_CONCRETE,
	BREAK_METAL,
	BREAK_CONCRETE,
	BREAK_FLESH,
	BREAK_FLESH,
	BREAK_FLESH,
	BREAK_WOOD,
	BREAK_FLESH
}

new g_i_CacheGibsMdl[sizeof g_sz_Const_GibModels],
g_i_CacheAvailableGibs[sizeof g_sz_Const_GibModels],g_i_CacheAvailableNum,
g_p_Cvar_GibType,g_p_Cvar_GibSpread,g_p_Cvar_GibCount,g_p_Cvar_GibLife
public plugin_precache() for(new i=0;i<sizeof g_sz_Const_GibModels;i++) g_i_CacheGibsMdl[i] = precache_model(g_sz_Const_GibModels[i])

public plugin_init()
{
	register_plugin("Gib Death","2.1","<VeCo>")
	
	
	g_p_Cvar_GibType = register_cvar("gib_type","abcdefghijklm")
	g_p_Cvar_GibSpread = register_cvar("gib_spread","10")
	g_p_Cvar_GibCount = register_cvar("gib_count","8")
	g_p_Cvar_GibLife = register_cvar("gib_life","30")
	
	
	register_logevent("LogEvent_RoundStart",2,"1=Round_Start")
	
	RegisterHam(Ham_Killed,"player","HamHook_Player_Killed_Post",1)
	
#if !defined USE_ZP
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
#else
	register_message(get_user_msgid("ClCorpse"),"MessageHook_ClCorpse")
#endif
}

public LogEvent_RoundStart()
{
	g_i_CacheAvailableNum = 0
	
	
	new sz_CacheCvar_Type[42]
	get_pcvar_string(g_p_Cvar_GibType, sz_CacheCvar_Type,charsmax(sz_CacheCvar_Type))
	
	new i_CacheCvar_StrLen = strlen(sz_CacheCvar_Type)
	
	
	for(new i=0;i<i_CacheCvar_StrLen;i++)
	{
		if(sz_CacheCvar_Type[i] > 'm' || sz_CacheCvar_Type[i] < 'a') continue
		
		g_i_CacheAvailableGibs[g_i_CacheAvailableNum++] = sz_CacheCvar_Type[i] - 'a'
	}
}

public HamHook_Player_Killed_Post(id/*,killer,shouldgib*/)
{
#if defined USE_ZP
	if(!zp_get_user_zombie(id)) return HAM_IGNORED
#endif
	
	entity_set_int(id,EV_INT_effects,entity_get_int(id,EV_INT_effects) | EF_NODRAW)
	
	
	new i_GetGib = g_i_CacheAvailableGibs[(g_i_CacheAvailableNum>1) ? random(g_i_CacheAvailableNum) : 0]
	
	
	new i_v_Origin[3]
	get_user_origin(id,i_v_Origin)
	
	message_begin(MSG_PVS,SVC_TEMPENTITY, i_v_Origin)
	{
		write_byte(TE_BREAKMODEL)
		
		write_coord(i_v_Origin[0])
		write_coord(i_v_Origin[1])
		write_coord(i_v_Origin[2] + 16)
		
		write_coord(32)
		write_coord(32)
		write_coord(32)
		
		write_coord(0)
		write_coord(0)
		write_coord(25)
		
		write_byte(get_pcvar_num(g_p_Cvar_GibSpread))
		
		write_short(g_i_CacheGibsMdl[i_GetGib])
		
		write_byte(get_pcvar_num(g_p_Cvar_GibCount))
		write_byte(get_pcvar_num(g_p_Cvar_GibLife))
		
		write_byte(g_i_Const_GibMaterials[i_GetGib])
	}
	message_end()
	
	return HAM_HANDLED
}

#if defined USE_ZP
public MessageHook_ClCorpse(msgid,msgdest,id) return zp_get_user_zombie(get_msg_arg_int(12))
#endif
