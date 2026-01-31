--[[
    Kashyyyk Zone Screenplay - Phase 1: Hub Waypoint System
    
    Creates the Kachirho hub waypoint when players arrive on Kashyyyk.
    This is the only always-visible waypoint per canon ROTW design.
    
    Future phases will add:
    - Phase 2: Quest-scoped temporary waypoints
    - Phase 3: Region entry messages
]]

local ObjectManager = require("managers.object.object_manager")

KashyyykZoneScreenplay = ScreenPlay:new {
    numberOfActs = 1,
    screenplayName = "KashyyykZoneScreenplay",
    
    -- Starport arrival area configuration
    arrivalArea = {
        x = -680,
        z = 18,
        y = -143,
        radius = 100
    },
    
    -- Data key prefix for tracking waypoints
    waypointKeyPrefix = "kashyyyk:hub_waypoint:",
    
    DEBUG = false
}

registerScreenPlay("KashyyykZoneScreenplay", true)

-- ============================================================
-- Initialization
-- ============================================================

function KashyyykZoneScreenplay:start()
    if not isZoneEnabled("kashyyyk_main") then
        return
    end
    
    if self.DEBUG then
        print("KashyyykZoneScreenplay: Starting...")
    end
    
    self:spawnArrivalArea()
    
    if self.DEBUG then
        print("KashyyykZoneScreenplay: Initialization complete")
    end
end

function KashyyykZoneScreenplay:spawnArrivalArea()
    local pArea = spawnActiveArea(
        "kashyyyk_main",
        "object/active_area.iff",
        self.arrivalArea.x,
        self.arrivalArea.z,
        self.arrivalArea.y,
        self.arrivalArea.radius,
        0
    )
    
    if pArea == nil then
        print("KashyyykZoneScreenplay: ERROR - Failed to spawn arrival area")
        return
    end
    
    local areaID = SceneObject(pArea):getObjectID()
    writeData("kashyyyk:arrival_area_id", areaID)
    
    createObserver(ENTEREDAREA, "KashyyykZoneScreenplay", "onPlayerEnteredArrivalArea", pArea)
    
    if self.DEBUG then
        print("KashyyykZoneScreenplay: Arrival area spawned at " .. 
              self.arrivalArea.x .. ", " .. self.arrivalArea.y .. 
              " with radius " .. self.arrivalArea.radius)
    end
end

-- ============================================================
-- Player Entry Handling
-- ============================================================

function KashyyykZoneScreenplay:onPlayerEnteredArrivalArea(pArea, pPlayer)
    if pPlayer == nil then
        return 0
    end
    
    if not SceneObject(pPlayer):isPlayerCreature() then
        return 0
    end
    
    if self.DEBUG then
        print("KashyyykZoneScreenplay: Player entered arrival area")
    end
    
    -- self:ensureHubWaypoint(pPlayer)
    
    return 0
end

-- ============================================================
-- Hub Waypoint Management
-- ============================================================

function KashyyykZoneScreenplay:ensureHubWaypoint(pPlayer)
    if pPlayer == nil then
        return
    end
    
    local pGhost = CreatureObject(pPlayer):getPlayerObject()
    if pGhost == nil then
        return
    end
    
    local playerID = SceneObject(pPlayer):getObjectID()
    
    if self:hasKachirhoWaypoint(pPlayer) then
        if self.DEBUG then
            print("KashyyykZoneScreenplay: Player already has Kachirho waypoint")
        end
        return
    end
    
    local kachirho = KashyyykNavigation:getLocation("kachirho")
    if kachirho == nil then
        print("KashyyykZoneScreenplay: ERROR - Kachirho location not found in navigation data")
        return
    end
    
    local waypointID = PlayerObject(pGhost):addWaypoint(
        kachirho.scene,
        kachirho.name,
        kachirho.description,
        kachirho.x,  -- x
        kachirho.z,  -- y  -- height
        kachirho.z,  -- y
        WAYPOINT_BLUE,
        true,
        true,
        0
    )
    
    if waypointID ~= 0 then
        writeData(self.waypointKeyPrefix .. playerID, waypointID)
        
        if self.DEBUG then
            print("KashyyykZoneScreenplay: Created Kachirho waypoint for player, ID: " .. waypointID)
        end
        
        CreatureObject(pPlayer):sendSystemMessage("A waypoint to Kachirho has been added to your datapad.")
    else
        print("KashyyykZoneScreenplay: ERROR - Failed to create waypoint")
    end
end

function KashyyykZoneScreenplay:hasKachirhoWaypoint(pPlayer)
    if pPlayer == nil then
        return false
    end
    
    local pGhost = CreatureObject(pPlayer):getPlayerObject()
    if pGhost == nil then
        return false
    end
    
    local kachirho = KashyyykNavigation:getLocation("kachirho")
    if kachirho == nil then
        return false
    end
    
    local pWaypoint = PlayerObject(pGhost):getWaypointAt(kachirho.x, kachirho.z, kachirho.scene)
    
    return pWaypoint ~= nil
end

-- ============================================================
-- Admin/Debug Commands
-- ============================================================

function KashyyykZoneScreenplay:debugPrintStatus(pPlayer)
    if pPlayer == nil then
        return
    end
    
    local playerID = SceneObject(pPlayer):getObjectID()
    local hasWaypoint = self:hasKachirhoWaypoint(pPlayer)
    local storedID = readData(self.waypointKeyPrefix .. playerID)
    
    print("=== Kashyyyk Zone Status ===")
    print("  Player ID: " .. playerID)
    print("  Has Kachirho Waypoint: " .. tostring(hasWaypoint))
    print("  Stored Waypoint ID: " .. tostring(storedID))
    print("============================")
end

function KashyyykZoneScreenplay:cleanup()
    local areaID = readData("kashyyyk:arrival_area_id")
    if areaID ~= nil and areaID ~= 0 then
        local pArea = getSceneObject(areaID)
        if pArea ~= nil then
            SceneObject(pArea):destroyObjectFromWorld()
        end
        deleteData("kashyyyk:arrival_area_id")
    end
end

return KashyyykZoneScreenplay
