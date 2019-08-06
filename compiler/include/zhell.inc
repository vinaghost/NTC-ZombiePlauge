#if defined _ZHELL_
  #endinput
#endif

#define _ZHELL_

forward zhell_spawn_zombie(id);
forward zhell_spawn_human(id);

forward zhell_killed_zombie(victim, attacker);
forward zhell_killed_human(victim, attacker);

forward zhell_last_human_pre(id);
forward zhell_last_human_post(id);
forward zhell_last_zombie_pre(id);
forward zhell_last_zombie_post(id);

forward zhell_round_start();
forward zhell_round_end(team_win);

native zhell_is_zombie(id);

native zhell_get_count_human();
native zhell_get_count_zombie();


//zhell_levelZombie
native zhell_get_level();

native zhell_get_zombie_health();
native Float:zhell_get_zombie_speed();
native zhell_get_boss();
native zhell_get_boss_health();
native Float:zhell_get_boss_speed();

native zhell_get_zombie_total();
native zhell_get_zombie_last();


//zhell_loginsystem
forward zhell_client_connected(id);
forward zhell_client_spec(id, spec);

native zhell_get_index(id);

//zhell_pointsystem

forward zhell_point_reward(id, point)

native zhell_point_set(id, point)
native zhell_point_get(id)
native zhell_point_add(id, point)


//zhell_weapon

forward zhell_wpn_select_pre(id, itemid, ignorecost);
forward zhell_wpn_select_post(id, itemid, ignorecost);
forward zhell_wpn_remove(id, itemid)


native zhell_weapons_register(const name[], cost, type)
native zhell_weapons_get_id(const real_name[])
native zhell_weapons_get_name(itemid, name[], len);
native zhell_weapons_get_cost(itemid);
native zhell_weapons_get_type(itemid);
native zhell_weapons_force_buy(id, itemid, ignorecost = false);
