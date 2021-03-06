/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <zp50_items>
#include <zp50_colorchat>

#define PLUGIN "[ZP] Item: Multijump"
#define VERSION "1.0"
#define AUTHOR "twistedeuphoria"


#define ITEM_NAME "Khinh công cho Zombie"
#define ITEM_COST 10

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_ItemID

new g_multijump = 0

new jumpnum[33] = 0
new dojump = 0

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_ItemID = zp_ap_items_register(ITEM_NAME, ITEM_COST)
}

public zp_fw_ap_items_select_pre(id, itemid, ignorecost)
{
	if (itemid != g_ItemID)
		return ZP_ITEM_AVAILABLE;

	if (  flag_get(g_multijump, id)  )
		return ZP_ITEM_NOT_AVAILABLE;

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_ap_items_select_post(id, itemid, ignorecost)
{
	// This is not our item
	if (itemid != g_ItemID)
		return;

	flag_set(g_multijump, id);
}
public client_putinserver(id)
{
	jumpnum[id] = 0
	flag_unset(dojump, id)
}

public client_disconnected(id)
{
	flag_unset(g_multijump, id)
	jumpnum[id] = 0
	flag_unset(dojump, id)
}
public client_PreThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	if(!zp_core_is_zombie(id) ) return PLUGIN_CONTINUE;
	if(!flag_get(g_multijump, id) ) return PLUGIN_CONTINUE;
	new nbut = get_user_button(id)
	new obut = get_user_oldbutton(id)
	if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if(jumpnum[id] < 1)
		{
			flag_set(dojump, id)
			jumpnum[id]++
			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		jumpnum[id] = 0
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	if(!zp_core_is_zombie(id) ) return PLUGIN_CONTINUE;
	if(!flag_get(g_multijump, id) ) return PLUGIN_CONTINUE;
	if(flag_get(dojump, id))
	{
		new Float:velocity[3]
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = random_float(265.0,285.0)
		entity_set_vector(id,EV_VEC_velocity,velocity)
		flag_unset(dojump, id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
