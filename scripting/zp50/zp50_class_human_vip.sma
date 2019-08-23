#include <amxmodx>
#include <zp50_class_human>
#include <vip>

#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

enum {
	DOROTHY,
	FLORA,
	CHOI,
	YURI,
	TOTAL_CLASS
}
// Classic Human Attributes
new const humanclass_name[][] = {
	"Dorothy Dark Knight",
	"Flora Paladin",
	"Choi Ji Yoon",
	"Yuri"
}
new const humanclass_info[] =  "";
new const humanclass_models[][] = {
	"buffclassa",
	"buffclassb",
	"buffclasschoijiyoon",
	"buffclassyuri"
}
const humanclass_health = 250;
const Float:humanclass_speed = 1.7;
const Float:humanclass_gravity = 0.7;

new g_HumanClassID[TOTAL_CLASS];
new g_choose[TOTAL_CLASS];
public plugin_precache() {
	register_plugin("[ZP] Class: Human: VIP", "1.0", "VINAGHOST")

	for( new i = 0; i < TOTAL_CLASS; i++) {
		g_HumanClassID[i] = zp_class_human_register(humanclass_name[i], humanclass_info, humanclass_health, humanclass_speed, humanclass_gravity)
		g_choose[i] = 0;
		zp_class_human_register_model(g_HumanClassID[i], humanclass_models[i])
	}

}

public zp_fw_class_human_select_pre(id, classid) {

	for( new i = 0; i < TOTAL_CLASS; i++) {
		if( classid == g_HumanClassID[i]) {
			if(!is_user_vip(id)) {
				zp_class_human_menu_text_add("[Only VIP]");
				return ZP_CLASS_NOT_AVAILABLE;
			}
			if(g_choose[i]) {
				zp_class_human_menu_text_add("Đã có người chọn skin này");
				return ZP_CLASS_NOT_AVAILABLE;
			}

			break;
		}
	}

	return ZP_CLASS_AVAILABLE;
}
public zp_fw_class_human_select_post(id, classid) {

	for( new i = 0; i < TOTAL_CLASS; i++) {
		if( classid == g_HumanClassID[i]) {
			g_choose[i] = id;
			break;
		}
	}

}

public client_disconnected(id) {
	for( new i = 0; i < TOTAL_CLASS; i++) {
		if( id == g_choose[i]) {
			g_choose[i] = 0;
			break;
		}
	}
}
