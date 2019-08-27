#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>
#include <fun>
#include <zombieplague>
#include <zp50_items>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_colorchat>

// The sizes of models
#define PALLET_MINS Float:{ -27.260000, -22.280001, -22.290001 }
#define PALLET_MAXS Float:{  27.340000,  26.629999,  29.020000 }


// from fakemeta util by VEN
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
// this is mine
#define fm_drop_to_floor(%1) engfunc(EngFunc_DropToFloor,%1)

// cvars
new maxpallets, phealth;

// num of pallets with bags
new palletscout = 0;

/* Models for pallets with bags .
  Are available 2 models, will be set a random of them  */
new g_models[][] =
{
	"models/pallet_with_bags2.mdl",
	"models/pallet_with_bags.mdl"
}

new g_bolsas[33];


new const g_item_name[] = { "Túi cát" }
const g_item_bolsas = 0
new g_itemid_bolsas
/*************************************************************
************************* AMXX PLUGIN *************************
**************************************************************/


public plugin_init()
{
	/* Register the plugin */
	//register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_plugin("[ZP] Extra: SandBags", "1.1", "LARP")


	//g_itemid_bolsas = zp_register_extra_item(g_item_name, g_item_bolsas, ZP_TEAM_HUMAN)
	g_itemid_bolsas = zp_money_items_register(g_item_name, 12000)



	/* Register the cvars */
	maxpallets = register_cvar("zp_pb_limit","200"); // max number of pallets with bags
	phealth = register_cvar("zp_pb_health","200"); // set the health to a pallet with bags

	/* Game Events */
	register_event("HLTV","event_newround", "a","1=0", "2=0"); // it's called every on new round

	/* This is for menuz: */
	register_clcmd("say /pb","show_the_menu");
	register_clcmd("/pb","show_the_menu");

}


public plugin_precache()
{
	for(new i;i < sizeof g_models;i++)
		engfunc(EngFunc_PrecacheModel,g_models[i]);
}

public show_the_menu(id)
{
	// check if user isn't alive
	if( ! is_user_alive( id ) )
	{
		return PLUGIN_HANDLED;
	}

	if ( !zp_get_user_zombie(id) )
	{
		new title[34];
		formatex(title, charsmax(title), "[NTC] Túi cát [%d]", g_bolsas[id])
		new menu = menu_create(title, "menu_command")
		menu_additem(menu, "Đặt túi cát");

		menu_display( id, menu, 0 );

		// depends what you want, if is continue will appear on chat what the admin sayd
		return PLUGIN_HANDLED;
	}
	zp_colored_print(id, "Zombie không thể đặt túi cát");
	return PLUGIN_HANDLED;
}


public menu_command( id, menu, item )
{

	switch( item )
	{
		// place a pallet with bags
		case 0:
		{
			if ( !zp_get_user_zombie(id) )
			{
				new money = g_bolsas[id]
				if ( money < 1 )
				{
					zp_colored_print(id, "Hết túi cát để đặt");

					return PLUGIN_CONTINUE
				}
				g_bolsas[id]-= 1
				place_palletwbags(id);
				show_the_menu(id);
				return PLUGIN_CONTINUE
			}
			zp_colored_print(id, "Zombie không thể đặt túi cát");

			return PLUGIN_CONTINUE
		}

		// remove a pallet with bags
		/*case 1:
		{
			if ( !zp_get_user_zombie(id) )
			{
				new ent, body, class[32];
				get_user_aiming(id, ent, body);
				if (pev_valid(ent))
				{
					pev(ent, pev_classname, class, 31);

					if (equal(class, "amxx_pallets"))
					{
						g_bolsas[id]+= 1
						fm_remove_entity(ent);
					}

					else
						client_print(id, print_chat, "[ZP] You are not aiming at a pallet with bags");
				}
				else
					client_print(id, print_chat, "[ZP] You are not aiming at a valid entity !");

				show_the_menu(id,level,cid);
			}
		}
		*/

		// remove all pallets with bags
		/*case 2:
		{
			g_bolsas[id]= 0
			remove_allpalletswbags();
			client_print(id,print_chat,"[AMXX] You removed all pallets with bags !");
			show_the_menu(id,level,cid);
		}
			*/

	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}



public place_palletwbags(id)
{

	if( palletscout >= get_pcvar_num(maxpallets) )
	{
		zp_colored_print(id, "Nhắm tránh crash server nên chỉ có thể đặt tối đa %d túi trên toàn map", get_pcvar_num(maxpallets));

		return PLUGIN_HANDLED;
	}

	// create a new entity
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_wall"));


	// set a name to the entity
	set_pev(ent,pev_classname,"amxx_pallets");

	// set model
	engfunc(EngFunc_SetModel,ent,g_models[random(sizeof g_models)]);

	// register a new var. for origin
	static Float:xorigin[3];
	get_user_hitpoint(id,xorigin);


	// check if user is aiming at the air
	if(engfunc(EngFunc_PointContents,xorigin) == CONTENTS_SKY)
	{
		zp_colored_print(id, "Không đặt túi cát trên không được");
		return PLUGIN_HANDLED;
	}


	// set sizes
	static Float:p_mins[3], Float:p_maxs[3];
	p_mins = PALLET_MINS;
	p_maxs = PALLET_MAXS;
	engfunc(EngFunc_SetSize, ent, p_mins, p_maxs);
	set_pev(ent, pev_mins, p_mins);
	set_pev(ent, pev_maxs, p_maxs );
	set_pev(ent, pev_absmin, p_mins);
	set_pev(ent, pev_absmax, p_maxs );


	// set the rock of origin where is user placed
	engfunc(EngFunc_SetOrigin, ent, xorigin);


	// make the rock solid
	set_pev(ent,pev_solid,SOLID_BBOX); // touch on edge, block

	// set the movetype
	set_pev(ent,pev_movetype,MOVETYPE_FLY); // no gravity, but still collides with stuff

	// now the damage stuff, to set to take it or no
	// if you set the cvar "pallets_wbags_health" 0, you can't destroy a pallet with bags
	// else, if you want to make it destroyable, just set the health > 0 and will be
	// destroyable.
	new Float:p_cvar_health = get_pcvar_float(phealth);
	switch(p_cvar_health)
	{
		case 0.0 :
		{
			set_pev(ent,pev_takedamage,DAMAGE_NO);
		}

		default :
		{
			set_pev(ent,pev_health,p_cvar_health);
			set_pev(ent,pev_takedamage,DAMAGE_YES);
		}
	}


	static Float:rvec[3];
	pev(id,pev_v_angle,rvec);

	rvec[0] = 0.0;

	set_pev(ent,pev_angles,rvec);

	// drop entity to floor
	fm_drop_to_floor(ent);

	// num ..
	palletscout++;

	zp_colored_print(id, "Đã dặt túi cát. Còn %d túi", g_bolsas[id]);

	return PLUGIN_HANDLED;
}

/* ====================================================
get_user_hitpoin stock . Was maked by P34nut, and is
like get_user_aiming but is with floats and better :o
====================================================*/
stock get_user_hitpoint(id, Float:hOrigin[3])
{
	if ( ! is_user_alive( id ))
		return 0;

	new Float:fOrigin[3], Float:fvAngle[3], Float:fvOffset[3], Float:fvOrigin[3], Float:feOrigin[3];
	new Float:fTemp[3];

	pev(id, pev_origin, fOrigin);
	pev(id, pev_v_angle, fvAngle);
	pev(id, pev_view_ofs, fvOffset);

	xs_vec_add(fOrigin, fvOffset, fvOrigin);

	engfunc(EngFunc_AngleVectors, fvAngle, feOrigin, fTemp, fTemp);

	xs_vec_mul_scalar(feOrigin, 9999.9, feOrigin);
	xs_vec_add(fvOrigin, feOrigin, feOrigin);

	engfunc(EngFunc_TraceLine, fvOrigin, feOrigin, 0, id);
	global_get(glb_trace_endpos, hOrigin);

	return 1;
}


/* ====================================================
This is called on every round, at start up,
with HLTV logevent. So if the "pallets_wbags_nroundrem"
cvar is set to 1, all placed pallets with bugs will be
removed.
====================================================*/
public event_newround()
{
	remove_allpalletswbags();

}


/* ====================================================
This is a stock to help for remove all pallets with
bags placed . Is called on new round if the cvar
"pallets_wbags_nroundrem" is set 1.
====================================================*/
stock remove_allpalletswbags()
{
	new pallets = -1;
	while((pallets = fm_find_ent_by_class(pallets, "amxx_pallets")))
		fm_remove_entity(pallets);

	palletscout = 0;
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true

	return false
}


public zp_fw_money_items_select_pre(id, itemid) {
	if (itemid != g_itemid_bolsas) return ZP_ITEM_AVAILABLE;

	if( zp_core_is_zombie(id) ) return ZP_ITEM_DONT_SHOW;

	if( zp_class_sniper_get(id) || zp_class_survivor_get(id) ) return ZP_ITEM_NOT_AVAILABLE;

	return ZP_ITEM_AVAILABLE;

}

public zp_fw_money_items_select_post(id, itemid) {
	if (itemid != g_itemid_bolsas) return;

	if( zp_core_is_zombie(id) ) return;

	if( zp_class_sniper_get(id) || zp_class_survivor_get(id) ) return;

	g_bolsas[id]+= 3
	show_the_menu(id)

	zp_colored_print(id, "Chat /pb để có thể mở lại menu đặt Túi cát");
	zp_colored_print(id, "Nếu muốn bấm nhấn, mở Console [~] rồi ghi lệnh bind l ^"say /pb^" và bấm L để mở menu");
}

