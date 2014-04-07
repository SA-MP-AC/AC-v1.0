#include <a_samp>

#define CZULOSC_AFK 500
#define	CZULOSC_HP 50

#define SetPlayerHealth(%1,%2) SPH(%1,%2)


native SPHF(playerid, Float:health) = SetPlayerHealth;

stock SPH(playerid, Float:health)
{
	OnPlayerTakeDamage(playerid, INVALID_PLAYER_ID, 100.0, 54);
	SPHF(playerid, health);
}



new auta[MAX_PLAYERS];
new AutaTickCount[MAX_PLAYERS];
new bron[MAX_PLAYERS];

forward OnPlayerWeaponChange(playerid, oldweapon, newweapon);


public OnVehicleDeath(vehicleid, killerid)
{
	SendClientMessageToAll(-1, "OnVhclDeath");
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	SendClientMessageToAll(-1, "OPTD");
	SetPVarInt(playerid, "OstatnieObrazenie", GetTickCount() );
	new string[128];
	format(string, 128, "Gracz %d otrzymal %f obrazen od %d z broni %d", playerid, amount, issuerid, weaponid);
	SendClientMessageToAll(0x0044FFFF, string);
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	SendClientMessageToAll(-1, "OPGD");
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new string[128];
	format(string, 128, "[DEBUG] Gracz %d zgin¹³ z rêki %d za pomoc¹ broni %d", playerid, killerid, reason);
	SendClientMessageToAll(0x1122FFFF, string);
		
		
	if(reason == 255 && killerid == INVALID_PLAYER_ID && (GetPVarInt(playerid, "PoprzedniStan") ==2  || GetPVarInt(playerid, "PoprzedniStan") == 3) )
	{
		SetPVarInt(playerid, "OstatniaSmierc", GetTickCount() );
		return 1;
	}
	if( (GetTickCount() - GetPVarInt(playerid, "OstatniaSmierc") < CZULOSC_AFK ) || (GetTickCount() - GetPVarInt(playerid, "OstatnieObrazenie")  > CZULOSC_HP ))
	{
		format(string, 128, "%d robi FK skurwysyn!!");
		SendClientMessageToAll(0x1234FFFF, string);
			
	}

	SetPVarInt(playerid, "OstatniaSmierc", GetTickCount() );
	return 1;
}


public OnFilterScriptInit()
{

	return 1;
}

public OnFilterScriptExit()
{

	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/hp", true))
	{
		new string[128], Float:hp;
		GetPlayerHealth(playerid, hp);
		format(string, 128, "Masz %f HP", hp);
		SendClientMessage(playerid, 0x35A80AFF, string);
		return 1;
	}
	if(!strcmp(cmdtext, "/kill", true))
	{
		SetPlayerHealth(playerid, 0);
		return 1;
	}
	return 0;
}

public OnPlayerConnect(playerid)
{
	AutaTickCount[playerid] = auta[playerid] = bron[playerid] = 0;
	SetPVarInt(playerid, "OstatniaSmierc", 0 );
	return 1;
}
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	if( vehicleid == GetPlayerVehicleID(playerid) )
	{
		new napis[128];
		format(napis, sizeof(napis), "Pomalowa³eœ pojazd o ID: %d", vehicleid);
		SendClientMessage(playerid, -1, napis);
		SendClientMessage(playerid, 0xFF0000FF, "Ryj se pomaluj kurwo jebana!!!!!!!!!!1111");
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new string[256];
	format(string, sizeof(string), "Gracz %d wszedl do pojazdu o ID: %d jako %d", playerid, vehicleid, ispassenger);
	//SendClientMessageToAll(-1, string);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	SetPVarInt(playerid, "PoprzedniStan", oldstate);
	new string[256];
	format(string, sizeof(string), "Gracz %d zmieni³ stan z %d na %d", playerid, oldstate, newstate);
	SendClientMessageToAll(-1, string);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	new gun = GetPlayerWeapon(playerid);
	if( gun != bron[playerid] )
	{
		OnPlayerWeaponChange(playerid, bron[playerid], gun);
		bron[playerid] = gun;
	}
	new car = GetPlayerVehicleID(playerid);
	if(car != auta[playerid])
	{
		new tick = GetTickCount();  
		{
			
			if( tick - AutaTickCount[playerid] <=500)
			{
				new string[256], name[MAX_PLAYER_NAME+1];
				GetPlayerName(playerid, name, sizeof(name));
				format(string, sizeof(string), "%s czituje skurwysyn jebany!!!111", name);
				SendClientMessageToAll( 0xFF0000FF, string);
				//Ban(playerid);
				//return 0;
			}
			auta[playerid] = car;
		}
		AutaTickCount[playerid] = tick;
	}
	
	return 1;
}

public OnPlayerWeaponChange(playerid, oldweapon, newweapon)
{
	new string[256];
	format(string, sizeof(string), "Gracz %d zmienil bron z %d na %d", playerid, oldweapon, newweapon);
	//SendClientMessage(playerid, -1, string);
	return 1;
}
