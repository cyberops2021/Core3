-- Petersburg Cantina Screenplay
-- Spawns Nyxara Syn and Karima Ghazlani in Nicoletta's house (The Dry Dock)

print("PetersburgCantina: FILE LOADING")

PetersburgCantina = ScreenPlay:new {
    screenplayName = "PetersburgCantina",
    planet = "corellia",
    houseX = -356.69,
    houseY = -1788.61,
    houseZ = 28.75,
}

print("PetersburgCantina: REGISTERING")
registerScreenPlay("PetersburgCantina", true)
print("PetersburgCantina: REGISTERED")

function PetersburgCantina:start()
    print("PetersburgCantina: START CALLED")
    if (isZoneEnabled(self.planet)) then
        print("PetersburgCantina: Zone enabled, spawning area in 30 seconds")
        deleteData("petersburg:npcs_spawned")
        createEvent(30000, "PetersburgCantina", "spawnActiveArea", nil, "")
    else
        print("PetersburgCantina: Zone NOT enabled!")
    end
end

function PetersburgCantina:spawnActiveArea()
    print("PetersburgCantina: spawnActiveArea called")
    if readData("petersburg:npcs_spawned") == 1 then
        return
    end

    local pActiveArea = spawnActiveArea(self.planet, "object/active_area.iff", self.houseX, self.houseZ, self.houseY, 20, 0)

    if pActiveArea ~= nil then
        print("PetersburgCantina: Active area spawned")
        createObserver(ENTEREDAREA, "PetersburgCantina", "onEnterArea", pActiveArea)
    else
        print("PetersburgCantina: Failed to spawn active area!")
    end
end

function PetersburgCantina:onEnterArea(pActiveArea, pObject)
    print("PetersburgCantina: onEnterArea triggered")

    if pObject == nil then
        print("PetersburgCantina: pObject is nil")
        return 0
    end

    if readData("petersburg:npcs_spawned") == 1 then
        print("PetersburgCantina: Already spawned, skipping")
        return 0
    end

    local objName = SceneObject(pObject):getDisplayedName()
    print("PetersburgCantina: Object entered: " .. tostring(objName))

    local pParent = SceneObject(pObject):getParent()
    local pRootParent = SceneObject(pObject):getRootParent()

    print("PetersburgCantina: pParent is " .. tostring(pParent))
    print("PetersburgCantina: pRootParent is " .. tostring(pRootParent))

    -- If the object entering IS inside a building, use that
    if pRootParent ~= nil and SceneObject(pRootParent):isBuildingObject() then
        print("PetersburgCantina: Object is inside a building!")
        self:spawnCantinaNPCs(pRootParent, pActiveArea)
        return 0
    end

    -- Otherwise, if it's a player, store a reference and wait for them to enter building
    if SceneObject(pObject):isPlayerCreature() then
        print("PetersburgCantina: Player entered area but not in building yet")
        createObserver(OBJECTADDED, "PetersburgCantina", "onPlayerEnterCell", pObject)
        writeData("petersburg:waiting_player", SceneObject(pObject):getObjectID())
        writeData("petersburg:active_area", SceneObject(pActiveArea):getObjectID())
    end

    return 0
end

function PetersburgCantina:onPlayerEnterCell(pContainer, pObject)
    print("PetersburgCantina: onPlayerEnterCell triggered")

    if pObject == nil then
        return 0
    end

    if readData("petersburg:npcs_spawned") == 1 then
        return 1  -- Remove observer
    end

    if not SceneObject(pObject):isPlayerCreature() then
        return 0
    end

    local pRootParent = SceneObject(pObject):getRootParent()
    if pRootParent ~= nil and SceneObject(pRootParent):isBuildingObject() then
        print("PetersburgCantina: Player entered building!")
        local areaId = readData("petersburg:active_area")
        local pActiveArea = getSceneObject(areaId)
        self:spawnCantinaNPCs(pRootParent, pActiveArea)
        return 1  -- Remove observer
    end

    return 0
end

function PetersburgCantina:spawnCantinaNPCs(pBuilding, pActiveArea)
    print("PetersburgCantina: spawnCantinaNPCs called")
    print("PetersburgCantina: pBuilding=" .. tostring(pBuilding))
    print("PetersburgCantina: building template=" .. tostring(SceneObject(pBuilding):getTemplateObjectPath()))
    print("PetersburgCantina: pCell=" .. tostring(pCell) .. " cellID=" .. tostring(cellID))

    if readData("petersburg:npcs_spawned") == 1 then
        return
    end

    local pCell = BuildingObject(pBuilding):getCell(3)
    if pCell == nil then
        print("PetersburgCantina: Cell 3 is nil, trying cell 1")
        pCell = BuildingObject(pBuilding):getCell(1)
    end

    if pCell == nil then
        print("PetersburgCantina: No valid cell found!")
        return
    end

    local cellID = SceneObject(pCell):getObjectID()
    print("PetersburgCantina: Spawning NPCs in cell " .. cellID)

    -- Spawn Nyxara (bartender position - behind bar)
    local pNyxara = spawnMobile(self.planet, "nyxara_syn", 0, -0.61, 0.74, 0.40, 180, cellID)

    if pNyxara ~= nil then
        print("PetersburgCantina: Nyxara spawned!")
        CreatureObject(pNyxara):setMoodString("friendly")
        AiAgent(pNyxara):addObjectFlag(AI_STATIC)
        writeData("petersburg:nyxara_id", SceneObject(pNyxara):getObjectID())

        if NyxaraConversation ~= nil then
            NyxaraConversation:initNpc(pNyxara)
        end
    else
        print("PetersburgCantina: Nyxara spawnMobile returned nil!")
    end

    -- Spawn Karima (dancer position - near entertainment area)
    local pKarima = spawnMobile(self.planet, "karima_ghazlani", 0, -0.80, 0.74, -4.22, 10, cellID)

    if pKarima ~= nil then
        print("PetersburgCantina: Karima spawned!")
        CreatureObject(pKarima):setMoodString("seductive")
        AiAgent(pKarima):addObjectFlag(AI_STATIC)
        writeData("petersburg:karima_id", SceneObject(pKarima):getObjectID())

        if KarimaConversation ~= nil then
            KarimaConversation:initNpc(pKarima)
        end
    else
        print("PetersburgCantina: Karima spawnMobile returned nil!")
    end

    -- Mark as spawned and clean up
    writeData("petersburg:npcs_spawned", 1)

    if pActiveArea ~= nil then
        SceneObject(pActiveArea):destroyObjectFromWorld()
    end
end
