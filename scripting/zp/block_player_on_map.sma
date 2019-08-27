#include <amxmodx>

#define PLUGIN "Block player on map"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    set_msg_block( get_user_msgid( "Radar" ) , BLOCK_SET );
}
