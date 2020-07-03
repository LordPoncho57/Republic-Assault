require("PGStateMachine")
require("PGSpawnUnits")
local LayerUtility = require("libLayerZ")


function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);
	Define_State("State_AI_Autofire", State_AI_Autofire)
	Define_State("State_Human_No_Autofire", State_Human_No_Autofire)
	Define_State("State_Human_Autofire", State_Human_Autofire)

	ability_name = "FULL_SALVO"
	
end

function State_Init(message)
	if message == OnEnter then
		if Get_Game_Mode() ~= "Space" then
			ScriptExit()
		end
		LayerUtility.enterBattlefield(Object)
		if Object.Get_Owner().Is_Human() then
			Set_Next_State("State_Human_No_Autofire")
		else
			Set_Next_State("State_AI_Autofire")
		end
	end
end

function State_AI_Autofire(message)
	if message == OnUpdate then
		if Object.Get_Rate_Of_Damage_Taken() > 20.0 then
			if Object.Is_Ability_Ready(ability_name) then
				Object.Activate_Ability(ability_name, true)
			end
		end
	end		
end

function State_Human_No_Autofire(message)
	if message == OnUpdate then
		if Object.Is_Ability_Autofire(ability_name) then
			Set_Next_State("State_Human_Autofire")
		end		
	end
end

function State_Human_Autofire(message)
	if message == OnUpdate then
	
		if Object.Is_Ability_Autofire(ability_name) then
			if Object.Get_Rate_Of_Damage_Taken() > 20.0 then
				if Object.Is_Ability_Ready(ability_name) then
					Object.Activate_Ability(ability_name, true)
				end
			end
		else
			Set_Next_State("State_Human_No_Autofire")
		end
			
	end				
end