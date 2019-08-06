#define VERSION	"1.0"

#include <amxmodx>
#include <amxmisc>

new name[33][32]

new saytext_msgid

public plugin_init()
{
	register_plugin("THONG BAO",VERSION,"VINAGHOST")
	saytext_msgid = get_user_msgid("SayText")
}

public client_putinserver(id)
{
	if(!is_user_bot(id))
	{
		get_client_info(id)

		new str[200]
		format(str,199,"^x04[NTC] %s ^x01đã tới server ._.",name[id])


		new num, players[32], player
		get_players(players,num,"ch")
		for(new i=0;i<num;i++)
		{
			player = players[i]

			message_begin(MSG_ONE,saytext_msgid,{0,0,0},player)
			write_byte(player)
			write_string(str)
			message_end()
		}
	}
}
public get_client_info(id)
{
	get_user_name(id,name[id],31)
}

public client_infochanged(id)
{
	if(!is_user_bot(id))
	{
		get_user_info(id,"name",name[id],31)
	}
}

public client_disconnect(id)
{
	if(!is_user_bot(id))
	{
		new string[200]
		format(string,199,"^x04[NTC] %s ^x01đi rồi .-.", name[id])


		new num, players[32], player
		get_players(players,num,"ch")
		for(new i=0;i<num;i++)
		{
			player = players[i]

			message_begin(MSG_ONE,saytext_msgid,{0,0,0},player)
			write_byte(player)
			write_string(string)
			message_end()
		}
	}
}
