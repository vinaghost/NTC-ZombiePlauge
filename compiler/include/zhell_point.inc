/*
 * SIMPLE POINTS API
 * by xPaw
 *
 * Website: https://xpaw.me/
 */

#if defined zhell_point_Included
    #endinput
#endif
#define zhell_point_Included

#if AMXX_VERSION_NUM >= 175
    #pragma reqlib zhell_point
    #if !defined AMXMODX_NOAUTOLOAD
        #pragma loadlib zhell_point
    #endif
#else
    #pragma library zhell_point
#endif

/*
 * Adds (or removes if negative) points from player
 *
 * @param       id - Player id
 * @param       iPoints - Points to add (or deduct if value is negative)
 *
 * @return      Returns true on success
 */
native points_add( id, iPoints );

/*
 * Get player's points
 *
 * @param       id - Player id
 *
 * @return      Returns player's points
 */
native points_get( id );

/*
 * Changes player's points to iPoints value
 *
 * @param       id - Player id
 * @param       iPoints - Points to set
 *
 * @return      Returns true on success
 */
native points_set( id, iPoints );

/*
 * Called when player just got his `Id` from database,
 * after this point, it is safe to use natives
 *
 * @param       id - Player id
 *
 */
forward points_client_connected( id, iPoints );


/*
 * Called when player just got his points
 *
 * @param       id - Player id
 * @param       iPoints - Points to reward
 *
 */
forward points_client_reward(id , iPoints);
