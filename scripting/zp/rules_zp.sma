#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#define PLUGIN_NAME	"Luat SERVER ZOMBIE PLAUGE"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"VINAGHOST"
new bool:first[33]
new menu
new const ip [][] = {
	"vinastudio.dynu.net:27015",
	"vinastudio.dynu.net:27016"
}
public plugin_init()
{	
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	RegisterHam(Ham_Spawn, "player", "ham_Spawn_post", 1)
}
public client_connect(id)
	first[id] = true
public ham_Spawn_post(id)
{
	if(first[id])
		show(id)
}
public show(id)
{
		menu = menu_create("\r[NTC] \wLuật Server ZOMBIE PLAUGE", "luat")
		menu_additem(menu, "Bấm 1 để biết luật")
		menu_additem(menu, "Bấm 2 nếu biết rồi")
		menu_additem(menu, "Bấm 3 nếu là mod")
		menu_additem(menu, "Bấm 4 nếu vô lộn server ._.")
		menu_display(id, menu, 0)
	}
public luat(id, menu, item){
	switch (item)
	{
		case 0:	luat_1(id)
		case 1: first[id] = false
		case 2: luat_5(id)
		case 3: server_info(id)
	}
}
public luat_1(id)
{
	menu = menu_create("\r[NTC] \wLuật Server ZOMBIE PLAUGE", "luat_2")
	menu_additem(menu, "Xin chào! Mình là VINAGHOST")
	menu_additem(menu, "Có vài điều cần lưu ý khi chơi nha")
	menu_additem(menu, "Thứ nhất, tôn trong mọi người xung quanh")
	menu_additem(menu, "Nếu họ không tôn trọng bạn hãy up demo lên group")
	menu_additem(menu, "để nhờ mod can thiệp")
	menu_additem(menu, "Bấm số 6 để biết cách up demo lên group")
	menu_display(id, menu, 0)
}
public luat_2(id)
{
	menu = menu_create("\r[NTC] \wLuật Server ZOMBIE PLAUGE", "luat_3")
	menu_additem(menu, "Bạn vào theo đường dẫn <thư mục CS>/cstrike/")
	menu_additem(menu, "Trong thư mục này sẽ có file NTC_ZP.dem")
	menu_additem(menu, "Lên group của server: fb.com/groups/csntcmod")
	menu_additem(menu, "Trong POST cũng nên có name + steamid")
	menu_additem(menu, "Mở console ghi status rồi enter để lấy steamid")
	menu_additem(menu, "CHÚ Ý: demo chỉ có giá trị trong 1 map")
	menu_additem(menu, "tức qua map khác là sẽ bị reset. Nhớ chú ý.")
	menu_additem(menu, "Bấm số 7 để tiếp tục")
	menu_display(id, menu, 0)
}
public luat_3(id)
{
	menu = menu_create("\r[NTC] \wLuật Server ZOMBIE PLAUGE", "luat_4")
	menu_additem(menu, "OK xong phần quan trọng giờ thì vô mấy cái linh tinh")
	menu_additem(menu, "- Không troll một cách bất lịch sự (ra đảo 1 tiếng)")
	menu_additem(menu, "- Spam dưới mọi hình thức (ra đảo 1 ngày)")
	menu_additem(menu, "- Ngoài mục định vui vẻ, ai văng tục, xúc phạm người khác ra đảo 1 ngày")
	menu_additem(menu, "- Ai phát hiện hành vi vi phạm các điều trên thì cứ up demo lên group")
	menu_additem(menu, "- Quyết định của VINA là quyết định cuối cùng, ý kiến ? up demo lên group")
	menu_additem(menu, "Hết rồi ae có thể bắt đầu chơi bằng cách nhấn số 6 ._.")
	menu_display(id, menu, 0)
}
public luat_4(id)
{
	first[id] = false
}
public luat_5(id)
{
	if( !is_user_admin(id))
	{
		ham_Spawn_post(id)
		return;
	}
	menu = menu_create("\r[NTC] \wLuật Server ZOMBIE PLAUGE cho mod", "luat_4")
	menu_additem(menu, "Luôn chắc chắn có demo và nhớ thêm reason khi kick/ban mem")
	menu_additem(menu, "Nói năng dễ nghe hộ VINA cho dù nó xúc phạm thì có demo rồi cứ ban khỏi đôi co ._.")
	menu_additem(menu, "Đề nghị ae mod không lạm dụng slap hoặc slay ._.")
	menu_additem(menu, "Ak nhớ đọc luật bên phần kia để biết tội đó cần ra đảo")
	menu_additem(menu, "tối đa bao lâu đừng lố hơn nó kiện đấy ._.")
	menu_additem(menu, "Sau khi ban xong ấy nhớ ra ngoài lấy demo lưu lại trong mục nào ấy")
	menu_additem(menu, " để nó kiện còn có thứ để up")
	menu_additem(menu, "OK hết rồi ._.")
	menu_display(id, menu, 0)
}
public server_info(id)
{
	menu = menu_create("\r[NTC] \wDanh sách server NTC Multimod DP", "server")
	menu_additem(menu, "DEATHRUN: vinastudio.dynu.net:27015")
	menu_additem(menu, "ZOMBIE PLAUGE: vinastudio.dynu.net:27016")
	menu_additem(menu, "Muốn thêm mode ? Lên group để góp ý cho VINA")
	menu_additem(menu, "Ở lại server")
	menu_display(id, menu, 0)
}
public server(id, menu, item)
{
	if(item < 2)
	{
		client_cmd(id, "connect %s", ip[item])
		return;
	}
	
	show(id)
}
