--@author: Kad_Venku
--@created for Yuuzhan Vong at War

require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")


function Definitions()
    Define_State("State_Init", State_Init)
end



function State_Init(message)
    if not Get_Game_Mode() == "Space" then
        ScriptExit()
    end
    -- Despawns the marker upon use:
    if message == OnEnter then
        Sleep(4.0)
        Object.Despawn()
        ScriptExit()
    end
end



