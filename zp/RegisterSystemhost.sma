#include <amxmodx>
#include <celltrie>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

#include <sqlx>
#include <zp_dsohud>

#define VERSION "9.0"
#define TASK_KICK 2000
#define AUTOJOIN 1000
#define TASK_MENU 3000
#define TASK_RULE 5000
#define TASK_TIMER 4000
#define SALT "8c4f4370c53e0c1e1ae9acd577dddbed"
#define MAX_NAMES 64
#define m_iMenuCode 205

#define Get_BitVar(%1,%2) !(!(%1 & (1 << (%2 & 31))))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

enum {
	NOTREGISTERED = 0,
	NOTLOGGED,
	OVERATMP,
	LOGOUT
}
enum {
	CT,
	T
}
//Start of Arrays
new params[2];
new check_pass[34];
new check_status[11];
new query[512];
new Handle:g_sqltuple;
new password[33][34];
new typedpass[32];
new new_pass[33][32];
new hash[34];
new attempts[33];
new times[33];
new g_player_time[33];
new g_client_data[33][35];
new value;
new g_saytxt
new g_sync_hud
//End fo Arrays


//Start of Booleans
new is_ruled = 0;
new is_logged = 0;
new is_registered = 0
new cant_change_pass = 0;
//End of Booleans

//Start of Trie handles
//new Trie:g_commands;
new Trie:g_login_times;
new Trie:g_cant_login_time;
new Trie:g_pass_change_times;
new Trie:g_cant_change_pass_time;
//End of Trie handles

stock const FIRST_JOIN_MSG[] =		"#Team_Select";
stock const FIRST_JOIN_MSG_SPEC[] =	"#Team_Select_Spect";
stock const INGAME_JOIN_MSG[] =		"#IG_Team_Select";
stock const INGAME_JOIN_MSG_SPEC[] =	"#IG_Team_Select_Spect";
const iMaxLen = sizeof(INGAME_JOIN_MSG_SPEC);

// New VGUI Menus
stock const VGUI_JOIN_TEAM_NUM =		2;

new const sprite_login[] = "sprites/ntc/login.spr"

new const g_szBotName[][ ] = { 
	"Group: fb.com/groups/csntcmod",
	"[NTC] Multimod DP"
};

new g_iFakeplayer[2];

//Start of Constants
new const prefix[] = "[Thông báo]";
new const table[] = "listuser"
//End of Constants

/*==============================================================================
Start of Plugin Init
================================================================================*/
public plugin_init() {
	register_plugin("Register System", VERSION, "m0skVi4a ;]")
	
	set_task(0.1, "Init_MYSQL")
	
	register_clcmd("jointeam", "HookTeamCommands")
	register_clcmd("chooseteam", "HookTeamCommands")
	
	register_message(get_user_msgid("ShowMenu"), "MessageShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "MessageVGUIMenu");
	
	register_clcmd("LOGIN_PASS", "Login")
	register_clcmd("REGISTER_PASS", "Register")
	register_clcmd("CHANGE_PASS_NEW", "ChangePasswordNew")
	register_clcmd("CHANGE_PASS_OLD", "ChangePasswordOld")
	
	register_forward(FM_ClientUserInfoChanged, "ClientInfoChanged")
	
	
	set_task( 5.0, "UpdateBot" );
	
	register_message( get_user_msgid( "DeathMsg" ), "MsgDeathMsg" );
	
	register_dictionary("register_system.txt")
	
	g_saytxt = get_user_msgid("SayText")
	g_sync_hud = CreateHudSyncObj()
	
	g_login_times = TrieCreate()
	g_cant_login_time = TrieCreate()
	g_pass_change_times = TrieCreate()
	g_cant_change_pass_time = TrieCreate()
}
/*==============================================================================
End of Plugin Init
================================================================================*/


public UpdateBot( ) {
	
	new id = engfunc( EngFunc_CreateFakeClient, g_szBotName[CT] );
	if( pev_valid( id ) ) {
		engfunc( EngFunc_FreeEntPrivateData, id );
		dllfunc( MetaFunc_CallGameEntity, "player", id );
		set_user_info( id, "rate", "3500" );
		set_user_info( id, "cl_updaterate", "25" );
		set_user_info( id, "cl_lw", "1" );
		set_user_info( id, "cl_lc", "1" );
		set_user_info( id, "cl_dlmax", "128" );
		set_user_info( id, "cl_righthand", "1" );
		set_user_info( id, "_vgui_menus", "0" );
		set_user_info( id, "_ah", "0" );
		set_user_info( id, "dm", "0" );
		set_user_info( id, "tracker", "0" );
		set_user_info( id, "friends", "0" );
		set_user_info( id, "*bot", "1" );
		set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FAKECLIENT );
		set_pev( id, pev_colormap, id );
		
		new szMsg[ 128 ];
		dllfunc( DLLFunc_ClientConnect, id, g_szBotName, "127.0.0.1", szMsg );
		dllfunc( DLLFunc_ClientPutInServer, id );
		
		cs_set_user_team( id, CS_TEAM_T );
		ExecuteHamB( Ham_CS_RoundRespawn, id );
		
		set_pev( id, pev_effects, pev( id, pev_effects ) | EF_NODRAW );
		set_pev( id, pev_solid, SOLID_NOT );
		dllfunc( DLLFunc_Think, id );
		
		g_iFakeplayer[CT] = id;
	}
	
	id = engfunc( EngFunc_CreateFakeClient, g_szBotName[T] );
	if( pev_valid( id ) ) {
		engfunc( EngFunc_FreeEntPrivateData, id );
		dllfunc( MetaFunc_CallGameEntity, "player", id );
		set_user_info( id, "rate", "3500" );
		set_user_info( id, "cl_updaterate", "25" );
		set_user_info( id, "cl_lw", "1" );
		set_user_info( id, "cl_lc", "1" );
		set_user_info( id, "cl_dlmax", "128" );
		set_user_info( id, "cl_righthand", "1" );
		set_user_info( id, "_vgui_menus", "0" );
		set_user_info( id, "_ah", "0" );
		set_user_info( id, "dm", "0" );
		set_user_info( id, "tracker", "0" );
		set_user_info( id, "friends", "0" );
		set_user_info( id, "*bot", "1" );
		set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FAKECLIENT );
		set_pev( id, pev_colormap, id );
		
		new szMsg[ 128 ];
		dllfunc( DLLFunc_ClientConnect, id, g_szBotName, "127.0.0.1", szMsg );
		dllfunc( DLLFunc_ClientPutInServer, id );
		
		cs_set_user_team( id, CS_TEAM_CT );
		ExecuteHamB( Ham_CS_RoundRespawn, id );
		
		set_pev( id, pev_effects, pev( id, pev_effects ) | EF_NODRAW );
		set_pev( id, pev_solid, SOLID_NOT );
		dllfunc( DLLFunc_Think, id );
		
		g_iFakeplayer[T] = id;
		
	}
}
public MsgDeathMsg( const iMsgId, const iMsgDest, const id ) {
	if( get_msg_arg_int( 2 ) == g_iFakeplayer[CT] || get_msg_arg_int( 2 ) == g_iFakeplayer[T] )
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}


/*==============================================================================
Start of Plugin Natives
================================================================================*/
public plugin_natives() {
	register_library("register_system")
	register_native("is_registered", "_is_registered")
	register_native("is_logged", "_is_logged")
	register_native("get_cant_login_time", "_get_cant_login_time")
	register_native("get_cant_change_pass_time", "_get_cant_change_pass_time")
}

public _is_registered(plugin, parameters) {
	if(parameters != 1)
		return false
	
	new id = get_param(1)
	
	if(!id)
		return false
	
	if( Get_BitVar(is_registered,id) )
	{
		return true
	}
	
	return false
}

public _is_logged(plugin, parameters) {
	if(parameters != 1)
		return false
	
	new id = get_param(1)
	
	if(!id)
		return false
	
	if(Get_BitVar(is_logged,id))
	{
		return true
	}
	
	return false
}


public _get_cant_login_time(plugin, parameters) {
	if(parameters != 1)
		return -1
	
	new id = get_param(1)
	
	if(!id)
		return -1
	
	new data[35];
	
	
	get_user_name(id, data, charsmax(data))
	
	
	if(TrieGetCell(g_cant_login_time, data, value))
	{
		new cal_time = 240 - (time() - value)
		return cal_time
	}
	
	return -1
}

public _get_cant_change_pass_time(plugin, parameters) {
	if(parameters != 1)
		return -1
	
	new id = get_param(1)
	
	if(!id)
		return -1
	
	new data[35];
	get_user_name(id, data, charsmax(data))
	
	if(TrieGetCell(g_cant_change_pass_time, data, value))
	{
		new cal_time = 240 - (time() - value)
		return cal_time
	}
	
	return -1
}
/*==============================================================================
End of Plugin Natives
================================================================================*/

/*==============================================================================
Start of Plugin Precache
================================================================================*/
public plugin_precache() {
	precache_model(sprite_login)
}
/*==============================================================================
End of Plugin Precache
================================================================================*/
/*==============================================================================
Start of Hooking Team Commands
================================================================================*/
public MessageShowMenu(iMsgid, iDest, id)
{
	static sMenuCode[iMaxLen];
	get_msg_arg_string(4, sMenuCode, sizeof(sMenuCode) - 1);
	if(equal(sMenuCode, FIRST_JOIN_MSG) || equal(sMenuCode, FIRST_JOIN_MSG_SPEC))
	{
		if( id == g_iFakeplayer[CT] || id == g_iFakeplayer[T] )
		{
			return PLUGIN_CONTINUE;
		}
		set_autojoin_task(id, iMsgid);
		
		if( !Get_BitVar(is_ruled, id) ) {
			set_task(1.0, "Ruling", id + TASK_RULE);
			
		}
		return PLUGIN_HANDLED;
		
	}
	return PLUGIN_HANDLED;
}

public MessageVGUIMenu(iMsgid, iDest, id)
{
	if(get_msg_arg_int(1) != VGUI_JOIN_TEAM_NUM)
	{
		return PLUGIN_CONTINUE;
	}
	if( id == g_iFakeplayer[CT] || id == g_iFakeplayer[T] )
	{
		return PLUGIN_CONTINUE;
	}
	set_autojoin_task(id, iMsgid);
	
	if( !Get_BitVar(is_ruled, id) ) {
		set_task(1.0, "Ruling", id + TASK_RULE);
	}
	
	return PLUGIN_HANDLED;
}
stock set_autojoin_task(id, iMsgid)
{
	new iParam[2];
	iParam[0] = iMsgid;
	set_task(0.1, "task_Autojoin", id + AUTOJOIN, iParam, sizeof(iParam));
}
public task_Autojoin(iParam[], id)
{
	id -= AUTOJOIN
	
	handle_join(id, iParam[0]);
	
}
stock handle_join(id, iMsgid)
{
	new iMsgBlock = get_msg_block(iMsgid);
	set_msg_block(iMsgid, BLOCK_SET);
	
	engclient_cmd(id, "jointeam", "2");
	
	engclient_cmd(id, "joinclass", "3");
	
	set_msg_block(iMsgid, iMsgBlock);
}

public HookTeamCommands(id) {
	if( !is_user_connected(id))
		return PLUGIN_CONTINUE
	
	if(!Get_BitVar(is_ruled, id) ) {
		
		ShowRuleMenu(id)
		return PLUGIN_HANDLED
	}
	
	if(!Get_BitVar(is_registered,id) || (Get_BitVar(is_registered,id) && !Get_BitVar(is_logged,id)))
	{
		MainMenu(id)
		return PLUGIN_HANDLED
	}	
	
	return PLUGIN_CONTINUE
}

public Ruling(id) {
	id -= TASK_RULE;
	
	PlayerLogin(id);
	ShowRuleMenu(id)
}

/*==============================================================================
End of Hooking Team Commands
================================================================================*/
/*==============================================================================
Start of Executing plugin's config and choose the save mode
================================================================================*/
public Init_MYSQL() {
	g_sqltuple = SQL_MakeStdTuple()
	formatex(query, charsmax(query), "CREATE TABLE IF NOT EXISTS %s (Name VARCHAR(35), Password VARCHAR(34), Status VARCHAR(34)) ;", table);
	SQL_ThreadQuery(g_sqltuple, "QueryCreateTable", query)
}


public QueryCreateTable(failstate, Handle:query1, error[], errcode, data[], datasize, Float:queuetime) {
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
		server_print("[REGISTER SYSTEM] Error on query: %s",  error)
	}
	else
	{
		server_print("[REGISTER SYSTEM] MYSQL connection succesful in %.0fs", queuetime)
	}	
}

/*==============================================================================
End of Executing plugin's config and choose the save mode
================================================================================*/

/*==============================================================================
Start of plugin's end function
================================================================================*/
public plugin_end(){
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
public client_authorized(id) {
	clear_user(id)
	remove_tasks(id)
	
	get_user_name(id, g_client_data[id], charsmax(g_client_data))
	
	if(TrieGetCell(g_login_times, g_client_data[id], value))
	{
		attempts[id] = value
		
		if(attempts[id] >= 3)
		{
			params[0] = id
			params[1] = 3
			set_task(1.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
		}
	}
	
	if(TrieGetCell(g_pass_change_times, g_client_data[id], value))
	{
		times[id] = value
		
		if(times[id] >= 60)
		{
			Set_BitVar(cant_change_pass,id)
		}
	}
	
	CheckClient(id)
	
	
}
public client_disconnect(id) {
	clear_user(id)
	remove_tasks(id)
}
/*==============================================================================
End of Client's connect and disconenct functions
================================================================================*/

/*==============================================================================
Start of Check Client functions
================================================================================*/
public CheckClient(id) {
	if( is_user_bot(id) || is_user_hltv(id) )
		return PLUGIN_HANDLED
	
	remove_tasks(id)
	UnSet_BitVar(is_registered,id)
	UnSet_BitVar(is_logged,id)
	
	get_user_name(id, g_client_data[id], charsmax(g_client_data))
	
	
	new data[1]
	data[0] = id
	
	formatex(query, charsmax(query), "SELECT `Password`, `Status` FROM `%s` WHERE Name = ^"%s^";", table, g_client_data[id])
	
	SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)
	
	
	return PLUGIN_CONTINUE
}

public QuerySelectData(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime) { 
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
			Set_BitVar(is_registered,id)
			password[id] = check_pass
			
			SQL_NextRow(Query)
		}
		
	}
}
public ShowRuleMenu(id) {
	
	new menuid = menu_create("[NTC] Da doc luat o group server ?", "menu_ShowRuleMenu");
	
	menu_additem(menuid, "Ok");
	menu_additem(menuid, "Khong");
	
	menu_setprop(menuid, MPROP_EXIT, MEXIT_NEVER);
	
	menu_display(id, menuid)
}

public menu_ShowRuleMenu(id, menuid, item) {
	
	if( !is_user_connected(id) ) return;
	
	switch (item) 
	{
		case 0: {
			
			ShowMsg(id);
			Set_BitVar(is_ruled,id);
		}
		case 1:{
			server_cmd("kick #%i ^"Vay thi khong the choi server duoc roi^"", id);
		}	
	}
	
	menu_destroy(menuid)
	
}
/*==============================================================================
End of Check Client functions
================================================================================*/


/*==============================================================================
Start of Show Client's informative messages
================================================================================*/
public ShowMsg(id) {
	
	remove_tasks(id)
	
	params[0] = id
	
	if(!Get_BitVar(is_registered,id))
	{
		
		MainMenu(id)
		
		g_player_time[id] = 60
		ShowTimer(id+TASK_TIMER)
		
		params[1] = 1
		set_task(60.0 + 3.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
		return PLUGIN_HANDLED
	}
	
	else if(!Get_BitVar(is_logged,id))
	{
		
		MainMenu(id)		
		g_player_time[id] = 60
		ShowTimer(id+TASK_TIMER)
		
		params[1] = 2
		set_task(60.0 + 3.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
		return PLUGIN_HANDLED
		
	}
	return PLUGIN_CONTINUE
}

public ShowTimer(id) {
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
		default: {
			set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 0.02, 1.0,_,_, -1)
		}
	}
	
	if(g_player_time[id] == 0)
	{
		ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "KICK_HUD")
		return PLUGIN_CONTINUE
	}
	else if(!Get_BitVar(is_registered,id))
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "REGISTER_AFTER")
			set_task(1.0, "ShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}
		
		ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, g_player_time[id] > 1 ? "REGISTER_HUD" : "REGISTER_HUD_SEC", g_player_time[id])
	}
	else if(Get_BitVar(is_registered,id) && !Get_BitVar(is_logged,id))
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

/*==============================================================================
End of Show Client's informative messages
================================================================================*/

/*==============================================================================
Start of the Main Menu function
================================================================================*/

public MainMenu(id) {
	if(!is_user_connected(id) )
		return PLUGIN_HANDLED
	
	new menuid = menu_create("[NTC] Multimod DP", "HandlerMainMenu") 
	
	if(Get_BitVar(is_registered,id))
	{
		if(!Get_BitVar(is_logged,id))
		{
			menu_additem(menuid, "Dang nhap");
		}
	}
	else
	{		
		menu_additem(menuid, "Dang ki");
	}
	
	menu_additem(menuid, "Thoat server");
	
	menu_setprop(menuid, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menuid);
	
	
	return PLUGIN_CONTINUE
}

public HandlerMainMenu(id, menuid, item) {
	switch(item)
	{
		case 0:
		{
			if(Get_BitVar(is_registered,id))
			{
				if( !Get_BitVar(is_logged,id) )
				{
					client_cmd(id, "messagemode LOGIN_PASS")
				}
			}
			else
			{	
				client_cmd(id, "messagemode REGISTER_PASS")
			}
		}
		case 1:
		{
			params[0] = id
			params[1] = 5
			set_task(1.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
		}
	}
	menu_destroy(menuid);
	
	return PLUGIN_HANDLED
}
/*==============================================================================
End of the Main Menu function
================================================================================*/

/*==============================================================================
Start of Login function
================================================================================*/
public Login(id) {
	
	if(!Get_BitVar(is_registered,id))
	{	
		client_printcolor(id, "%L", LANG_SERVER, "LOG_NOTREG", prefix)
		return PLUGIN_HANDLED
	}
	
	if(Get_BitVar(is_logged, id))
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
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix, attempts[id], 3 )
		
		if(attempts[id] >= 3)
		{
			
			TrieSetCell(g_cant_login_time, g_client_data[id], time())
			
			params[0] = id
			params[1] = 3
			set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
			
			
			set_task(24.0, "RemoveCantLogin", 0, g_client_data[id], sizeof g_client_data)
			
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
		Set_BitVar(is_logged,id)
		attempts[id] = 0
		remove_task(id+TASK_KICK)
		
		zp_remove_hud_sprite(id);
	}
	
	
	return PLUGIN_CONTINUE
}

/*==============================================================================
End of Login function
================================================================================*/

/*==============================================================================
Start of Register function
================================================================================*/
public Register(id) {
	
	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)
	
	new passlength = strlen(typedpass)
	
	if(equal(typedpass, ""))
		return PLUGIN_HANDLED
	
	if(Get_BitVar(is_registered,id))
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_EXISTS", prefix)
		return PLUGIN_HANDLED
	}
	
	if(passlength < 6)
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_LEN", prefix, 6)
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
public ChangePasswordNew(id) {
	if(!Get_BitVar(is_registered,id) || !Get_BitVar(is_logged,id))
		return PLUGIN_HANDLED
	
	if(Get_BitVar(cant_change_pass,id))
	{
		client_printcolor(id, "%L", LANG_SERVER, "CHANGE_TIMES", prefix, 240)
		return PLUGIN_HANDLED
	}
	
	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)
	
	new passlenght = strlen(typedpass)
	
	if(equal(typedpass, ""))
		return PLUGIN_HANDLED
	
	if(passlenght < 6)
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_LEN", prefix, 6)
		client_cmd(id, "messagemode CHANGE_PASS_NEW")
		return PLUGIN_HANDLED
	}
	
	new_pass[id] = typedpass
	client_cmd(id, "messagemode CHANGE_PASS_OLD")
	return PLUGIN_CONTINUE
}

public ChangePasswordOld(id) {
	if(!Get_BitVar(is_registered , id) || !Get_BitVar(is_logged,id))
		return PLUGIN_HANDLED
	
	if(Get_BitVar(cant_change_pass,id))
	{
		client_printcolor(id, "%L", LANG_SERVER, "CHANGE_TIMES", prefix, 240)
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
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix, attempts[id], 3)
		
		if(attempts[id] >= 3)
		{
			g_player_time[id] = 0
			ShowTimer(id+TASK_TIMER)
			
			TrieSetCell(g_cant_login_time, g_client_data[id], time())
			
			params[0] = id
			params[1] = 3
			set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
			
			
			set_task(240.0, "RemoveCantLogin", 0, g_client_data[id], sizeof g_client_data)
			
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
public ConfirmPassword(id) {
	if( !is_user_connected(id))
		return PLUGIN_HANDLED
	
	new menuid = menu_create("[NTC] Multimod DP", "HandlerConfirmPasswordMenu") 
	
	menu_additem(menuid, "Xac nhan mat khau");
	menu_additem(menuid, "Doi lai mat khau khac");
	
	menu_setprop(menuid, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menuid);
	return PLUGIN_CONTINUE
}

public HandlerConfirmPasswordMenu(id, menuid, item) {
	switch(item)
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
			
			hash = convert_password(new_pass[id])
			
			if(Get_BitVar(is_registered,id))
			{
				
				formatex(query, charsmax(query), "UPDATE `%s` SET Password = ^"%s^", Status = ^"%s^" WHERE Name = ^"%s^";", table, hash, "LOGIN", g_client_data[id])
				SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
				
				password[id] = hash
				TrieSetCell(g_pass_change_times, g_client_data[id], ++times[id])
				client_printcolor(id, "!g[NTC]!y Da doi pass thanh cong")
				
				
				
				if(times[id] >= 240)
				{
					Set_BitVar(cant_change_pass,id)
					
					TrieSetCell(g_cant_change_pass_time, g_client_data[id], time())
					
					set_task(240.0, "RemoveCantChangePass", 0, g_client_data[id], sizeof g_client_data)
					
				}
			}
			else
			{
				formatex(query, charsmax(query), "INSERT INTO `%s` (`Name`, `Password`, `Status`) VALUES (^"%s^", ^"%s^", ^"REGISTERED^");",table,  g_client_data[id], hash)
				SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
				
				
				Set_BitVar(is_registered,id);
				password[id] = hash
				new_pass[id] = ""
				
				
				ShowMsg(id)
				
				
			}
		}
		case 1:
		{
			if(Get_BitVar(is_registered,id))
			{
				client_cmd(id, "messagemode CHANGE_PASS_NEW")
			}
			else
			{
				client_cmd(id, "messagemode REGISTER_PASS")
				MainMenu(id)
			}
		}
	}
	return PLUGIN_HANDLED
}

public QuerySetData(FailState, Handle:Query, error[],errcode, data[], datasize) {
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
Start of Client Info Change function for hooking name change of clients
================================================================================*/
public ClientInfoChanged(id) {
	static const name[] = "name" 
	static szOldName[32], szNewName[32] 
	pev(id, pev_netname, szOldName, charsmax(szOldName)) 
	if( szOldName[0] ) 
	{ 
		get_user_info(id, name, szNewName, charsmax(szNewName)) 
		if( !equal(szOldName, szNewName) ) 
		{ 
			set_user_info(id, name, szOldName) 
			return FMRES_HANDLED 
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
public KickPlayer(parameters[]) {
	new id = parameters[0]
	new reason = parameters[1]
	
	if(!is_user_connecting(id) && !is_user_connected(id))
		return PLUGIN_HANDLED
	
	new userid = get_user_userid(id)
	
	switch(reason)
	{
		case NOTREGISTERED:
		{
			if(Get_BitVar(is_registered,id))
				return PLUGIN_HANDLED
			
			server_cmd("kick #%i ^"Phai dang ki de co the tham gia server^"", userid)
		}
		case NOTLOGGED:
		{
			if(Get_BitVar(is_logged,id))
				return PLUGIN_HANDLED
			
			server_cmd("kick #%i ^"Phai dang nhap de co the tham gia serer^"", userid)
		}
		case OVERATMP:
		{
			if(TrieGetCell(g_cant_login_time, g_client_data[id], value))
			{
				
				if(!value)
				{
					server_cmd("kick #%i ^"%s^"", userid, LANG_PLAYER, "KICK_ATMP_MAP", 3)
				}
				else
				{
					new cal_time = 240 - (time() - value)
					server_cmd("kick #%i ^"%s^"", userid, LANG_PLAYER, "KICK_ATMP_TIME", 3, cal_time)
				}
			}
		}
		case LOGOUT:
		{
			server_cmd("kick #%i ^"Thoat server thanh cong^"", userid)
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
public RemoveCantLogin(data[]) {
	TrieDeleteKey(g_login_times, data)
	TrieDeleteKey(g_cant_login_time, data)
}

public RemoveCantChangePass(data[]) {
	TrieDeleteKey(g_cant_change_pass_time, data)
	TrieDeleteKey(g_pass_change_times, data)
	
	new target;
	
	target = find_player("a", data)
	
	
	if(!target)
		return PLUGIN_HANDLED
	
	UnSet_BitVar(cant_change_pass,target)
	client_printcolor(target, "!g[NTC]!y Da co the doi pass");
	return PLUGIN_CONTINUE
}
/*==============================================================================
End of Removing Punish function
================================================================================*/

/*==============================================================================
Start of Plugin's stocks
================================================================================*/
stock PlayerLogin(const id) {
	
	user_silentkill(id)
	cs_set_user_team(id, CS_TEAM_CT)
	ExecuteHamB(Ham_CS_RoundRespawn, id)
	set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN)
	
	zp_display_hud_sprite(id, sprite_login, 0.1)
	
}
stock client_printcolor(const id, const message[], any:...) {
	new g_message[191];
	new i = 1, players[32];
	
	vformat(g_message, charsmax(g_message), message, 3)
	
	replace_all(g_message, charsmax(g_message), "!g", "^4")
	replace_all(g_message, charsmax(g_message), "!y", "^1")
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

stock convert_password(const password[]) {
	new pass_salt[64], converted_password[34];
	
	formatex(pass_salt, charsmax(pass_salt), "%s%s", password, SALT)
	md5(pass_salt, converted_password)
	
	return converted_password
}

stock clear_user(const id) {
	UnSet_BitVar(is_logged,id)
	UnSet_BitVar(is_registered,id)
	UnSet_BitVar(is_ruled,id)
	UnSet_BitVar(cant_change_pass,id)
	attempts[id] = 0
	times[id] = 0
	zp_remove_hud_sprite(id);
}

stock remove_tasks(const id) {
	remove_task(id+TASK_KICK)
	remove_task(id+TASK_MENU)
	remove_task(id+TASK_TIMER)
	remove_task(id)
}
/*==============================================================================
End of Plugin's stocks
================================================================================*/
