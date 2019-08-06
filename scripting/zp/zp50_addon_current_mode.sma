#include <amxmodx>
#include <engine>
#include <zp50_gamemodes>



new g_hudcolor, g_hudposition, g_hudmsg


public plugin_init()
{
	register_plugin("[ZP] Addon: Display Current Mode", "1.0", "NewZMLife")
	register_think("msg", "OnHudMsgThink")
	g_hudcolor = register_cvar( "zp_currentmode_hudcolor", "0 255 0")
	g_hudposition = register_cvar( "zp_currentmode_hudposition", "-1.0 0.08")
	g_hudmsg = CreateHudSyncObj()
}




public OnHudMsgThink(Target)
{
	show_hud()
	entity_set_float(Target, EV_FL_nextthink, get_gametime() + 2.0)
}



public show_hud()
{

	if(zp_gamemodes_get_current() == ZP_NO_GAME_MODE) return;

	static hud_red,hud_green,hud_blue, Float:hud_x, Float:hud_y

	hudmsgcolor(hud_red,hud_green,hud_blue)
	hudmsgpos(hud_x,hud_y)

	set_hudmessage(hud_red, hud_green, hud_blue, hud_x, hud_y, _, _, 4.0, _, _)
	new ModeName[32]
	zp_gamemodes_get_name(zp_gamemodes_get_current(), ModeName, 31)
	ShowSyncHudMsg(0, g_hudmsg, "[%s]", ModeName)
}


public hudmsgcolor(&hud_red,&hud_green,&hud_blue)
{
	new color[16], red[4], green[4], blue[4]
	get_pcvar_string(g_hudcolor, color, 15)
	parse(color, red, 3, green, 3, blue, 3)
		
	hud_red = str_to_num(red)
	hud_green = str_to_num(green)
	hud_blue = str_to_num(blue)
}


public hudmsgpos(&Float:hud_x,&Float:hud_y)
{
	new Position[19], PositionX[6], PositionY[6]
	get_pcvar_string(g_hudposition, Position, 18)
	parse(Position, PositionX, 6, PositionY, 6)
	
	hud_x = str_to_float(PositionX)
	hud_y = str_to_float(PositionY)
}
