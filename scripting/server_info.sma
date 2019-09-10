#include <amxmodx>
#include <cromchat>

#define PLUGIN_NAME "Server Info"
#define PLUGIN_VERSION  "1.0"
#define PLUGIN_AUTHOR   "VINAGHOST"

new const message[][] = {
	"!wChat !g/server!w để có thể xem danh sách server",
	"!wGroup FB: fb.com/groups/csntcmod",
	"!wDiscord: https://discord.gg/XFKRFtV",
	"!wNhấn !gJ!w để CHEER",
	"!wỦng hộ Server: 6380205557537 - Nguyễn Trung Nhân - Agribank Bình Thạnh",
	"!wỦng hộ Server: 0908341796 - Nguyễn Trung Nhân - MoMo",
	"!wServer !gVĂN HOÁ!w nên hãy là những con người có !VĂN HOÁ!w",
	"!wKhông !gNÊN!w gian lận vì bạn sẽ bị xích như !gCHÓ!w",
	"!wBáo lỗi cho VINAGHOST thông qua Discord để nhận quà",
	"!wQuyết định của VINAGHOST là quyết định cuối cùng"
}
new num;
public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /server", "server")

	CC_SetPrefix("!g[NTC]!w");
	num = 0;
	set_task(30.0, "show_message", _, _, _, "b");
}

public show_message() {

	if( num > 9) {
		num = 0;
	}
	CC_SendMessage(0, "%s", message[num]);
	num++;

}
public server(id) {
	client_print(id, print_console, "[NTC] Multimod DP - Match - 103.48.193.60:27020");
	client_print(id, print_console, "[NTC] Multimod DP - Deathrun - 103.48.193.60:27015");
	client_print(id, print_console, "[NTC] Multimod DP - KZ - 103.48.193.60:27030");
	client_print(id, print_console, "[NTC] Multimod DP - HNS - 103.48.193.60:27040");
	client_print(id, print_console, "[NTC] Multimod DP - Battle Royale - 103.48.193.60:27060");
	client_print(id, print_console, "[NTC] Multimod DP - Zombie Plauge - 103.48.193.60:27016");
	CC_SendMessage(id, "IP các server đã được in trong Console ( nút ~ )");

}
