#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <zp50_weapon>

#include <cs_weap_models_api>

#define PLUGIN "[ZP] Weapon: Primary default"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

new const primary_items[][] = { "weapon_galil", "weapon_famas", "weapon_m4a1", "weapon_ak47","weapon_m3", "weapon_xm1014" }

new const WEAPONNAMES[][] = { "", "P228 Compact", "", "Schmidt Scout", "HE Grenade", "XM1014 M4", "", "Ingram MAC-10", "Steyr AUG A1",
			"Smoke Grenade", "Dual Elite Berettas", "FiveseveN", "UMP 45", "SG-550 Auto-Sniper", "IMI Galil", "Famas",
			"USP .45 ACP Tactical", "Glock 18C", "AWP Magnum Sniper", "MP5 Navy", "M249 Para Machinegun",
			"M3 Super 90", "M4A1 Carbine", "Schmidt TMP", "G3SG1 Auto-Sniper", "Flashbang", "Desert Eagle .50 AE",
			"SG-552 Commando", "AK-47 Kalashnikov", "", "ES P90" }				

new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

/*new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }
*/
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }			
			
//const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)			

new primary[6];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	for(new i =0 ; i < 6; i++ )
	{
		new weaponid = get_weaponid(primary_items[i]) 
		primary[i] = zp_weapons_register(WEAPONNAMES[weaponid], 0, ZP_PRIMARY, ZP_WEAPON_AP)
	}
}
public zp_fw_wpn_select_post(id, itemid) {
	
	for(new i = 0; i < 6; i++) {
		if(itemid == primary[i] ) {
			give_weapon(id, i) 
			break;
		}
	}
}
give_weapon(id, index) {
	new weaponid = get_weaponid(primary_items[index])
	
	give_item(id, primary_items[index])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
}
