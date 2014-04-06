#include <a_samp>
//AC
//GitHub edit

/*
		AC_CheckTeleport(i);
		AC_CheckAirBreak(i);
		AC_CheckFly(i);
		AC_CheckCar(i);
		FakeKill
		ColorChanger
		CarFloat
		WeaponHack
		AmmoHack
		Speedhack
*/
#define MAX_CARS 	2000
#define MAX_PLAYERS	500

#define CHEAT_TELEPORT		1
#define CHEAT_AIRBRK		2
#define CHEAT_FLY			3
#define CHEAT_CAR			4
#define CHEAT_FAKEKILL		5
#define CHEAT_COLORCHANG	6
#define CHEAT_CARFLOAT		7
#define CHEAT_WEAPONHACK	8
#define CHEAT_AMMOHACK		9
#define CHEAT_SPEEDHACK		10

new CarInfo[MAX_CARS][eCars];
new PlayerInfo[MAX_PLAYERS][ePlayers];

enum ePlayers {
	Float:pPos[3],
    Float:pOldPos[3],
	//ANTY CHEAT
    bool:CarSpeed,
    bool:DeathTimer,
    bool:ColorTimer,
    bool:CarFloatTimer
};

enum eCars {
	Float:cPos[3],
    Float:cOldPos[3],
	Float:ac_POS[2],
    ac_Warns
};

//ANTI CHEAT
forward AntiCheat();
forward CheckCarSpeedCheat(playerid);
forward DeathOK(playerid);
forward ColorOK(playerid);
forward CarOK(playerid);

forward OnPlayerHack(playerid, cheatid);
forward CarCheck();
forward AC_CheckTeleport(playerid);
forward AC_CheckAirBreak(playerid);
forward AC_CheckFly(playerid);
forward AC_CheckCar(playerid);
forward AC_CheckPortal(playerid);

public OnFilterScriptInit()
{
	SetTimer("AntiCheat", 2500, 1);
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(!PlayerInfo[playerid][DeathTimer])SetTimerEx("DeathOK",500,false,"i",playerid),PlayerInfo[playerid][DeathTimer]=true;
    else if(PlayerInfo[playerid][DeathTimer])
    {
        SetPVarInt(playerid, "Death", GetPVarInt(playerid, "Death")+1);
        if(GetPVarInt(playerid, "Death")==4)return CallRemoteFunction("OnPlayerHack", "dd", playerid,CHEAT_FAKEKILL); // Fake Kill Hack
    }
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    if(!PlayerInfo[playerid][ColorTimer])SetTimerEx("ColorOK",500,false,"i",playerid),PlayerInfo[playerid][ColorTimer]=true;
    else if(PlayerInfo[playerid][ColorTimer])
    {
        SetPVarInt(playerid, "Color", GetPVarInt(playerid, "Color")+1);
        if(GetPVarInt(playerid, "Color")==5)return CallRemoteFunction("OnPlayerHack", "dd", playerid,CHEAT_COLORCHANGE); // Vehicle Color Hack
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    //AC
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
    {
        if(!PlayerInfo[playerid][CarFloatTimer])SetTimerEx("CarOK",400,false,"i",playerid),PlayerInfo[playerid][CarFloatTimer]=true;
        else if(PlayerInfo[playerid][CarFloatTimer])
        {
            SetPVarInt(playerid, "CarFloat", GetPVarInt(playerid, "CarFloat")+1);
            if(GetPVarInt(playerid, "CarFloat")==5)CallRemoteFunction("OnPlayerHack", "dd", playerid,CHEAT_CARFLOAT); // Car Float/Circle HACK
        }
    }
	return 1;
}

public AntiCheat()
{
	foreach(Player, i)
	{
		if(!IsPlayerConnected(i)) continue;
		AC_CheckTeleport(i);
		AC_CheckAirBreak(i);
		AC_CheckFly(i);
		AC_CheckCar(i);
	}
}

public AC_CheckTeleport(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x,y,z);
    if(GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID && GetPlayerSurfingObjectID(playerid) == INVALID_OBJECT_ID)
    {
        new Float:dist;
        dist = GetDistanceBetweenPoints(PlayerInfo[playerid][pOldPos][0], PlayerInfo[playerid][pOldPos][1], PlayerInfo[playerid][pOldPos][2], x,y,z);
        if(!GetPVarInt(playerid, "teleport"))
        {
            if(dist > 250)
            {
                if(GetPVarInt(playerid, "spawned") == 1 && GetPVarInt(playerid, "ac_jump") == 0)
                {
                    CallRemoteFunction("OnPlayerHack", "ii", playerid, CHEAT_TELEPORT);
                }
            }
        }
        else
        {
            SetPVarInt(playerid, "teleport", 0);
        }
    }
    PlayerInfo[playerid][pOldPos][0] = x;
    PlayerInfo[playerid][pOldPos][1] = y;
    PlayerInfo[playerid][pOldPos][2] = z;
}

public AC_CheckAirBreak(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x,y,z);
    if(!IsPlayerInAnyVehicle(playerid) && GetPlayerSpeed(playerid) > 5)
    {
        if(GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID && GetPlayerSurfingObjectID(playerid) == INVALID_OBJECT_ID)
        {
            new Float:dist;
            dist = GetDistanceBetweenPoints(PlayerInfo[playerid][pOldPos][0], PlayerInfo[playerid][pOldPos][1], PlayerInfo[playerid][pOldPos][2], x,y,z);
            if(!GetPVarInt(playerid, "teleport"))
            {
                if(dist > 250)
                {
                    if(GetPVarInt(playerid, "spawned") == 1 && GetPVarInt(playerid, "ac_jump") == 0 && IsPlayerFalling(playerid) == 0)
                    {
                        CallRemoteFunction("OnPlayerHack", "ii", playerid, CHEAT_AIRBRK);
                    }
                }
            }
            else
            {
                SetPVarInt(playerid, "teleport", 0);
            }
        }
    }
    PlayerInfo[playerid][pOldPos][0] = x;
    PlayerInfo[playerid][pOldPos][1] = y;
    PlayerInfo[playerid][pOldPos][2] = z;
}

public AC_CheckFly(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid) && GetPlayerSpeed(playerid) > 5)
    {
        static animlib[32], animname[32];
        GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);
        if(strcmp(animlib, "SWIM", true) == 0 && PlayerInfo[playerid][pPos][2] > 5.0)
        {
            if(GetDistanceBetweenPoints(PlayerInfo[playerid][pOldPos][0], PlayerInfo[playerid][pOldPos][1], PlayerInfo[playerid][pOldPos][2], PlayerInfo[playerid][pPos][0], PlayerInfo[playerid][pPos][1], PlayerInfo[playerid][pPos][2]) > 25)
            {
                CallRemoteFunction("OnPlayerHack", "ii", playerid, CHEAT_FLY);
            }
        }
    }
}

public AC_CheckCar(playerid)
{
    if(IsPlayerInAnyVehicle(playerid))
    {
        static veh, speed,Float:x, Float:y, Float:z, Float:dist;
        veh = GetPlayerVehicleID(playerid);
        speed = GetVehicleSpeed(veh);
        GetVehiclePos(veh, x, y, z);
        dist = GetDistanceBetweenPoints(CarInfo[veh][cOldPos][0],CarInfo[veh][cOldPos][1],CarInfo[veh][cOldPos][2],x,y,z);
        if(speed < 5)
        {
            if(dist > 250)
            {
                CallRemoteFunction("OnPlayerHack", "ii", playerid, CHEAT_CAR);
            }
        }
        CarInfo[veh][cOldPos][0] = x;
        CarInfo[veh][cOldPos][1] = y;
        CarInfo[veh][cOldPos][2] = z;
    }
}

public OnPlayerHack(playerid, cheatid)
{
 //uzupełnić
}

//STOCKS
stock GetVehicleSpeed(vehicleid)
{
    if(vehicleid != INVALID_VEHICLE_ID)
    {
        new Float:Pos[3],Float:VS ;
        GetVehicleVelocity(vehicleid, Pos[0], Pos[1], Pos[2]);
        VS = floatsqroot(Pos[0]*Pos[0] + Pos[1]*Pos[1] + Pos[2]*Pos[2])*136.6666;
        return floatround(VS,floatround_round);
    }
    return INVALID_VEHICLE_ID;
}

stock GetPlayerSpeed(playerid)
{
    new Float:Pos[3],Float:VS ;
    GetPlayerVelocity(playerid, Pos[0], Pos[1], Pos[2]);
    VS = floatsqroot(Pos[0]*Pos[0] + Pos[1]*Pos[1] + Pos[2]*Pos[2])*136.6666;
    return floatround(VS,floatround_round);
}