/*  SM Glow Buttons
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define DATA "1.2"
public Plugin:myinfo =
{
	name = "SM Glow Buttons",
	author = "Franc1sco franug",
	description = "",
	version = DATA,
	url = "http://steamcommunity.com/id/franug/"
};

Handle buttons;
bool csgo;

public OnPluginStart() 
{
	if (GetEngineVersion() != Engine_CSGO)csgo = false;
	else csgo = true;
	
	HookEvent("round_start", EventRoundStart);
	HookEntityOutput("func_button", "OnPressed", Presionado);
	CreateConVar("sm_glowbuttons_version", DATA, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	buttons = CreateTrie();
}

public OnMapStart()
{
	if(csgo) PrecacheModel("models/chicken/chicken.mdl");
	else PrecacheModel("materials/sprites/bomb_planted_ring.vmt");
}

public Action:EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
	ClearTrie(buttons);
	int ent2 = -1;
	while ((ent2 = FindEntityByClassname(ent2, "func_button")) != -1) 
	{

		char buffer1[256];
		float origin[3];
		int Ent;
		GetEntPropVector(ent2, Prop_Send, "m_vecOrigin", origin);
		Format(buffer1, 256, "%i", EntIndexToEntRef(ent2));
		if(csgo)
		{
			
			Ent = CreateEntityByName("prop_dynamic_glow");
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
		}
		else
		{
			Ent = CreateEntityByName("env_glow");
			if (Ent == -1)return;
			DispatchKeyValue(Ent, "model", "materials/sprites/bomb_planted_ring.vmt");
			DispatchKeyValue(Ent, "rendermode", "3");
			DispatchKeyValue(Ent, "renderfx", "14");
			DispatchKeyValue(Ent, "scale", "0.2");
			DispatchKeyValue(Ent, "renderamt", "255");
			DispatchKeyValue(Ent, "rendercolor", "0 255 0 255");
			DispatchSpawn(Ent);
			AcceptEntityInput(Ent, "ShowSprite");
			TeleportEntity(Ent, origin, NULL_VECTOR, NULL_VECTOR);	
		}
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