#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>

#include <cs_maxspeed_api>
#include <cs_weap_models_api>

#include <zp50_class_zombie>

#define PLUGIN "[ZP] Class: Lusty Rose"
#define VERSION "1.0"
#define AUTHOR "Dias"

#define INVISIBLE_FOV 100
#define INVISIBLE_TIME 10
#define INVISIBLE_COOLDOWN 20
#define INVISIBLE_SPEED 240.0


// Zombie Configs
new zclass_name[] = "Lusty Rose"
new zclass_desc[] = "Invisible"
new const zclass_model[] = "LustyRose"
new const zclass_clawsmodel[] = "models/zombie_plague/v_knife_LustyRose.mdl"
new const zclass_clawsmodel_inv[] = "models/zombie_plague/v_knife_LustyRose.mdl"
new const Float:zclass_gravity = 0.7
new const zclass_health = 1300;
new const Float:zclass_speed = 295.0
new const Float:zclass_knockback = 2.0


// Skill
new const Inv_StartSound[] = "zombie_plague/zombie/skill/zombi_pressure_female.wav"

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

// Var
new g_LustyRose
new g_Msg_Fov

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
		
	g_Msg_Fov = get_user_msgid("SetFOV")
}

public plugin_precache()
{	
	
	// Register Zombie Class
	g_LustyRose = zp_class_zombie_register(zclass_name, zclass_desc, zclass_health, zclass_speed, zclass_gravity)
	
	zp_class_zombie_register_kb(g_LustyRose, zclass_knockback);
	zp_class_zombie_register_model(g_LustyRose, zclass_model)
	zp_class_zombie_register_claw(g_LustyRose, zclass_clawsmodel)
	zp_class_zombie_register_1(g_LustyRose, zclass_desc, INVISIBLE_COOLDOWN + INVISIBLE_TIME, INVISIBLE_TIME)
	
	// Precache Class Resource
	engfunc(EngFunc_PrecacheSound, Inv_StartSound)
	engfunc(EngFunc_PrecacheModel, zclass_clawsmodel_inv)
}
public zp_fw_zombie_skill1_active(id, classid) {
	if( classid != g_LustyRose) return;
	
	Do_Invisible(id)
}

public zp_fw_zombie_skill1_activing(id, classid) {
	if( classid != g_LustyRose) return;
		
	Remove_Invisible(id)
}


public Do_Invisible(id)
{	
	// Set Render Red
	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 9)

	// Set Fov
	set_fov(id, INVISIBLE_FOV)
	
	cs_set_player_maxspeed_auto(id, INVISIBLE_SPEED);
	
	// Play Berserk Sound
	EmitSound(id, CHAN_ITEM, Inv_StartSound)

	// Set Invisible Claws
	cs_set_player_view_model(id, CSW_KNIFE, zclass_clawsmodel_inv) 
}

public Remove_Invisible(id)
{	
	if( !is_user_connected(id) ) 
		return;
		
	// Reset Rendering
	set_user_rendering(id)
	
	// Reset FOV
	set_fov(id)
	
	// Remove Invisible Claws
	cs_set_player_view_model(id, CSW_KNIFE, zclass_clawsmodel) 
	
	// Reset Speed
	cs_set_player_maxspeed_auto(id, zclass_speed)		
}


stock set_fov(id, num = 90)
{
	message_begin(MSG_ONE_UNRELIABLE, g_Msg_Fov, {0,0,0}, id)
	write_byte(num)
	message_end()
}

stock EmitSound(id, chan, const file_sound[])
{
	emit_sound(id, chan, file_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
