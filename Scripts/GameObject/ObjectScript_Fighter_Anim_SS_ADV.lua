--@author: Kad_Venku
--@created for Yuuzhan Vong at War
require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")

function Definitions()
    ServiceRate = 0.1

    Define_State("State_Init", State_Init);
    Define_State("State_Idle_Flight",State_Idle_Flight);
    Define_State("State_In_Combat", State_In_Combat);
    Define_State("State_Evade", State_Evade);

    deploy_animation = "deploy";
    undeploy_animation = "undeploy";
    turn_left_70 = "deploy"
    turn_left_70_up = 1
    turn_left_70_down = 2
    
    turn_left_180 = "deploy"
    turn_left_180_up = 3
    turn_left_180_down = 4

    turn_right_70 = "deploy"
    turn_right_70_up = 5
    turn_right_70_down = 6

    turn_right_180 = "deploy"
    turn_right_180_up = 7
    turn_right_180_down = 8

    doneonce=false;
    play=true;
    choose_anim=0;
    last_played_anim=0;
    count=0;
    count_upper=0;
    wait_timer=1.0;
    stable_state_mult=3;
    state_mult=1;
end

function State_Init(message)
    if message==OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit();
        end
        Set_Next_State("State_Idle_Flight");
    end
end

function State_Idle_Flight(message)
    if message==OnEnter then
        Object.Prevent_All_Fire(true)
    elseif message==OnUpdate then
        if Object.Has_Attack_Target()then
            Set_Next_State("State_In_Combat");
        end
    end
end

function State_In_Combat(message)
    if message==OnUpdate then
        if not doneonce then
            count_upper=GameRandom(20,100)
            doneonce=Engage_Combat_Mode(Object,deploy_animation,false);
            Object.Prevent_All_Fire(false)
            stable_state_mult=GameRandom(4,8)
            state_mult=GameRandom(1,3)
            Sleep(wait_timer*stable_state_mult)
        elseif not Object.Has_Attack_Target() then
            if last_played_anim ~=0 then
                if last_played_anim == 1 then
                    Play_Random_Animation(Object, turn_left_70, turn_left_70_down)
                    Sleep(wait_timer)
                    last_played_anim=0
                elseif last_played_anim == 2 then
                    Play_Random_Animation(Object, turn_left_180, turn_left_180_down)
                    Sleep(wait_timer)
                    last_played_anim=0
                elseif last_played_anim == 3 then
                    Play_Random_Animation(Object, turn_right_70, turn_right_70_down)
                    Sleep(wait_timer)
                    last_played_anim=0
                elseif last_played_anim == 4 then
                    Play_Random_Animation(Object, turn_right_180, turn_right_180_down)
                    Sleep(wait_timer)
                    last_played_anim=0
                end
            end
            Object.Prevent_All_Fire(true)
            doneonce=Disengage_Combat_Mode(Object,undeploy_animation,false);
            Sleep(wait_timer*state_mult)
            play=true;
            last_played_anim=0
            Set_Next_State("State_Idle_Flight");
        elseif play then
            count=0
            Set_Next_State("State_Evade")
        else
            count=count+1
            if count>=count_upper then
                Sleep(wait_timer*state_mult)
                play=true
            end
        end
    end
end

function State_Evade()
    if  Object.Has_Attack_Target() then
        if last_played_anim == 0 then
            choose_anim=GameRandom(1,10)
            if choose_anim==1 and last_played_anim~=1 then
                Play_Random_Animation(Object, turn_left_70, turn_left_70_up)
                state_mult=GameRandom(1,5)
                Sleep(wait_timer*state_mult)
                play=false
                last_played_anim=1
            elseif choose_anim==2 and last_played~=2 then
                play=false
                Play_Random_Animation(Object, turn_left_180, turn_left_180_up)
                state_mult=GameRandom(1,5)
                Sleep(wait_timer*state_mult)
                last_played_anim=2
            elseif choose_anim==3 and last_played~=3 then
                play=false
                Play_Random_Animation(Object, turn_right_70, turn_right_70_up)
                state_mult=GameRandom(1,5)
                Sleep(wait_timer*state_mult)
                last_played_anim=3
            elseif choose_anim==4 and last_played~=4 then
                play=false
                Play_Random_Animation(Object, turn_right_180, turn_right_180_up)
                state_mult=GameRandom(1,5)
                Sleep(wait_timer*state_mult)
                last_played_anim=4
            elseif choose_anim==10 then
                play=true
                Set_Next_State("State_In_Combat")
            end
        elseif last_played_anim == 1 then
            Play_Random_Animation(Object, turn_left_70, turn_left_70_down)
            stable_state_mult=GameRandom(1,5)
            Sleep(wait_timer*stable_state_mult)
            last_played_anim=0
            play=true
            Set_Next_State("State_In_Combat")
        elseif last_played_anim == 2 then
            Play_Random_Animation(Object, turn_left_180, turn_left_180_down)
            stable_state_mult=GameRandom(1,5)
            Sleep(wait_timer*stable_state_mult)
            last_played_anim=0
            play=true
            Set_Next_State("State_In_Combat")
        elseif last_played_anim == 3 then
            Play_Random_Animation(Object, turn_right_70, turn_right_70_down)
            stable_state_mult=GameRandom(1,5)
            Sleep(wait_timer*stable_state_mult)
            last_played_anim=0
            play=true
            Set_Next_State("State_In_Combat")
        elseif last_played_anim == 4 then
            Play_Random_Animation(Object, turn_right_180, turn_right_180_down)
            stable_state_mult=GameRandom(1,5)
            Sleep(wait_timer*stable_state_mult)
            last_played_anim=0
            play=true
            Set_Next_State("State_In_Combat")
        else
            Set_Next_State("State_In_Combat")
        end
    else
        Set_Next_State("State_In_Combat")
    end
end

function Engage_Combat_Mode(ship,animation,repeatanim)
    ship.Play_Animation(animation, repeatanim, 0);
    return true;
end

function Play_Random_Animation(ship, animation, nbr)
    ship.Play_Animation(animation, false, nbr);
end

function Disengage_Combat_Mode(ship,animation,repeatanim)
    ship.Play_Animation(animation, repeatanim, 0);
    return false;
end