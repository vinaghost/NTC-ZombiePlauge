#pragma compress 1

//#define TRACE_BULLETS

#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <xs>

#include <reapi>

#define PLUGIN "CSO Weapon: OICW"
#define VERSION "1.0"
#define AUTHOR "Bim Bim Cay"

//**********************************************
//* Resources                                  *
//**********************************************

// Models
#define MODEL_VIEW		"models/v_oicw.mdl"
#define MODEL_WORLD		"models/w_oicw.mdl"
#define MODEL_PLAYER		"models/p_oicw.mdl"
#define MODEL_GRENADE		"models/s_oicw.mdl"

#define SUBMODEL_WORLD		-1

// Sounds
#define SOUND_FIRE		"weapons/oicw-1.wav"
#define SOUND_SHOOT_NADE1	"weapons/oicw_grenade_shoot1.wav"
#define SOUND_SHOOT_NADE2	"weapons/oicw_grenade_shoot2.wav"
#define SOUND_FOLEY1		"weapons/oicw_foley1.wav"
#define SOUND_FOLEY2		"weapons/oicw_foley2.wav"
#define SOUND_FOLEY3		"weapons/oicw_foley3.wav"
#define SOUND_MOVE_CARBINE	"weapons/oicw_move_carbine.wav"
#define SOUND_MOVE_GRENADE	"weapons/oicw_move_grenade.wav"

// Sprites
#define SPRITE_MUZZLEFLASH	"sprites/muzzleflash12.spr"

#define SPRITE_SMOKE		"sprites/steam1.spr"
#define SPRITE_EXPLOSION	"sprites/WXplo1.spr"
#define SPRITE_FIREBALL		"sprites/zerogxplode.spr"
#define SPRITE_TRAIL		"sprites/laserbeam.spr"
#define SPRITE_BUBBLE		"sprites/bubble.spr"

#define WEAPON_HUD_TXT		"sprites/weapon_oicw.txt"
#define WEAPON_HUD_ITEM		"sprites/640hud79.spr"
#define WEAPON_HUD_AMMO1	"sprites/640hud7.spr"
#define WEAPON_HUD_AMMO2	"sprites/640hud2.spr"
#define WEAPON_HUD_CROSSHAIR	"sprites/scope_vip_grenade.spr"

//**********************************************
//* Animations.                                *
//**********************************************

#define ANIM_IDLE		0
#define ANIM_SHOOT1		1
#define ANIM_SHOOT2		2
#define ANIM_SHOOT3		3
#define ANIM_RELOAD		4
#define ANIM_DRAW		5
#define ANIM_GRENADEIDLE	6
#define ANIM_GRENADESHOOT1	7
#define ANIM_GRENADESHOOT2	8
#define ANIM_SWITCHGRENADE	9
#define ANIM_SWITCHCARBINE	10

#define ANIM_EXTENSION 		"carbine"

//**********************************************
//* Events                                     *
//**********************************************

#define EVENT_USP		"events/usp.sc"
#define EVENT_M4A1		"events/m4a1.sc"
#define EVENT_KNIFE		"events/knife.sc"

//**********************************************
//* Private Data Offsets.                      *
//**********************************************

// Linux extra offsets
#define extra_offset_weapon		4
#define extra_offset_player		5

// CWeaponBox
#define m_rgpPlayerItems2		34

// CBasePlayerItem
#define m_pPlayer			41
#define m_pNext				42

// CBasePlayerWeapon
#define	m_flStartThrow 			30
#define m_flReleaseThrow 		31
#define m_iSwing			32
#define m_iId 				43
#define m_fFireOnEmpty 			45
#define m_flNextPrimaryAttack		46
#define m_flNextSecondaryAttack		47
#define m_flTimeWeaponIdle		48
#define m_iPrimaryAmmoType		49
#define m_iSecondaryAmmoType 		50
#define m_iClip				51
#define m_fInReload			54
#define m_fInSpecialReload		55
#define m_iDefaultAmmo 			56
#define m_fMaxSpeed 			58
#define m_bDelayFire 			59
#define m_iDirection			60
#define m_flAccuracy 			62
#define m_flLastFireTime 		63
#define m_iShotsFired			64
#define m_flFamasShoot 			71
#define m_iFamasShotsFired 		72
#define m_fBurstSpread 			73
#define m_iWeaponState			74
#define m_flNextReload 			75
#define m_flDecreaseShotsFired 		76
#define m_bStartedArming   		78
#define m_bBombPlacedAnimation          79
#define m_fArmedTime    		80

// CSprite
#define m_maxFrame 			35

// CBaseMonster
#define m_flNextAttack			83
#define m_iTeam				114

// CBasePlayer
#define random_seed 			96
#define m_hObserverTarget  		98
#define m_flVelocityModifier 		108
#define m_iLastZoom 			109
#define m_fResumeZoom      		110
#define m_flEjectBrass 			111
#define m_bIgnoreRadio 			193
#define m_iWeaponVolume 		239
#define m_iWeaponFlash 			241
#define m_iFOV				363
#define	m_iHideHUD			361
#define	m_iClientHideHUD		362
#define m_rgpPlayerItems		367
#define m_pActiveItem			373
#define	m_pClientActiveItem		374
#define m_rgAmmo			376
#define m_szAnimExtention		492

// CbaseGrenade
#define m_bIsC4            		96
#define m_bStartDefuse        		97	//?
#define m_flDefuseCountDown 		99
#define m_flC4Blow			100
#define m_flNextFreqInterval    	101
#define m_flNextBeep        		102
#define m_flNextFreq        		103
#define m_sBeepName        		104
#define m_fAttenu        		105
#define m_flNextBlink     	        106
#define m_fNextDefuse			107 	//?
#define m_bJustBlew 		 	108
#define m_iCurWave 			110	//?
#define m_pentCurBombTarget 		111
#define m_SGSmoke			112
#define	m_bLightSmoke			114

//**********************************************
//* Some macroses.                             *
//**********************************************

#define MDLL_Spawn(%0)			dllfunc(DLLFunc_Spawn, %0)
#define MDLL_Touch(%0,%1)		dllfunc(DLLFunc_Touch, %0, %1)
#define MDLL_USE(%0,%1)			dllfunc(DLLFunc_Use, %0, %1)

#define SET_MODEL(%0,%1)		engfunc(EngFunc_SetModel, %0, %1)
#define SET_ORIGIN(%0,%1)		engfunc(EngFunc_SetOrigin, %0, %1)

#define PRECACHE_MODEL(%0)		engfunc(EngFunc_PrecacheModel, %0)
#define PRECACHE_SOUND(%0)		engfunc(EngFunc_PrecacheSound, %0)
#define PRECACHE_GENERIC(%0)		engfunc(EngFunc_PrecacheGeneric, %0)

#define MESSAGE_BEGIN(%0)		engfunc(EngFunc_MessageBegin, %0)
#define MESSAGE_END()			message_end()

#define WRITE_ANGLE(%0)			engfunc(EngFunc_WriteAngle, %0)
#define WRITE_BYTE(%0)			write_byte(%0)
#define WRITE_COORD(%0)			engfunc(EngFunc_WriteCoord, %0)
#define WRITE_STRING(%0)		write_string(%0)
#define WRITE_SHORT(%0)			write_short(%0)

#define REMOVE_ENTITY(%0) 		set_pev(%0, pev_flags, pev(%0, pev_flags) | FL_KILLME)

#define INSTANCE(%0)			((%0 == -1) ? 0 : %0)
#define IsValidPev(%0) 			(pev_valid(%0) == 2)
#define IsObserver(%0) 			pev(%0,pev_iuser1)
#define OBS_IN_EYE 			4

#define EMIT_SOUND(%0)			engfunc(EngFunc_EmitSound, %0)
#define EMIT_AMBIENT_SOUND(%0)		engfunc(EngFunc_EmitAmbientSound, %0)

#define NUMBER_OF_ENTITIES()		engfunc(EngFunc_NumberOfEntities)

//**********************************************
//* Messages.                                  *
//**********************************************

#define MESSAGE_HIDEWEAPON		"HideWeapon"
#define MESSAGE_WEAPONLIST		"WeaponList"
#define MESSAGE_AMMOPICKUP		"AmmoPickup"
#define MESSAGE_RELOADSOUND		"ReloadSound"
#define MESSAGE_DEATHMSG		"DeathMsg"
#define MESSAGE_SCREENSHAKE		"ScreenShake"

#define MESSAGEID_WEAPONLIST		78

//**********************************************
//* Weapon state                               *
//**********************************************

#define WPNSTATE_OICW_GRENADEMODE 	(1<<0)

//**********************************************
//* Bullet types                               *
//**********************************************

#define BULLET_NONE  			0
#define	BULLET_PLAYER_9MM		1
#define	BULLET_PLAYER_MP5		2
#define	BULLET_PLAYER_357		3
#define	BULLET_PLAYER_BUCKSHOT		4
#define	BULLET_PLAYER_CROWBAR		5

#define	BULLET_MONSTER_9MM		6
#define	BULLET_MONSTER_MP5		7
#define	BULLET_MONSTER_12MM		8

#define	BULLET_PLAYER_45ACP		9
#define	BULLET_PLAYER_338MAG		10
#define	BULLET_PLAYER_762MM		11
#define	BULLET_PLAYER_556MM		12
#define	BULLET_PLAYER_50AE		13
#define	BULLET_PLAYER_57MM		14
#define	BULLET_PLAYER_357SIG		15

//**********************************************
//* Hit groups                                 *
//**********************************************

#define HITGROUP_GENERIC 		0
#define	HITGROUP_HEAD			1
#define	HITGROUP_CHEST			2
#define HITGROUP_STOMACH		3
#define HITGROUP_LEFTARM		4
#define HITGROUP_RIGHTARM		5
#define HITGROUP_LEFTLEG		6
#define HITGROUP_RIGHTLEG		7
#define HITGROUP_SHIELD			8

//**********************************************
//* Hit result                                 *
//**********************************************

#define RESULT_HIT_NONE  		0
#define	RESULT_HIT_PLAYER		1
#define	RESULT_HIT_WORLD		2

//**********************************************
//* Ammo types                                 *
//**********************************************

#define AMMOID_OFF  			-1
#define AMMOID_NONE  			0
#define	AMMOID_338MAGNUM		1
#define	AMMOID_762NATO			2
#define	AMMOID_556NATOBOX		3
#define	AMMOID_556NATO			4
#define	AMMOID_BUCKSHOT			5
#define	AMMOID_45ACP			6
#define	AMMOID_57MM			7
#define	AMMOID_50AE			8
#define	AMMOID_357SIG			9
#define	AMMOID_9MM			10
#define	AMMOID_FLASHBANG		11
#define	AMMOID_HEGRENADE		12
#define	AMMOID_SMOKEGRENADE		13
#define	AMMOID_C4			14
#define AMMOID_OICWGRENADE		15

//**********************************************
//* Item Flags                                 *
//**********************************************

#define ITEM_FLAG_NONE			0
#define ITEM_FLAG_SELECTONEMPTY		(1<<0)
#define ITEM_FLAG_NOAUTORELOAD		(1<<1)
#define ITEM_FLAG_NOAUTOSWITCHEMPTY	(1<<2)
#define ITEM_FLAG_LIMITINWORLD		(1<<3)
#define ITEM_FLAG_EXHAUSTIBLE		(1<<4)

//**********************************************
//* Hide Hud Flags                             *
//**********************************************

#define HUD_HIDE_CROSS 			(1<<6)
#define HUD_DRAW_CROSS 			(1<<7)

//**********************************************
//* Entity Config                              *
//**********************************************

#define MUZZLEFLASH_CLASSNAME		"OICW_MuzzleFlash"
#define MUZZLE_INTOLERANCE		100

#define GRENADE_CLASSNAME		"OICW_Grenade"
#define GRENADE_INTOLERANCE 		100

//**********************************************
//* Weapon Volume                              *
//**********************************************

#define LOUD_GUN_VOLUME			1000
#define NORMAL_GUN_VOLUME		600
#define QUIET_GUN_VOLUME		200

//**********************************************
//* Weapon Flash                               *
//**********************************************

#define BRIGHT_GUN_FLASH		512
#define NORMAL_GUN_FLASH		256
#define DIM_GUN_FLASH			128

//**********************************************
//* Weapon Config                              *
//**********************************************

// Weapon replace
#define WEAPON_NAME 			"weapon_oicw"
#define WEAPON_REFERANCE		"weapon_m4a1"

// Ammo Id
#define WEAPON_PRIMARYAMMOID		AMMOID_556NATO
#define WEAPON_SECONDARYAMMOID		AMMOID_OICWGRENADE

// Bullet type
#define WEAPON_BULLETTYPE		BULLET_PLAYER_556MM

// Speed
#define WEAPON_MAXSPEED			230.0

// Range
#define WEAPON_RANGE_MODIFIER		0.97

// Damage
#define WEAPON_BULLET_DAMAGE		100.0

// Range
#define WEAPON_SHOOT_RANGE		8192.0

// Penetration
#define WEAPON_BULLET_PENETRATION	2

// Delay Time
#define WEAPON_ATTACK1_INTERVAL		0.087
#define WEAPON_ATTACK2_INTERVAL		2.9
#define WEAPON_RELOAD_TIME		2.9
#define WEAPON_CHANGE_TIME		1.33

// Clip
#define WEAPON_MAX_AMMO			90

#define WEAPON_MAX_CLIP			30
#define WEAPON_DEFAULT_CLIP		30

#define WEAPON_MAX_EXTRAAMMO		10

// Paintshock
#define WEAPON_VELOCITYMODIFIER		0.5

// Accuracy and Recoil
#define WEAPON_ACCURACYDEFAULT		0.2
#define WEAPON_ACCURACY			220.0, 0.3
#define WEAPON_ACCURACYRANGE		0.2, 1.0

#define WEAPON_ACCURACYMULTINOTONGROUND	0.4
#define WEAPON_ACCURACYMULTIRUNINNG	0.07
#define WEAPON_ACCURACYMULTI		0.02

#define WEAPON_SPREADNOTONGROUND	0.035
#define WEAPON_SPREADRUNNING		0.035
#define WEAPON_SPREAD			0.0

#define WEAPON_SPEADRUNNINGACTIVATE	140.0

#define WEAPON_KICKBACKWALKING  	1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7
#define WEAPON_KICKBACKNOTONGROUND 	1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6
#define WEAPON_KICKBACKDUCKING		0.5, 0.2, 0.15, 0.01, 3.0, 2.0, 7
#define WEAPON_KICKBACK			0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7

#define WEAPON_SHOOTNADEPUNCHANGLE	0.0
#define WEAPON_SHOOTNADESHAKE		0

// Grenade
#define GRENADE_SPAWN_ORIGIN		28.0, 3.5, -5.0
#define GRENADE_DAMAGE			150.0
#define GRENADE_RANGE			200.0
#define GRENADE_SPEED			900.0
#define GRENADE_GRAVITY			1.0
#define GRENADE_ANGLE			-7.5
#define GRENADE_MOVETYPE		MOVETYPE_BOUNCE
#define GRENADE_KNOCKBACK		380.0
#define GRENADE_LIFETIME		2.5

// Fov
#define WEAPON_DEFAULT_FOV		90

// Item flag
#define WEAPON_FLAG			ITEM_FLAG_NONE

// Reload sound
#define WEAPON_DISTANCE_RELOADSOUND	512.0

// Weapon Volume
#define WEAPON_VOLUME			NORMAL_GUN_VOLUME

// Weapon Flash
#define WEAPON_FLASH			BRIGHT_GUN_FLASH

// Muzzle Flash
#define MUZZLEFLASH_SPEED		0.1
#define MUZZLEFLASH_SCALE		0.1
#define MUZZLEFLASH_BRIGHTNESS		100.0
#define MUZZLEFLASH_ATTACHMENT		3
#define MUZZLEFLASH_FRAMES		5
#define MUZZLEFLASH_RANDOMANGLES	-180.0, 180.0

//**********************************************
//* Vars                                       *
//**********************************************

// Weapon's key
new g_iszWeaponKey

// Sprite effect
new g_FireBall_SprId, g_Explode_SprId, g_Smoke_SprId, g_Trail_SprId, g_Bubble_SprId

// Events
new g_EventId_M4A1, g_EventId_Knife

// Message
new g_MsgId_HideWeapon, g_MsgId_WeaponList, g_MsgId_AmmoPickup, g_MsgId_ScreenShake, g_MsgId_ReloadSound, g_MsgId_DeathMsg

// Decal
new g_Decal_Scorch1, g_Decal_Scorch2

//**********************************************
//* Plugin Init                                *
//**********************************************

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	// Event
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")

	// Forward
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_SetModel, "fw_SetModel")

	// Think
	register_think(GRENADE_CLASSNAME, "fw_Grenade_Think")
	register_think(MUZZLEFLASH_CLASSNAME, "fw_MuzzleFlash_Think")

	register_touch(GRENADE_CLASSNAME, "*", "fw_Grenade_Touch")

	// Ham
	RegisterHam(Ham_Spawn, "weaponbox", "fw_Weaponbox_Spawn_Post", 1)
	RegisterHam(Ham_CS_RoundRespawn, "player", "fw_Player_Spawn_Post", 1)

	RegisterHam(Ham_Item_Deploy, WEAPON_REFERANCE, "fw_Item_Deploy")
	RegisterHam(Ham_Item_Holster, WEAPON_REFERANCE, "fw_Item_Holster")
	RegisterHam(Ham_Weapon_Reload, WEAPON_REFERANCE, "fw_Weapon_Reload")
	RegisterHam(Ham_Item_PostFrame, WEAPON_REFERANCE, "fw_Item_PostFrame")
	RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_REFERANCE, "fw_Weapon_WeaponIdle")
	RegisterHam(Ham_Item_AddToPlayer, WEAPON_REFERANCE, "fw_Item_AddToPlayer_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_REFERANCE, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, WEAPON_REFERANCE, "fw_Weapon_SecondaryAttack")
	RegisterHam(Ham_CS_Item_GetMaxSpeed, WEAPON_REFERANCE, "fw_Item_GetMaxSpeed")

	RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDamage_Post", 1)

	// Message Hook
	Message_Hook(0)

	// Client Commands
	register_clcmd("say /get", "Get_All")
	register_clcmd("say /getweapon", "Get_Weapon")
	register_clcmd("say /getammo", "Get_Ammo")
}

//**********************************************
//* Precache                                   *
//**********************************************

public plugin_precache()
{
	Weapon_OnPrecache()

	Message_Hook(1)

	g_iszWeaponKey = engfunc(EngFunc_AllocString, WEAPON_NAME)

	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)

	g_Decal_Scorch1 = engfunc(EngFunc_DecalIndex, "{scorch1")
	g_Decal_Scorch2 = engfunc(EngFunc_DecalIndex, "{scorch2")
}

Weapon_OnPrecache()
{
	PRECACHE_MODEL(MODEL_VIEW)
	PRECACHE_MODEL(MODEL_WORLD)
	PRECACHE_MODEL(MODEL_PLAYER)
	PRECACHE_MODEL(MODEL_GRENADE)

	PRECACHE_SOUND(SOUND_FIRE)
	PRECACHE_SOUND(SOUND_SHOOT_NADE1)
	PRECACHE_SOUND(SOUND_SHOOT_NADE2)
	PRECACHE_SOUND(SOUND_FOLEY1)
	PRECACHE_SOUND(SOUND_FOLEY2)
	PRECACHE_SOUND(SOUND_FOLEY3)
	PRECACHE_SOUND(SOUND_MOVE_CARBINE)
	PRECACHE_SOUND(SOUND_MOVE_GRENADE)

	PRECACHE_GENERIC(WEAPON_HUD_TXT)
	PRECACHE_GENERIC(WEAPON_HUD_ITEM)
	PRECACHE_GENERIC(WEAPON_HUD_AMMO1)
	PRECACHE_GENERIC(WEAPON_HUD_AMMO2)
	PRECACHE_GENERIC(WEAPON_HUD_CROSSHAIR)


	PRECACHE_MODEL(SPRITE_MUZZLEFLASH)

	g_FireBall_SprId =  PRECACHE_MODEL(SPRITE_FIREBALL)
	g_Explode_SprId =  PRECACHE_MODEL(SPRITE_EXPLOSION)
	g_Smoke_SprId = PRECACHE_MODEL(SPRITE_SMOKE)
	g_Trail_SprId = PRECACHE_MODEL(SPRITE_TRAIL)
	g_Bubble_SprId = PRECACHE_MODEL(SPRITE_BUBBLE)
}

public fw_PrecacheEvent_Post(Type, Resource[])
{
	if(equal(Resource, EVENT_M4A1))
	{
		g_EventId_M4A1 = get_orig_retval()
	}

	if(equal(Resource, EVENT_KNIFE))
	{
		g_EventId_Knife = get_orig_retval()
	}
}

//**********************************************
//* Message Hook.                              *
//**********************************************

Message_Hook(GetWeaponList)
{
	if(GetWeaponList)
	{
		g_MsgId_WeaponList = MESSAGEID_WEAPONLIST

		register_message(g_MsgId_WeaponList, "MsgHook_WeaponList")
	}
	else
	{
		g_MsgId_ReloadSound = get_user_msgid(MESSAGE_RELOADSOUND)
		g_MsgId_AmmoPickup = get_user_msgid(MESSAGE_AMMOPICKUP)
		g_MsgId_HideWeapon = get_user_msgid(MESSAGE_HIDEWEAPON)
		g_MsgId_DeathMsg = get_user_msgid(MESSAGE_DEATHMSG)
		g_MsgId_ScreenShake = get_user_msgid(MESSAGE_SCREENSHAKE)

		register_message(g_MsgId_DeathMsg, "MsgHook_Death")
	}
}

//**********************************************
//* Commands                                   *
//**********************************************

public Get_All(iPlayer)
{
	Weapon_Give(iPlayer)
	Ammo_Give(iPlayer)
}

public Get_Weapon(iPlayer)
{
	Weapon_Give(iPlayer)
}

public Get_Ammo(iPlayer)
{
	Ammo_Give(iPlayer)
}

//**********************************************
//* Block client weapon.                       *
//**********************************************

public fw_UpdateClientData_Post(iPlayer, iSendWeapons, CD_Handle)
{
	static iActiveItem; iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, extra_offset_player)

	if(!IsValidPev(iActiveItem) || !IsCustomItem(iActiveItem))
		return

	set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001)
}

//**********************************************
//* Weaponbox world model.                     *
//**********************************************

public fw_Weaponbox_Spawn_Post(iWeaponBox)
{
	if(IsValidPev(iWeaponBox))
	{
		state (IsValidPev(pev(iWeaponBox, pev_owner))) WeaponBox: Enabled
	}
}

public fw_SetModel(iEntity) <WeaponBox: Enabled>
{
	state WeaponBox: Disabled

	if(!IsValidPev(iEntity))
		return FMRES_IGNORED

	#define MAX_ITEM_TYPES	6

	for(new i, iItem; i < MAX_ITEM_TYPES; i++)
	{
		iItem = get_pdata_cbase(iEntity, m_rgpPlayerItems2 + i, extra_offset_weapon)

		if(IsValidPev(iItem) && IsCustomItem(iItem))
		{
			SET_MODEL(iEntity, MODEL_WORLD)

			set_pev(iEntity, pev_body, SUBMODEL_WORLD)

			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}

public fw_SetModel() </* Empty statement */>
{
	/*  Fallback  */
	return FMRES_IGNORED
}
public fw_SetModel() <WeaponBox: Disabled>
{
	/* Do nothing */
	return FMRES_IGNORED
}

//**********************************************
//* Ham hook                                   *
//**********************************************

public fw_Item_Deploy(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnDeploy(iItem)

	return HAM_SUPERCEDE
}

public fw_Item_Holster(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnHolster(iItem)

	return HAM_SUPERCEDE
}

public fw_Item_PostFrame(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnPostFrame(iItem)

	return HAM_IGNORED
}

public fw_Weapon_Reload(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnReload(iItem)

	return HAM_SUPERCEDE
}

public fw_Weapon_WeaponIdle(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnIdle(iItem)

	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnPrimaryAttack(iItem)

	return HAM_SUPERCEDE
}

public fw_Weapon_SecondaryAttack(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	Weapon_OnSecondaryAttack(iItem)

	return HAM_SUPERCEDE
}

public fw_Item_GetMaxSpeed(iItem)
{
	if(!IsCustomItem(iItem))
		return HAM_IGNORED

	SetHamReturnFloat(WEAPON_MAXSPEED)

	return HAM_SUPERCEDE
}

//**********************************************
//* Weapon list update.                        *
//**********************************************
Weapon_OnDeploy(iItem)
{
	set_pdata_float(iItem, m_flAccuracy, WEAPON_ACCURACYDEFAULT, extra_offset_weapon)
	set_pdata_int(iItem, m_iShotsFired, 0, extra_offset_weapon)
	set_pdata_int(iItem, m_bDelayFire, 0, extra_offset_weapon)

	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)

	Weapon_DefaultDeploy(iItem, iPlayer, MODEL_VIEW, MODEL_PLAYER, ANIM_DRAW, ANIM_EXTENSION)

	// Cancel any reload in progress.
	set_pdata_int(iItem, m_fInReload, 0, extra_offset_weapon)

	ChangeCrosshairMode(iPlayer, 0)
	set_pdata_int(iItem, m_iWeaponState, get_pdata_int(iItem, m_iWeaponState, extra_offset_weapon) &~ WPNSTATE_OICW_GRENADEMODE, extra_offset_weapon)
}

Weapon_OnHolster(iItem)
{
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)

	set_pev(iPlayer, pev_viewmodel, 0)
	set_pev(iPlayer, pev_weaponmodel, 0)

	// Cancel any reload in progress.
	set_pdata_int(iItem, m_fInReload, 0, extra_offset_weapon)

	ChangeCrosshairMode(iPlayer, 0)
	set_pdata_int(iItem, m_iWeaponState, get_pdata_int(iItem, m_iWeaponState, extra_offset_weapon) &~ WPNSTATE_OICW_GRENADEMODE, extra_offset_weapon)
}

Weapon_OnIdle(iItem)
{
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iItem)

	if(get_pdata_float(iItem, m_flTimeWeaponIdle, extra_offset_weapon) > 0.0)
		return

	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)

	set_pdata_float(iItem, m_flTimeWeaponIdle, 10.0, extra_offset_weapon)

	if(get_pdata_int(iItem, m_iWeaponState, extra_offset_weapon) & WPNSTATE_OICW_GRENADEMODE)
	{
		Weapon_SendAnim(iPlayer, iItem, ANIM_GRENADEIDLE)
	}
	else
	{
		Weapon_SendAnim(iPlayer, iItem, ANIM_IDLE)
	}
}

Weapon_OnReload(iItem)
{
	if(get_pdata_int(iItem, m_iWeaponState, extra_offset_weapon) & WPNSTATE_OICW_GRENADEMODE)
		return

	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)

	if(Weapon_DefaultReload(iItem, iPlayer, WEAPON_MAX_CLIP, ANIM_RELOAD, WEAPON_RELOAD_TIME))
	{
		static szAnimation[64]

		if(pev(iPlayer, pev_flags) & FL_DUCKING)
		{
			formatex(szAnimation, charsmax(szAnimation), "crouch_reload_%s", ANIM_EXTENSION)
		}
		else
		{
			formatex(szAnimation, charsmax(szAnimation), "ref_reload_%s", ANIM_EXTENSION)
		}

		Player_SetAnimation(iPlayer, szAnimation)

		set_pdata_float(iItem, m_flAccuracy, WEAPON_ACCURACYDEFAULT, extra_offset_weapon)
		set_pdata_int(iItem, m_iShotsFired, 0, extra_offset_weapon)
	}
}

Weapon_OnPostFrame(iItem)
{
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)

	// Complete reload
	if(get_pdata_int(iItem, m_fInReload, extra_offset_weapon))
	{
		static iClip; iClip = get_pdata_int(iItem, m_iClip, extra_offset_weapon)
		static iPrimaryAmmoIndex; iPrimaryAmmoIndex = PrimaryAmmoIndex(iItem)
		static iAmmoPrimary; iAmmoPrimary = GetAmmoInventory(iPlayer, iPrimaryAmmoIndex)
		static iAmount; iAmount = min(WEAPON_MAX_CLIP - iClip, iAmmoPrimary)

		set_pdata_int(iItem, m_iClip, iClip + iAmount, extra_offset_weapon)
		set_pdata_int(iItem, m_fInReload, 0, extra_offset_weapon)

		SetAmmoInventory(iPlayer, iPrimaryAmmoIndex, iAmmoPrimary - iAmount)
	}
}

Weapon_OnSecondaryAttack(iItem)
{
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)
	static WeaponMode; WeaponMode = get_pdata_int(iItem, m_iWeaponState, extra_offset_weapon)

	if(WeaponMode & WPNSTATE_OICW_GRENADEMODE)
	{
		WeaponMode &= ~WPNSTATE_OICW_GRENADEMODE

		ChangeCrosshairMode(iPlayer, 0)
		Weapon_SendAnim(iPlayer, iItem, ANIM_SWITCHCARBINE)
	}
	else
	{
		WeaponMode |= WPNSTATE_OICW_GRENADEMODE

		ChangeCrosshairMode(iPlayer, 1)
		Weapon_SendAnim(iPlayer, iItem, ANIM_SWITCHGRENADE)
	}

	set_pdata_int(iItem, m_iWeaponState, WeaponMode, extra_offset_weapon)

	set_pdata_float(iPlayer, m_flNextAttack, WEAPON_CHANGE_TIME, extra_offset_player)
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_CHANGE_TIME, extra_offset_weapon)
}

Weapon_OnPrimaryAttack(iItem)
{
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon)

	if(get_pdata_int(iItem, m_iWeaponState, extra_offset_weapon) & WPNSTATE_OICW_GRENADEMODE)
	{
		OICW_FireGrenade(iItem, iPlayer, WEAPON_ATTACK2_INTERVAL)
	}
	else
	{
		static Float:flAccuracy; flAccuracy = get_pdata_float(iItem, m_flAccuracy, extra_offset_weapon)

		if(!(pev(iPlayer, pev_flags) & FL_ONGROUND))
		{
			OICWFire(iItem, iPlayer, WEAPON_SPREADNOTONGROUND + (WEAPON_ACCURACYMULTINOTONGROUND * flAccuracy), WEAPON_ATTACK1_INTERVAL)
		}
		else
		{
			static Float:Velocity[3]; pev(iPlayer, pev_velocity, Velocity)

			if(xs_vec_len_2d(Velocity) > WEAPON_SPEADRUNNINGACTIVATE)
			{
				OICWFire(iItem, iPlayer, WEAPON_SPREADRUNNING + (WEAPON_ACCURACYMULTIRUNINNG * flAccuracy), WEAPON_ATTACK1_INTERVAL)
			}
			else
			{
				OICWFire(iItem, iPlayer, WEAPON_SPREAD + (WEAPON_ACCURACYMULTI * flAccuracy), WEAPON_ATTACK1_INTERVAL)
			}
		}
	}
}

OICW_FireGrenade(iItem, iPlayer, Float:flNextAttack)
{
	static iSecondaryAmmoIndex; iSecondaryAmmoIndex = SecondaryAmmoIndex(iItem)
	static iAmmoSecondary; iAmmoSecondary = GetAmmoInventory(iPlayer, iSecondaryAmmoIndex)

	if(iAmmoSecondary <= 0)
	{
		// No ammo, play empty sound and cancel
		if(get_pdata_int(iItem, m_fFireOnEmpty, extra_offset_weapon))
		{
			ExecuteHamB(Ham_Weapon_PlayEmptySound, iItem)
			set_pdata_float(iItem, m_flNextPrimaryAttack, 0.2, extra_offset_weapon)
		}

		return
	}

	iAmmoSecondary--
	SetAmmoInventory(iPlayer, iSecondaryAmmoIndex, iAmmoSecondary)

	static szAnimation[64]

	if(pev(iPlayer, pev_flags) & FL_DUCKING)
	{
		formatex(szAnimation, charsmax(szAnimation), "crouch_shoot_%s", ANIM_EXTENSION)
	}
	else
	{
		formatex(szAnimation, charsmax(szAnimation), "ref_shoot_%s", ANIM_EXTENSION)
	}

	Player_SetAnimation(iPlayer, szAnimation)

	set_pdata_float(iItem, m_flNextPrimaryAttack, flNextAttack, extra_offset_weapon)
	set_pdata_float(iItem, m_flNextSecondaryAttack, flNextAttack, extra_offset_weapon)

	if(iAmmoSecondary)
	{
		Weapon_SendAnim(iPlayer, iItem, ANIM_GRENADESHOOT1)

		set_pdata_float(iItem, m_flTimeWeaponIdle, 3.0, extra_offset_weapon)

		EMIT_SOUND(iPlayer, CHAN_WEAPON, SOUND_SHOOT_NADE1, 0.9, ATTN_NORM, 0, PITCH_NORM)
	}
	else
	{
		Weapon_SendAnim(iPlayer, iItem, ANIM_GRENADESHOOT2)

		set_pdata_float(iItem, m_flTimeWeaponIdle, 1.0, extra_offset_weapon)

		EMIT_SOUND(iPlayer, CHAN_WEAPON, SOUND_SHOOT_NADE2, 0.9, ATTN_NORM, 0, PITCH_NORM)
	}

	static ShakePower; ShakePower = WEAPON_SHOOTNADESHAKE

	if(ShakePower > 0)
	{
		UTIL_ScreenShake(iPlayer, ShakePower, 1, ShakePower)
	}

	PunchAxis(iPlayer, WEAPON_SHOOTNADEPUNCHANGLE, 0.0)

	query_client_cvar(iPlayer, "cl_righthand", "Create_Grenade")

	Make_MuzzleFlash(iPlayer)
}

OICWFire(iItem, iPlayer, Float:flSpread, Float:flNextAttack)
{
	static Float:vecAiming[3], Float:vecSrc[3], Float:vecDir[3]
	static Flag

	set_pdata_int(iItem, m_bDelayFire, 1, extra_offset_weapon)

	static iShotsFired; iShotsFired = get_pdata_int(iItem, m_iShotsFired, extra_offset_weapon)

	iShotsFired++
	set_pdata_int(iItem, m_iShotsFired, iShotsFired, extra_offset_weapon)

	static Float:Accuracy; Accuracy = AccuracyCalculate(iShotsFired, WEAPON_ACCURACY)
	Accuracy = floatclamp(Accuracy, WEAPON_ACCURACYRANGE)

	set_pdata_float(iItem, m_flAccuracy, Accuracy, extra_offset_weapon)

	static iClip; iClip = get_pdata_int(iItem, m_iClip, extra_offset_weapon)

	if(iClip <= 0)
	{
		// No ammo, play empty sound and cancel
		if(get_pdata_int(iItem, m_fFireOnEmpty, extra_offset_weapon))
		{
			ExecuteHamB(Ham_Weapon_PlayEmptySound, iItem)
			set_pdata_float(iItem, m_flNextPrimaryAttack, 0.2, extra_offset_weapon)
		}

		return
	}

	iClip--
	set_pdata_int(iItem, m_iClip, iClip, extra_offset_weapon)

	set_pev(iPlayer, pev_effects, pev(iPlayer, pev_effects) | EF_MUZZLEFLASH)

	static Animation

	switch(random_num(0, 2))
	{
		case 0: Animation = ANIM_SHOOT1
		case 1: Animation = ANIM_SHOOT2
		case 2: Animation = ANIM_SHOOT3
	}

	Weapon_SendAnim(iPlayer, iItem, Animation)

	static iFlags
	static szAnimation[64], Float:Velocity[3]

	iFlags = pev(iPlayer, pev_flags)

	if(iFlags & FL_DUCKING)
	{
		formatex(szAnimation, charsmax(szAnimation), "crouch_shoot_%s", ANIM_EXTENSION)
	}
	else
	{
		formatex(szAnimation, charsmax(szAnimation), "ref_shoot_%s", ANIM_EXTENSION)
	}

	Player_SetAnimation(iPlayer, szAnimation)

	static Float:Angles[3], Float:PunchAngle[3], Float:vecTemp1[3]

	pev(iPlayer, pev_v_angle, Angles)
	pev(iPlayer, pev_punchangle, PunchAngle)

	xs_vec_add(Angles, PunchAngle, vecTemp1)
	engfunc(EngFunc_MakeVectors, vecTemp1)

	GetGunPosition(iPlayer, vecSrc)
	global_get(glb_v_forward, vecAiming)

	FireBullets3(iPlayer, vecSrc, vecAiming, flSpread, WEAPON_SHOOT_RANGE, WEAPON_BULLET_PENETRATION, WEAPON_BULLETTYPE, WEAPON_BULLET_DAMAGE, WEAPON_RANGE_MODIFIER, iPlayer, 0, get_pdata_int(iPlayer, random_seed, extra_offset_player), vecDir)

#if defined CLIENT_WEAPONS
	Flag = FEV_NOTHOST
#else
	Flag = 0
#endif

	pev(iPlayer, pev_punchangle, PunchAngle)

	engfunc(EngFunc_PlaybackEvent, Flag, iPlayer, g_EventId_M4A1, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, vecDir[0], vecDir[1], floatround(PunchAngle[0] * 100.0), floatround(PunchAngle[1] * 100.0), true, true)
	engfunc(EngFunc_PlaybackEvent, Flag, iPlayer, g_EventId_Knife, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, Animation, 2, 3, 4)

	set_pdata_int(iPlayer, m_iWeaponVolume, WEAPON_VOLUME, extra_offset_player)
	set_pdata_int(iPlayer, m_iWeaponFlash, WEAPON_FLASH, extra_offset_player)

	set_pdata_float(iItem, m_flNextPrimaryAttack, flNextAttack, extra_offset_weapon)
	set_pdata_float(iItem, m_flNextSecondaryAttack, flNextAttack, extra_offset_weapon)
	set_pdata_float(iItem, m_flTimeWeaponIdle, 1.13, extra_offset_weapon)

	if(xs_vec_len(Velocity) > 0)
	{
		Weapon_KickBack(iItem, iPlayer, WEAPON_KICKBACKWALKING)
	}
	else if(!(iFlags & FL_ONGROUND))
	{
		Weapon_KickBack(iItem, iPlayer, WEAPON_KICKBACKNOTONGROUND)
	}
	else if(iFlags & FL_DUCKING)
	{
		Weapon_KickBack(iItem, iPlayer, WEAPON_KICKBACKDUCKING)
	}
	else
	{
		Weapon_KickBack(iItem, iPlayer, WEAPON_KICKBACK)
	}

	EMIT_SOUND(iPlayer, CHAN_STATIC, SOUND_FIRE, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

Float:AccuracyCalculate(iShotsFired, Float:FloatNum1, Float:FloatNum2)
{
	return ((iShotsFired * iShotsFired * iShotsFired) / FloatNum1) + FloatNum2
}
//**********************************************
//* Weapon list update.                        *
//**********************************************

public fw_Item_AddToPlayer_Post(iItem, iPlayer)
{
	if(!IsValidPev(iItem) || !IsConnected(iPlayer))
		return

	if(IsCustomItem(iItem))
	{
		if(PrimaryAmmoIndex(iItem) != WEAPON_PRIMARYAMMOID || SecondaryAmmoIndex(iItem) != WEAPON_SECONDARYAMMOID)
		{
			set_pdata_int(iItem, m_iPrimaryAmmoType, WEAPON_PRIMARYAMMOID, extra_offset_weapon)
			set_pdata_int(iItem, m_iSecondaryAmmoType, WEAPON_SECONDARYAMMOID, extra_offset_weapon)
		}
	}

	MsgHook_WeaponList(g_MsgId_WeaponList, iItem, iPlayer)
}

public MsgHook_WeaponList(iMsgID, iMsgDest, iMsgEntity)
{
	static arrWeaponListData[8]

	if(!iMsgEntity)
	{
		new szWeaponName[32]
		get_msg_arg_string(1, szWeaponName, charsmax(szWeaponName))

		if(!strcmp(szWeaponName, WEAPON_REFERANCE))
		{
			for (new i, a = sizeof arrWeaponListData; i < a; i++)
			{
				arrWeaponListData[i] = get_msg_arg_int(i + 2)
			}
		}
	}
	else
	{
		if(!IsCustomItem(iMsgDest) && pev(iMsgDest, pev_impulse))
			return

		if(IsCustomItem(iMsgDest))
		{
			MESSAGE_BEGIN(MSG_ONE, iMsgID, {0.0, 0.0, 0.0}, iMsgEntity)
			WRITE_STRING(WEAPON_NAME)
			WRITE_BYTE(WEAPON_PRIMARYAMMOID)
			WRITE_BYTE(WEAPON_MAX_AMMO)
			WRITE_BYTE(WEAPON_SECONDARYAMMOID)
			WRITE_BYTE(WEAPON_MAX_EXTRAAMMO)
			WRITE_BYTE(arrWeaponListData[4])
			WRITE_BYTE(arrWeaponListData[5])
			WRITE_BYTE(arrWeaponListData[6])
			WRITE_BYTE(WEAPON_FLAG)
			MESSAGE_END()
		}
		else
		{
			MESSAGE_BEGIN(MSG_ONE, iMsgID, {0.0, 0.0, 0.0}, iMsgEntity)
			WRITE_STRING(WEAPON_REFERANCE)

			for (new i, a = sizeof arrWeaponListData; i < a; i++)
			{
				WRITE_BYTE(arrWeaponListData[i])
			}

			MESSAGE_END()
		}
	}
}

//**********************************************
//* Death Hook                                 *
//**********************************************
public MsgHook_Death() <CustomDeath: Enabled>
{
	static szTruncatedWeaponName[32]

	if(szTruncatedWeaponName[0] == EOS)
	{
		copy(szTruncatedWeaponName, charsmax(szTruncatedWeaponName), WEAPON_NAME)
		replace(szTruncatedWeaponName, charsmax(szTruncatedWeaponName), "weapon_", "")
	}

	set_msg_arg_string(4, szTruncatedWeaponName)
}

public MsgHook_Death() </* Empty statement */>
{
	/* Fallback */
}

public MsgHook_Death() <CustomDeath: Disabled>
{
	/* Do notning */
}

//**********************************************
//* Do painshock                               *
//**********************************************

public fw_PlayerTakeDamage_Post(iVictim, iInflictor, iAttacker) <CustomPainshock: Enabled>
{
	if(!IsConnected(iAttacker))
		return

	if(get_pdata_int(iVictim, m_iTeam, extra_offset_player) == get_pdata_int(iAttacker, m_iTeam, extra_offset_player))
		return

	static Float:flVelocityModifier; flVelocityModifier = WEAPON_VELOCITYMODIFIER

	if(flVelocityModifier)
	{
		set_pdata_float(iVictim, m_flVelocityModifier, flVelocityModifier, extra_offset_player)
	}
}

public fw_PlayerTakeDamage_Post() </* Empty statement */>
{
	/* Fallback */
}

public fw_PlayerTakeDamage_Post() <CustomPainshock: Disabled>
{
	/* Do notning */
}

//**********************************************
//* Muzzle Flash                               *
//**********************************************

Make_MuzzleFlash(iPlayer)
{
	if(global_get(glb_maxEntities) - NUMBER_OF_ENTITIES() < MUZZLE_INTOLERANCE)
		return

	static iEntity
	static iszAllocStringCached

	if(iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "info_target")))
	{
		   iEntity = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached)
	}

	if(!pev_valid(iEntity))
		return

	engfunc(EngFunc_SetModel, iEntity, SPRITE_MUZZLEFLASH)

	set_pev(iEntity, pev_classname, MUZZLEFLASH_CLASSNAME)
	set_pev(iEntity, pev_body, MUZZLEFLASH_ATTACHMENT)
	set_pev(iEntity, pev_skin, iPlayer)
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)

	set_pev(iEntity, pev_owner, iPlayer)

	set_pev(iEntity, pev_scale, MUZZLEFLASH_SCALE)
	set_pev(iEntity, pev_frame, 0.0)
	set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderamt, MUZZLEFLASH_BRIGHTNESS)

	static Float:Angles[3]
	Angles[2] = random_float(MUZZLEFLASH_RANDOMANGLES)
	set_pev(iEntity, pev_angles, Angles)

	static Float:Origin[3]
	pev(iPlayer, pev_origin, Origin)
	set_pev(iEntity, pev_origin, Origin)

	set_pev(iEntity, pev_nextthink, get_gametime() + MUZZLEFLASH_SPEED)
}

public fw_MuzzleFlash_Think(iEntity)
{
	if(!pev_valid(iEntity))
		return

	static iOwner; iOwner = pev(iEntity, pev_owner)

	if(!IsConnected(iOwner))
	{
		REMOVE_ENTITY(iEntity)
		return
	}

	static iActiveItem; iActiveItem = get_pdata_cbase(iOwner, m_pActiveItem, extra_offset_player)

	if(!IsValidPev(iActiveItem) || !IsCustomItem(iActiveItem))
	{
		REMOVE_ENTITY(iEntity)
		return
	}

	static Float:Frame
	pev(iEntity, pev_frame, Frame)

	if(Frame > (MUZZLEFLASH_FRAMES - 2))
	{
		REMOVE_ENTITY(iEntity)
		return
	}
	else
	{
		Frame += 1.0
		set_pev(iEntity, pev_frame, Frame)
	}

	set_pev(iEntity, pev_nextthink, get_gametime() + MUZZLEFLASH_SPEED)
}

//**********************************************
//* Grenade                                    *
//**********************************************

public Event_NewRound()
{
	static iEntity; iEntity = 0

	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", GRENADE_CLASSNAME)) != 0)
	{
		REMOVE_ENTITY(iEntity)
	}
}

public Create_Grenade(iPlayer, CvarName[], Value[], Param[])
{
	if(global_get(glb_maxEntities) - NUMBER_OF_ENTITIES() < GRENADE_INTOLERANCE)
		return

	static Float:Origin[3], Float:Velocity[3], Float:Angles[3]

	pev(iPlayer, pev_v_angle, Angles)
	xs_vec_set(Origin, GRENADE_SPAWN_ORIGIN)

	static RightHand; RightHand = str_to_num(Value)

	if(!RightHand)
	{
		Origin[1] *= -1.0
	}

	Get_Position(iPlayer, Origin[0], Origin[1], Origin[2], Origin)

	static Float:vecEnd[3]
	fm_get_aim_origin(iPlayer, vecEnd)

	static Float:Distance
	Distance = get_distance_f(Origin, vecEnd)

	static Float:Angle; Angle = GRENADE_ANGLE

	if(Angle == 0.0)
	{
		if(Distance >= GRENADE_SPEED)
		{
			Stock_Get_Speed_Vector(Origin, vecEnd, GRENADE_SPEED, Velocity)
		}
		else
		{
			Stock_Get_Speed_Vector(Origin, vecEnd, Distance * 2.0, Velocity)
		}
	}
	else
	{
		if(Distance >= GRENADE_SPEED)
		{
			Stock_Velocity_By_Aim(Angles, Angle, GRENADE_SPEED, Velocity)
		}
		else
		{
			Stock_Velocity_By_Aim(Angles, Angle, Distance * 2.0, Velocity)
		}
	}

	vector_to_angle(Velocity, Angles)

	if(Angles[0] > 90.0)
	{
		Angles[0] = - (360.0 - Angles[0])
	}

	static iEntity
	static iszAllocStringCached

	if(iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "info_target")))
	{
		   iEntity = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached)
	}

	if(!pev_valid(iEntity))
		return

	engfunc(EngFunc_SetModel, iEntity, MODEL_GRENADE)

	set_pev(iEntity, pev_classname, GRENADE_CLASSNAME)
	set_pev(iEntity, pev_movetype, GRENADE_MOVETYPE)
	set_pev(iEntity, pev_gravity, GRENADE_GRAVITY)
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_dmg, GRENADE_DAMAGE)

	set_pev(iEntity, pev_owner, iPlayer)
	set_pev(iEntity, pev_team, get_pdata_int(iPlayer, m_iTeam, extra_offset_player))

	set_pev(iEntity, pev_origin, Origin)
	set_pev(iEntity, pev_angles, Angles)
	set_pev(iEntity, pev_velocity, Velocity)

	set_pev(iEntity, pev_iuser4, 0)

	set_pev(iEntity, pev_nextthink, get_gametime() + GRENADE_LIFETIME)

	// Make a Beam
	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0)
	WRITE_BYTE(TE_BEAMFOLLOW)
	WRITE_SHORT(iEntity)
	WRITE_SHORT(g_Trail_SprId)
	WRITE_BYTE(4)
	WRITE_BYTE(2)
	WRITE_BYTE(225)
	WRITE_BYTE(225)
	WRITE_BYTE(255)
	WRITE_BYTE(220)
	MESSAGE_END()
}

public fw_Grenade_Touch(iEntity, Touch)
{
	if(!pev_valid(iEntity))
		return

	static Float:Velocity[3]
	pev(iEntity, pev_velocity, Velocity)

	xs_vec_mul_scalar(Velocity, 0.5, Velocity)

	set_pev(iEntity, pev_velocity, Velocity)
}

public fw_Grenade_Think(iEntity)
{
	if(!pev_valid(iEntity))
		return

	static Float:Origin[3]
	pev(iEntity, pev_origin, Origin)

	if(pev(iEntity, pev_iuser4))
	{
		if(UTIL_PointContents(Origin) == CONTENTS_WATER)
		{
			static Float:vecTemp1[3], Float:vecTemp2[3]

			xs_vec_set(vecTemp1, 64.0, 64.0, 64.0)
			xs_vec_set(vecTemp2, -64.0, -64.0, -64.0)

			xs_vec_add(Origin, vecTemp1, vecTemp1)
			xs_vec_add(Origin, vecTemp2, vecTemp2)

			UTIL_Bubbles(vecTemp2, vecTemp1, 100)
		}
		else
		{
			static Float:Damage
			pev(iEntity, pev_dmg, Damage)

			MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0)
			WRITE_BYTE(TE_SMOKE)
			WRITE_COORD(Origin[0])
			WRITE_COORD(Origin[1])
			WRITE_COORD(Origin[2])
			WRITE_SHORT(g_Smoke_SprId)
			WRITE_BYTE(floatround((Damage - 50.0) * 0.8))
			WRITE_BYTE(12)
			MESSAGE_END()
		}

		REMOVE_ENTITY(iEntity)
	}
	else
	{
		static Float:Damage
		pev(iEntity, pev_dmg, Damage)

		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0)
		WRITE_BYTE(TE_EXPLOSION)
		WRITE_COORD(Origin[0])
		WRITE_COORD(Origin[1])
		WRITE_COORD(Origin[2])

		if(UTIL_PointContents(Origin) != CONTENTS_WATER)
		{
			WRITE_SHORT(g_FireBall_SprId)
		}
		else
		{
			WRITE_SHORT(g_Explode_SprId)
		}

		WRITE_BYTE(floatround((Damage - 50.0) * 0.6))
		WRITE_BYTE(15)
		WRITE_BYTE(0)
		MESSAGE_END()

		static iOwner; iOwner = pev(iEntity, pev_owner)

		if(IsValidPev(iOwner))
		{
			UTIL_RadiusDamage(Origin, iEntity, iOwner, Damage, GRENADE_RANGE, GRENADE_KNOCKBACK, DMG_BULLET, 0, 1)
		}
		else
		{
			UTIL_RadiusDamage(Origin, iEntity, 0, Damage, GRENADE_RANGE, GRENADE_KNOCKBACK, DMG_BULLET, 0, 1)
		}

		// Put decal on "world" (a wall)
		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0)
		WRITE_BYTE(TE_WORLDDECAL)
		WRITE_COORD(Origin[0])
		WRITE_COORD(Origin[1])
		WRITE_COORD(Origin[2])
		WRITE_BYTE(random_num(0, 1) ? g_Decal_Scorch1 : g_Decal_Scorch2)
		MESSAGE_END()

		switch(random_num(0, 2))
		{
			case 0: EMIT_SOUND(iEntity, CHAN_VOICE, "weapons/debris1.wav", 0.55, ATTN_NORM, 0, PITCH_NORM)
			case 1: EMIT_SOUND(iEntity, CHAN_VOICE, "weapons/debris2.wav", 0.55, ATTN_NORM, 0, PITCH_NORM)
			case 2: EMIT_SOUND(iEntity, CHAN_VOICE, "weapons/debris3.wav", 0.55, ATTN_NORM, 0, PITCH_NORM)
		}

		set_pev(iEntity, pev_effects, pev(iEntity, pev_effects) | EF_NODRAW)
		set_pev(iEntity, pev_velocity, {0.0, 0.0, 0.0})

		set_pev(iEntity, pev_iuser4, 1)
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.3)
	}
}

UTIL_Bubbles(Float:vecMins[3], Float:vecMaxs[3], count)
{
	static Float:vecMid[3]

	xs_vec_add(vecMins, vecMaxs, vecMid)
	xs_vec_mul_scalar(vecMid, 0.5, vecMid)

	static Float:flHeight; flHeight = UTIL_WaterLevel(vecMid, vecMid[2], vecMid[2] + 1024.0)
	flHeight = flHeight - vecMins[2]

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0)
	WRITE_BYTE(TE_BUBBLES)
	WRITE_COORD(vecMins[0])
	WRITE_COORD(vecMins[1])
	WRITE_COORD(vecMins[2])
	WRITE_COORD(vecMaxs[0])
	WRITE_COORD(vecMaxs[1])
	WRITE_COORD(vecMaxs[2])
	WRITE_COORD(flHeight)
	WRITE_SHORT(g_Bubble_SprId)
	WRITE_BYTE(count)
	WRITE_COORD(8.0)
	MESSAGE_END()
}

Float:UTIL_WaterLevel(Float:Position[3], Float:Minz, Float:Maxz)
{
	static Float:MidUp[3]
	xs_vec_copy(Position, MidUp)

	MidUp[2] = Minz

	if(UTIL_PointContents(MidUp) != CONTENTS_WATER)
		return Minz

	MidUp[2] = Maxz

	if(UTIL_PointContents(MidUp) == CONTENTS_WATER)
		return Maxz

	static Float:Diff; Diff = Maxz - Minz

	while(Diff > 1.0)
	{
		MidUp[2] = Minz + Diff / 2.0

		if(UTIL_PointContents(MidUp) == CONTENTS_WATER)
		{
			Minz = MidUp[2]
		}
		else
		{
			Maxz = MidUp[2]
		}

		Diff = Maxz - Minz
	}

	return MidUp[2]
}

stock UTIL_PointContents(Float:Origin[3])
{
	return engfunc(EngFunc_PointContents, Origin)
}

//**********************************************
//* Radius Damage                              *
//**********************************************

public UTIL_RadiusDamage(Float:vecSrc[3], pevInflictor, pevAttacker, Float:flDamage, Float:flRadius, Float:flKnockBack, bitsDamageType, bSkipAttacker, bDistanceCheck)
{
	static pEntity; pEntity = 0
	static tr; tr = create_tr2()
	static Float:flAdjustedDamage, Float:falloff
	static iHitResult; iHitResult = RESULT_HIT_NONE

	if(bDistanceCheck)
	{
		falloff = flDamage / flRadius
	}
	else
	{
		falloff = 0.0
	}

	static bInWater; bInWater = (UTIL_PointContents(vecSrc) == CONTENTS_WATER)

	vecSrc[2] += 1.0

	if(!pevAttacker)
	{
		pevAttacker = pevInflictor
	}

	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRadius)) != 0)
	{
		if(pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue

		if(bInWater && !pev(pEntity, pev_waterlevel))
			continue

		if(!bInWater && pev(pEntity, pev_waterlevel) == 3)
			continue

		if(bSkipAttacker && pEntity == pevAttacker)
			continue

		static Float:vecEnd[3]
		Stock_Get_Origin(pEntity, vecEnd)

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, 0, tr)

		static Float:flFraction
		get_tr2(tr, TR_flFraction, flFraction)

		if(flFraction >= 1.0)
		{
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, 0, tr)
		}

		xs_vec_sub(vecEnd, vecSrc, vecEnd)

		static Float:fDistance; fDistance = xs_vec_len(vecEnd)
		if(fDistance < 1.0)
		{
			fDistance = 0.0
		}

		flAdjustedDamage = fDistance * falloff
		flAdjustedDamage = flDamage - flAdjustedDamage

		if(get_tr2(tr, TR_pHit) != pEntity)
		{
			flAdjustedDamage *= 0.3
		}

		if(flAdjustedDamage <= 0)
			continue

		xs_vec_normalize(vecEnd, vecEnd)

		static Float:vecVelocity[3], Float:vecOldVelocity[3]

		xs_vec_mul_scalar(vecEnd, flKnockBack * ((flRadius - fDistance) / flRadius), vecVelocity)
		pev(pEntity, pev_velocity, vecOldVelocity)
		xs_vec_add(vecVelocity, vecOldVelocity, vecVelocity)

		if(IsPlayer(pEntity))
		{
			set_pev(pEntity, pev_velocity, vecVelocity)
		}
		else
		{
			set_tr2(tr, TR_iHitgroup, HITGROUP_CHEST)
		}

		ClearMultiDamage()

		ExecuteHamB(Ham_TraceAttack, pEntity, pevAttacker, flAdjustedDamage, vecEnd, tr, bitsDamageType)

		state CustomDeath: Enabled
		ApplyMultiDamage(pevInflictor, pevAttacker)
		state CustomDeath: Disabled

		iHitResult = RESULT_HIT_PLAYER
	}

	free_tr2(tr)

	return iHitResult
}

//**********************************************
//* FireBullets3                               *
//**********************************************

// Materials
#define CHAR_TEX_CONCRETE 'C'
#define	CHAR_TEX_METAL 'M'
#define CHAR_TEX_DIRT 'D'
#define CHAR_TEX_VENT 'V'
#define CHAR_TEX_GRATE 'G'
#define CHAR_TEX_TILE 'T'
#define CHAR_TEX_SLOSH 'S'
#define CHAR_TEX_WOOD 'W'
#define CHAR_TEX_COMPUTER 'P'
#define CHAR_TEX_GLASS 'Y'
#define CHAR_TEX_FLESH 'F'
#define CHAR_TEX_SNOW 'N'

// Classify
#define CLASS_NONE			0
#define CLASS_MACHINE			1
#define CLASS_PLAYER			2
#define CLASS_HUMAN_PASSIVE		3
#define CLASS_HUMAN_MILITARY		4
#define CLASS_ALIEN_MILITARY		5
#define CLASS_ALIEN_PASSIVE		6
#define CLASS_ALIEN_MONSTER		7
#define CLASS_ALIEN_PREY		8
#define CLASS_ALIEN_PREDATOR		9
#define CLASS_INSECT			10
#define CLASS_PLAYER_ALLY		11
#define CLASS_PLAYER_BIOWEAPON		12
#define CLASS_ALIEN_BIOWEAPON		13
#define CLASS_VEHICLE			14
#define CLASS_BARNACLE			99

FireBullets3(iEntity, Float:vecSrc[3], Float:vecDirShooting[3], Float:vecSpread, Float:flDistance, iPenetration, iBulletType, Float:flDamage, Float:flRangeModifier, iAttacker, bPistol, shared_rand, Float:vecRet[3])
{
	static Float:flPenetrationPower
	static Float:flPenetrationDistance
	static Float:flCurrentDamage; flCurrentDamage = flDamage
	static Float:flCurrentDistance

	static tr; tr = create_tr2()
	static Float:vecRight[3], Float:vecUp[3]

	static bHitMetal; bHitMetal = 0
	static iSparksAmount; iSparksAmount = 1

	global_get(glb_v_right, vecRight)
	global_get(glb_v_up, vecUp)

	switch(iBulletType)
	{
		case BULLET_PLAYER_9MM:
		{
			flPenetrationPower = 21.0
			flPenetrationDistance = 800.0
		}
		case BULLET_PLAYER_45ACP:
		{
			flPenetrationPower = 15.0
			flPenetrationDistance = 500.0
		}
		case BULLET_PLAYER_50AE:
		{
			flPenetrationPower = 30.0
			flPenetrationDistance = 1000.0
		}
		case BULLET_PLAYER_762MM:
		{
			flPenetrationPower = 39.0
			flPenetrationDistance = 5000.0
		}
		case BULLET_PLAYER_556MM:
		{
			flPenetrationPower = 35.0
			flPenetrationDistance = 4000.0
		}
		case BULLET_PLAYER_338MAG:
		{
			flPenetrationPower = 45.0
			flPenetrationDistance = 8000.0
		}
		case BULLET_PLAYER_57MM:
		{
			flPenetrationPower = 30.0
			flPenetrationDistance = 2000.0
		}
		case BULLET_PLAYER_357SIG:
		{
			flPenetrationPower = 25.0
			flPenetrationDistance = 800.0
		}
		default:
		{
			flPenetrationPower = 0.0
			flPenetrationDistance = 0.0
		}
	}

	if(!iAttacker)
	{
		// The default attacker is ourselves
		iAttacker = iEntity
	}

	static Float:x, Float:y, Float:z

	if(IsPlayer(iEntity))
	{
		// Use player's random seed.
		// get circular gaussian spread
		x = UTIL_SharedRandomFloat(shared_rand, -0.5, 0.5) + UTIL_SharedRandomFloat(shared_rand + 1, -0.5, 0.5)
		y = UTIL_SharedRandomFloat(shared_rand + 2, -0.5, 0.5) + UTIL_SharedRandomFloat(shared_rand + 3, -0.5, 0.5)
	}
	else
	{
		do
		{
			x = random_float(-0.5, 0.5) + random_float(-0.5, 0.5)
			y = random_float(-0.5, 0.5) + random_float(-0.5, 0.5)
			z = x * x + y * y
		}
		while(z > 1.0)
	}

	static Float:vecDir[3]
	static Float:vecTemp1[3], Float:vecTemp2[3]
	xs_vec_mul_scalar(vecRight, x * vecSpread, vecTemp1)
	xs_vec_mul_scalar(vecUp, y * vecSpread, vecTemp2)

	vecDir[0] = vecDirShooting[0] + vecTemp1[0] + vecTemp2[0]
	vecDir[1] = vecDirShooting[1] + vecTemp1[1] + vecTemp2[1]
	vecDir[2] = vecDirShooting[2] + vecTemp1[2] + vecTemp2[2]

	static Float:vecEnd[3], Float:vecTemp3[3]
	xs_vec_mul_scalar(vecDir, flDistance, vecTemp3)
	xs_vec_add(vecSrc, vecTemp3, vecEnd)

	static Float:flDamageModifier; flDamageModifier = 0.5

	while(iPenetration != 0)
	{
		ClearMultiDamage()

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, iEntity, tr)

		static cTextureType; cTextureType = UTIL_TextureHit(tr, vecSrc, vecEnd)
		static bSpark; bSpark = 0

		switch(cTextureType)
		{
			case CHAR_TEX_METAL:
			{
				bHitMetal = 1
				bSpark = 1

				flDamageModifier = 0.2
				flPenetrationPower = flPenetrationPower * 0.15
			}
			case CHAR_TEX_CONCRETE:
			{
				flDamageModifier = 1.0
				flPenetrationPower = flPenetrationPower * 0.25
			}
			case CHAR_TEX_GRATE:
			{
				bHitMetal = 1
				bSpark = 1

				flDamageModifier = 0.4
				flPenetrationPower = flPenetrationPower * 0.5
			}
			case CHAR_TEX_VENT:
			{
				bHitMetal = 1
				bSpark = 1

				flDamageModifier = 0.45
				flPenetrationPower = flPenetrationPower * 0.5
			}
			case CHAR_TEX_TILE:
			{
				flDamageModifier = 0.3
				flPenetrationPower = flPenetrationPower * 0.65
			}
			case CHAR_TEX_COMPUTER:
			{
				bHitMetal = 1
				bSpark = 1

				flDamageModifier = 0.45
				flPenetrationPower = flPenetrationPower * 0.4
			}
			case CHAR_TEX_WOOD:
			{
				flDamageModifier = 0.6
				flPenetrationPower = flPenetrationPower * 1.0
			}
			default:
			{
				flDamageModifier = 1.0
				flPenetrationPower = flPenetrationPower * 1.0
			}
		}

		static Float:flFraction
		get_tr2(tr, TR_flFraction, flFraction)

		if(flFraction != 1.0)
		{
			static pEntity; pEntity = INSTANCE(get_tr2(tr, TR_pHit))

			static Float:vecEndPos[3]
			get_tr2(tr, TR_vecEndPos, vecEndPos)

			iPenetration--

			flCurrentDistance = flFraction * flDistance
			flCurrentDamage = flCurrentDamage * floatpower(flRangeModifier, flCurrentDistance / 500.0)

			if(flCurrentDistance > flPenetrationDistance)
			{
				iPenetration = 0
			}

			if(get_tr2(tr, TR_iHitgroup) == HITGROUP_SHIELD)
			{
				EMIT_SOUND(pEntity, CHAN_VOICE, (random_num(0, 1) == 1) ? "weapons/ric_metal-1.wav" : "weapons/ric_metal-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

				UTIL_Sparks(vecEndPos)

				static Float:PunchAngle[3]
				pev(pEntity, pev_punchangle, PunchAngle)

				PunchAngle[0] = flCurrentDamage * random_float(-0.15, 0.15)
				PunchAngle[2] = flCurrentDamage * random_float(-0.15, 0.15)

				if(PunchAngle[0] < 4.0)
				{
					PunchAngle[0] = -4.0
				}

				if(PunchAngle[2] < -5.0)
				{
					PunchAngle[2] = -5.0
				}
				else if(PunchAngle[2] > 5.0)
				{
					PunchAngle[2] = 5.0
				}

				set_pev(pEntity, pev_punchangle, PunchAngle)
			}

			static Float:flDistanceModifier
			if(pev(pEntity, pev_solid) != SOLID_BSP || !iPenetration)
			{
				flPenetrationPower = 42.0
				flDamageModifier = 0.75
				flDistanceModifier = 0.75
			}
			else
			{
				flDistanceModifier = 0.5
			}

			Create_SparkEffect(tr, bSpark, iSparksAmount)
			DecalGunshot(tr, iBulletType, (!bPistol && random_num(0, 3)), iEntity, bHitMetal)

#if defined TRACE_BULLETS
			static Float:vecTemp4[3], Float:vecEndPos2[3]

			xs_vec_mul_scalar(vecDir, 3.0, vecTemp4)
			xs_vec_sub(vecEndPos, vecTemp4, vecEndPos2)

			MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, {0.0, 0.0, 0.0}, 0)
			WRITE_BYTE(TE_LINE)
			WRITE_COORD(vecEndPos2[0])
			WRITE_COORD(vecEndPos2[1])
			WRITE_COORD(vecEndPos2[2])
			WRITE_COORD(vecEndPos[0])
			WRITE_COORD(vecEndPos[1])
			WRITE_COORD(vecEndPos[2])
			WRITE_SHORT(300)
			WRITE_BYTE(0)
			WRITE_BYTE(0)
			WRITE_BYTE(255)
			MESSAGE_END()
#endif
			static Float:vecTemp5[3]

			xs_vec_mul_scalar(vecDir, flPenetrationPower, vecTemp5)
			xs_vec_add(vecTemp5, vecEndPos, vecSrc)

			flDistance = (flDistance - flCurrentDistance) * flDistanceModifier

			xs_vec_mul_scalar(vecDir, flDistance, vecTemp5)
			xs_vec_add(vecTemp5, vecSrc, vecEnd)

			ExecuteHamB(Ham_TraceAttack, pEntity, iAttacker, flCurrentDamage, vecDir, tr, DMG_BULLET | DMG_NEVERGIB)

			flCurrentDamage = flCurrentDamage * flDamageModifier
		}
		else
		{
			iPenetration = 0
		}

		state CustomPainshock: Enabled
		state CustomDeath: Enabled
		ApplyMultiDamage(iEntity, iAttacker)
		state CustomPainshock: Disabled
		state CustomDeath: Disabled
	}

	free_tr2(tr)

	vecRet[0] = x * vecSpread
	vecRet[1] = y * vecSpread
	vecRet[2] = 0.0
}

Create_SparkEffect(pTrace, bSpark, iSparksAmount)
{
	// Moved to client-side (Playback Event)

	#pragma unused pTrace, bSpark, iSparksAmount
}

DecalGunshot(pTrace, iBulletType, ClientOnly, pShooter, bHitMetal)
{
	// Moved to client-side (Playback Event)

	#pragma unused pTrace, iBulletType, ClientOnly, pShooter, bHitMetal
}

UTIL_TextureHit(tr, Float:vecSrc[3], Float:vecEnd[3])
{
	static chTextureType
	static Float:rgfl1[3], Float:rgfl2[3]
	static pTextureName[64]

	static pEntity; pEntity = INSTANCE(get_tr2(tr, TR_pHit))

	if(pEntity && ExecuteHamB(Ham_Classify, pEntity) != CLASS_NONE && ExecuteHamB(Ham_Classify, pEntity) != CLASS_MACHINE)
		return CHAR_TEX_FLESH

	xs_vec_copy(vecSrc, rgfl1)
	xs_vec_copy(vecEnd, rgfl2)

	engfunc(EngFunc_TraceTexture, pEntity, rgfl1, rgfl2, pTextureName, charsmax(pTextureName))

	chTextureType = dllfunc(DLLFunc_PM_FindTextureType, pTextureName)

	return chTextureType
}

UTIL_Sparks(Float:Position[3])
{
	MESSAGE_BEGIN(MSG_PAS, SVC_TEMPENTITY, Position, 0)
	WRITE_BYTE(TE_SPARKS)
	WRITE_COORD(Position[0])
	WRITE_COORD(Position[1])
	WRITE_COORD(Position[2])
	MESSAGE_END()
}

//**********************************************
//* Random seed                                *
//**********************************************

new glSeed
new seed_table[256] =
{
	28985, 27138, 26457, 9451, 17764, 10909, 28790, 8716, 6361, 4853, 17798, 21977, 19643, 20662, 10834, 20103,
	27067, 28634, 18623, 25849, 8576, 26234, 23887, 18228, 32587, 4836, 3306, 1811, 3035, 24559, 18399, 315,
	26766, 907, 24102, 12370, 9674, 2972, 10472, 16492, 22683, 11529, 27968, 30406, 13213, 2319, 23620, 16823,
	10013, 23772, 21567, 1251, 19579, 20313, 18241, 30130, 8402, 20807, 27354, 7169, 21211, 17293, 5410, 19223,
	10255, 22480, 27388, 9946, 15628, 24389, 17308, 2370, 9530, 31683, 25927, 23567, 11694, 26397, 32602, 15031,
	18255, 17582, 1422, 28835, 23607, 12597, 20602, 10138, 5212, 1252, 10074, 23166, 19823, 31667, 5902, 24630,
	18948, 14330, 14950, 8939, 23540, 21311, 22428, 22391, 3583, 29004, 30498, 18714, 4278, 2437, 22430, 3439,
	28313, 23161, 25396, 13471, 19324, 15287, 2563, 18901, 13103, 16867, 9714, 14322, 15197, 26889, 19372, 26241,
	31925, 14640, 11497, 8941, 10056, 6451, 28656, 10737, 13874, 17356, 8281, 25937, 1661, 4850, 7448, 12744,
	21826, 5477, 10167, 16705, 26897, 8839, 30947, 27978, 27283, 24685, 32298, 3525, 12398, 28726, 9475, 10208,
	617, 13467, 22287, 2376, 6097, 26312, 2974, 9114, 21787, 28010, 4725, 15387, 3274, 10762, 31695, 17320,
	18324, 12441, 16801, 27376, 22464, 7500, 5666, 18144, 15314, 31914, 31627, 6495, 5226, 31203, 2331, 4668,
	12650, 18275, 351, 7268, 31319, 30119, 7600, 2905, 13826, 11343, 13053, 15583, 30055, 31093, 5067, 761,
	9685, 11070, 21369, 27155, 3663, 26542, 20169, 12161, 15411, 30401, 7580, 31784, 8985, 29367, 20989, 14203,
	29694, 21167, 10337, 1706, 28578, 887, 3373, 19477, 14382, 675, 7033, 15111, 26138, 12252, 30996, 21409,
	25678, 18555, 13256, 23316, 22407, 16727, 991, 9236, 5373, 29402, 6117, 15241, 27715, 19291, 19888, 19847
}

U_Random()
{
	glSeed *= 69069
	glSeed += seed_table[glSeed & 0xFF] + 1

	return (glSeed & 0x0FFFFFFF)
}

U_Srand(seed)
{
	glSeed = seed_table[seed & 0xFF]
}

Float:UTIL_SharedRandomFloat(Seed, Float:Low, Float:High)
{
	static Float:Range

	U_Srand(Seed + floatround(Low) + floatround(High))

	U_Random()
	U_Random()

	Range = High - Low

	if(Range)
	{
		static Tensixrand, Float:Offset

		Tensixrand = U_Random() & 65535
		Offset = float(Tensixrand) / 65536.0

		return (Low + Offset * Range)
	}

	return Low
}

//**********************************************
//* Player Check                               *
//**********************************************
IsPlayer(iEntity)
{
	return (ExecuteHamB(Ham_Classify, iEntity) == CLASS_PLAYER)
}

IsConnected(iPlayer)
{
	return IsValidPev(iPlayer)
}

//**********************************************
//* Multi Damage Controler                     *
//**********************************************

ClearMultiDamage()
{
		rg_multidmg_clear()
}

ApplyMultiDamage(iEntity, iAttacker)
{
	rg_multidmg_apply(iEntity, iAttacker)
}

//**********************************************
//* Create and check our custom weapon.        *
//**********************************************

IsCustomItem(iItem)
{
	return (pev(iItem, pev_impulse) == g_iszWeaponKey)
}

Weapon_Create(Float:vecOrigin[3] = {0.0, 0.0, 0.0}, Float:vecAngles[3] = {0.0, 0.0, 0.0})
{
	new iWeapon

	static iszAllocStringCached
	if(iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, WEAPON_REFERANCE)))
	{
		iWeapon = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached)
	}

	if(!IsValidPev(iWeapon))
		return FM_NULLENT

	MDLL_Spawn(iWeapon)
	SET_ORIGIN(iWeapon, vecOrigin)

	set_pev_string(iWeapon, pev_classname, g_iszWeaponKey)
	set_pev(iWeapon, pev_impulse, g_iszWeaponKey)
	set_pev(iWeapon, pev_angles, vecAngles)

	Weapon_OnSpawn(iWeapon)

	return iWeapon
}

Weapon_OnSpawn(iWeapon)
{
	SET_MODEL(iWeapon, MODEL_WORLD)

	set_pdata_int(iWeapon, m_iDefaultAmmo, WEAPON_DEFAULT_CLIP, extra_offset_weapon)
	set_pdata_float(iWeapon, m_flAccuracy, WEAPON_ACCURACYDEFAULT, extra_offset_weapon)
	set_pdata_int(iWeapon, m_iShotsFired, 0, extra_offset_weapon)
	set_pdata_int(iWeapon, m_iWeaponState, 0, extra_offset_weapon)
	set_pdata_int(iWeapon, m_bDelayFire, 0, extra_offset_weapon)
}

Weapon_Give(iPlayer)
{
	if(!IsConnected(iPlayer))
		return FM_NULLENT

	new iWeapon, Float:vecOrigin[3]
	pev(iPlayer, pev_origin, vecOrigin)

	if((iWeapon = Weapon_Create(vecOrigin)) != FM_NULLENT)
	{
		Player_DropWeapons(iPlayer, ExecuteHamB(Ham_Item_ItemSlot, iWeapon))

		set_pev(iWeapon, pev_spawnflags, pev(iWeapon, pev_spawnflags) | SF_NORESPAWN)
		MDLL_Touch(iWeapon, iPlayer)

		return iWeapon
	}

	return FM_NULLENT
}

Ammo_Give(iPlayer)
{
	if(!IsConnected(iPlayer))
		return

	static i
	static iClip, iOdd

	static iAmmoPrimary; iAmmoPrimary = GetAmmoInventory(iPlayer, WEAPON_PRIMARYAMMOID)

	if(iAmmoPrimary < WEAPON_MAX_AMMO)
	{
		iClip = floatround(float(WEAPON_MAX_AMMO - iAmmoPrimary) / WEAPON_MAX_CLIP, floatround_floor)
		iOdd = (WEAPON_MAX_AMMO - iAmmoPrimary) % WEAPON_MAX_CLIP

		for(i = 0; i < iClip; i++)
		{
			MESSAGE_BEGIN(MSG_ONE, g_MsgId_AmmoPickup, {0.0, 0.0, 0.0}, iPlayer)
			WRITE_BYTE(WEAPON_PRIMARYAMMOID)
			WRITE_BYTE(WEAPON_MAX_CLIP)
			MESSAGE_END()
		}

		MESSAGE_BEGIN(MSG_ONE, g_MsgId_AmmoPickup, {0.0, 0.0, 0.0}, iPlayer)
		WRITE_BYTE(WEAPON_PRIMARYAMMOID)
		WRITE_BYTE(iOdd)
		MESSAGE_END()

		SetAmmoInventory(iPlayer, WEAPON_PRIMARYAMMOID, WEAPON_MAX_AMMO)
	}

	static iAmmoSecondary; iAmmoSecondary = GetAmmoInventory(iPlayer, WEAPON_SECONDARYAMMOID)

	if(iAmmoSecondary < WEAPON_MAX_EXTRAAMMO)
	{
		MESSAGE_BEGIN(MSG_ONE, g_MsgId_AmmoPickup, {0.0, 0.0, 0.0}, iPlayer)
		WRITE_BYTE(WEAPON_SECONDARYAMMOID)
		WRITE_BYTE(WEAPON_MAX_EXTRAAMMO - iAmmoSecondary)
		MESSAGE_END()

		SetAmmoInventory(iPlayer, WEAPON_SECONDARYAMMOID, WEAPON_MAX_EXTRAAMMO)
	}

	EMIT_SOUND(iPlayer, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

Player_DropWeapons(iPlayer, iSlot)
{
	new szWeaponName[32], iItem = get_pdata_cbase(iPlayer, m_rgpPlayerItems + iSlot, extra_offset_player)

	while(IsValidPev(iItem))
	{
		pev(iItem, pev_classname, szWeaponName, charsmax(szWeaponName))
		engclient_cmd(iPlayer, "drop", szWeaponName)

		iItem = get_pdata_cbase(iItem, m_pNext, extra_offset_weapon)
	}
}

//**********************************************
//* Ammo Inventory.                            *
//**********************************************

PrimaryAmmoIndex(iItem)
{
	return get_pdata_int(iItem, m_iPrimaryAmmoType, extra_offset_weapon)
}

SecondaryAmmoIndex(iItem)
{
	return get_pdata_int(iItem, m_iSecondaryAmmoType, extra_offset_weapon)
}

GetAmmoInventory(iPlayer, iAmmoIndex)
{
	if(iAmmoIndex == -1)
		return -1

	return get_pdata_int(iPlayer, m_rgAmmo + iAmmoIndex, extra_offset_player)
}

SetAmmoInventory(iPlayer, iAmmoIndex, iAmount)
{
	if(iAmmoIndex == -1)
		return 0

	set_pdata_int(iPlayer, m_rgAmmo + iAmmoIndex, iAmount, extra_offset_player)

	return 1
}

//**********************************************
//* Default fuctions                           *
//**********************************************

Weapon_DefaultDeploy(iItem, iPlayer, szViewModel[], szWeaponModel[], iAnim, szAnimExt[])
{
	if(!ExecuteHamB(Ham_Item_CanDeploy, iItem))
		return

	set_pev(iPlayer, pev_viewmodel2, szViewModel)
	set_pev(iPlayer, pev_weaponmodel2, szWeaponModel)

	Weapon_SendAnim(iPlayer, iItem, iAnim)
	set_pdata_string(iPlayer, m_szAnimExtention * 4, szAnimExt, -1, extra_offset_player * 4)

	set_pdata_float(iPlayer, m_flNextAttack, 0.75, extra_offset_player)
	set_pdata_float(iItem, m_flTimeWeaponIdle, 1.0, extra_offset_weapon)
	set_pdata_float(iItem, m_flLastFireTime, 0.0, extra_offset_weapon)
	set_pdata_float(iItem, m_flDecreaseShotsFired, get_gametime(), extra_offset_weapon)

	set_pev(iPlayer, pev_fov, float(WEAPON_DEFAULT_FOV))
	set_pdata_int(iPlayer, m_iFOV, WEAPON_DEFAULT_FOV, extra_offset_player)
	set_pdata_int(iPlayer, m_fResumeZoom, 0, extra_offset_player)
	set_pdata_int(iPlayer, m_iLastZoom, WEAPON_DEFAULT_FOV, extra_offset_player)
}

Weapon_DefaultReload(iItem, iPlayer, iClipSize, iAnim, Float:fDelay)
{
	static iClip; iClip = get_pdata_int(iItem, m_iClip, extra_offset_weapon)
	static iPrimaryAmmoIndex; iPrimaryAmmoIndex = PrimaryAmmoIndex(iItem)
	static iAmmoPrimary; iAmmoPrimary = GetAmmoInventory(iPlayer, iPrimaryAmmoIndex)

	if(iAmmoPrimary <= 0)
		return 0

	if(min(iClipSize - iClip, iAmmoPrimary) <= 0)
		return 0

	set_pdata_float(iPlayer, m_flNextAttack, fDelay, extra_offset_player)

	Weapon_ReloadSound(iPlayer)
	Weapon_SendAnim(iPlayer, iItem, iAnim)

	set_pdata_int(iItem, m_fInReload, 1, extra_offset_weapon)
	set_pdata_float(iItem, m_flTimeWeaponIdle, fDelay + 0.5, extra_offset_weapon)

	return 1
}

//**********************************************
//* Reload Sound                               *
//**********************************************

Weapon_ReloadSound(iPlayer)
{
	static Float:Origin[3], Float:TargetOrigin[3], Float:Distance
	pev(iPlayer, pev_origin, Origin)

	static iTarget; iTarget = 0

	while((iTarget = engfunc(EngFunc_FindEntityByString, iTarget, "classname", "player")) != 0)
	{
		if(IsDormant(iTarget))
			break

		if(iTarget == iPlayer)
			continue

		pev(iTarget, pev_origin, TargetOrigin)

		Distance = get_distance_f(TargetOrigin,  Origin)

		if(Distance <= WEAPON_DISTANCE_RELOADSOUND)
		{
			MESSAGE_BEGIN(MSG_ONE, g_MsgId_ReloadSound, {0.0, 0.0, 0.0}, iTarget)
			WRITE_BYTE(floatround((1.0 - (Distance / WEAPON_DISTANCE_RELOADSOUND)) * 255.0))
			WRITE_BYTE(1) // Normal Reload: 1, Shotgun Reload 0
			MESSAGE_END()
		}
	}
}

IsDormant(iPlayer)
{
	return (pev(iPlayer, pev_flags) & FL_DORMANT)
}

//**********************************************
//* Kick back.                                 *
//**********************************************

Weapon_KickBack(iItem, iPlayer, Float:upBase, Float:lateralBase, Float:upMod, Float:lateralMod, Float:upMax, Float:lateralMax, directionChange)
{
	static iDirection
	static iShotsFired

	static Float:vecPunchangle[3]
	pev(iPlayer, pev_punchangle, vecPunchangle)

	if((iShotsFired = get_pdata_int(iItem, m_iShotsFired, extra_offset_weapon)) != 1)
	{
		upBase += iShotsFired * upMod
		lateralBase += iShotsFired * lateralMod
	}

	upMax *= -1.0
	vecPunchangle[0] -= upBase

	if(upMax >= vecPunchangle[0])
	{
		vecPunchangle[0] = upMax
	}

	if((iDirection = get_pdata_int(iItem, m_iDirection, extra_offset_weapon)))
	{
		vecPunchangle[1] += lateralBase

		if(lateralMax < vecPunchangle[1])
		{
			vecPunchangle[1] = lateralMax
		}
	}
	else
	{
		lateralMax *= -1.0
		vecPunchangle[1] -= lateralBase

		if(lateralMax > vecPunchangle[1])
		{
			vecPunchangle[1] = lateralMax
		}
	}

	if(!random_num(0, directionChange))
	{
		set_pdata_int(iItem, m_iDirection, !iDirection, extra_offset_weapon)
	}

	set_pev(iPlayer, pev_punchangle, vecPunchangle)
}

//**********************************************
//* Hide hud.                                  *
//**********************************************

ChangeCrosshairMode(iPlayer, GrenadeMode)
{
	static iPlayerHud; iPlayerHud = get_pdata_int(iPlayer, m_iHideHUD, extra_offset_player)

	if(GrenadeMode)
	{
		iPlayerHud |= HUD_HIDE_CROSS

		set_pdata_int(iPlayer, m_iFOV, WEAPON_DEFAULT_FOV - 1, extra_offset_player)
	}
	else
	{
		iPlayerHud &= ~HUD_HIDE_CROSS

		set_pdata_int(iPlayer, m_iFOV, WEAPON_DEFAULT_FOV, extra_offset_player)
	}

	set_pdata_int(iPlayer, m_iHideHUD, iPlayerHud, extra_offset_player)

	MESSAGE_BEGIN(MSG_ONE, g_MsgId_HideWeapon, {0.0, 0.0, 0.0}, iPlayer)
	WRITE_BYTE(iPlayerHud)
	MESSAGE_END()
}

public fw_Player_Spawn_Post(iPlayer)
{
	if(!IsConnected(iPlayer))
		return

	static iActiveItem; iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, extra_offset_player)

	if(!IsValidPev(iActiveItem) || !IsCustomItem(iActiveItem))
		return

	if(get_pdata_int(iActiveItem, m_iWeaponState, extra_offset_weapon) & WPNSTATE_OICW_GRENADEMODE)
	{
		set_pdata_int(iPlayer, m_iFOV, WEAPON_DEFAULT_FOV - 1, extra_offset_player)
	}
}

//**********************************************
//* Set Animations.                            *
//**********************************************

stock Weapon_SendAnim(iPlayer, iItem, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)

	MESSAGE_BEGIN(MSG_ONE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, iPlayer)
	WRITE_BYTE(iAnim)
	WRITE_BYTE(pev(iItem, pev_body))
	MESSAGE_END()
}

stock Player_SetAnimation(iPlayer, szAnim[])
{
	#define ACT_RANGE_ATTACK1   28

	// Linux extra offsets
	#define extra_offset_animating   4
	#define extra_offset_player 5

	// CBaseAnimating
	#define m_flFrameRate      36
	#define m_flGroundSpeed      37
	#define m_flLastEventCheck   38
	#define m_fSequenceFinished   39
	#define m_fSequenceLoops   40

	// CBaseMonster
	#define m_Activity      73
	#define m_IdealActivity      74

	// CBasePlayer
	#define m_flLastAttackTime   220

	new iAnimDesired, Float:flFrameRate, Float:flGroundSpeed, bool:bLoops

	if((iAnimDesired = lookup_sequence(iPlayer, szAnim, flFrameRate, bLoops, flGroundSpeed)) == -1)
	{
		iAnimDesired = 0
	}

	static Float:flGametime; flGametime = get_gametime()

	set_pev(iPlayer, pev_frame, 0.0)
	set_pev(iPlayer, pev_framerate, 1.0)
	set_pev(iPlayer, pev_animtime, flGametime)
	set_pev(iPlayer, pev_sequence, iAnimDesired)

	set_pdata_int(iPlayer, m_fSequenceLoops, bLoops, extra_offset_animating)
	set_pdata_int(iPlayer, m_fSequenceFinished, 0, extra_offset_animating)

	set_pdata_float(iPlayer, m_flFrameRate, flFrameRate, extra_offset_animating)
	set_pdata_float(iPlayer, m_flGroundSpeed, flGroundSpeed, extra_offset_animating)
	set_pdata_float(iPlayer, m_flLastEventCheck, flGametime , extra_offset_animating)

	set_pdata_int(iPlayer, m_Activity, ACT_RANGE_ATTACK1, extra_offset_player)
	set_pdata_int(iPlayer, m_IdealActivity, ACT_RANGE_ATTACK1, extra_offset_player)
	set_pdata_float(iPlayer, m_flLastAttackTime, flGametime , extra_offset_player)
}

//**********************************************
//* Some useful stocks.                        *
//**********************************************
/*stock Float:xs_vec_len_2d(Float:vec[])
{
	return xs_sqrt(vec[0] * vec[0] + vec[1] * vec[1])
}*/

stock PunchAxis(iPlayer, Float:x, Float:y, Float:x_min = -100.0, Float:y_min = -100.0)
{
	static Float:PunchAngle[3]
	pev(iPlayer, pev_punchangle, PunchAngle)

	PunchAngle[0] += x
	PunchAngle[1] += y

	PunchAngle[0] = PunchAngle[0] < x_min ? x_min : PunchAngle[0]
	PunchAngle[0] = PunchAngle[0] > -x_min ? -x_min : PunchAngle[0]
	PunchAngle[1] = PunchAngle[1] < y_min ? y_min : PunchAngle[1]
	PunchAngle[1] = PunchAngle[1] > -y_min ? -y_min : PunchAngle[1]

	set_pev(iPlayer, pev_punchangle, PunchAngle)
}

stock Get_Position(iPlayer, Float:forw, Float:right, Float:up, Float:vStart[])
{
	new Float:Origin[3], Float:Angles[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

	pev(iPlayer, pev_origin, Origin)
	pev(iPlayer, pev_view_ofs,vUp) //for player
	xs_vec_add(Origin, vUp, Origin)
	pev(iPlayer, pev_v_angle, Angles) // if normal entity ,use pev_angles

	angle_vector(Angles, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(Angles, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(Angles, ANGLEVECTOR_UP, vUp)

	vStart[0] = Origin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = Origin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = Origin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock Stock_Velocity_By_Aim(Float:vAngle[3], Float:fAngleOffset, Float:fMulti, Float:vVelocity[3])
{
	static Float:vForward[3], Float:vAngleTemp[3]

	xs_vec_copy(vAngle, vAngleTemp)

	vAngleTemp[0] += fAngleOffset

	angle_vector(vAngleTemp, ANGLEVECTOR_FORWARD, vForward)

	xs_vec_mul_scalar(vForward, fMulti, vVelocity)
}

stock Stock_Get_Speed_Vector(Float:Origin1[3], Float:Origin2[3], Float:Speed, Float:NewVelocity[3])
{
	NewVelocity[0] = Origin2[0] - Origin1[0]
	NewVelocity[1] = Origin2[1] - Origin1[1]
	NewVelocity[2] = Origin2[2] - Origin1[2]
	new Float:num = floatsqroot(Speed*Speed / (NewVelocity[0]*NewVelocity[0] + NewVelocity[1]*NewVelocity[1] + NewVelocity[2]*NewVelocity[2]))
	NewVelocity[0] *= num
	NewVelocity[1] *= num
	NewVelocity[2] *= num

	return 1
}

stock GetGunPosition(iPlayer, Float:vecSrc[3])
{
	static Float:vecViewOfs[3]

	pev(iPlayer, pev_origin, vecSrc)
	pev(iPlayer, pev_view_ofs, vecViewOfs)
	xs_vec_add(vecSrc, vecViewOfs, vecSrc)
}

stock Stock_Get_Origin(iEntity, Float:Origin[3])
{
	if(pev(iEntity, pev_solid) == SOLID_BSP)
	{
		static Float:Maxs[3], Float:Mins[3]

		pev(iEntity, pev_maxs, Maxs)
		pev(iEntity, pev_mins, Mins)

		Origin[0] = (Maxs[0] - Mins[0]) / 2 + Mins[0]
		Origin[1] = (Maxs[1] - Mins[1]) / 2 + Mins[1]
		Origin[2] = (Maxs[2] - Mins[2]) / 2 + Mins[2]
	}
	else
	{
		pev(iEntity, pev_origin, Origin)
	}
}

stock UTIL_ScreenShake(iPlayer, Amplitude = 8, Duration = 6, Frequency = 18)
{
	if(!Amplitude)
		return

	MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, g_MsgId_ScreenShake, {0.0, 0.0, 0.0}, iPlayer)
	WRITE_SHORT((1<<12) * Amplitude)
	WRITE_SHORT((1<<12) * Duration)
	WRITE_SHORT((1<<12) * Frequency)
	MESSAGE_END()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1066\\ f0\\ fs16 \n\\ par }
*/
