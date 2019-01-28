/*================================================================================
	
	-----------------------------------
	-*- [ZP] Zombie Class : Invisible Cat -*-
	-----------------------------------
	Created by Anggara_nothing. ^_^
	
	Description:
	The cat will be invisible if not move/jump.
	
	Credit:
	Hello-World -> Cat model.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <zombieplague>

// Zombie Attributes
new const zclass_name[] = { "Meo meo" } // name
new const zclass_info[] = { "Dung yen de tang hinh" } // description
new const zclass_model[] = { "cat_zombie" } // model
new const zclass_clawmodel[] = { "cat_claw.mdl" } // claw model
const zclass_health = 350 // health
const zclass_speed = 270 // speed
const Float:zclass_gravity = 1.0 // gravity
const Float:zclass_knockback = 1.0 // knockback

new g_pcvaramount
// Class IDs
new g_cat_class

public plugin_init()
{
	register_plugin("[ZP] Poison Cat Zombie", "1.2", "Anggara_nothing")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	g_pcvaramount = register_cvar("zp_inviscat_amount", "0")
	// Register the new class and store ID for reference
	g_cat_class = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)	
}

// User Infected forward
public zp_user_infected_post(id, infector)
{
	if(!zp_get_user_zombie(id))
		return;
	
	// Check if the infected player is using our custom zombie class
	if (zp_get_user_zombie_class(id) == g_cat_class)
	{
		give_item(id, "item_longjump")
	}

}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id) || !zp_get_user_zombie(id))
		return PLUGIN_CONTINUE;
	
	if(zp_get_user_zombie_class(id) != g_cat_class)
		return PLUGIN_CONTINUE;
	
	new button = pev(id, pev_button)
	
	if(button&IN_ATTACK || button&IN_ATTACK2 || button&IN_BACK || button&IN_FORWARD || button&IN_RUN || button&IN_JUMP || button&IN_MOVELEFT || button&IN_MOVERIGHT || button&IN_LEFT || button&IN_RIGHT)
		set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderNormal, 255)
	else
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(g_pcvaramount))
	
	
	return PLUGIN_HANDLED
}

