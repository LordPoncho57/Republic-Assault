--[[
==================== YVAW ====================
@AUTHOR: Kad_Venku
@created for Yuuzhan Vong at War
@DATE: 24/02/2016
@TIME: 16:40

This script enables friendly fire and an area of effect damage.
==================== YVAW ====================
]]

require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")

function Definitions()
    --ServiceRate = 0.05
    Define_State("State_Init", State_Init);
    -- adjust this to your liking:
    -- shouldn't be too high, this is a damage dealt per bomb drop, so it pretyy likely will kill all squadrons in the area
    min_damage_dealt=5
    max_damage_dealt=50

    -- If used this should be less than the bomb's countdown.
    -- countdown = 4.0

    -- should be a maximum of half the size of the <Projectile_Blast_Area_Range> tag in the xml.
    -- chose 150 for reasonable damage.
    area_of_effect=150
end

function State_Init(message)
    if message==OnEnter then
        -- Sleep(countdown)
        local shiplist = Find_All_Objects_Of_Type("Hero | Capital | Frigate | Corvette | Transport | Fighter | Bomber");
        for _,ship in pairs(shiplist) do
            if Object.Get_Distance(ship)<=area_of_effect then
                ship.Take_Damage(GameRandom(min_damage_dealt,max_damage_dealt))
            end
        end
    end
end