#include <sourcemod>

public Plugin myinfo =
{
	name = "ScoreBar",
	author = "Neidermeyer",
	description = "Quake3-style scorebar showing best player and clients score in deathmatch and team scores in team deathmatch",
	version = "0.0",
	url = ""
};

new Handle:SBar;
new Handle:teamPlay;

new PlayersScores[MAXPLAYERS+1];

public void OnPluginStart()
{
	SBar = CreateConVar("ScoreBar", "1", "Enable ScoreBar");
	teamPlay = FindConVar("mp_teamplay");
    HookEvent("player_death", Event_PlayerDied);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_disconnect", Event_PlayerDisconnect); 
	
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	if (GetConVarInt(SBar) == 1){
		CreateTimer(0.3, updateScores);   //cause scores do not seem to be updated instantly
	}	
}

public void Event_PlayerDied(Event event, const char[] name, bool dontBroadcast)
{
	if (GetConVarInt(SBar) == 1){
		CreateTimer(0.3, updateScores);   //cause scores do not seem to be updated instantly
	}
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (GetConVarInt(SBar) == 1){
		CreateTimer(0.3, updateScores);   //cause scores do not seem to be updated instantly
	}
}

public Action updateScores(Handle timer)
{
	if (GetConVarInt(teamPlay) == 0){
		new max = GetClientFrags(1);
		new second = 0;
		new clsecond = 1;
		new clmax = 1;
		
		//Getting two first players
		for (new client = 2; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsClientAuthorized(client))
			{
				PlayersScores[client] = GetClientFrags(client);
				if (PlayersScores[client] > max){
					second = max;
					clsecond = clmax;
					max = PlayersScores[client];
					clmax = client;
					} else if (PlayersScores[client] >= second){
					second = PlayersScores[client];
					clsecond = client;
				}					
			}
		}
		
		decl color[4] = {255, 220, 0, 200};
		decl String:maxname[255];
		GetClientName(clmax, maxname, 255);
		
		decl String:secondname[255];
		GetClientName(clsecond, secondname, 255);
		
		//Printing first and second players to everyone
		for (new client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && !IsFakeClient(client) && IsClientAuthorized(client) && client != clmax)
			{
				SetHudTextParamsEx(-1.0, 0.02, 999.0, color, color, 0, 0.0, 0.0, 0.0);
				ShowHudText(client, 255, "№1: %d by %s, №2: %d by %s", max, maxname, second, secondname);		
			}
		}
		
		//For first player
		SetHudTextParamsEx(-1.0, 0.02, 999.0, color, color, 0, 0.0, 0.0, 0.0);
		ShowHudText(clmax, 255, "№1: %d by %s, №2: %d by %s", max, maxname, second, secondname);
	}
	return Plugin_Stop; 
}