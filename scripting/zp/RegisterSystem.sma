/*  AMX Mod X script
*                               ______                       __                    __          __                              ________
*		               / ____ \                      \ \                  / /         /  |                            |______  |
*		              / /    \ \                      \ \                / /         /   |                        __         | |
*		             | /      \ |                      \ \              / /         / /| |                       |__|        | |
*		             | |      | |    ______     _    __ \ \            / /  _      / / | |       ______                      | |
*    	 _   _____   _____   | |      | |   / ____ \   | |  / /  \ \          / /  |_|    / /  | |      / ____ \                     | |
*	| | / __  | / __  |  | |      | |  | /    \_\  | | / /    \ \        / /    _    / /   | |     /_/    \ \                    | |
*	| |/ /  | |/ /  | |  | |      | |  | \_____    | |/ /      \ \      / /    | |  / /____| |__     ______| |                   | |
*	| | /   | | /   | |  | |      | |   \_____ \   | | /        \ \    / /     | | /_______  |__|   / _____  |                   | |
*	| |/    | |/    | |  | |      | |         \ |  | |/\         \ \  / /      | |         | |     / /     | |        __         | |
* 	| |     | |     | |  | \      / |  __     | |  | |\ \         \ \/ /       | |         | |    | |     /| |       |  |        | |
*	| |     | |     | |   \ \____/ /   \ \____/ |  | | \ \         \  /        | |         | |     \ \___/ /\ \      / /    _____| |
*	|_|     |_|     |_|    \______/     \______/   |_|  \_\         \/         |_|         |_|      \_____/  \_\    /_/    |_______|
*
*
*
*** Copyright 2011 - 2013, m0skVi4a ;]
*** Plugin created in Rousse, Bulgaria
*
*
*** Plugin thread 1:
*	https://forums.alliedmods.net/showthread.php?t=171460
*
*** Plugin thread 2:
*	http://amxmodxbg.org/forum/viewtopic.php?t=37116
*
*
*** Description:
*
*	This is Register System. You can put a password to your name and if someone connect to the server with the same name he will be kicked if he does not login.
*
*
*** Commands:
*
*	say /reg
*	say_team /reg
*	Open the register system menu
*
*
*** CVARS:
*
*	"rs_on"			- 	Is the plugin on(1) or off(0).   Default: 1
*	"rs_save_type"		-	Where to seve the information: to file(0) or to MySQL(1).   Default: 0
*	"rs_remember"		-	How to remember the players (Registrations, Punishments): by Name(0), by IP(1) or by SteamID(2).   Default: 0
*	"rs_host"    		-	The host for the database.   Default: 127.0.0.1
*	"rs_user"	 	-	The username for the database login.   Default: root
*	"rs_pass"		-	The password for the database login.   Default:
*	"rs_db" 		- 	The database name.   Default: registersystem
*	"rs_password_prefix"	-	The prefix of the setinfo for the Auto Login function.   Default: _rspass
*	"rs_register_time"  	- 	How much time has the client to register. If is set to 0 registration is not mandatory.   Default: 0
*	"rs_login_time" 	- 	How much time has the client to login if is registered.   Default: 60.0
*	"rs_password_len"	-	What is minimum length of the password.   Default: 6
*	"rs_attempts"  		- 	How much attempts has the client to login if he type wrong password.   Default: 3
*	"rs_chngpass_times"	-	How much times can the client change his password per map.   Default: 3
*	"rs_register_log"	-	Is it allowed the plugin to log in file when the client is registered.   Default: 1
*	"rs_chngpass_log"	-	Is it allowed the plugin to log in file when the client has change his password.   Default: 1
*	"rs_autologin_log"	- 	Is it allowed the plugin to log in file when the client has change his Auto Login function.   Default: 1
*	"rs_blind"		-	Whether clients who have not Logged or who must Register be blinded.   Default: 1
*	"rs_commands"		-	Whether clients who have not Logged or who must Register commands' be blocked: Dissabled(0), Enabled for all commands(1), Enabled by File or SQL table(2).   Default: 1
*	"rs_logout"		-	What to do when client Logout - kick him from the server(0) or wait to Login during the Login time(1).   Default: 0
*	"rs_count"		-	Is the countig when you have to register or you have to login on(1) or off(0).   Default: 1
*	"rs_advert"		-	Is the advertisement for not registered players on(1) or off(0).   Default: 1
*	"rs_advert_int"		-	What is the interval between two advertisements in seconds.   Default: 60
*	"rs_ajc_team"		-	Is the Auto Join On Connect option on(1, 2, 5, 6) or off(0). 1 is Terrorists, 2 is Counter-Terrorsits, 6 Spectators, 5 Auto Assign.   Default: 0
*	"rs_ajc_class_t"	-	Which class the Terrorists will be (AJC must be on) - 1 is Terror, 2 is Leet, 3 is Artic, 4 is Guerilla, 5 is Auto Sellect, if it is set to 0 playes can choose which class they wiil be.   Default: 5
*	"rs_ajc_class_ct"	-	Which class the Counter-Terrorists will be (AJC must be on) - 1 is Urban, 2 is GSG-9, 3 is SAS, 4 is GIGN, 5 is Auto Sellect, if it is set to 0 playes can choose which class they wiil be.   Default: 5
*	"rs_ajc_admin"		-	Is it allowed players with defined flag (Default: ADMIN_IMMUNITY) can choose in which team will they be (AJC must be on).   Default: 1
*	"rs_ajc_change"		-	Is it allowed players to change their team(0) or not(1).   Default: 0
*	"rs_remember_punish_by"	-	How to remember the punished players: by Nmae(0), by IP(1) or by SteamID(2).   Default: 0
*	"rs_cant_login_time"	-	How much time in seconds players can't login after typing wrong passwrods.   Default: 300
*	"rs_cant_change_pass_time"- 	How much time in seconds players can't change their paswords after changing it before that.   Default: 300
*	"rs_whitelsit"		-	Whether clients, whose Names are in File or SQL table, must Register(1) or not(0).   Default: 1
*
*	All CVARS are without quotes!
*
*
*** Credits:
*
* 	m0skVi4a ;]    	-	for the idea of the plugin and its creation
* 	ConnorMcLeod 	- 	for his help to block the name change for logged clients
*	Sylwester	-	for the idea for the encrypt
*	dark_style	-	for ideas in the plugin
* 	Vasilii-Zaicev	-	for testing the plugin
*
*
*** Changelog:
*
*	November 6, 2011   -  V1.0 BETA:
*		-  First Release
*
*	November 20, 2011   -  V1.1 FINAL
*		-  Fixed some bugs
*		-  Added change Password function
*		-  Added Info/Help
*		-  Added cvars to show when the client is registered and change his password
*		-  Password are now encrypted for more safety
*
*	November 23, 2011   -  V1.1 FINAL FIX 1
*	-  Fixed bug if the client type more than CVAR setted attempts passwords
*
*	November 28, 2011   -  V1.1 FINAL FIX 2
*		-  Fixed bug if that the menu does not pop up when user connect
*
*	December 26, 2011   -  V2.0
*		-  Fixed bug if player change his name and the system does not check the new name
*		-  Added block chooseteam if the client is registered but not logged
*		-  Added MySQL support
*		-  Added .cfg file to manually set the settings of the system
*		-  Added CVAR for setting which clients can change their names
*		-  Added auto login on changelevel or client retry
*
*	December 27, 2011   -  V2.0 FIX 1
*		-  Fixed bug with the kick function
*
*	January 3, 2012   -  V2.0 FIX 2
*		-  Fixed bug with the auto login function that does not work on Steam clients
*
*	January 24, 2012   -  V3.0
*		-  Fixed bug with the MYSQL Connection
*		-  Added new style of the Change Password function
*		-  Removed some CVARs and added new
*		-  Now in the Register System file or into MYSQL table is not saving the date and time for registering or for changing password for the client. They are saving in special log file with name register_system_log.txt
*
*	February 17, 2012   -  V4.0
*		-  Fixed some little bugs
*		-  Added new style of the main menu
*		-  Removed the possibility of SQL Injection
*		-  The whole name change function is rewritten
*		-  Added option for the not registered and not logged clients to be blinded
*		-  Added option for the not registered and not logged clients chat's to be blocked
*		-  Added showing information in the consoles of the clients about why they are kicked
*
*	February 19, 2012   -  V4.0 FIX 1
*		-  Fixed bug with the join in the Spectator team
*		-  Added the Auto Assign option in the main menu
*		-  Small rewrite of the Auto Login function
*
*	March 7, 2012   -  V5.0
*		-  Fixed bug with % that replace the space in the name of the client
*		-  Fixed the bug with the menu that stands when client choose team
*		-  Fixed some little bugs
*		-  Added new style of the main menu
*
*	August 4, 2012   -  V6.0
*		-  Fixed bug which the plugin changes player names sometimes
*		-  Fixed bug when the main menu sometimes appears on new round and it can't be choosen an option
*		-  Added live counter to count how many seconds does the player has to Login or Register
*		-  Added Auto Join On Connect (AJC) options.
*		-  Added plugin natives for API plugins
*		-  Added Advertisement for players which are not registered
*		-  Now the plugin doesn't use the team menu and it can be used in other mods like Zombie Plague
*		-  Some functions are rewritten for better work of the plugin
*		-  The Optiosn Menu is removed and its options are in the new style Main Menu
*
*	September 21, 2012   -  V7.0
*		-  Fixed bug with passwords conflicts
*		-  Fixed bug with the Auto Login function
*		-  Fixed bug with the Auto join function
*		-  Fixed bug with the Name Change function
*		-  Added file with listed commands which players can not use until they login
*		-  Added reconnect Support for the Login functions
*		-  Added reconnect Support for the Change Password function
*		-  Added some features for the Auto Join function
*		-  Added more stylish way for executing the configuration files
*
*	October 14, 2012   -  V7.0 FIX 1
*		-  Fxied bug when player change his name to admin name and hi can register it before hi is kicked
*
*	January 4, 2013    - V7.0 FIX 2
*		-  Fixed bug with the MYSQL part
*		-  Fixed bug with the automatic name chage
*		-  Small changes of the code
*
*	June 9, 2013    - V8.0
*		-  Fixed bug when HLTV connects and registration is mandatory and the HLTV is kicked
*		-  Fixed bug with the configuration file which doesn't set properly some CVARS
*		-  Small changes of the code for better work of the plugin
*
*	November 24, 2013    - V9.0
*		-  Added White list for names
*		-  Added global advertisements for Registering and Logging
*		-  Added option for choosing by what to save the registrations - Name, IP, SteamID
*		-  Added CVAR for managing restricted commands to ALL instead of writing them one by one
*
*
*** Contact me on:
*	E-MAIL: pvldimitrov@gmail.com
*	SKYPE: pa7ohin
*/

#include <amxmodx>
#include <celltrie>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

#include <sqlx>
#include <zp_dsohud>

#include <zp50_core>


#define VERSION "9.0"
#define TASK_MESS 1000
#define TASK_KICK 2000
#define TASK_MENU 3000
#define TASK_TIMER 4000
#define TASK_ADVERT 5000
#define TASK_AJC 6000
#define MENU_TASK_TIME 0.5
#define AJC_TASK_TIME 0.1
#define AJC_ADMIN_FLAG ADMIN_IMMUNITY
#define SALT "8c4f4370c53e0c1e1ae9acd577dddbed"
#define MAX_NAMES 64

//Start of CVAR pointers
new g_on;
new g_save;
new g_setinfo_pr;
new g_regtime;
new g_logtime;
new g_pass_length;
new g_attempts;
new g_chp_time;
new g_reg_log;
new g_chp_log;
new g_aulog_log;
new g_blind;
new g_comm;
new g_logout;
new g_count;
new g_announce;
new g_advert;
new g_advert_int;
new g_ajc_team;
new g_ajc_admin;
new g_ajc_class[2];
new g_ajc_change;
new g_member;
new g_time;
new g_time_pass;
new g_whitelist;
//End of CVAR pointers

//Start of Arrays
new configs_dir[64]
new cfg_file[256];
new reg_file[256];
new commands_file[256];
new whitelist_file[256];
new part_names[MAX_NAMES][32];
new starting_names[MAX_NAMES][32];
new ending_names[MAX_NAMES][32];
new count;
new sz_time[9];
new line = 0;
new text[512];
new params[2];
new check_name[32];
new check_client_data[35];
new check_pass[34];
new check_status[11];
new query[512];
new Handle:g_sqltuple;
new password[33][34];
new typedpass[32];
new new_pass[33][32];
new hash[34];
new pass_prefix[32];
new attempts[33];
new times[33];
new g_player_time[33];
new g_client_data[33][35];
new value;
new menu[512];
new keys;
new length;
new g_maxplayers;
new g_saytxt
new g_screenfade
new g_sync_hud
new temp1[2];
new temp2[2];
new temp_count;
new type;
new col_command;
new col_name;
new input[32];
new temp_name[32];
//End fo Arrays

//Start of Booleans
new bool:error = false
new bool:data_ready = false;
new bool:is_logged[33];
new bool:is_registered[33];
new bool:is_autolog[33];
new bool:cant_change_pass[33];
new bool:changing_name[33];
new bool:name_checked[33];
new bool:is_true = false
//End of Booleans

//Start of Trie handles
new Trie:g_commands;
new Trie:g_login_times;
new Trie:g_cant_login_time;
new Trie:g_pass_change_times;
new Trie:g_cant_change_pass_time;
new Trie:g_full_nmaes;
//End of Trie handles

new const sprite_login[] = "sprites/ntc/login.spr"

//Start of Constants
new const separator_1[] = "==============================================================================="
new const separator_2[] = "-------------------------------------------------------------------------------"
new const prefix[] = "[Thông báo]";
new const log_file[] = "register_system_log.txt";
new const JOIN_TEAM_MENU_FIRST[] = "#Team_Select";
new const JOIN_TEAM_MENU_FIRST_SPEC[] = "#Team_Select_Spect";
new const JOIN_TEAM_MENU_INGAME[] = "#IG_Team_Select";
new const JOIN_TEAM_MENU_INGAME_SPEC[] = "#IG_Team_Select_Spect"; 
new const JOIN_TEAM_VGUI_MENU = 2;

//Start of CVARs
new const g_cvars[][][] =
{
	{"rs_on", "1"},
	{"rs_save_type", "1"},
	{"rs_remember", "0"},
	{"rs_host", "127.0.0.1"},
	{"rs_user", "cs_admin"},
	{"rs_pass", "MultimodDP"},
	{"rs_db", "registersystem"},
	{"rs_password_prefix", "_rspass"},
	{"rs_register_time", "60.0"},
	{"rs_login_time", "60.0"},
	{"rs_password_len", "6"},
	{"rs_attempts", "3"},
	{"rs_chngpass_times", "3"},
	{"rs_register_log", "1"},
	{"rs_chngpass_log", "1"},
	{"rs_autologin_log", "1"},
	{"rs_blind", "1"},
	{"rs_commands", "1"},
	{"rs_logout", "0"},
	{"rs_count", "1"},
	{"rs_announce", "0"},
	{"rs_advert", "1"},
	{"rs_advert_int", "60.0"},
	{"rs_ajc_team", "2"},
	{"rs_ajc_class_t", "5"},
	{"rs_ajc_class_ct", "5"},
	{"rs_ajc_admin", "1"},
	{"rs_ajc_change", "0"},
	{"rs_cant_login_time", "300"},
	{"rs_cant_change_pass_time", "300"},
	{"rs_whitelist", "0"}
};//End of CVARs
//End of Constants

/*==============================================================================
	Start of Plugin Init
================================================================================*/
public plugin_init() 
{
	register_plugin("Register System", VERSION, "m0skVi4a ;]")
	
	set_task(0.1, "Init_MYSQL")
	
	g_on = register_cvar(g_cvars[0][0], g_cvars[0][1])
	g_save = register_cvar(g_cvars[1][0], g_cvars[1][1])
	g_member = register_cvar(g_cvars[2][0], g_cvars[2][1])
	g_setinfo_pr = register_cvar(g_cvars[7][0], g_cvars[7][1])
	g_regtime = register_cvar(g_cvars[8][0], g_cvars[8][1])
	g_logtime = register_cvar(g_cvars[9][0], g_cvars[9][1])
	g_pass_length = register_cvar(g_cvars[10][0], g_cvars[10][1])
	g_attempts = register_cvar(g_cvars[11][0], g_cvars[11][1])
	g_chp_time = register_cvar(g_cvars[12][0], g_cvars[12][1])
	g_reg_log = register_cvar(g_cvars[13][0], g_cvars[13][1])
	g_chp_log = register_cvar(g_cvars[14][0], g_cvars[14][1])
	g_aulog_log = register_cvar(g_cvars[15][0], g_cvars[15][1])
	g_blind = register_cvar(g_cvars[16][0], g_cvars[16][1])
	g_comm = register_cvar(g_cvars[17][0], g_cvars[17][1])
	g_logout = register_cvar(g_cvars[18][0], g_cvars[18][1])
	g_count = register_cvar(g_cvars[19][0], g_cvars[19][1])
	g_announce = register_cvar(g_cvars[20][0], g_cvars[20][1])
	g_advert = register_cvar(g_cvars[21][0], g_cvars[21][1])
	g_advert_int = register_cvar(g_cvars[22][0], g_cvars[22][1])
	g_ajc_team = register_cvar(g_cvars[23][0], g_cvars[23][1])
	g_ajc_class[0] = register_cvar(g_cvars[24][0], g_cvars[24][1])
	g_ajc_class[1] = register_cvar(g_cvars[25][0], g_cvars[25][1])
	g_ajc_admin = register_cvar(g_cvars[26][0], g_cvars[26][1])
	g_ajc_change = register_cvar(g_cvars[27][0], g_cvars[27][1])	
	g_time = register_cvar(g_cvars[28][0], g_cvars[28][1])
	g_time_pass = register_cvar(g_cvars[29][0], g_cvars[29][1])
	g_whitelist = register_cvar(g_cvars[30][0], g_cvars[30][1])

	get_localinfo("amxx_configsdir", configs_dir, charsmax(configs_dir))
	formatex(cfg_file, charsmax(cfg_file), "%s/registersystem.cfg", configs_dir)
	formatex(reg_file, charsmax(reg_file), "%s/regusers.ini", configs_dir)
	formatex(commands_file, charsmax(commands_file), "%s/registersystem_commands.ini", configs_dir)
	formatex(whitelist_file, charsmax(whitelist_file), "%s/registersystem_whitelist.ini", configs_dir)

	register_message(get_user_msgid("ShowMenu"), "TextMenu")
	register_message(get_user_msgid("VGUIMenu"), "VGUIMenu")
	register_menucmd(register_menuid("Register System Main Menu"), 1023, "HandlerMainMenu")
	register_menucmd(register_menuid("Password Menu"), 1023, "HandlerConfirmPasswordMenu")
	register_clcmd("jointeam", "HookTeamCommands")
	//register_clcmd("chooseteam", "HookTeamCommands")
	register_clcmd("LOGIN_PASS", "Login")
	register_clcmd("REGISTER_PASS", "Register")
	register_clcmd("CHANGE_PASS_NEW", "ChangePasswordNew")
	register_clcmd("CHANGE_PASS_OLD", "ChangePasswordOld")
	register_clcmd("AUTO_LOGIN_PASS", "AutoLoginPassword")
	RegisterHam(Ham_Spawn, "player", "HookPlayerSpawn", 1)
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	register_forward(FM_ClientUserInfoChanged, "ClientInfoChanged")

	register_dictionary("register_system.txt")
	g_maxplayers = get_maxplayers()
	g_saytxt = get_user_msgid("SayText")
	g_screenfade = get_user_msgid("ScreenFade")
	g_sync_hud = CreateHudSyncObj()
	g_commands = TrieCreate()
	g_login_times = TrieCreate()
	g_cant_login_time = TrieCreate()
	g_pass_change_times = TrieCreate()
	g_cant_change_pass_time = TrieCreate()
	g_full_nmaes = TrieCreate()
}
/*==============================================================================
	End of Plugin Init
================================================================================*/

/*==============================================================================
	Start of Plugin Natives
================================================================================*/
public plugin_natives()
{
	register_library("register_system")
	register_native("is_registered", "_is_registered")
	register_native("is_logged", "_is_logged")
	register_native("is_autologged", "_is_autologged")
	register_native("get_cant_login_time", "_get_cant_login_time")
	register_native("get_cant_change_pass_time", "_get_cant_change_pass_time")
}

public _is_registered(plugin, parameters)
{
	if(parameters != 1)
		return false

	new id = get_param(1)

	if(!id)
		return false

	if(is_registered[id])
	{
		return true
	}

	return false
}

public _is_logged(plugin, parameters)
{
	if(parameters != 1)
		return false

	new id = get_param(1)

	if(!id)
		return false

	if(is_logged[id])
	{
		return true
	}

	return false
}

public _is_autologged(plugin, parameters)
{
	if(parameters != 1)
		return -1

	new id = get_param(1)

	if(!id)
		return -1

	if(is_autolog[id])
	{
		return true
	}

	return false
}

public _get_cant_login_time(plugin, parameters)
{
	if(parameters != 1)
		return -1

	new id = get_param(1)

	if(!id)
		return -1

	new data[35];

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, data, charsmax(data))
		}
		case 1:
		{
			get_user_ip(id, data, charsmax(data))
		}
		case 2:
		{
			get_user_authid(id, data, charsmax(data))
		}		
		default:
		{
			get_user_name(id, data, charsmax(data))
		}
	}

	if(TrieGetCell(g_cant_login_time, data, value))
	{
		new cal_time = get_pcvar_num(g_time) - (time() - value)
		return cal_time
	}

	return -1
}

public _get_cant_change_pass_time(plugin, parameters)
{
	if(parameters != 1)
		return -1

	new id = get_param(1)

	if(!id)
		return -1

	new data[35];

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, data, charsmax(data))
		}
		case 1:
		{
			get_user_ip(id, data, charsmax(data))
		}
		case 2:
		{
			get_user_authid(id, data, charsmax(data))
		}		
		default:
		{
			get_user_name(id, data, charsmax(data))
		}
	}

	if(TrieGetCell(g_cant_change_pass_time, data, value))
	{
		new cal_time = get_pcvar_num(g_time_pass) - (time() - value)
		return cal_time
	}

	return -1
}
/*==============================================================================
	End of Plugin Natives
================================================================================*/

/*==============================================================================
	Start of Executing plugin's config and choose the save mode
================================================================================*/
public plugin_precache() {
	precache_model(sprite_login)
}
public plugin_cfg()
{
	if(!get_pcvar_num(g_on))
		return PLUGIN_HANDLED

	/*server_print(" ")
	server_print(separator_1)
	server_print("Title	: Register System")
	server_print("Version	: %s", VERSION)
	server_print("Author	: m0skVi4a ;]")
	server_print("Site	: https://forums.alliedmods.net/showthread.php?t=171460")
	server_print(separator_2)*/

	get_time("%H:%M:%S", sz_time, charsmax(sz_time))

	if(!file_exists(cfg_file))
	{
		server_print("[%s] [ERROR] > File registersystem.cfg not found!", sz_time)
		error = true
	}
	else
	{
		server_print("[%s] > Loading settings from registersystem.cfg", sz_time)

		line = 0, length = 0, count = 0, error = false;

		while(read_file(cfg_file, line++ , text, charsmax(text), length))
		{
			if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
				continue

			new cvar[32], param[32], bool:error_1 = true, bool:error_2 = true

			trim(text)
			parse(text, cvar, charsmax(cvar), param, charsmax(param))

			for(new i = 0; i <= charsmax(g_cvars); i++)
			{
				if(equal(cvar, g_cvars[i][0]))
				{
					error_1 = false
				}
			}

			if(param[0] && !(equali(param, " ")))
			{
				error_2 = false
			}

			if(error_1)
			{
				server_print("[%s] [ERROR] > Unknown CVAR ^"%s^"", sz_time, cvar)
				error = true
			}
			else
			{
				if(error_2)
				{
					server_print("[%s] [ERROR] > Bad value for ^"%s^"", sz_time, cvar)
					error = true
				}
				else
				{
					//server_print("[%s] [OK] > Read cvar ^"%s^" ^"%s^"", sz_time, cvar, param)
					server_cmd("%s %s", cvar, param)
					count++
				}
			}
		}

		if(!count)
		{
			server_print("[%s] [ERROR] > There were no CVARs in registersystem.cfg", sz_time)
			error = true
		}
	}

	server_print(separator_2)

	if(error)
	{
		server_print("[%s] [WARNING] > Reading some data from configuration file failed!", sz_time)
		server_print("> Please check [ERROR] messages above for solving this problem!")
	}
	else
	{
		server_print("[%s] [OK] > All settings loaded successfully!", sz_time)
	}

	server_print(separator_1)
	server_print(" ")

	
	
	return PLUGIN_CONTINUE
}
public Init_MYSQL()
{
	new host[64], user[64], pass[64], db[64]
	
	get_cvar_string("amx_sql_host", host, 63)
	get_cvar_string("amx_sql_user", user, 63)
	get_cvar_string("amx_sql_pass", pass, 63)
	formatex(db, charsmax(db), "registersystem")

	g_sqltuple = SQL_MakeDbTuple(host, user, pass, db)
	formatex(query, charsmax(query), "CREATE TABLE IF NOT EXISTS registersystem (Name VARCHAR(35), Password VARCHAR(34), Status VARCHAR(10)) ; CREATE TABLE IF NOT EXISTS rs_commands (Command VARCHAR(64)) ; CREATE TABLE IF NOT EXISTS rs_names (Names VARCHAR(64))")
	SQL_ThreadQuery(g_sqltuple, "QueryCreateTable", query)
}

public QueryCreateTable(failstate, Handle:query1, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[REGISTER SYSTEM] Could not connect to database!")
	}
	else if(failstate == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[REGISTER SYSTEM] Query failed!")
	}
	else if(errcode)
	{
		server_print("%s Error on query: %s", prefix, error)
	}
	else
	{
		server_print("[REGISTER SYSTEM] MYSQL connection succesful in %.0fs", queuetime)

		data_ready = true;

		for(new i = 1 ; i <= g_maxplayers ; i++)
		{
			if(!is_user_connecting(i) && !is_user_connected(i))
				continue
				
			CheckClient(i)
				
		}
	}	
}

/*==============================================================================
	End of Executing plugin's config and choose the save mode
================================================================================*/

/*==============================================================================
	Start of plugin's end function
================================================================================*/
public plugin_end()
{
	TrieDestroy(g_commands)
	TrieDestroy(g_login_times)
	TrieDestroy(g_cant_login_time)
	TrieDestroy(g_pass_change_times)
	TrieDestroy(g_cant_change_pass_time)
}
/*==============================================================================
	End of plugin's end function
================================================================================*/

/*==============================================================================
	Start of Client's connect and disconenct functions
================================================================================*/
public client_authorized(id)
{
	clear_user(id)
	remove_tasks(id)

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}		
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	if(TrieGetCell(g_login_times, g_client_data[id], value))
	{
		attempts[id] = value

		if(attempts[id] >= get_pcvar_num(g_attempts))
		{
			params[0] = id
			params[1] = 3
			set_task(1.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
		}
	}

	if(TrieGetCell(g_pass_change_times, g_client_data[id], value))
	{
		times[id] = value

		if(times[id] >= get_pcvar_num(g_chp_time))
		{
			cant_change_pass[id] = true
		}
	}
	
	if(data_ready)
	{
		CheckClient(id)
		
	}
}public client_disconnect(id)
{
	clear_user(id)
	remove_tasks(id)
}
/*==============================================================================
	End of Client's connect and disconenct functions
================================================================================*/

/*==============================================================================
	Start of Check Client functions
================================================================================*/
public CheckClient(id)
{
	if(!get_pcvar_num(g_on) || is_user_bot(id) || is_user_hltv(id) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	remove_tasks(id)
	is_registered[id] = false
	is_logged[id] = false
	is_autolog[id] = false
	
	get_user_name(id, g_client_data[id], charsmax(g_client_data))

	new data[1]
	data[0] = id

	formatex(query, charsmax(query), "SELECT `Password`, `Status` FROM `registersystem` WHERE Name = ^"%s^";", g_client_data[id])

	SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)
	

	return PLUGIN_CONTINUE
}

public QuerySelectData(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{ 
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		new id = data[0];
		new col_pass = SQL_FieldNameToNum(Query, "Password")
		new col_status = SQL_FieldNameToNum(Query, "Status")

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, col_pass, check_pass, charsmax(check_pass))
			SQL_ReadResult(Query, col_status, check_status, charsmax(check_status))
			is_registered[id] = true
			password[id] = check_pass

			if(equal(check_status, "LOGGED_IN"))
			{
				is_autolog[id] = true
				CheckAutoLogin(id)
			}

			if(is_user_connected(id))
			{
				user_silentkill(id)
				cs_set_user_team(id, CS_TEAM_UNASSIGNED)
				
				ShowMsg(id);
						
			}

			SQL_NextRow(Query)
		}
	}
}
public ShowRuleMenu(id) {
	
	
	ExecuteHamB(Ham_CS_RoundRespawn, id)
	set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN)
	
	zp_display_hud_sprite(id, sprite_login, 0.5)
	//Tao 1 sprite truoc mat player sau do tao menu xac nhan
	
	new menuid = menu_create("Dong y ?", "menu_ShowRuleMenu");
	
	menu_additem(menuid, "Ok");
	menu_additem(menuid, "Khong");
	
	menu_setprop(menuid, MPROP_EXIT, MEXIT_NEVER);
	
	menu_display(id, menuid)
}

public menu_ShowRuleMenu(id, menuid, item) {
	
	if( !is_user_connected(id) ) return;
	
	switch (item) {
		case 0: {
			ShowMsg(id);
			zp_remove_hud_sprite(id);
		}
		case 1: server_cmd("kick #%i ^"Vay thi khong the choi server duoc roi^"", id);
	}

	menu_destroy(menuid)
 		
}
public CheckAutoLogin(id)
{
	new client_password[32];

	get_pcvar_string(g_setinfo_pr, pass_prefix, charsmax(pass_prefix))
	get_user_info(id, pass_prefix, client_password, charsmax(client_password))
	hash = convert_password(client_password)

	if(equal(hash, password[id]))
	{
		is_logged[id] = true
	}
	else
	{
		is_autolog[id] = false
	}
}
/*==============================================================================
	End of Check Client functions
================================================================================*/

/*==============================================================================
	Start of Show Client's informative messages
================================================================================*/
public ShowMsg(id)
{
	if(!get_pcvar_num(g_on))
		return PLUGIN_HANDLED
		
	remove_tasks(id)

	set_task(5.0, "Messages", id+TASK_MESS)

	params[0] = id

	if(!is_registered[id])
	{
		if(get_pcvar_float(g_regtime) != 0)
		{
			if(!changing_name[id])
			{
				CreateMainMenuTask(id+TASK_MENU)

				if(get_pcvar_num(g_count))
				{
					g_player_time[id] = get_pcvar_num(g_regtime)
					ShowTimer(id+TASK_TIMER)
				}
				params[1] = 1
				set_task(get_pcvar_float(g_regtime) + 3, "KickPlayer", id+TASK_KICK, params, sizeof params)
				return PLUGIN_HANDLED
			}
			else
			{
				g_player_time[id] = -1
				set_task(1.0, "ShowTimer", id+TASK_TIMER)
			}
		}
	}
	else if(!is_logged[id])
	{
		if(!changing_name[id])
		{
			CreateMainMenuTask(id+TASK_MENU)
	
			if(get_pcvar_num(g_count))
			{
				g_player_time[id] = get_pcvar_num(g_logtime)
				ShowTimer(id+TASK_TIMER)
			}
			params[1] = 2
			set_task(get_pcvar_float(g_logtime) + 3, "KickPlayer", id+TASK_KICK, params, sizeof params)
			return PLUGIN_HANDLED
		}
		else
		{
			g_player_time[id] = -1
			set_task(1.0, "ShowTimer", id+TASK_TIMER)
		}
	}
	return PLUGIN_CONTINUE
}

public ShowTimer(id)
{
	id -= TASK_TIMER

	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	switch(g_player_time[id])
	{
		case 10..19:
		{
			set_hudmessage(255, 255, 0, -1.0, -1.0, 0, 0.02, 1.0,_,_, -1)
		}
		case 0..9:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0,_,_, -1)
		}
		case -1:
		{
			set_hudmessage(255, 255, 255, -1.0, -1.0, 1, 0.02, 1.0,_,_, -1)
		}
		default:
		{
			set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 0.02, 1.0,_,_, -1)
		}
	}

	if(g_player_time[id] == 0)
	{
		ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "KICK_HUD")
		return PLUGIN_CONTINUE
	}
	else if(!is_registered[id] && get_pcvar_float(g_regtime))
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "REGISTER_AFTER")
			set_task(1.0, "ShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}

		ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, g_player_time[id] > 1 ? "REGISTER_HUD" : "REGISTER_HUD_SEC", g_player_time[id])
	}
	else if(is_registered[id] && !is_logged[id])
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "LOGIN_AFTER")
			set_task(1.0, "ShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}

		ShowSyncHudMsg(id, g_sync_hud, "%L ", LANG_SERVER, g_player_time[id] > 1 ? "LOGIN_HUD" : "LOGIN_HUD_SEC", g_player_time[id])
	}
	else return PLUGIN_HANDLED

	g_player_time[id]--

	set_task(1.0, "ShowTimer", id+TASK_TIMER)

	return PLUGIN_CONTINUE
}

public Messages(id)
{
	id -= TASK_MESS

	if(!is_registered[id])
	{
		if(get_pcvar_float(g_regtime) != 0)
		{
			client_printcolor(id, "%L", LANG_SERVER, "REGISTER_CHAT", prefix, get_pcvar_num(g_regtime))
		}
		else
		{
			client_printcolor(id, "%L", LANG_SERVER, "YOUCANREG_CHAT", prefix)
		}
	}
	else if(!is_logged[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOGIN_CHAT", prefix, get_pcvar_num(g_logtime))
	}
	else if(is_autolog[id])
	{
		if(get_pcvar_num(g_announce))
		{
			get_user_name(id, temp_name, charsmax(temp_name))
			client_printcolor(0, "%L", LANG_SERVER, "LOG_LOGING_G", prefix, temp_name)
		}
		else
		{
			client_printcolor(id, "%L", LANG_SERVER, "AUTO_LOGIN_CHAT", prefix)
		}
	}
}
/*==============================================================================
	End of Show Client's informative messages
================================================================================*/

/*==============================================================================
	Start of Client's Auto Login Changer function
================================================================================*/
public AutoLoginPassword(id)
{
	if(!get_pcvar_num(g_on))
		return PLUGIN_HANDLED

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	hash = convert_password(typedpass)

	if(!equal(hash, password[id]))
	{
		TrieSetCell(g_login_times, g_client_data[id], ++attempts[id])
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix, attempts[id], get_pcvar_num(g_attempts))

		if(attempts[id] >= get_pcvar_num(g_attempts))
		{
			if(get_pcvar_num(g_count))
			{
				g_player_time[id] = 0
				ShowTimer(id+TASK_TIMER)
			}

			if(get_pcvar_num(g_time))
			{
				TrieSetCell(g_cant_login_time, g_client_data[id], time())
			}
			else
			{
				TrieSetCell(g_cant_login_time, g_client_data[id], 0)
			}
			params[0] = id
			params[1] = 3
			set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)

			if(get_pcvar_num(g_time))
			{	
				set_task(get_pcvar_float(g_time), "RemoveCantLogin", 0, g_client_data[id], sizeof g_client_data)
			}
			return PLUGIN_HANDLED
		}
		else
		{
			client_cmd(id, "messagemode AUTO_LOGIN_PASS")
		}

		return PLUGIN_HANDLED
	}
	else
	{
		get_pcvar_string(g_setinfo_pr, pass_prefix, charsmax(pass_prefix))
		client_cmd(id, "setinfo %s %s", pass_prefix, typedpass)
		AutoLogin(id, true)
		MainMenu(id)
	}
	return PLUGIN_CONTINUE
}

AutoLogin(id, bool:enabled = true)
{
	if(!is_registered[id] || !is_logged[id])
		return PLUGIN_HANDLED
		
	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}		
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	if(get_pcvar_num(g_save))
	{
		formatex(query, charsmax(query), "UPDATE registersystem SET Status = ^"%s^" WHERE Name = ^"%s^";", enabled ? "LOGGED_IN" : "LOGGED_OUT", g_client_data[id])
		SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
	}
	else
	{
		line = 0, length = 0;

		while(read_file(reg_file, line++ , text, charsmax(text), length))
		{
			parse(text, text, charsmax(text))

			if(!(equal(text, g_client_data[id])))
				continue

			formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^"", g_client_data[id], password[id], enabled ? "LOGGED_IN" : "LOGGED_OUT")
			write_file(reg_file, text, line - 1)							

			break
		}
	}

	if(enabled)
	{
		is_autolog[id] = true
		client_printcolor(id, "%L", LANG_SERVER, "AUTO_LOGIN_ON", prefix)

		if(get_pcvar_num(g_aulog_log))
		{
			log_to_file(log_file, "%L", LANG_SERVER, "LOGFILE_AUTO_ON", g_client_data[id])
		}
	}
	else
	{
		is_autolog[id] = false
		client_printcolor(id, "%L", LANG_SERVER, "AUTO_LOGIN_OFF", prefix)
		get_pcvar_string(g_setinfo_pr, pass_prefix, charsmax(pass_prefix))
		client_cmd(id, "setinfo %s ^"^"", pass_prefix)
		
		if(get_pcvar_num(g_aulog_log))
		{
			log_to_file(log_file, "%L", LANG_SERVER, "LOGFILE_AUTO_OFF", g_client_data[id])
		}
	}

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Client's Auto Login Changer function
================================================================================*/

/*==============================================================================
	Start of the Main Menu function
================================================================================*/
public CreateMainMenuTask(id)
{
	id -= TASK_MENU

	if((!is_registered[id] && get_pcvar_float(g_regtime)) || (is_registered[id] && !is_logged[id]))
	{
		MainMenu(id)
		set_task(MENU_TASK_TIME, "CreateMainMenuTask", id+TASK_MENU)
	}
}

public MainMenu(id)
{
	if(!get_pcvar_num(g_on) || !is_user_connected(id) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	length = 0

	if(is_registered[id])
	{
		if(is_logged[id])
		{
			length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_LOG", LANG_SERVER, is_autolog[id] ? "AUTO_LOG_DIS" : "AUTO_LOG_EN")
			keys = MENU_KEY_1|MENU_KEY_4|MENU_KEY_5|MENU_KEY_9|MENU_KEY_0
		}
		else
		{
			length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_REG")
			keys = MENU_KEY_1|MENU_KEY_9
		}
	}
	else
	{		
		if(get_pcvar_float(g_regtime) == 0)
		{
			length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_NOTREG")
			keys = MENU_KEY_2|MENU_KEY_9|MENU_KEY_0
		}
		else
		{
			length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_NOTREG_FORCE")
			keys = MENU_KEY_2|MENU_KEY_9
		}
	}
	show_menu(id, keys, menu, -1, "Register System Main Menu")

	return PLUGIN_CONTINUE
}

public HandlerMainMenu(id, key)
{
	switch(key)
	{
		case 0:
		{
			if(!is_logged[id])
			{
				client_cmd(id, "messagemode LOGIN_PASS")
			}
			else
			{
				AutoLogin(id, false)

				if(get_pcvar_num(g_logout))
				{
					CheckClient(id)
					CreateMainMenuTask(id+TASK_MENU)
				}
				else
				{
					if(get_pcvar_num(g_count))
					{
						g_player_time[id] = 0
						ShowTimer(id+TASK_TIMER)
					}

					params[0] = id
					params[1] = 4
					set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
				}

				client_printcolor(id, "%L", LANG_SERVER, "LOG_OUT", prefix)
				is_logged[id] = false
			}
		}
		case 1:
		{
			client_cmd(id, "messagemode REGISTER_PASS")
		}
		case 3:
		{
			if(!is_logged[id])
				return PLUGIN_HANDLED

			if(cant_change_pass[id])
			{
				client_printcolor(id, "%L", LANG_SERVER, "CHANGE_TIMES", prefix, get_pcvar_num(g_chp_time))
				MainMenu(id)
				return PLUGIN_HANDLED
			}
			else
			{
				client_cmd(id, "messagemode CHANGE_PASS_NEW")
				MainMenu(id)
			}
		}
		case 4:
		{
			if(!is_logged[id])
			{
				MainMenu(id)
				return PLUGIN_HANDLED
			}

			if(is_autolog[id])
			{
				AutoLogin(id, false)
			}
			else
			{
				client_cmd(id, "messagemode AUTO_LOGIN_PASS")
			}
			MainMenu(id)
		}
		case 8:
		{
			Info(id)
			MainMenu(id)
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}
/*==============================================================================
	End of the Main Menu function
================================================================================*/

/*==============================================================================
	Start of Login function
================================================================================*/
public Login(id)
{
	if(!get_pcvar_num(g_on) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	if(changing_name[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOGIN_AFTER")
		return PLUGIN_HANDLED
	}

	if(!is_registered[id])
	{	
		client_printcolor(id, "%L", LANG_SERVER, "LOG_NOTREG", prefix)
		return PLUGIN_HANDLED
	}

	if(is_logged[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGGED", prefix);
		return PLUGIN_HANDLED
	}
	
	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED

	hash = convert_password(typedpass)

	if(!equal(hash, password[id]))
	{	
		TrieSetCell(g_login_times, g_client_data[id], ++attempts[id])
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix, attempts[id], get_pcvar_num(g_attempts))

		if(attempts[id] >= get_pcvar_num(g_attempts))
		{
			if(get_pcvar_num(g_count))
			{
				g_player_time[id] = 0
				ShowTimer(id+TASK_TIMER)
			}

			if(get_pcvar_num(g_time))
			{
				TrieSetCell(g_cant_login_time, g_client_data[id], time())
			}
			else
			{
				TrieSetCell(g_cant_login_time, g_client_data[id], 0)
			}

			params[0] = id
			params[1] = 3
			set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)

			if(get_pcvar_num(g_time))
			{	
				set_task(get_pcvar_float(g_time), "RemoveCantLogin", 0, g_client_data[id], sizeof g_client_data)
			}
			return PLUGIN_HANDLED
		}
		else
		{
			client_cmd(id, "messagemode LOGIN_PASS")
		}
		return PLUGIN_HANDLED
	}
	else
	{
		is_logged[id] = true
		attempts[id] = 0
		remove_task(id+TASK_KICK)

		if(get_pcvar_num(g_announce))
		{
			get_user_name(id, temp_name, charsmax(temp_name))
			client_printcolor(0, "%L", LANG_SERVER, "LOG_LOGING_G", prefix, temp_name)
		}
		else
		{
			client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGING", prefix)
		}
		
		client_cmd(id, "menu");
	}
	
	
	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Login function
================================================================================*/

/*==============================================================================
	Start of Register function
================================================================================*/
public Register(id)
{
	if(!get_pcvar_num(g_on) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	if(changing_name[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "REGISTER_AFTER")
		return PLUGIN_HANDLED
	}

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	new passlength = strlen(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED
	
	if(is_registered[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_EXISTS", prefix)
		return PLUGIN_HANDLED
	}

	if(passlength < get_pcvar_num(g_pass_length))
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_LEN", prefix, get_pcvar_num(g_pass_length))
		client_cmd(id, "messagemode REGISTER_PASS")
		return PLUGIN_HANDLED
	}

	new_pass[id] = typedpass
	remove_task(id+TASK_MENU)
	ConfirmPassword(id)
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Register function
================================================================================*/

/*==============================================================================
	Start of Change Password function
================================================================================*/
public ChangePasswordNew(id)
{
	if(!get_pcvar_num(g_on) || !is_registered[id] || !is_logged[id] || changing_name[id] || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	if(cant_change_pass[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "CHANGE_TIMES", prefix, get_pcvar_num(g_chp_time))
		return PLUGIN_HANDLED
	}

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	new passlenght = strlen(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED

	if(passlenght < get_pcvar_num(g_pass_length))
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_LEN", prefix, get_pcvar_num(g_pass_length))
		client_cmd(id, "messagemode CHANGE_PASS_NEW")
		return PLUGIN_HANDLED
	}

	new_pass[id] = typedpass
	client_cmd(id, "messagemode CHANGE_PASS_OLD")
	return PLUGIN_CONTINUE
}

public ChangePasswordOld(id)
{
	if(!get_pcvar_num(g_on) || !is_registered[id] || !is_logged[id] || changing_name[id] || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	if(cant_change_pass[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "CHANGE_TIMES", prefix, get_pcvar_num(g_chp_time))
		return PLUGIN_HANDLED
	}

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	if(equal(typedpass, "") || equal(new_pass[id], ""))
		return PLUGIN_HANDLED

	hash = convert_password(typedpass)

	if(!equali(hash, password[id]))
	{
		TrieSetCell(g_login_times, g_client_data[id], ++attempts[id])
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix, attempts[id], get_pcvar_num(g_attempts))

		if(attempts[id] >= get_pcvar_num(g_attempts))
		{
			if(get_pcvar_num(g_count))
			{
				g_player_time[id] = 0
				ShowTimer(id+TASK_TIMER)
			}
			
			if(get_pcvar_num(g_time))
			{
				TrieSetCell(g_cant_login_time, g_client_data[id], time())
			}
			else
			{
				TrieSetCell(g_cant_login_time, g_client_data[id], 0)
			}
			params[0] = id
			params[1] = 3
			set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)

			if(get_pcvar_num(g_time))
			{	
				set_task(get_pcvar_float(g_time), "RemoveCantLogin", 0, g_client_data[id], sizeof g_client_data)
			}
			return PLUGIN_HANDLED
		}
		else
		{
			client_cmd(id, "messagemode CHANGE_PASS_OLD")
		}
		return PLUGIN_HANDLED
	}

	ConfirmPassword(id)
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Change Password function
================================================================================*/

/*==============================================================================
	Start of Confirming Register's or Change Password's password function
================================================================================*/
public ConfirmPassword(id)
{
	if(!get_pcvar_num(g_on) || !is_user_connected(id))
		return PLUGIN_HANDLED

	length = 0
		
	formatex(menu, charsmax(menu) - length, "%L", LANG_SERVER, "MENU_PASS", new_pass[id])
	keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_0

	show_menu(id, keys, menu, -1, "Password Menu")
	return PLUGIN_CONTINUE
}

public HandlerConfirmPasswordMenu(id, key)
{
	switch(key)
	{
		case 0:
		{
			switch(get_pcvar_num(g_member))
			{
				case 0:
				{
					get_user_name(id, g_client_data[id], charsmax(g_client_data))
				}
				case 1:
				{
					get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
				}
				case 2:
				{
					get_user_authid(id, g_client_data[id], charsmax(g_client_data))
				}		
				default:
				{
					get_user_name(id, g_client_data[id], charsmax(g_client_data))
				}
			}

			hash = convert_password(new_pass[id])

			if(is_registered[id])
			{
				if(get_pcvar_num(g_save))
				{
					formatex(query, charsmax(query), "UPDATE `registersystem` SET Password = ^"%s^", Status = ^"%s^" WHERE Name = ^"%s^";", hash, is_autolog[id] == true ? "LOGGED_IN" : "LOGGED_OUT", g_client_data[id])
					SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
				}
				else
				{
					line = 0, length = 0;

					while(read_file(reg_file, line++ , text, charsmax(text), length))
					{
						parse(text, text, charsmax(text))

						if(!(equal(text, g_client_data[id])))
							continue

						formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^"", g_client_data[id], hash, is_autolog[id] == true ? "LOGGED_IN" : "LOGGED_OUT")
						write_file(reg_file, text, line - 1)							

						break
					}
				}

				password[id] = hash
				TrieSetCell(g_pass_change_times, g_client_data[id], ++times[id])
				client_printcolor(id, "%L", LANG_SERVER, "CHANGE_NEW", prefix, new_pass[id])

				if(is_autolog[id])
				{
					get_pcvar_string(g_setinfo_pr, pass_prefix, charsmax(pass_prefix))
					client_cmd(id, "setinfo %s %s", pass_prefix, new_pass[id])
				}

				if(times[id] >= get_pcvar_num(g_chp_time))
				{
					cant_change_pass[id] = true
					
					if(get_pcvar_num(g_time_pass))
					{
						TrieSetCell(g_cant_change_pass_time, g_client_data[id], time())
					}
					else
					{
						TrieSetCell(g_cant_change_pass_time, g_client_data[id], 0)
					}

					if(get_pcvar_num(g_time_pass))
					{	
						set_task(get_pcvar_float(g_time), "RemoveCantChangePass", 0, g_client_data[id], sizeof g_client_data)
					}
				}

				if(get_pcvar_num(g_chp_log))
				{
					log_to_file(log_file, "%L", LANG_SERVER, "LOGFILE_CHNG_PASS", g_client_data[id])
				}

				MainMenu(id)
			}
			else
			{
				if(get_pcvar_num(g_save))
				{
					formatex(query, charsmax(query), "INSERT INTO `registersystem` (`Name`, `Password`, `Status`) VALUES (^"%s^", ^"%s^", ^"LOGGED_OUT^");", g_client_data[id], hash)
					SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
				}
				else
				{
					new file_pointer = fopen(reg_file, "a")
					format(text, charsmax(text), "^n^"%s^" ^"%s^" ^"^"", g_client_data[id], hash)
					fprintf(file_pointer, text)
					fclose(file_pointer)
				}

				is_registered[id] = true
				password[id] = hash
				new_pass[id] = ""
				
				if(get_pcvar_num(g_announce))
				{
					client_printcolor(0, "%L", LANG_SERVER, "REG_REGIS_G", prefix, temp_name)
				}
				else
				{
					client_printcolor(id, "%L", LANG_SERVER, "REG_REGIS", prefix, get_pcvar_num(g_logtime))
				}
				
				if(get_pcvar_num(g_reg_log))
				{
					log_to_file(log_file, "%L", LANG_SERVER, "LOGFILE_REG", g_client_data[id])
				}
				
				if(is_user_connected(id))
				{
					user_silentkill(id)
					cs_set_user_team(id, CS_TEAM_UNASSIGNED)
					ShowMsg(id)
				}
			}
		}
		case 1:
		{
			if(is_registered[id])
			{
				client_cmd(id, "messagemode CHANGE_PASS_NEW")
			}
			else
			{
				client_cmd(id, "messagemode REGISTER_PASS")
				CreateMainMenuTask(id+TASK_MENU)
			}
		}
		case 9:
		{
			MainMenu(id)
			CreateMainMenuTask(id+TASK_MENU)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public QuerySetData(FailState, Handle:Query, error[],errcode, data[], datasize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
}
/*==============================================================================
	End of Confirming Register's or Change Password's password function
================================================================================*/

/*==============================================================================
	Start of Jointeam menus and commands functions
================================================================================*/
public HookTeamCommands(id)
{
	if(!get_pcvar_num(g_on) || !is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	if(!name_checked[id])
		return PLUGIN_CONTINUE

	if((!is_registered[id] && get_pcvar_float(g_regtime)) || (is_registered[id] && !is_logged[id]))
	{
		MainMenu(id)
		return PLUGIN_HANDLED
	}	
	else if(get_pcvar_num(g_ajc_change) && cs_get_user_team(id) != CS_TEAM_UNASSIGNED && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
	{
		return PLUGIN_HANDLED
	}	
	return PLUGIN_CONTINUE
}

public TextMenu(msgid, dest, id)
{
	if(!get_pcvar_num(g_on) || !is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	if(!name_checked[id])
		return PLUGIN_CONTINUE

	static menu_text[64];

	get_msg_arg_string(4, menu_text, charsmax(menu_text))

	if(equal(menu_text, JOIN_TEAM_MENU_FIRST) || equal(menu_text, JOIN_TEAM_MENU_FIRST_SPEC))
	{
		if((!is_registered[id] && get_pcvar_float(g_regtime)) || (is_registered[id] && !is_logged[id]))
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		else if((get_pcvar_num(g_ajc_team) && cs_get_user_team(id) == CS_TEAM_UNASSIGNED) && !task_exists(TASK_AJC) && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
		{
			SetAutoJoinTask(id, msgid)
			return PLUGIN_HANDLED
		}		
	}
	else if(equal(menu_text, JOIN_TEAM_MENU_INGAME) || equal(menu_text, JOIN_TEAM_MENU_INGAME_SPEC))
	{
		if((!is_registered[id] && get_pcvar_float(g_regtime)) || (is_registered[id] && !is_logged[id]))
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(g_ajc_change) && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
		{
			return PLUGIN_HANDLED
		}	
	}
	return PLUGIN_CONTINUE
}

public VGUIMenu(msgid, dest, id)
{
	if(!get_pcvar_num(g_on) || get_msg_arg_int(1) != JOIN_TEAM_VGUI_MENU || !is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	if(!name_checked[id])
		return PLUGIN_CONTINUE

	if((!is_registered[id] && get_pcvar_float(g_regtime)) || (is_registered[id] && !is_logged[id]))
	{
		MainMenu(id)
		return PLUGIN_HANDLED
	}	
	else if(get_pcvar_num(g_ajc_team))
	{
		if((!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
		{
			if(cs_get_user_team(id) == CS_TEAM_UNASSIGNED && !task_exists(TASK_AJC))
			{
				SetAutoJoinTask(id, msgid)
				return PLUGIN_HANDLED
			}
			else if(get_pcvar_num(g_ajc_change))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	else if(get_pcvar_num(g_ajc_change) && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
	{
		return PLUGIN_HANDLED
	}	
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Jointeam menus and commands functions
================================================================================*/

/*==============================================================================
	Start of Auto Join function
================================================================================*/
public AutoJoin(parameters[])
{
	new id = parameters[0]

	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	if(cs_get_user_team(id) != CS_TEAM_UNASSIGNED)
		return PLUGIN_HANDLED

	new g_team[2], g_team_num = get_pcvar_num(g_ajc_team)

	if(g_team_num == 6)
	{
		num_to_str(g_team_num, g_team, charsmax(g_team))
		engclient_cmd(id, "jointeam", g_team)
		return PLUGIN_CONTINUE
	}

	if(g_team_num == 5)
	{
		g_team_num = random_num(1, 2)
	}
	else if(g_team_num != 1 && g_team_num != 2)
		return PLUGIN_HANDLED

	new g_class_num = get_pcvar_num(g_ajc_class[g_team_num - 1])
	num_to_str(g_team_num, g_team, charsmax(g_team))
	
	if(g_class_num == 5)
	{
		g_class_num = random_num(1, 4)
	}

	if(g_class_num == 0 || (g_class_num != 1 && g_class_num != 2 && g_class_num != 3 && g_class_num != 4))
	{
		engclient_cmd(id, "jointeam", g_team)
		return PLUGIN_CONTINUE
	}	

	new g_class[2], msg_block = get_msg_block(parameters[1])

	num_to_str(g_class_num, g_class, charsmax(g_class))

	set_msg_block(parameters[1], BLOCK_SET)
	engclient_cmd(id, "jointeam", g_team)
	engclient_cmd(id, "joinclass", g_class)
	set_msg_block(parameters[1], msg_block)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Auto Join functions
================================================================================*/

/*==============================================================================
	Start of Hook Client's commands
================================================================================*/
public client_command(id)
{
	if(!get_pcvar_num(g_on) || !data_ready)
		return PLUGIN_HANDLED

	new command[64], arg[16];

	read_argv(0, command, charsmax(command))
	read_argv(1, arg, charsmax(arg))

	if((equali(command, "say") || equali(command, "say_team")) && equali(arg, "/reg"))
	{
		if(!name_checked[id])
		{
			client_printcolor(id, "%L", LANG_SERVER, "WHITE_LIST", prefix)
		}
		else
		{
			MainMenu(id)
		}

		return PLUGIN_CONTINUE
	}

	if(get_pcvar_num(g_comm) == 1)
	{
		if(TrieKeyExists(g_commands, command))
		{
			if(!is_registered[id] && get_pcvar_float(g_regtime))
			{
				console_print(id, "%s %L", prefix, LANG_SERVER, "COMMAND_REG")
				client_printcolor(id, "!g%s!t %L", prefix, LANG_SERVER, "COMMAND_REG")
				return PLUGIN_HANDLED
			}
			else if(is_registered[id] && !is_logged[id])
			{
				console_print(id, "%s %L", prefix, LANG_SERVER, "COMMAND_LOG")
				client_printcolor(id, "!g%s!t %L", prefix, LANG_SERVER, "COMMAND_LOG")
				return PLUGIN_HANDLED
			}	
		}
	}
	else if(get_pcvar_num(g_comm) == 2)
	{
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Hook Client's commands
================================================================================*/

/*==============================================================================
	Start of Info/Help MOTD function
================================================================================*/
public Info(id)
{
	show_motd(id, "rshelpmotd.txt", "Hướng dẫn")
}
/*==============================================================================
	End of Info/Help MOTD function
================================================================================*/

/*==============================================================================
	Start of Advret function
================================================================================*/
public ShowAdvert(id)
{
	id -= TASK_ADVERT
	
	if(!get_pcvar_num(g_on) || !get_pcvar_num(g_advert) || !is_user_connected(id) || is_registered[id])
		return PLUGIN_HANDLED

	client_printcolor(id, "%L", LANG_SERVER, "YOUCANREG_CHAT", prefix)
	set_task(get_pcvar_float(g_advert_int), "ShowAdvert", id+TASK_ADVERT)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Advret function
================================================================================*/

/*==============================================================================
	Start of Player Spawn function
================================================================================*/
public HookPlayerSpawn(id)
{
	if(get_pcvar_num(g_on) && is_user_connected(id))
	{
		show_menu(id, 0, "^n", 1)
	}
}
/*==============================================================================
	End of Player Spawn function
================================================================================*/

/*==============================================================================
	Start of Player PreThink function for the blind function
================================================================================*/
public PlayerPreThink(id)
{
	if(!get_pcvar_num(g_on) || !get_pcvar_num(g_blind) || !is_user_connected(id) || changing_name[id])
		return PLUGIN_HANDLED

	if((!is_registered[id] && get_pcvar_float(g_regtime)) || (is_registered[id] && !is_logged[id]))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
		write_short(1<<12)
		write_short(1<<12)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Player PreThink function for the blind function
================================================================================*/

/*==============================================================================
	Start of Client Info Change function for hooking name change of clients
================================================================================*/
public ClientInfoChanged(id) 
{
	if(!get_pcvar_num(g_on) || !is_user_connected(id))
		return FMRES_IGNORED
	
	new oldname[32], newname[32];
		
	get_user_name(id, oldname, charsmax(oldname))
	get_user_info(id, "name", newname, charsmax(newname))

	if(!equal(oldname, newname))
	{
		replace_all(newname, charsmax(newname), "%", " ")

		changing_name[id] = false

		if(!is_user_alive(id))
		{
			changing_name[id] = true
		}
		else
		{
			if(is_logged[id])
			{
				set_user_info(id, "name", oldname)
				client_printcolor(id, "%L", LANG_SERVER, "NAME_CHANGE_LOG", prefix)
				return FMRES_HANDLED
			}

			if(get_pcvar_num(g_whitelist))
			{
				set_task(1.0, "CheckName", id)
			}
			else
			{
				set_task(1.0, "CheckClient", id)
			}
		}
	}
	return FMRES_IGNORED
}
/*==============================================================================
	End of Client Info Change function for hooking name change of clients
================================================================================*/

/*==============================================================================
	Start of Kick Player function
================================================================================*/
public KickPlayer(parameters[])
{
	new id = parameters[0]
	new reason = parameters[1]

	if(!is_user_connecting(id) && !is_user_connected(id))
		return PLUGIN_HANDLED

	new userid = get_user_userid(id)

	switch(reason)
	{
		case 1:
		{
			if(is_registered[id])
				return PLUGIN_HANDLED

			console_print(id, "%L", LANG_SERVER, "KICK_INFO")
			server_cmd("kick #%i ^"%L^"", userid, LANG_PLAYER, "KICK_REG")
		}
		case 2:
		{
			if(is_logged[id])
				return PLUGIN_HANDLED

			console_print(id, "%L", LANG_SERVER, "KICK_INFO")
			server_cmd("kick #%i ^"%L^"", userid, LANG_PLAYER, "KICK_LOGIN")
		}
		case 3:
		{
			if(TrieGetCell(g_cant_login_time, g_client_data[id], value))
			{
				console_print(id, "%L", LANG_SERVER, "KICK_INFO")

				if(!value)
				{
					server_cmd("kick #%i ^"%s^"", userid, LANG_PLAYER, "KICK_ATMP_MAP", get_pcvar_num(g_attempts))
				}
				else
				{
					new cal_time = get_pcvar_num(g_time) - (time() - value)
					server_cmd("kick #%i ^"%s^"", userid, LANG_PLAYER, "KICK_ATMP_TIME", get_pcvar_num(g_attempts), cal_time)
				}
			}
		}
		case 4:
		{
			console_print(id, "%L", LANG_SERVER, "KICK_INFO")
			server_cmd("kick #%i ^"%L^"", userid, LANG_SERVER, "KICK_LOGOUT")
		}
	}
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Kick Player function
================================================================================*/

/*==============================================================================
	Start of Removing Punishes function
================================================================================*/
public RemoveCantLogin(data[])
{
	TrieDeleteKey(g_login_times, data)
	TrieDeleteKey(g_cant_login_time, data)
}

public RemoveCantChangePass(data[])
{
	TrieDeleteKey(g_cant_change_pass_time, data)
	TrieDeleteKey(g_pass_change_times, data)

	new target;
	
	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			target = find_player("a", data)
		}
		case 1:
		{
			target = find_player("d", data)
		}
		case 2:
		{
			target = find_player("c", data)
		}
		default:
		{
			target = find_player("a", data)
		}
	}

	if(!target)
		return PLUGIN_HANDLED

	cant_change_pass[target] = false
	client_printcolor(target, "%L", LANG_SERVER, "CHANGE_CAN", prefix)
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Removing Punish function
================================================================================*/

/*==============================================================================
	Start of Plugin's stocks
================================================================================*/
stock client_printcolor(const id, const message[], any:...)
{
	new g_message[191];
	new i = 1, players[32];

	vformat(g_message, charsmax(g_message), message, 3)

	replace_all(g_message, charsmax(g_message), "!g", "^4")
	replace_all(g_message, charsmax(g_message), "!n", "^1")
	replace_all(g_message, charsmax(g_message), "!t", "^3")

	if(id)
	{
		players[0] = id
	}
	else
	{
		get_players(players, i, "ch")
	}

	for(new j = 0; j < i; j++)
	{
		if(is_user_connected(players[j]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_saytxt,_, players[j])
			write_byte(players[j])
			write_string(g_message)
			message_end()
		}
	}
}

stock convert_password(const password[])
{
	new pass_salt[64], converted_password[34];

	formatex(pass_salt, charsmax(pass_salt), "%s%s", password, SALT)
	md5(pass_salt, converted_password)
	
	return converted_password
}

stock SetAutoJoinTask(id, menu_msgid)
{
	params[0] = id
	params[1] = menu_msgid

	set_task(AJC_TASK_TIME, "AutoJoin", id+TASK_AJC, params, sizeof params)
}

stock clear_user(const id)
{
	is_logged[id] = false
	is_registered[id] = false
	is_autolog[id] = false
	cant_change_pass[id] = false
	changing_name[id] = false
	name_checked[id] = true
	attempts[id] = 0
	times[id] = 0
}

stock remove_tasks(const id)
{
	remove_task(id+TASK_MESS)
	remove_task(id+TASK_KICK)
	remove_task(id+TASK_MENU)
	remove_task(id+TASK_TIMER)
	remove_task(id+TASK_ADVERT)
	remove_task(id+TASK_AJC)
	remove_task(id)
}
/*==============================================================================
	End of Plugin's stocks
================================================================================*/
