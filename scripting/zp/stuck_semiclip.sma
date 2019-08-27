#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <engine>

new stuck[33]

new g_cvar[3]

new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}

#define IsPlayer(%1) (1 <= %1 <= g_MaxPlayers)

new g_MaxPlayers

public plugin_init() {
	register_plugin("Automatic Unstuck","1.5","NL)Ramon(NL")
	g_cvar[0] = register_cvar("amx_autounstuck","1")
	g_cvar[1] = register_cvar("amx_autounstuckeffects","1")
	g_cvar[2] = register_cvar("amx_autounstuckwait","3")
	
	register_think("StuckTimer", "checkstuck")    
	
	new ent
	
	do
		ent = create_entity("info_null")
	
	while(!is_valid_ent(ent))   
		
	entity_set_string(ent, EV_SZ_classname, "StuckTimer")
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 10.0)
	
	g_MaxPlayers = get_maxplayers()
}

public checkstuck(ent) 
{
	static Float:gameTime, Float:oldGameTime, cvar[3]
	
	gameTime = get_gametime()
	
	if(gameTime >= oldGameTime)
	{
		cvar[0] = get_pcvar_num(g_cvar[0])
		cvar[1] = get_pcvar_num(g_cvar[1])
		cvar[2] = get_pcvar_num(g_cvar[2])
		
		oldGameTime = gameTime + 60.0
	}
	
	if(cvar[0] >= 1) {
		static players[32], pnum, player
		get_players(players, pnum, "a")
		static Float:origin[3]
		static Float:mins[3], hull
		static Float:vec[3]
		static o,i
		for(i=0; i<pnum; i++){
			player = players[i]
			
			pev(player, pev_origin, origin)
			hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
			if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player)) {
				++stuck[player]
				if(stuck[player] >= cvar[2]) {
					pev(player, pev_mins, mins)
					vec[2] = origin[2]
					for (o=0; o < sizeof size; ++o) {
						vec[0] = origin[0] - mins[0] * size[o][0]
						vec[1] = origin[1] - mins[1] * size[o][1]
						vec[2] = origin[2] - mins[2] * size[o][2]
						if (is_hull_vacant(vec, hull,player)) {
							engfunc(EngFunc_SetOrigin, player, vec)
							effects(player, cvar[1])
							set_pev(player,pev_velocity,{0.0,0.0,0.0})
							o = sizeof size
						}
					}
				}
			}
			else
			{
				stuck[player] = 0
			}
		}
	}
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0)
}

stock bool:is_hull_vacant(const Float:origin[3], hull, id)
{
	static tr
	
	engfunc(EngFunc_TraceHull, origin, origin, DONT_IGNORE_MONSTERS, hull, id, tr)
	
	if (IsPlayer(get_tr2(tr, TR_pHit)) || (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen)))
		return true
		
	return false
}

public effects(id, cvar[])
{
	if(cvar[0])
	{
		set_hudmessage(255,150,50, -1.0, 0.65, 0, 6.0, 1.5,0.1,0.7) // HUDMESSAGE
		show_hudmessage(id,"You should be unstucked now!") // HUDMESSAGE		
		message_begin(MSG_ONE_UNRELIABLE,105,{0,0,0},id )      
		write_short(1<<10)   // fade lasts this long duration
		write_short(1<<10)   // fade lasts this long hold time
		write_short(1<<1)   // fade type (in / out)
		write_byte(20)            // fade red
		write_byte(255)    // fade green
		write_byte(255)        // fade blue
		write_byte(255)    // fade alpha
		message_end()
		client_cmd(id,"spk fvox/blip.wav")
	}
}
