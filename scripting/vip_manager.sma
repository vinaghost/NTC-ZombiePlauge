#include <amxmodx>
#include <amxmisc>
#include <regex>
#include <sqlx>

#define MAX_PLAYERS 32

//#define BACKWARDS_COMPAT

enum _:Auths {
	Auth_Name,
	Auth_SteamID,
	Auth_IP,
	Auth_Tag
};

enum _:AuthData {
	Auth_Type,
	Auth_Key[35],
	Auth_Password[32],
	Auth_RemoveTime,
	Auth_Flags
};

enum _:AddData {
	Data_Type,
	Data_Auth[35],
	Data_Password[32],
	Data_Flags[27],
	Data_RemoveDate[32]
};

#define getBit(%1,%2) (%1 &   (1 << (%2 & 31)))
#define setBit(%1,%2)  %1 |=  (1 << (%2 & 31))
#define delBit(%1,%2)  %1 &= ~(1 << (%2 & 31))

new gVIP;
#define is_vip(%1) getBit(gVIP, %1)
#define set_vip(%1) setBit(gVIP, %1)
#define remove_vip(%1) delBit(gVIP, %1)

new gFlags[MAX_PLAYERS + 1];

new Handle:gSqlTuple = Empty_Handle;
new gUsersFile[64];

new gCvarSql;
new gCvarHost;
new gCvarUser;
new gCvarPass;
new gCvarDb;
new gCvarAuthFlags;
new gCvarDefaultFlags;
new gCvarDeleteExpired;
new gCvarPasswordField;

new gForwardAuth;
new gForwardPutinserver;
new gForwardDisconnect;
new gReturnFromForward;

new Trie:gAuthKeys;

new Array:gAuthData;
new Trie:gAuthToIndex[Auths];
new gNumAuths;

new Regex:gDatePattern;

public plugin_init() {
	register_plugin("VIP Manager", "0.0.6", "Exolent");
	
	register_concmd("vip_adduser", "CmdAddUser", ADMIN_RCON, "<name, #userid, authid> <type> [password] [flags] [days] -- <type> can be 'name', 'steamid', or 'ip'");
	register_concmd("vip_addauth", "CmdAddAuth", ADMIN_RCON, "<type> <auth> [password] [flags] [days] -- <type> can be 'name', 'steamid', 'ip', or 'tag'");
	register_concmd("vip_reload", "CmdReload", ADMIN_RCON, "-- reloads the VIP users list for the vip_users.ini");
	
	gCvarSql = register_cvar("vip_sql", "0");
	gCvarHost = register_cvar("vip_sql_host", "");
	gCvarUser = register_cvar("vip_sql_user", "");
	gCvarPass = register_cvar("vip_sql_pass", "");
	gCvarDb = register_cvar("vip_sql_db", "");
	gCvarAuthFlags = register_cvar("vip_auth_flags", "b");
	gCvarDefaultFlags = register_cvar("vip_default_flags", "");
	gCvarDeleteExpired = register_cvar("vip_delete_expired", "0");
	gCvarPasswordField = register_cvar("vip_password_field", "_vip_pw");
	
	gForwardAuth = CreateMultiForward("vip_authorized", ET_IGNORE, FP_CELL);
	gForwardPutinserver = CreateMultiForward("vip_putinserver", ET_IGNORE, FP_CELL);
	gForwardDisconnect = CreateMultiForward("vip_disconnect", ET_IGNORE, FP_CELL);
	
	gAuthKeys = TrieCreate();
	TrieSetCell(gAuthKeys, "name", Auth_Name);
	TrieSetCell(gAuthKeys, "steam", Auth_SteamID);
	TrieSetCell(gAuthKeys, "steamid", Auth_SteamID);
	TrieSetCell(gAuthKeys, "authid", Auth_SteamID);
	TrieSetCell(gAuthKeys, "ip", Auth_IP);
	TrieSetCell(gAuthKeys, "tag", Auth_Tag);
	
	gAuthData = ArrayCreate(AuthData);
	
	for(new i = 0; i < Auths; i++) {
		gAuthToIndex[i] = TrieCreate();
	}
	
	gDatePattern = regex_compile("\d{4}-\d{1,2}-\d{1,2}", gReturnFromForward, "", 0);
	
	get_configsdir(gUsersFile, charsmax(gUsersFile));
	add(gUsersFile, charsmax(gUsersFile), "/vip_users.ini");
	
	LoadConfig();
}

public plugin_end() {
	TrieDestroy(gAuthKeys);
	
	ArrayDestroy(gAuthData);
	
	for(new i = 0; i < Auths; i++) {
		TrieDestroy(gAuthToIndex[i]);
	}
	
	regex_free(gDatePattern);
}

public plugin_natives() {
	register_library("vip");
	
	register_native("is_user_vip", "_is_user_vip");
	register_native("get_vip_flags", "_get_vip_flags");
}

public _is_user_vip(plugin, params) {
	return is_vip(get_param(1)) ? 1 : 0;
}

public _get_vip_flags(plugin, params) {
	new id = get_param(1);
	
	return is_vip(id) ? gFlags[id] : 0;
}

public client_authorized(id) {
	CheckAuth(id, gForwardAuth);
}

public client_putinserver(id) {
	CheckAuth(id, gForwardPutinserver);
}

public client_infochanged(id) {
	if(!is_user_connected(id)) return;
	
	new oldName[32], newName[32];
	get_user_name(id, oldName, charsmax(oldName));
	get_user_info(id, "name", newName, charsmax(newName));
	
	if(!equal(oldName, newName)) {
		CheckAuth(id, gForwardAuth, newName);
	}
}

public client_disconnect(id) {
	if(is_vip(id)) {
		ExecuteForward(gForwardDisconnect, gReturnFromForward, id);
		
		remove_vip(id);
		gFlags[id] = 0;
		
		remove_task(id);
	}
}

public CmdAddUser(id, level, cid) {
	if(!cmd_access(id, level, cid, 3)) {
		return PLUGIN_HANDLED;
	}
	
	new auth[35];
	read_argv(1, auth, charsmax(auth));
	
	new target = cmd_target(id, auth, CMDTARGET_NO_BOTS);
	if(!target) {
		return PLUGIN_HANDLED;
	}
	
	new type[16];
	read_argv(2, type, charsmax(type));
	strtolower(type);
	
	new typeNum;
	if(!TrieGetCell(gAuthKeys, type, typeNum) || typeNum == Auth_Tag) {
		console_print(id, "Invalid type! Only 'name', 'steamid', and 'ip' are valid types!");
		return PLUGIN_HANDLED;
	}
	
	switch(typeNum) {
		case Auth_SteamID: {
			get_user_authid(target, auth, charsmax(auth));
		}
		case Auth_IP: {
			get_user_ip(target, auth, charsmax(auth), 1);
		}
		default: {
			get_user_name(target, auth, charsmax(auth));
		}
	}
	
	new password[32];
	new flagString[27], flags;
	new remove, removeDate[32];
	
	new argCount = read_argc();
	if(argCount > 3) {
		read_argv(3, password, charsmax(password));
		
		if(argCount > 4) {
			read_argv(4, flagString, charsmax(flagString));
			
			flags = read_flags(flagString);
			
			// fix flagString in case it wasn't 100% proper
			get_flags(flags, flagString, charsmax(flagString));
			
			if(argCount > 5) {
				new days[12];
				read_argv(5, days, charsmax(days));
				
				if(!is_str_num(days) || (remove = str_to_num(days)) < 0) {
					console_print(id, "Days must be a positive integer, or 0 for no expiring!");
					return PLUGIN_HANDLED;
				}
				
				if(remove) {
					remove = get_systime() + (remove * 86400);
					
					format_time(removeDate, charsmax(removeDate), "%Y-%m-%d", remove);
				}
			}
		}
	}
	
	new f = fopen(gUsersFile, "a+");
	
	if(f) {
		fprintf(f, "^n^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"", type, auth, password, flagString, removeDate);
		fclose(f);
	}
	
	if(gSqlTuple != Empty_Handle) {
		new data[AddData];
		data[Data_Type] = typeNum;
		copy(data[Data_Auth], charsmax(data[Data_Auth]), auth);
		copy(data[Data_Password], charsmax(data[Data_Password]), password);
		copy(data[Data_Flags], charsmax(data[Data_Flags]), flagString);
		copy(data[Data_RemoveDate], charsmax(data[Data_RemoveDate]), remove ? removeDate : "0000-00-00");
		
		new query[128];
		formatex(query, charsmax(query), "SELECT COUNT(*) FROM `vip_users` WHERE `auth_type` = %d AND `auth` = ^"%s^";", typeNum, auth);
		
		SQL_ThreadQuery(gSqlTuple, "QueryCheckAddUser", query, data, AddData);
	}
	
	if(typeNum != Auth_Name) {
		get_user_name(target, auth, charsmax(auth));
	}
	
	console_print(id, "Added user to VIP: <%s> <%s>", type, auth);
	
	return PLUGIN_HANDLED;
}

public QueryCheckAddUser(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to check add user (%d): %s", errcode, error);
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on check add user (%d): %s", errcode, error);
	}
	else if(!SQL_ReadResult(query, 0)) {
		new queryString[256];
		formatex(queryString, charsmax(queryString), "INSERT INTO `vip_users` (`auth_type`, `auth`, `password`, `flags`, `date_remove`) VALUES (%d, ^"%s^", ^"%s^", ^"%s^", ^"%s^");",
			data[Data_Type], data[Data_Auth], data[Data_Password], data[Data_Flags], data[Data_RemoveDate]);
		
		SQL_ThreadQuery(gSqlTuple, "QueryAddUser", queryString);
	}
}

public QueryAddUser(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to add user (%d): %s", errcode, error);
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on add user (%d): %s", errcode, error);
	}
}

public CmdAddAuth(id, level, cid) {
	if(!cmd_access(id, level, cid, 3)) {
		return PLUGIN_HANDLED;
	}
	
	new type[16], auth[35];
	read_argv(1, type, charsmax(type));
	read_argv(2, auth, charsmax(auth));
	
	strtolower(type);
	
	new typeNum;
	if(!TrieGetCell(gAuthKeys, type, typeNum)) {
		console_print(id, "Invalid type! Only 'name', 'steamid', 'ip', and 'tag' are valid types!");
		return PLUGIN_HANDLED;
	}
	
	new password[32];
	new flagString[27], flags;
	new remove, removeDate[32];
	
	new argCount = read_argc();
	if(argCount > 3) {
		read_argv(3, password, charsmax(password));
		
		if(argCount > 4) {
			read_argv(4, flagString, charsmax(flagString));
			
			flags = read_flags(flagString);
			
			// fix flagString in case it wasn't 100% proper
			get_flags(flags, flagString, charsmax(flagString));
			
			if(argCount > 5) {
				new days[12];
				read_argv(5, days, charsmax(days));
				
				if(!is_str_num(days) || (remove = str_to_num(days)) < 0) {
					console_print(id, "Days must be a positive integer, or 0 for no expiring!");
					return PLUGIN_HANDLED;
				}
				
				if(remove) {
					remove = get_systime() + (remove * 86400);
					
					format_time(removeDate, charsmax(removeDate), "%Y-%m-%d", remove);
				}
			}
		}
	}
	
	new f = fopen(gUsersFile, "a+");
	
	if(f) {
		fprintf(f, "^n^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"", type, auth, password, flagString, removeDate);
		fclose(f);
	}
	
	if(gSqlTuple != Empty_Handle) {
		new data[AddData];
		data[Data_Type] = typeNum;
		copy(data[Data_Auth], charsmax(data[Data_Auth]), auth);
		copy(data[Data_Password], charsmax(data[Data_Password]), password);
		copy(data[Data_Flags], charsmax(data[Data_Flags]), flagString);
		copy(data[Data_RemoveDate], charsmax(data[Data_RemoveDate]), remove ? removeDate : "0000-00-00");
		
		new query[128];
		formatex(query, charsmax(query), "SELECT COUNT(*) FROM `vip_users` WHERE `auth_type` = %d AND `auth` = ^"%s^";", typeNum, auth);
		
		SQL_ThreadQuery(gSqlTuple, "QueryCheckAddAuth", query, data, AddData);
	}
	
	console_print(id, "Added user to VIP: <%s> <%s>", type, auth);
	
	return PLUGIN_HANDLED;
}

public QueryCheckAddAuth(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to check add auth (%d): %s", errcode, error);
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on check add auth (%d): %s", errcode, error);
	}
	else if(!SQL_ReadResult(query, 0)) {
		new queryString[256];
		formatex(queryString, charsmax(queryString), "INSERT INTO `vip_users` (`auth_type`, `auth`, `password`, `flags`, `date_remove`) VALUES (%d, ^"%s^", ^"%s^", ^"%s^", ^"%s^");",
			data[Data_Type], data[Data_Auth], data[Data_Password], data[Data_Flags], data[Data_RemoveDate]);
		
		SQL_ThreadQuery(gSqlTuple, "QueryAddAuth", queryString);
	}
}

public QueryAddAuth(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to add auth (%d): %s", errcode, error);
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on add auth (%d): %s", errcode, error);
	}
}

public CmdReload(id, level, cid) {
	if(!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}
	
	LoadConfig();
	
	new players[32], num;
	get_players(players, num, "ch");
	
	while(num) {
		CheckAuth(players[--num], gForwardAuth);
	}
	
	console_print(id, "Reloaded VIP users list");
	
	return PLUGIN_HANDLED;
}

LoadConfig() {
	static bool:alreadyLoaded;
	
	if(alreadyLoaded) {
		gSqlTuple = Empty_Handle;
		
		ArrayClear(gAuthData);
		gNumAuths = 0;
	}
	
	new config[64];
	get_configsdir(config, charsmax(config));
	add(config, charsmax(config), "/vip.cfg");
	
	if(file_exists(config)) {
		server_cmd("exec %s", config);
		server_exec();
	}
	
	if(!get_pcvar_num(gCvarSql) || !LoadSql(alreadyLoaded)) {
		LoadFile();
	}
	
	alreadyLoaded = true;
}

LoadFile() {
	
	new f = fopen(gUsersFile, "rt");
	
	if(!f) return;
	
	new data[64];
	new type[16];
	new typeNum;
	new auth[32];
	new flagString[32];
	new removeDate[32];
	new remove, curTime = get_systime();
	new authData[AuthData];
	new deleteExpired = get_pcvar_num(gCvarDeleteExpired);
	new Trie:linesExpired, line;
	
#if defined BACKWARDS_COMPAT
	new Trie:linesToFix = TrieCreate(), bool:fixLines = false;
#endif
	
	new tmpFile[64];
	formatex(tmpFile, charsmax(tmpFile), "%s.tmp", gUsersFile);
	
	if(deleteExpired) {
		linesExpired = TrieCreate();
	}
	
	while(!feof(f)) {
		fgets(f, data, charsmax(data));
		trim(data);
		line++;
		
		if(!data[0] || data[0] == ';' || data[0] == '/' && data[1] == '/') continue;
		
		if(parse(data, type, charsmax(type), auth, charsmax(auth), flagString, charsmax(flagString), removeDate, charsmax(removeDate)) < 2) continue;
		
		strtolower(type);
		
		if(!TrieGetCell(gAuthKeys, type, typeNum) || TrieKeyExists(gAuthToIndex[typeNum], auth)) continue;
		
#if defined BACKWARDS_COMPAT
		if(!removeDate[0]) {
			// there are only 3 params
			// check if the 3rd is a date instead of flags
			// this is for backwards compatibility for older versions without flags
			if(flagString[0] && regex_match_c(flagString, gDatePattern, gReturnFromForward) > 0) {
				// this flag string is really a date string
				// switch the strings
				copy(data, charsmax(data), removeDate);
				copy(removeDate, charsmax(removeDate), flagString);
				copy(flagString, charsmax(flagString), data);
				
				// say we want to fix lines later
				fixLines = true;
				
				// add specific line to be fixed
				num_to_str(line, data, charsmax(data));
				TrieSetCell(linesToFix, data, line);
			}
		}
#endif
		
		remove = DateToUnix(removeDate);
		
		if(remove && remove <= curTime) {
			if(deleteExpired) {
				num_to_str(line, type, charsmax(type));
				TrieSetCell(linesExpired, type, line);
			}
			continue;
		}
		
		authData[Auth_Type] = typeNum;
		copy(authData[Auth_Key], charsmax(authData[Auth_Key]), auth);
		authData[Auth_Flags] = read_flags(flagString);
		authData[Auth_RemoveTime] = remove;
		
		ArrayPushArray(gAuthData, authData);
		TrieSetCell(gAuthToIndex[typeNum], auth, gNumAuths);
		gNumAuths++;
	}
	
#if defined BACKWARDS_COMPAT
	if(deleteExpired || fixLines) {
#else
	if(deleteExpired) {
#endif
		fseek(f, 0, SEEK_SET);
		
		new t = fopen(tmpFile, "wt");
		line = 0;
		
		while(!feof(f)) {
			num_to_str(++line, type, charsmax(type));
			fgets(f, data, charsmax(data));
			
			if(deleteExpired && TrieKeyExists(linesExpired, type)) continue;
			
#if defined BACKWARDS_COMPAT
			if(TrieKeyExists(linesToFix, type)) {
				parse(data, type, charsmax(type), auth, charsmax(auth), flagString, charsmax(flagString), removeDate, charsmax(removeDate));
				
				// switch date and flag string since they are backwards
				formatex(data, charsmax(data), "^"%s^" ^"%s^" ^"%s^" ^"%s^"^n", type, auth, removeDate, flagString);
			}
#endif
			
			fputs(t, data);
		}
		
		fclose(t);
		
		TrieDestroy(linesExpired);
	}
	
#if defined BACKWARDS_COMPAT
	TrieDestroy(linesToFix);
#endif
	
	fclose(f);
	
#if defined BACKWARDS_COMPAT
	if(deleteExpired || fixLines) {
#else
	if(deleteExpired) {
#endif
		rename_file(tmpFile, gUsersFile, 1);
	}
}

DateToUnix(const dateString[]) {
	if(!dateString[0] || regex_match_c(dateString, gDatePattern, gReturnFromForward) <= 0 || equal(dateString, "0000-00-00")) {
		return 0;
	}
	
	new year[5], month[3], rest[32];
	strtok(dateString, year, charsmax(year), rest, charsmax(rest), '-');
	strtok(rest, month, charsmax(month), rest, charsmax(rest), '-');
	
	return TimeToUnix(str_to_num(year), str_to_num(month), str_to_num(rest), 0, 0, 0);
}

LoadSql(bool:threadQueries) {
	new host[32], user[32], pass[32], db[32];
	get_pcvar_string(gCvarHost, host, charsmax(host));
	get_pcvar_string(gCvarUser, user, charsmax(user));
	get_pcvar_string(gCvarPass, pass, charsmax(pass));
	get_pcvar_string(gCvarDb, db, charsmax(db));
	
	gSqlTuple = SQL_MakeDbTuple(host, user, pass, db);
	
	if(gSqlTuple == Empty_Handle) {
		log_amx("Failed to create SQL tuple.");
		return 0;
	}
	
	new const queryString[] = "CREATE TABLE IF NOT EXISTS `vip_users` (\
			`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,\
			`auth_type` INT NOT NULL DEFAULT '0',\
			`auth` VARCHAR(32) NOT NULL,\
			`password` VARCHAR(32) NOT NULL,\
			`flags` VARCHAR(26) NOT NULL,\
			`date_remove` DATE NOT NULL DEFAULT '0000-00-00');";
	
	if(threadQueries) {
		SQL_ThreadQuery(gSqlTuple, "QueryCreateTable", queryString);
	} else {
		new errcode, error[128];
		new Handle:link = SQL_Connect(gSqlTuple, errcode, error, charsmax(error));
		
		if(link == Empty_Handle) {
			gSqlTuple = Empty_Handle;
			
			log_amx("Failed to connect to database (%d): %s", errcode, error);
			return 0;
		}
		
		new Handle:query = SQL_PrepareQuery(link, "%s", queryString);
		
		// Added `date_remove` field to table
		// 
		// Fix for v0.0.1 to v0.0.2
		// ALTER TABLE `vip_users` ADD `date_remove` DATE NOT NULL DEFAULT '0000-00-00';
		
		// Added `flags` field to table
		// 
		// Fix for v0.0.1 to v0.0.4
		// ALTER TABLE `vip_users` ADD `date_remove` DATE NOT NULL DEFAULT '0000-00-00', ADD `flags` VARCHAR(26) NOT NULL DEFAULT '';
		// 
		// Fix for v0.0.2 to v0.0.4
		// ALTER TABLE `vip_users` ADD `flags` VARCHAR(26) NOT NULL DEFAULT '';
		
		// Added `password` field to table
		// 
		// Fix for v0.0.1 to v0.0.5
		// ALTER TABLE `vip_users` ADD `date_remove` DATE NOT NULL DEFAULT '0000-00-00', ADD `flags` VARCHAR(26) NOT NULL DEFAULT '', ADD `password` VARCHAR(32) NOT NULL DEFAULT '';
		// 
		// Fix for v0.0.2 to v0.0.5
		// ALTER TABLE `vip_users` ADD `flags` VARCHAR(26) NOT NULL DEFAULT '', ADD `password` VARCHAR(32) NOT NULL DEFAULT '';
		// 
		// Fix for v0.0.4 to v0.0.5
		// ALTER TABLE `vip_users` ADD `password` VARCHAR(32) NOT NULL DEFAULT '';
		
		if(!SQL_Execute(query)) {
			gSqlTuple = Empty_Handle;
			
			SQL_QueryError(query, error, charsmax(error));
			log_amx("Error creating table: %s", error);
		}
		
		SQL_FreeHandle(query);
		SQL_FreeHandle(link);
		
		if(gSqlTuple != Empty_Handle) {
			LoadFromSql();
		} else {
			return 0;
		}
	}
	
	return 1;
}

public QueryCreateTable(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to create table (%d): %s", errcode, error);
		
		LoadFile();
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on create table (%d): %s", errcode, error);
		
		LoadFile();
	}
	else {
		LoadFromSql();
	}
}

LoadFromSql() {
	new curDate[11];
	get_time("%Y-%m-%d", curDate, charsmax(curDate));
	
	new queryString[94];
	// SELECT * FROM `vip_users` WHERE `date_remove` = '0000-00-00' OR `date_remove` > '2012-02-09';
	// 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 
	
	if(get_pcvar_num(gCvarDeleteExpired)) {
		formatex(queryString, charsmax(queryString), "DELETE FROM `vip_users` WHERE `date_remove` > '%s';", curDate);
		
		SQL_ThreadQuery(gSqlTuple, "QueryDeleteExpired", queryString);
	}
	
	formatex(queryString, charsmax(queryString), "SELECT * FROM `vip_users` WHERE `date_remove` = '0000-00-00' OR `date_remove` > '%s';", curDate);
	
	SQL_ThreadQuery(gSqlTuple, "QueryLoadUsers", queryString);
}

public QueryDeleteExpired(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to delete expired (%d): %s", errcode, error);
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on delete expired (%d): %s", errcode, error);
	}
}

public QueryLoadUsers(failstate, Handle:query, error[], errcode, data[], size, Float:queueTime) {
	if(failstate == TQUERY_CONNECT_FAILED) {
		log_amx("Failed connecting to load users (%d): %s", errcode, error);
		
		LoadFile();
	}
	else if(failstate == TQUERY_QUERY_FAILED) {
		log_amx("Failed query on load users (%d): %s", errcode, error);
		
		LoadFile();
	}
	else if(SQL_NumResults(query)) {
		new fieldAuth = SQL_FieldNameToNum(query, "auth");
		new fieldType = SQL_FieldNameToNum(query, "auth_type");
		new fieldPassword = SQL_FieldNameToNum(query, "password");
		new fieldFlags = SQL_FieldNameToNum(query, "flags");
		new fieldRemove = SQL_FieldNameToNum(query, "date_remove");
		
		new flagString[27];
		new removeDate[11];
		new curTime = get_systime();
		new authData[AuthData];
		
		do {
			SQL_ReadResult(query, fieldRemove, removeDate, charsmax(removeDate));
			
			authData[Auth_RemoveTime] = DateToUnix(removeDate);
			
			if(!authData[Auth_RemoveTime] || authData[Auth_RemoveTime] > curTime) {
				SQL_ReadResult(query, fieldAuth, authData[Auth_Key], charsmax(authData[Auth_Key]));
				authData[Auth_Type] = SQL_ReadResult(query, fieldType);
				
				SQL_ReadResult(query, fieldPassword, authData[Auth_Password], charsmax(authData[Auth_Password]));
				
				SQL_ReadResult(query, fieldFlags, flagString, charsmax(flagString));
				authData[Auth_Flags] = read_flags(flagString);
				
				ArrayPushArray(gAuthData, authData);
				TrieSetCell(gAuthToIndex[authData[Auth_Type]], authData[Auth_Key], gNumAuths);
				gNumAuths++;
			}
			
			SQL_NextRow(query);
		}
		while(SQL_MoreResults(query));
	}
}

CheckAuth(id, forwardHandle, forceName[] = "") {
	new wasVip = is_vip(id);
	remove_vip(id);
	gFlags[id] = 0;
	
	remove_task(id);
	
	new flags[27];
	get_pcvar_string(gCvarAuthFlags, flags, charsmax(flags));
	
	if(flags[0] && has_all_flags(id, flags)) {
		gFlags[id] = read_flags(flags) | read_pcvar_flags(gCvarDefaultFlags);
		AuthUser(id, wasVip, forwardHandle);
		return;
	}
	
	new name[32], steamid[32], ip[32];
	if(forceName[0]) {
		copy(name, charsmax(name), forceName);
	} else {
		get_user_name(id, name, charsmax(name));
	}
	get_user_authid(id, steamid, charsmax(steamid));
	get_user_ip(id, ip, charsmax(ip), 1);
	
	new curTime = get_systime();
	
	new authData[AuthData], index;
	
	if(!TrieGetCell(Trie:gAuthToIndex[Auth_Name], name, index)
	&& !TrieGetCell(Trie:gAuthToIndex[Auth_SteamID], steamid, index)
	&& !TrieGetCell(Trie:gAuthToIndex[Auth_IP], ip, index)) {
		index = -1;
		
		for(new i = 0; i < gNumAuths; i++) {
			ArrayGetArray(gAuthData, i, authData);
			
			if(authData[Auth_Type] == Auth_Tag
			&& (0 < authData[Auth_RemoveTime] <= curTime)
			&& containi(name, authData[Auth_Key]) != -1) {
				index = i;
				break;
			}
		}
		
		if(index == -1) return;
	}
	
	if(authData[Auth_Password][0]) {
		new field[32], password[32];
		get_pcvar_string(gCvarPasswordField, field, charsmax(field));
		get_user_info(id, field, password, charsmax(password));
		
		if(!equal(authData[Auth_Password], password)) return;
	}
	
	gFlags[id] = authData[Auth_Flags] | read_pcvar_flags(gCvarDefaultFlags);
	AuthUser(id, wasVip, forwardHandle, authData[Auth_RemoveTime] - curTime);
}

AuthUser(id, wasVip, forwardHandle, remove = 0) {
	set_vip(id);
	
	if(!wasVip) {
		ExecuteForward(forwardHandle, wasVip, id);
	}
	
	if(remove > 0) {
		set_task(float(remove), "TaskCheckAuth", id);
	}
}

public TaskCheckAuth(id) {
	CheckAuth(id, gForwardAuth);
}

read_pcvar_flags(cvar) {
	new flags[27];
	get_pcvar_string(cvar, flags, charsmax(flags));
	return read_flags(flags);
}

// CODE BELOW IS FROM BUGSY'S UNIX TO TIME CONVERSION INCLUDE
// https://forums.alliedmods.net/showthread.php?t=91915

stock const YearSeconds[2] = 
{ 
	31536000,	//Normal year
	31622400 	//Leap year
};

stock const MonthSeconds[12] = 
{ 
	2678400, //January	31 
	2419200, //February	28
	2678400, //March	31
	2592000, //April	30
	2678400, //May		31
	2592000, //June		30
	2678400, //July		31
	2678400, //August	31
	2592000, //September	30
	2678400, //October	31
	2592000, //November	30
	2678400  //December	31
};

stock const DaySeconds = 86400;
stock const HourSeconds = 3600;
stock const MinuteSeconds = 60;

stock TimeToUnix( const iYear , const iMonth , const iDay , const iHour , const iMinute , const iSecond /*, TimeZones:tzTimeZone=UT_TIMEZONE_UTC*/)
{
	new i , iTimeStamp;

	for ( i = 1970 ; i < iYear ; i++ )
		iTimeStamp += YearSeconds[ IsLeapYear(i) ];

	for ( i = 1 ; i < iMonth ; i++ )
		iTimeStamp += SecondsInMonth( iYear , i );

	iTimeStamp += ( ( iDay - 1 ) * DaySeconds );
	iTimeStamp += ( iHour * HourSeconds );
	iTimeStamp += ( iMinute * MinuteSeconds );
	iTimeStamp += iSecond;

	/*if ( tzTimeZone == UT_TIMEZONE_SERVER )
		tzTimeZone = GetTimeZone();
		
	return ( iTimeStamp + TimeZoneOffset[ tzTimeZone ] );*/
	
	return iTimeStamp;
}

stock SecondsInMonth( const iYear , const iMonth ) 
{
	return ( ( IsLeapYear( iYear ) && ( iMonth == 2 ) ) ? ( MonthSeconds[iMonth - 1] + DaySeconds ) : MonthSeconds[iMonth - 1] );
}

stock IsLeapYear( const iYear ) 
{
	return ( ( (iYear % 4) == 0) && ( ( (iYear % 100) != 0) || ( (iYear % 400) == 0 ) ) );
}
