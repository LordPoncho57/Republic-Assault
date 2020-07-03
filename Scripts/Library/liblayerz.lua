local libLayerZ = { }

libLayerZ.neutralPlayer = "NEUTRAL"
libLayerZ.actualOwner = nil

--- Disables a given GameObject.
-- @tparam GameObject gameObject
-- @tparam Boolean spawnsFighters [optional]
function libLayerZ:disableObject(gameObject, spawnsFighters)
    if not gameObject.Get_Owner().Is_Human() then
        gameObject.Prevent_AI_Usage(true)
        self.actualOwner = gameObject.Get_Owner()
        gameObject.Change_Owner(Find_Player(self.neutralPlayer))
    end
    local spawns = false
    if spawnsFighters then
        spawns = spawnsFighters
    end
    if spawns then
        gameObject.Set_Garrison_Spawn(false)
    end
    gameObject.Make_Invulnerable(true)
    gameObject.Set_Selectable(false)
    gameObject.Prevent_All_Fire(true)
end

--- Enables a given GameObject.
-- @tparam GameObject gameObject
-- @tparam Boolean spawnsFighters [optional]
function libLayerZ:enableObject(gameObject, spawnsFighters)
    local spawns = false
    if spawnsFighters then
        spawns = spawnsFighters
    end
    gameObject.Make_Invulnerable(false)
    gameObject.Set_Selectable(true)
    gameObject.Prevent_All_Fire(false)
    if not gameObject.Get_Owner().Is_Human() then
        gameObject.Change_Owner(self.actualOwner)
        gameObject.Prevent_AI_Usage(false)
    end
    if spawns then
        gameObject.Set_Garrison_Spawn(true)
    end
end

--- Hides a given game object.
-- It's a wrapper around two consecutive GameObject.Hide(true) calls - don't even ask why we need those.
-- @tparam GameObject gameObject
function libLayerZ.hideObject(gameObject)
    gameObject.Hide(true)
    gameObject.Hide(true)
end

--- Teleports the given object to a randomized Z-Layer.
-- @tparam GameObject gameObject
function libLayerZ.setLayerZ(gameObject)
    local layerZObj = Spawn_Unit(Find_Object_Type("LAYER_Z_DUMMY"), gameObject.Get_Position(), gameObject.Get_Owner())
    layerZObj = layerZObj[1]
    local layer = "CORVETTE"
    if gameObject.Is_Category("Frigate") then
        layer = "FRIGATE"
    elseif gameObject.Is_Category("CAPITALal") then
        layer = "CAPITALAL"
    elseif gameObject.Is_Category("Super") then
        layer = "SUPER"
    end
    local layerMarkerTable = {
        ["CORVETTE"] = {
            -- TODO: Add bone names!
			"CORVETTE_01",
			"CORVETTE_02",
			"CORVETTE_03",
			"CORVETTE_04",
			"CORVETTE_05",
			"CORVETTE_06",
        },
        ["FRIGATE"] = {
            -- TODO: Add bone names!
			"FRIGATE_01",
			"FRIGATE_02",
			"FRIGATE_03",
			"FRIGATE_04",
			"FRIGATE_05",
            "FRIGATE_06",
			"FRIGATE_07",
			"FRIGATE_08",
			"FRIGATE_09",
			"FRIGATE_10",
        },
        ["CAPITALAL"] = {
            -- TODO: Add bone names!
			"CAPITAL_01",
			"CAPITAL_02",
			"CAPITAL_03",
			"CAPITAL_04",
			"CAPITAL_05",
			"CAPITAL_06",
        },
        ["SUPER"] = {
            -- TODO: Add bone names!
			"SUPER_06",
        },
    }
    local finalBoneTab = layerMarkerTable[layer]
    if finalBoneTab then
        local bone = finalBoneTab[GameRandom(1,table.getn(finalBoneTab))]
        if bone then
            gameObject.Teleport(layerZObj.Get_Bone_Position(bone))
        else
            gameObject.Teleport(layerZObj.Get_Position())
        end
    else
        gameObject.Teleport(layerZObj.Get_Position())
    end
    layerZObj.Despawn()
end

--- Only function that needs to be called from the gameobject script.
--- Call this function with the ":" operator!
-- @tparam GameObject gameObject
function libLayerZ:enterBattlefield(gameObject)
    self:disableObject(gameObject)
    gameObject.Cancel_Hyperspace()
    self.hideObject(gameObject)
    self.setLayerZ(gameObject)
    gameObject.Cinematic_Hyperspace_In(1)
    self:enableObject(gameObject)
end

return libLayerZ
