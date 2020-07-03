--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
-- ____    ____  __    __   __    __   ________   __    __       ___      .__   __.    
-- \   \  /   / |  |  |  | |  |  |  | |       /  |  |  |  |     /   \     |  \ |  |    
--  \   \/   /  |  |  |  | |  |  |  | `---/  /   |  |__|  |    /  ^  \    |   \|  |    
--   \_    _/   |  |  |  | |  |  |  |    /  /    |   __   |   /  /_\  \   |  . `  |    
--     |  |     |  `--'  | |  `--'  |   /  /----.|  |  |  |  /  _____  \  |  |\   |    
--     |__|      \______/   \______/   /________||__|  |__| /__/     \__\ |__| \__|    
--                                                                                     
-- ____    ____  ______   .__   __.   _______                                          
-- \   \  /   / /  __  \  |  \ |  |  /  _____|                                         
--  \   \/   / |  |  |  | |   \|  | |  |  __                                           
--   \      /  |  |  |  | |  . `  | |  | |_ |                                          
--    \    /   |  `--'  | |  |\   | |  |__| |                                          
--     \__/     \______/  |__| \__|  \______|                                          
--                                                                                     
--      ___   .___________.   ____    __    ____  ___      .______                     
--     /   \  |           |   \   \  /  \  /   / /   \     |   _  \                    
--    /  ^  \ `---|  |----`    \   \/    \/   / /  ^  \    |  |_)  |                   
--   /  /_\  \    |  |          \            / /  /_\  \   |      /                    
--  /  _____  \   |  |           \    /\    / /  _____  \  |  |\  \----.               
-- /__/     \__\  |__|            \__/  \__/ /__/     \__\ | _| `._____|          
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--@ORIGINAL AUTHOR: Kad_Venku
--@EDITED BY:
--@FILE: HBR_Ability_Y-Wing_ADV
--@DATE: 05.03.2016
--@TIME: 12:56
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")

function Definitions()
    ServiceRate = 0.05

    Define_State("State_Init", State_Init)

    Define_State("State_Wait_For_Input", State_Wait_For_Input)
    Define_State("State_Begin_Bombing_Run", State_Begin_Bombing_Run)
    Define_State("State_Drop_Bombs", State_Drop_Bombs)
    Define_State("State_Return_Home", State_Return_Home)
    Define_State("State_Home", State_Home)
    Define_State("State_Reset_Ability", State_Reset_Ability)
    Define_State("State_Wait_For_Recharge", State_Wait_For_Recharge)
    Define_State("State_Self_Destruct", State_Self_Destruct)
    --Define_State("State_Being_Recharged", State_Being_Recharched)

    target_lock = "WEAKEN_ENEMY"

    drop_bomb = "HARMONIC_BOMB"

    ability_2 = "TURBO"

    target_lock_usage_counter = 0
    target_lock_usage_limit = 2

    recharge_time=10
    recharge_rate=1
    recharge_state=0
    --recharge_ability="Neb_Range_Repair_Bay_Healing"
    --recharge_ability="Neb_B_Recharge"
    activation_distance=200
    bomb_drop_timer=1.0
    home_distance=150

    bombing_target=nil
    return_home=nil
    locked = false
    ability_was_triggered=false
    adv_state=false

    unit_type="GA_Y-Wing_Adv"
    squadron={}
end

function State_Init(message)
    if message == OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end
        Sleep (6.0)
        local tmp_squad=Find_All_Objects_Of_Type(unit_type)
        for _,fighter in pairs(tmp_squad) do
            if fighter.Get_Parent_Object()==Object then
                table.insert(squadron, fighter)
            end
        end
        Sleep(1.0)
        Set_Next_State("State_Wait_For_Input")
    end
end

function State_Wait_For_Input(message)
    if message == OnUpdate then
        -- AI mode
        --[[
        for _,fighter in pairs(squadron) do
            if TestValid(fighter) then
                if not fighter.Get_Owner().Is_Human() and fighter.Has_Ability(target_lock) and fighter.Is_Ability_Ready(target_lock) then
                    if target_lock_usage_counter < target_lock_usage_limit and not locked then
                        fighter.Activate_Ability(target_lock,true)
                    end
                end
            end
        end]]

        for _,fighter in pairs(squadron) do
            if TestValid(fighter) then
                if fighter.Has_Ability(target_lock) and not fighter.Is_Ability_Ready(target_lock) and not fighter.Is_In_Nebula()then
                    if target_lock_usage_counter < target_lock_usage_limit and not locked then
                        adv_state=true
                    end
                end
            end
        end
        if target_lock_usage_counter < target_lock_usage_limit and adv_state then
            adv_state=false
            Set_Next_State("State_Begin_Bombing_Run")
        end
        --[[if Object.Is_Under_Effects_Of_Ability(recharge_ability) and Object.Has_Ability(target_lock) and target_lock_usage_counter >= target_lock_usage_limit and locked then
        Object.Highlight(true)
            Set_Next_State("State_Being_Recharged")
        end]]
    end
end

function State_Begin_Bombing_Run(message)
    if message == OnEnter then
        local marker_list=Find_All_Objects_Of_Type("Space_Bombardment_Spawn_Marker")
        local closest=1500
        local shiplist=Find_All_Objects_Of_Type("Hero | Capital | Frigate")
        for _,unit in pairs(shiplist)do
            if unit.Get_Owner()==Object.Get_Owner().Get_Enemy() then
                if unit.Get_Distance(marker_list[1])<=closest then
                    closest=unit.Get_Distance(marker_list[1])
                    bombing_target=unit
                end
            end
        end
        if bombing_target~=nil then
            return_home=Object.Get_Position()
            -- If you like realism, uncomment this and the end below:
            --[[local failiure_chance=GameRandom(1,100)
            if failiure_chance==50 then
                Set_Next_State("State_Self_Destruct")
            else]]
            for _,fighter in pairs(squadron) do
                if TestValid(fighter) then
                    if fighter.Has_Ability(ability_2) and fighter.Is_Ability_Ready(ability_2) then
                        fighter.Activate_Ability(ability_2,true)
                    end
                end
            end
            Object.Prevent_Opportunity_Fire(true)
            Object.Attack_Target(bombing_target)
            Object.Lock_Current_Orders()
            Set_Next_State("State_Drop_Bombs")
            --end
        else
            Set_Next_State("State_Wait_For_Recharge")
        end

    end
end

function State_Drop_Bombs(message)
    if message== OnUpdate then
        Object.Prevent_Opportunity_Fire(true)
        local distance=Object.Get_Distance(bombing_target)
        if distance < activation_distance then
            Object.Prevent_Opportunity_Fire(true)
            --Sleep(bomb_drop_timer)
            for _,fighter in pairs(squadron) do
                if TestValid(fighter) then
                    if fighter.Has_Ability(ability_2) and fighter.Is_Ability_Active(ability_2) then
                        fighter.Cancel_Ability(ability_2)
                    end
                end
            end
            --[[for _,fighter in pairs(squadron) do
                if TestValid(fighter) then
                    if fighter.Is_Ability_Ready(drop_bomb) then
                        fighter.Activate_Ability(drop_bomb,true)
                    end
                end
            end
            Sleep(1.0)]]
            for _,fighter in pairs(squadron) do
                if TestValid(fighter) then
                    if fighter.Is_Ability_Ready(drop_bomb) then
                        fighter.Activate_Ability(drop_bomb,true)
                    end
                end
            end
            Sleep(2.0)
            ability_was_triggered=true
            Set_Next_State("State_Return_Home")
        end
        -- abort if target is going to be destroyed any second anyways.
        if bombing_target.Get_Hull()<=0.01 then
            Set_Next_State("State_Return_Home")
        end
    end
end

function State_Return_Home(message)
    if message == OnEnter then
        Object.Move_To(return_home)
        Object.Prevent_Opportunity_Fire(true)
        Object.Lock_Current_Orders()
        Set_Next_State("State_Home")
    end
end

function State_Home(message)
    if message == OnUpdate then
        local distance=Object.Get_Distance(return_home)
        if distance <= home_distance then
            Sleep(1.0)
            Object.Prevent_Opportunity_Fire(false)
            Set_Next_State("State_Reset_Ability")
        end
    end
end


function State_Reset_Ability(message)
    if message == OnEnter then
        if ability_was_triggered then
            target_lock_usage_counter = target_lock_usage_counter + 1
            ability_was_triggered=false
            if target_lock_usage_counter >= target_lock_usage_limit then
                bombing_target=nil
                return_home=nil
                lock=true
            end
        end
        Set_Next_State("State_Wait_For_Recharge")
    end
end

function State_Wait_For_Recharge(message)
    if message==OnUpdate then
        if Object.Is_Ability_Ready(target_lock) then
            Set_Next_State("State_Wait_For_Input")
        end
    end
end

function State_Self_Destruct(message)
    if message== OnEnter then
        for _,fighter in pairs(squadron) do
            if TestValid(fighter) then
                if fighter.Is_Ability_Ready(drop_bomb) then
                    fighter.Activate_Ability(drop_bomb,true)
                end
            end
        end
        Sleep(1.0)
        for _,fighter in pairs(squadron) do
            if TestValid(fighter) then
                if fighter.Is_Ability_Ready(drop_bomb) then
                    fighter.Activate_Ability(drop_bomb,true)
                end
            end
        end
        Sleep(2.0)
        Object.Take_Damage(1000)
        ScriptExit()
    end
end

--[[function State_Being_Recharged(message)
    if message== OnEnter then
        Object.Highlight(true)
        recharge_state=0
    elseif message == OnUpdate then
       if  Object.Is_Under_Effects_Of_Ability(recharge_ability) then
           if recharge_state>=recharge_time then
               Object.Highlight(true)
               target_lock_usage_counter=0
               locked=false
               Set_Next_State("State_Wait_For_Input")
           else
               recharge_state=recharge_state+recharge_rate
           end
       else
           Set_Next_State("State_Wait_For_Input")
       end
    end
end]]

