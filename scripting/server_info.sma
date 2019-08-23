#include <amxmodx>
#include <cromchat>

#define PLUGIN_NAME "Server Info"
#define PLUGIN_VERSION  "1.0"
#define PLUGIN_AUTHOR   "VINAGHOST"

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /server", "server")
	register_clcmd("say /info", "info")

	CC_SetPrefix("!g[NTC]!w");
}

public server(id) {
	client_print(id, print_console, "[NTC] Multimod DP - Match - 103.48.193.60:27020");
	client_print(id, print_console, "[NTC] Multimod DP - KZ - 103.48.193.60:27030");
	client_print(id, print_console, "[NTC] Multimod DP - HNS - 103.48.193.60:27040");
	client_print(id, print_console, "[NTC] Multimod DP - Battle Royale - 103.48.193.60:27060");
	client_print(id, print_console, "[NTC] Multimod DP - Zombie Plauge - 103.48.193.60:27016");
	CC_SendMessage(id, "IP các server đã được in trong Console ( nút ~ )");

}
public info(id) {
	client_print(id, print_console, "[NTC] Multimod DP - Match - 103.48.193.60:27020");
	client_print(id, print_console, "[NTC] Multimod DP - KZ - 103.48.193.60:27030");
	client_print(id, print_console, "[NTC] Multimod DP - HNS - 103.48.193.60:27040");
	client_print(id, print_console, "[NTC] Multimod DP - Battle Royale - 103.48.193.60:27060");
	client_print(id, print_console, "[NTC] Multimod DP - Zombie Plauge - 103.48.193.60:27016");
	CC_SendMessage(id, "IP các server đã được in trong Console ( nút ~ )");
}
