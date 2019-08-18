#if defined _csoconst_included
	#endinput
#endif
#define _csoconst_included

#pragma compress 1
#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <xs>

#include <reapi>

// Sprites
#define SPRITE_MUZZLEFLASH  "sprites/muzzleflash12.spr"
#define SPRITE_SMOKE        "sprites/steam1.spr"
#define SPRITE_EXPLOSION    "sprites/WXplo1.spr"
#define SPRITE_FIREBALL     "sprites/zerogxplode.spr"
#define SPRITE_TRAIL        "sprites/laserbeam.spr"
#define SPRITE_BUBBLE       "sprites/bubble.spr"


//**********************************************
//* Events                                     *
//**********************************************


#define EVENT_USP       "events/usp.sc"
#define EVENT_M4A1      "events/m4a1.sc"
#define EVENT_KNIFE     "events/knife.sc"


//**********************************************
//* Private Data Offsets.                      *
//**********************************************


// Linux extra offsets
#define extra_offset_weapon     4
#define extra_offset_player     5


// CWeaponBox
#define m_rgpPlayerItems2       34


// CBasePlayerItem
#define m_pPlayer           41
#define m_pNext             42


// CBasePlayerWeapon
#define m_flStartThrow          30
#define m_flReleaseThrow        31
#define m_iSwing                32
#define m_iId                   43
#define m_fFireOnEmpty          45
#define m_flNextPrimaryAttack   46
#define m_flNextSecondaryAttack 47
#define m_flTimeWeaponIdle      48
#define m_iPrimaryAmmoType      49
#define m_iSecondaryAmmoType    50
#define m_iClip                 51
#define m_fInReload             54
#define m_fInSpecialReload      55
#define m_iDefaultAmmo          56
#define m_fMaxSpeed             58
#define m_bDelayFire            59
#define m_iDirection            60
#define m_flAccuracy            62
#define m_flLastFireTime        63
#define m_iShotsFired           64
#define m_flFamasShoot          71
#define m_iFamasShotsFired      72
#define m_fBurstSpread          73
#define m_iWeaponState          74
#define m_flNextReload          75
#define m_flDecreaseShotsFired  76
#define m_bStartedArming        78
#define m_bBombPlacedAnimation  79
#define m_fArmedTime            80

// CSprite
#define m_maxFrame              35

// CBaseMonster
#define m_flNextAttack          83
#define m_iTeam                 114

// CBasePlayer
#define random_seed             96
#define m_hObserverTarget       98
#define m_flVelocityModifier    108
#define m_iLastZoom             109
#define m_fResumeZoom           110
#define m_flEjectBrass          111
#define m_bIgnoreRadio          193
#define m_iWeaponVolume         239
#define m_iWeaponFlash          241
#define m_iFOV                  363
#define m_iHideHUD              361
#define m_iClientHideHUD        362
#define m_rgpPlayerItems        367
#define m_pActiveItem           373
#define m_pClientActiveItem     374
#define m_rgAmmo                376
#define m_szAnimExtention       492

// CbaseGrenade
#define m_bIsC4                 96
#define m_bStartDefuse          97  	//?
#define m_flDefuseCountDown     99
#define m_flC4Blow              100
#define m_flNextFreqInterval    101
#define m_flNextBeep            102
#define m_flNextFreq            103
#define m_sBeepName             104
#define m_fAttenu               105
#define m_flNextBlink           106
#define m_fNextDefuse           107     //?
#define m_bJustBlew             108
#define m_iCurWave         		110 	//?
#define m_pentCurBombTarget     111
#define m_SGSmoke               112
#define m_bLightSmoke           114


//**********************************************
//* Some macroses.                             *
//**********************************************

#define m_iBulletFired          pev_iuser3
#define m_fCooldown             pev_fuser1

#define MDLL_Spawn(%0)			dllfunc(DLLFunc_Spawn, %0)
#define MDLL_Touch(%0,%1)		dllfunc(DLLFunc_Touch, %0, %1)
#define MDLL_USE(%0,%1)			dllfunc(DLLFunc_Use, %0, %1)

#define SET_MODEL(%0,%1)		engfunc(EngFunc_SetModel, %0, %1)
#define SET_ORIGIN(%0,%1)		engfunc(EngFunc_SetOrigin, %0, %1)

#define PRECACHE_MODEL(%0)		engfunc(EngFunc_PrecacheModel, %0)
#define PRECACHE_SOUND(%0)		engfunc(EngFunc_PrecacheSound, %0)
#define PRECACHE_GENERIC(%0)	engfunc(EngFunc_PrecacheGeneric, %0)

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
#define OBS_IN_EYE 			    4

#define EMIT_SOUND(%0)			engfunc(EngFunc_EmitSound, %0)
#define EMIT_AMBIENT_SOUND(%0)	engfunc(EngFunc_EmitAmbientSound, %0)

#define NUMBER_OF_ENTITIES()	engfunc(EngFunc_NumberOfEntities)


//**********************************************
//* Messages.                                  *
//**********************************************


#define MESSAGE_HIDEWEAPON			"HideWeapon"
#define MESSAGE_WEAPONLIST			"WeaponList"
#define MESSAGE_AMMOPICKUP			"AmmoPickup"
#define MESSAGE_RELOADSOUND			"ReloadSound"
#define MESSAGE_DEATHMSG			"DeathMsg"
#define MESSAGE_SCREENSHAKE			"ScreenShake"

#define MESSAGEID_WEAPONLIST		78

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

#define HUD_HIDE_CROSS 			      (1<<6)
#define HUD_DRAW_CROSS 			      (1<<7)

//**********************************************
//* Entity Config                              *
//**********************************************

#define MUZZLEFLASH_CLASSNAME       "OICW_MuzzleFlash"
#define MUZZLE_INTOLERANCE          100

#define GRENADE_CLASSNAME           "OICW_Grenade"
#define GRENADE_INTOLERANCE         100

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

// Muzzle Flash
#define MUZZLEFLASH_SPEED		0.1
#define MUZZLEFLASH_SCALE		0.1
#define MUZZLEFLASH_BRIGHTNESS		100.0
#define MUZZLEFLASH_ATTACHMENT		3
#define MUZZLEFLASH_FRAMES		5
#define MUZZLEFLASH_RANDOMANGLES	-180.0, 180.0


stock Player_DropWeapons(iPlayer, iSlot) {
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

stock PrimaryAmmoIndex(iItem) {
    return get_pdata_int(iItem, m_iPrimaryAmmoType, extra_offset_weapon)
}

stock econdaryAmmoIndex(iItem) {
    return get_pdata_int(iItem, m_iSecondaryAmmoType, extra_offset_weapon)
}

stock GetAmmoInventory(iPlayer, iAmmoIndex) {
    if(iAmmoIndex == -1)
        return -1

    return get_pdata_int(iPlayer, m_rgAmmo + iAmmoIndex, extra_offset_player)
}

stock SetAmmoInventory(iPlayer, iAmmoIndex, iAmount) {
    if(iAmmoIndex == -1)
        return 0

    set_pdata_int(iPlayer, m_rgAmmo + iAmmoIndex, iAmount, extra_offset_player)

    return 1
}

//**********************************************
//* Set Animations.                            *
//**********************************************

stock Weapon_SendAnim(iPlayer, iItem, iAnim) {
    set_pev(iPlayer, pev_weaponanim, iAnim)

    MESSAGE_BEGIN(MSG_ONE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, iPlayer)
    WRITE_BYTE(iAnim)
    WRITE_BYTE(pev(iItem, pev_body))
    MESSAGE_END()
}

stock Player_SetAnimation(iPlayer, szAnim[]) {
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
stock PunchAxis(iPlayer, Float:x, Float:y, Float:x_min = -100.0, Float:y_min = -100.0) {
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

stock Get_Position(iPlayer, Float:forw, Float:right, Float:up, Float:vStart[]) {
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

stock Stock_Velocity_By_Aim(Float:vAngle[3], Float:fAngleOffset, Float:fMulti, Float:vVelocity[3]) {
    static Float:vForward[3], Float:vAngleTemp[3]

    xs_vec_copy(vAngle, vAngleTemp)

    vAngleTemp[0] += fAngleOffset

    angle_vector(vAngleTemp, ANGLEVECTOR_FORWARD, vForward)

    xs_vec_mul_scalar(vForward, fMulti, vVelocity)
}

stock Stock_Get_Speed_Vector(Float:Origin1[3], Float:Origin2[3], Float:Speed, Float:NewVelocity[3]) {
    NewVelocity[0] = Origin2[0] - Origin1[0]
    NewVelocity[1] = Origin2[1] - Origin1[1]
    NewVelocity[2] = Origin2[2] - Origin1[2]
    new Float:num = floatsqroot(Speed*Speed / (NewVelocity[0]*NewVelocity[0] + NewVelocity[1]*NewVelocity[1] + NewVelocity[2]*NewVelocity[2]))
    NewVelocity[0] *= num
    NewVelocity[1] *= num
    NewVelocity[2] *= num

    return 1
}

stock GetGunPosition(iPlayer, Float:vecSrc[3]) {
    static Float:vecViewOfs[3]

    pev(iPlayer, pev_origin, vecSrc)
    pev(iPlayer, pev_view_ofs, vecViewOfs)
    xs_vec_add(vecSrc, vecViewOfs, vecSrc)
}

stock Stock_Get_Origin(iEntity, Float:Origin[3]) {
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

stock UTIL_ScreenShake(iPlayer, Amplitude = 8, Duration = 6, Frequency = 18) {
    if(!Amplitude)
        return
    static g_MsgId_ScreenShake;
    if( g_MsgId_ScreenShake || (g_MsgId_ScreenShake = get_user_msgid(MESSAGE_SCREENSHAKE)) )
    {
        MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, g_MsgId_ScreenShake, {0.0, 0.0, 0.0}, iPlayer)
        WRITE_SHORT((1<<12) * Amplitude)
        WRITE_SHORT((1<<12) * Duration)
        WRITE_SHORT((1<<12) * Frequency)
        MESSAGE_END()
    }
}

//**********************************************
//* Default fuctions                           *
//**********************************************

stock Weapon_DefaultDeploy(iItem, iPlayer, szViewModel[], szWeaponModel[], iAnim, szAnimExt[], ifov) {
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

    set_pev(iPlayer, pev_fov, float(ifov))
    set_pdata_int(iPlayer, m_iFOV, ifov, extra_offset_player)
    set_pdata_int(iPlayer, m_fResumeZoom, 0, extra_offset_player)
    set_pdata_int(iPlayer, m_iLastZoom, ifov, extra_offset_player)
}

stock Weapon_DefaultReload(iItem, iPlayer, iClipSize, iAnim, Float:fDelay) {
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
//* Hide hud.                                  *
//**********************************************

stock ChangeCrosshairMode(iPlayer, GrenadeMode) {
    static iPlayerHud; iPlayerHud = get_pdata_int(iPlayer, m_iHideHUD, extra_offset_player)

    if(GrenadeMode) {
        iPlayerHud |= HUD_HIDE_CROSS;
    }
    else {
        iPlayerHud &= ~HUD_HIDE_CROSS;
    }

    set_pdata_int(iPlayer, m_iHideHUD, iPlayerHud, extra_offset_player)

    static g_MsgId_HideWeapon;
    if( g_MsgId_HideWeapon || (g_MsgId_HideWeapon = get_user_msgid(MESSAGE_HIDEWEAPON)) ) {
        MESSAGE_BEGIN(MSG_ONE, g_MsgId_HideWeapon, {0.0, 0.0, 0.0}, iPlayer)
        WRITE_BYTE(iPlayerHud)
        MESSAGE_END()
    }
}

//**********************************************
//* Player Check                               *
//**********************************************
IsPlayer(iEntity) {
    return (ExecuteHamB(Ham_Classify, iEntity) == CLASS_PLAYER)
}

IsConnected(iPlayer) {
    return IsValidPev(iPlayer)
}

//**********************************************
//* Multi Damage Controler                     *
//**********************************************

stock ClearMultiDamage() {
    rg_multidmg_clear()
}

stock ApplyMultiDamage(iEntity, iAttacker) {
    rg_multidmg_apply(iEntity, iAttacker)
}

//**********************************************
//* Số đạn đã bắn                              *
//**********************************************

stock getUserFired(id) {
    return pev(id, m_iBulletFired);
}
stock setUserFired(id, fired) {
    set_pev(id, m_iBulletFired, fired);
}

//**********************************************
//* Cooldown Mode                              *
//**********************************************

stock Float:getUserCooldown(id) {
    return float(pev(id, m_fCooldown));
}
stock setUserCooldown(id, Float:cooldown) {
    set_pev(id, m_fCooldown, cooldown);
}



//**********************************************
//* FireBullets3                               *
//**********************************************

// Materials
#define CHAR_TEX_CONCRETE 'C'
#define CHAR_TEX_METAL 'M'
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
#define CLASS_NONE          0
#define CLASS_MACHINE           1
#define CLASS_PLAYER            2
#define CLASS_HUMAN_PASSIVE     3
#define CLASS_HUMAN_MILITARY        4
#define CLASS_ALIEN_MILITARY        5
#define CLASS_ALIEN_PASSIVE     6
#define CLASS_ALIEN_MONSTER     7
#define CLASS_ALIEN_PREY        8
#define CLASS_ALIEN_PREDATOR        9
#define CLASS_INSECT            10
#define CLASS_PLAYER_ALLY       11
#define CLASS_PLAYER_BIOWEAPON      12
#define CLASS_ALIEN_BIOWEAPON       13
#define CLASS_VEHICLE           14
#define CLASS_BARNACLE          99

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
