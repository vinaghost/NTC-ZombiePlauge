    
    #include <amxmodx>
    #include <orpheu_memory>

    public plugin_init ()
    {
        register_plugin( "Max Start Money", "1.0.0", "Arkshine" );
        
        PatchMemory();
    }

    PatchMemory()
    {
        const MAX_MONEY             = 999999;
        const Float:MAX_MONEY_FLOAT = 999999.0;

        new const maxMoneyEntriesFloat[][] =
        {
            "maxStartMoney@CheckStartMoney()#SetCvar",
            "maxStartMoney@ClientPutInServer()#SetCvar",
            "maxStartMoney@HandleMenu_ChooseTeam()#SetCvar"
        };

        new const maxMoneyEntriesNonFloat[][] =
        {
            "maxStartMoney@CheckStartMoney()#Check",
            "maxStartMoney@ClientPutInServer()#Check",
            "maxStartMoney@HandleMenu_ChooseTeam()#Check",
            "maxStartMoney@CBasePlayer::AddAccount()#Check",
            "maxStartMoney@CBasePlayer::AddAccount()#Set",
            "maxStartMoney@CBasePlayer::JoiningThink()#Check",
            "maxStartMoney@CBasePlayer::JoiningThink()#Set",
            "maxStartMoney@CBasePlayer::Reset()#Check",
            "maxStartMoney@CBasePlayer::Reset()#Set",
            "maxStartMoney@CHalfLifeTraining::PlayerThink()#Check",
            "maxStartMoney@CHalfLifeTraining::PlayerThink()#Set"
        };

        new const messageHeaderSigNotFound [] = "* Signature was not found in '%s'";
        new const messageHeaderSigFoundInfo[] = "* Max start money changed to '%d'. Total Patches : %d";
        
        new offsetsPatched;
        new i;

        for ( i = 0; i < sizeof maxMoneyEntriesFloat; i++ )
        {
            if ( !OrpheuMemorySet( maxMoneyEntriesFloat[ i ], 1, MAX_MONEY_FLOAT ) )
            {
                log_amx( messageHeaderSigNotFound, maxMoneyEntriesFloat[ i ] );
                continue;
            }

            offsetsPatched++;
        }

        for ( i = 0; i < sizeof maxMoneyEntriesNonFloat; i++ )
        {
            if ( !OrpheuMemorySet( maxMoneyEntriesNonFloat[ i ], 1, MAX_MONEY ) )
            {
                log_amx( messageHeaderSigNotFound, maxMoneyEntriesNonFloat[ i ] );
                continue;
            }

            offsetsPatched++;
        }

        log_amx( messageHeaderSigFoundInfo, MAX_MONEY, offsetsPatched );
    }
