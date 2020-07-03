--[[
==================== YVAW ====================
@AUTHOR: Kad_Venku
@created for Yuuzhan Vong at War
@DATE: 24/02/2016
@TIME: 19:00
This script enables friendly fire and an area of effect damage.
==================== YVAW ====================
]]

require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")

function Definitions()
    Define_State("State_Init", State_Init);
end

function State_Init(message)
    if message==OnEnter then
		if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end
        hostile = Find_Player("Hostile")
        Object.Change_Owner(hostile)
	else
		ScriptExit()
    end
end