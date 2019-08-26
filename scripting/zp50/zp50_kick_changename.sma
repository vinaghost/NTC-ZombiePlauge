#include <amxmodx>


#define PLUGIN "Anti change name"
#define VERSION "1.0"
#define AUTHOR "VINAGHOST"


public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
}
public client_infochanged(id)
{
  new new_name[32];
  new old_name[32];

  get_user_info(id, "name", new_name, 31);
  get_user_name(id, old_name, 31);

  if(!equal(new_name, old_name))
  {
    server_cmd("kick #%i ^"Bạn vừa đổi tên. Xin lỗi vì sự bất tiện này^"", get_user_userid(id));

  }
}
