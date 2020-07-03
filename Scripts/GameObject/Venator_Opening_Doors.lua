require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")

function Definitions()
    Define_State("State_Init", State_Init)
    Define_State("State_Idle_Flight",State_Idle_Flight)
    Define_State("State_Open", State_Open)
    Define_State("State_Hold", State_Hold)
    Define_State("State_Close", State_Close)

    -- $User$-$Datetime$: I've set this up to work with the deploy animations.
    Animation_ID = "deploy"
    -- $User$-$Datetime$: This is your former open animation, now called [modelname]_deploy_00.ala
    Open_Animation = 0
    -- $User$-$Datetime$: This is your former hold animation, now called [modelname]_deploy_01.ala
    Hold_Animation = 1
    -- $User$-$Datetime$: This is your former close animation, now called [modelname]_deploy_02.ala
    Close_Animation = 2

    -- $User$-$Datetime$: This is the time the hangar will stay open for sure.
    Hangar_Open_Time = 4.0
    -- $User$-$Datetime$: This is the time the hangar will stay closed for sure.
    Hangar_Min_Closed_Time = 2.0
    -- $User$-$Datetime$: You have to make sure that the Deploy Squad reload time is equal to Hangar_Open_Time + Hangar_Min_Closed_Time; so mathematically speaking:
    -- $User$-$Datetime$: Ability_Countdown = Hangar_Open_Time + Hangar_Min_Closed_Time
end

function State_Init(message)
    if message==OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end
        -- $User$-$Datetime$: Initial sleep to prevent premature use of the ability. The Rebel AI loves doing that for some reason.
        Sleep(2.0)
        Set_Next_State("State_Idle_Flight")
    end
end


function State_Idle_Flight(message)
    if message==OnUpdate then
        if Object.Has_Ability("DEPLOY_SQUAD") and not Object.Is_Ability_Ready("DEPLOY_SQUAD") then
            Set_Next_State("State_Open")
        end
    end
end


function State_Open(message)
    if message==OnEnter then
        -- $User$-$Datetime$: This plays the [modelname]_deploy_00.ala animation.
        cPlay_Animation(Object, Animation_ID, Open_Animation)
        Set_Next_State("State_Hold")
    end
end

function State_Hold(message)
    if message==OnEnter then
        -- $User$-$Datetime$: I assume you want to use this to keep the hangar open for a certain amount of time, so we put the script to sleep:
        Sleep(Hangar_Open_Time)
        Set_Next_State("State_Close")
    end
end

function State_Close(message)
    if message==OnEnter then
        -- $User$-$Datetime$: This plays the [modelname]_deploy_02.ala animation.
        cPlay_Animation(Object, Animation_ID, Close_Animation)
        -- $User$-$Datetime$: This is the time the hangar will stay closed for sure:
        Sleep(Hangar_Min_Closed_Time)
        -- $User$-$Datetime$: Now we reset everything and return to the Idle State.
        Set_Next_State("State_Idle_Flight")
    end
end


-- $User$-$Datetime$: Wrapper function for the exposed Object.Play_Animation(String anim_name, Boolean repeat_anim, Int anim_number) function. It simply never repeats the animation.
function cPlay_Animation(ship, animation, nbr)
    ship.Play_Animation(animation, false, nbr);
end