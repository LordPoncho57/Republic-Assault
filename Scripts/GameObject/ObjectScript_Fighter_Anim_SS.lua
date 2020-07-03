--@author: Kad_Venku

require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")

function Definitions()
    Define_State("State_Init", State_Init)
    Define_State("State_Idle_Flight",State_Idle_Flight)
    Define_State("State_In_Combat", State_In_Combat)

    --[[
    	The animation files are made up of three parts; the name of the models the animation belongs to, the animation name and its number:
		e.g.:
		BwingR.alo
		BwingR_deploy_00.ala
		BwingR_celebrate_00.ala
		You only need the name and the number for the animation to trigger it; but you can only trigger existing animations this way.
		Introducing new animations names is sadly not possible, but numbering availiable names should provide a sufficient amount of animations.
    ]]
    -- Animation which opens the wings:
    Deploy_Animation = "undeploy"
    -- Animation which closes the wings:
    Undeploy_Animation = "deploy"

    Wings_Are_S_Foils=true
    Ship_In_Combat=false

    -- The time the wings stay in a certain position to avoid animations cutting through each other, as well as avoiding constant opening and closing.
    Wing_Min_Open_Time=8.0;
    Wing_Min_Closed_Time=3.0;

end

function State_Init(message)
    if message==OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end
        Sleep(2.0)
        -- close wings; Uncomment this line, if your ship comes with opened wings per default.
        -- Ship_In_Combat=Disengage_Combat_Mode(Object,Undeploy_Animation,Wings_Are_S_Foils)
        Set_Next_State("State_Idle_Flight")
    end
end

-- This state is used for idle flight, the unit is not engaged in combat.
function State_Idle_Flight(message)
    if message==OnEnter then
        Sleep(Wing_Min_Closed_Time)
    elseif message==OnUpdate then
        -- Engage combat mode, once the unit has locked onto a target; A little side effect is a more individual unit behaviour, as not all units within a squadron have a target at any given point in time.
        if Object.Has_Attack_Target() then
            Set_Next_State("State_In_Combat")
        end
        -- Engage combat mode, if the "HUNT" ability is active:
        if Object.Has_Ability("HUNT") and Object.Is_Ability_Active("HUNT") then
            Set_Next_State("State_In_Combat")
        end
    end
end

function State_In_Combat(message)
    if message==OnEnter then
        -- Opening wings:
        Ship_In_Combat=Engage_Combat_Mode(Object,Deploy_Animation,Wings_Are_S_Foils)
        -- Wings stay open for at least this amount of time:
        Sleep(Wing_Min_Open_Time)
    elseif message==OnUpdate then
        --[[
        This is the main difference to the b-wing state machine:
        The B-Wing will now advance to a evade state, which plays animations randomly until the unit has lost its target.
        ]]
        if Ship_In_Combat then
            -- Disengage combat if the "HUNT" ability is off and the unit does not have an active target.
            if not Object.Has_Attack_Target() and not (Object.Has_Ability("HUNT") and Object.Is_Ability_Active("HUNT")) then
                -- close wings:
                Ship_In_Combat=Disengage_Combat_Mode(Object,Undeploy_Animation,Wings_Are_S_Foils)
                Set_Next_State("State_Idle_Flight")
            end
            -- Disengage combat mode, if the "HUNT" ability is switched off and the unit does not have an active target:
            if (Object.Has_Ability("HUNT") and not Object.Is_Ability_Active("HUNT")) and not Object.Has_Attack_Target() then
                -- close wings:
                Ship_In_Combat=Disengage_Combat_Mode(Object,Undeploy_Animation,Wings_Are_S_Foils)
                Set_Next_State("State_Idle_Flight")
            end
        else
            -- Just in case we get stuck:
            Set_Next_State("State_Idle_Flight")
        end
    end
end


--[[
    Engages combat mode.
    @param ship: unit object which should play the animation
    @param animation: String name of the animation which should be played
    @param unlock_weapons: Boolean; optional; if present, playing the animation unlocks weapons.
]]
function Engage_Combat_Mode(ship,animation,unlock_weapons)
    ship.Play_Animation(animation, false, 0);
    if unlock_weapons~=nil then
        ship.Prevent_All_Fire(false)
    end
    return true;
end

--[[
    Plays a custom animation.
    @param ship: unit object which should play the animation
    @param animation: String name of the animation which should be played
    @param nbr: integer; corresponds to the animation's number

    A valid call would be: cPlay_Animation(Object, "deploy", 2)
    This would force the current unit with the model x-wing.alo to play the animation x-wing_deploy_02.ala
]]
function cPlay_Animation(ship, animation, nbr)
    ship.Play_Animation(animation, false, nbr);
end

--[[
    Engages combat mode.
    @param ship: unit object which should play the animation
    @param animation: String name of the animation which should be played
    @param unlock_weapons: Boolean; optional; if present, playing the animation locks weapons.
]]
function Disengage_Combat_Mode(ship,animation,lock_weapons)
    ship.Play_Animation(animation, false, 0);
    if lock_weapons~=nil then
        ship.Prevent_All_Fire(true)
    end
    return false;
end