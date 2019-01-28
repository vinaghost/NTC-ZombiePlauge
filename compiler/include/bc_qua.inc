enum _: {
	HAKI = 0,
	TRAIACQUY,
	KHAC
}

native bc_qua_register(name[], type)
native bc_qua_random(id)
native bc_qua_custom_hand(id, bool)

forward bc_lanhqua_pre(id, id_qua)
forward bc_lanhqua_post(id, id_qua)

