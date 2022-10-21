#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define BLOCK_TIME 30.0

ConVar g_cvEnabled;

bool g_CommandAllowed = true;

public Plugin myinfo = 
{
	name = "Round Start Command Blocker",
	author = "Natanel 'LuqS'",
	description = "Blockes a command for a number of seconds from the start of the round.",
	version = "1.0.0",
	url = "https://steamcommunity.com/id/luqsgood || Discord: LuqS#6505"
};

public void OnPluginStart()
{
	// So you can enable / disable the plugin
	g_cvEnabled = CreateConVar("round_start_command_blocker_enabled", "1", "any non zero value will enable the plugin, blocks a command for X seconds from round start.");
	
	// Start here the timer
	HookEvent("round_start", Event_RoundStart);
	
	// This command will be blocked	↓
	AddCommandListener(OnCommand, "sm_dance");
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	// Don't allow this command until we want it again
	g_CommandAllowed = false;
	
	// Wait X number of seconds before enabling the command again.
	CreateTimer(BLOCK_TIME, Timer_EnableCommand);
}

Action Timer_EnableCommand(Handle timer)
{
	// Time to enable it :)
	g_CommandAllowed = true;
}

public Action OnCommand(int client, const char[] command, int argc)
{
	// Check if the command is not allowed for this moment.
	if (g_cvEnabled.BoolValue && !g_CommandAllowed && !GameRules_GetProp("m_bWarmupPeriod"))
	{
		PrintToChat(client, "[SM] This command is not avilable in the first %.1f second of the round!", BLOCK_TIME);
		return Plugin_Stop;
	}
	
	// Everything is fine
	return Plugin_Continue;
}