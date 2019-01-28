#include <amxmodx>
#include <hamsandwich>

new Float:g_fNextCheer[33]
new amluong
new const cheer_sound[7][] =
{
	"cheer/cheer_1.wav",
	"cheer/cheer_2.wav",
	"cheer/cheer_3.wav",
	"cheer/cheer_4.wav",
	"cheer/cheer_5.wav",
	"cheer/cheer_6.wav",
	"cheer/cheer_7.wav"
}
new msgid
public plugin_init()
{
	register_plugin("CHEER", "1.0", "VINAGHOST")
	register_clcmd("cheer", "clcmd_cheer")
	amluong = register_cvar("vg_cheer", "1.0")
	msgid = get_user_msgid("SayText")
	
}

public plugin_precache()
{
	for(new i = 0; i < sizeof cheer_sound; i++)
		precache_sound(cheer_sound[i])
}
stock client_mau(const id, const input[], any:...) 
{ 
	new count = 1, players[32] 
	
	static msg[191] 
	
	vformat(msg, 190, input, 3) 
	
	replace_all(msg, 190, "!g", "^4") 
	replace_all(msg, 190, "!y", "^1") 
	replace_all(msg, 190, "!t", "^3") 
	replace_all(msg, 190, "!t2", "^0") 
	
	if (id) players[0] = id; else get_players(players, count, "ch") 
	
	for (new i = 0; i < count; i++) 
	{ 
		if (is_user_connected(players[i])) 
		{ 
			message_begin(MSG_ONE_UNRELIABLE, msgid, _, players[i]) 
			write_byte(players[i]) 
			write_string(msg) 
			message_end() 
		} 
	}  
}
public clcmd_cheer(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED
	
	new Float:time_cheer = get_gametime()
	
	if (g_fNextCheer[id] > time_cheer)
	{
		return PLUGIN_HANDLED
	}
	
	new cheer = random_num(0,6)
	emit_sound(0, CHAN_VOICE, cheer_sound[cheer], get_pcvar_float(amluong), ATTN_NONE, 0, PITCH_NORM)
	new name[33]
	get_user_name(id, name, 32) 
	client_mau(0, "!g[Thông báo] !t%s !ycheer!!!!!!", name)
	
	g_fNextCheer[id] = time_cheer + 40.0
	
	return PLUGIN_HANDLED
}
