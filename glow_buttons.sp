#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define DATA "1.1"
public Plugin:myinfo =
{
	name = "SM Glow Buttons",
	author = "Franc1sco franug",
	description = "",
	version = DATA,
	url = "http://steamcommunity.com/id/franug/"
};

Handle buttons;

public OnPluginStart() 
{
	HookEvent("round_start", EventRoundStart);
	HookEntityOutput("func_button", "OnPressed", Presionado);
	CreateConVar("sm_glowbuttons_version", DATA, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	buttons = CreateTrie();
}

public OnMapStart()
{
	PrecacheModel("models/chicken/chicken.mdl");
}

public Action:EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
	ClearTrie(buttons);
	int ent2 = -1;
	while ((ent2 = FindEntityByClassname(ent2, "func_button")) != -1) 
	{
		char buffer1[256];
		float origin[3];
		GetEntPropVector(ent2, Prop_Send, "m_vecOrigin", origin);
		Format(buffer1, 256, "%i", EntIndexToEntRef(ent2));
		new Ent = CreateEntityByName("prop_dynamic_glow");
		if (Ent == -1)return;
		DispatchKeyValue(Ent, "model", "models/chicken/chicken.mdl");
		DispatchKeyValue(Ent, "disablereceiveshadows", "1");
		DispatchKeyValue(Ent, "disableshadows", "1");
		DispatchKeyValue(Ent, "solid", "0");
		DispatchKeyValue(Ent, "spawnflags", "256");
		SetEntProp(Ent, Prop_Send, "m_CollisionGroup", 11);
		DispatchSpawn(Ent);
		TeleportEntity(Ent, origin, NULL_VECTOR, NULL_VECTOR);
		SetEntProp(Ent, Prop_Send, "m_bShouldGlow", true, true);
		SetEntPropFloat(Ent, Prop_Send, "m_flGlowMaxDist", 10000000.0);
		SetGlowColor(Ent, "0 255 0");
		SetEntPropFloat(Ent, Prop_Send, "m_flModelScale", 0.7);
		SetVariantString("!activator");
		AcceptEntityInput(Ent, "SetParent", ent2);
		
		SetTrieValue(buttons, buffer1, EntIndexToEntRef(Ent));
	}
}

stock void SetGlowColor(int entity, const char[] color)
{
    char colorbuffers[3][4];
    ExplodeString(color, " ", colorbuffers, sizeof(colorbuffers), sizeof(colorbuffers[]));
    int colors[4];
    for (int i = 0; i < 3; i++)
        colors[i] = StringToInt(colorbuffers[i]);
    colors[3] = 255; // Set alpha
    SetVariantColor(colors);
    AcceptEntityInput(entity, "SetGlowColor");
}  

public Presionado(const String:output[], caller, activator, Float:delay)
{
	char buffer1[256];
	int theglow;

	Format(buffer1, 256, "%i", EntIndexToEntRef(caller));
	if (!GetTrieValue(buttons, buffer1, theglow))return;
	theglow = EntRefToEntIndex(theglow);
	
	if (theglow == INVALID_ENT_REFERENCE) return;
	
	AcceptEntityInput(theglow, "Kill");
}