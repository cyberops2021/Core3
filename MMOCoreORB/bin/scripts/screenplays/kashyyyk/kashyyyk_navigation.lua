--[[
    Kashyyyk Navigation System - Phase 0: Data Structure
    
    Canon ROTW Kashyyyk Location Definitions
    
    Location Types:
        HUB          - Narrative hub, semi-persistent POI (e.g., Kachirho)
        REGION       - Named area/route, label only, never a waypoint
        QUEST_TARGET - Temporary waypoint, only visible during relevant quests
    
    Visibility Policies:
        ALWAYS       - Waypoint created on zone entry, persists
        NEVER_STATIC - Never a waypoint, region label only
        QUEST_ONLY   - Waypoint injected/removed by quest system
]]

KashyyykNavigation = {}

-- Location type constants
KashyyykNavigation.TYPE_HUB = "HUB"
KashyyykNavigation.TYPE_REGION = "REGION"
KashyyykNavigation.TYPE_QUEST_TARGET = "QUEST_TARGET"

-- Visibility policy constants
KashyyykNavigation.VIS_ALWAYS = "ALWAYS"
KashyyykNavigation.VIS_NEVER_STATIC = "NEVER_STATIC"
KashyyykNavigation.VIS_QUEST_ONLY = "QUEST_ONLY"

-- Canonical Kashyyyk locations
-- Coordinates: x, z (horizontal), y (vertical/height)
KashyyykNavigation.locations = {
    
    -- ============================================================
    -- HUBS - Semi-persistent narrative anchors
    -- ============================================================
    
    kachirho = {
        name = "Kachirho",
        description = "The Wookiee city of Kachirho",
        scene = "kashyyyk_main",
        x = -592,
        y = 0,
        z = -146,
        locationType = KashyyykNavigation.TYPE_HUB,
        visibility = KashyyykNavigation.VIS_ALWAYS,
        waypointColor = "blue"
    },
    
    -- ============================================================
    -- REGIONS - Named areas, labels only, never waypoints
    -- ============================================================
    
    rryatt_trail = {
        name = "Rryatt Trail",
        description = "A major pathway through the Kashyyyk canopy",
        scene = "kashyyyk_main",
        x = -82,
        y = 0,
        z = -781,
        radius = 200,
        locationType = KashyyykNavigation.TYPE_REGION,
        visibility = KashyyykNavigation.VIS_NEVER_STATIC
    },
    
    etyyy_hunting_grounds = {
        name = "Etyyy, The Hunting Grounds",
        description = "Wookiee rite-of-passage hunting area",
        scene = "kashyyyk_main",
        x = 237,
        y = 0,
        z = -422,
        radius = 300,
        locationType = KashyyykNavigation.TYPE_REGION,
        visibility = KashyyykNavigation.VIS_NEVER_STATIC
    },
    
    kkowir_forest = {
        name = "Kkowir Forest",
        description = "A dark and dangerous forest region",
        scene = "kashyyyk_main",
        x = -778,
        y = 0,
        z = 230,
        radius = 250,
        locationType = KashyyykNavigation.TYPE_REGION,
        visibility = KashyyykNavigation.VIS_NEVER_STATIC
    },
    
    -- ============================================================
    -- QUEST TARGETS - Temporary waypoints, quest-scoped only
    -- ============================================================
    
    blackscale_slaver_compound = {
        name = "Blackscale Slaver Compound",
        description = "A compound run by Blackscale slavers",
        scene = "kashyyyk_main",
        x = 386,
        y = 0,
        z = 731,
        locationType = KashyyykNavigation.TYPE_QUEST_TARGET,
        visibility = KashyyykNavigation.VIS_QUEST_ONLY,
        waypointColor = "orange"
    },
    
    isolationist_wookiee_village = {
        name = "Isolationist Wookiee Village",
        description = "A village of Wookiees who shun outsiders",
        scene = "kashyyyk_main",
        x = 280,
        y = 0,
        z = -198,
        locationType = KashyyykNavigation.TYPE_QUEST_TARGET,
        visibility = KashyyykNavigation.VIS_QUEST_ONLY,
        waypointColor = "purple"
    },
    
    rodian_hunters_camp = {
        name = "Rodian Hunters Camp",
        description = "A camp of Rodian hunters",
        scene = "kashyyyk_main",
        x = 686,
        y = 0,
        z = -630,
        locationType = KashyyykNavigation.TYPE_QUEST_TARGET,
        visibility = KashyyykNavigation.VIS_QUEST_ONLY,
        waypointColor = "orange"
    },
    
    slaver_camp = {
        name = "Slaver Camp",
        description = "A Trandoshan slaver camp",
        scene = "kashyyyk_main",
        x = 126,
        y = 0,
        z = 151,
        locationType = KashyyykNavigation.TYPE_QUEST_TARGET,
        visibility = KashyyykNavigation.VIS_QUEST_ONLY,
        waypointColor = "orange"
    }
}

-- ============================================================
-- Utility Functions
-- ============================================================

function KashyyykNavigation:getLocation(key)
    return self.locations[key]
end

function KashyyykNavigation:getLocationsForScene(sceneName)
    local results = {}
    for key, loc in pairs(self.locations) do
        if loc.scene == sceneName then
            results[key] = loc
        end
    end
    return results
end

function KashyyykNavigation:getLocationsByType(locationType)
    local results = {}
    for key, loc in pairs(self.locations) do
        if loc.locationType == locationType then
            results[key] = loc
        end
    end
    return results
end

function KashyyykNavigation:getHubs()
    return self:getLocationsByType(self.TYPE_HUB)
end

function KashyyykNavigation:getRegions()
    return self:getLocationsByType(self.TYPE_REGION)
end

function KashyyykNavigation:getQuestTargets()
    return self:getLocationsByType(self.TYPE_QUEST_TARGET)
end

function KashyyykNavigation:locationExists(key)
    return self.locations[key] ~= nil
end

function KashyyykNavigation:getDistanceToLocation(key, x, z)
    local loc = self.locations[key]
    if not loc then
        return nil
    end
    local dx = loc.x - x
    local dz = loc.z - z
    return math.sqrt(dx * dx + dz * dz)
end

function KashyyykNavigation:isWithinRegion(key, x, z)
    local loc = self.locations[key]
    if not loc or not loc.radius then
        return false
    end
    local distance = self:getDistanceToLocation(key, x, z)
    return distance ~= nil and distance <= loc.radius
end

function KashyyykNavigation:debugPrintAll()
    print("=== Kashyyyk Navigation Locations ===")
    for key, loc in pairs(self.locations) do
        print(string.format("  [%s] %s (%s) @ %s: %.0f, %.0f, %.0f",
            key, loc.name, loc.locationType, loc.scene, loc.x, loc.y, loc.z))
    end
    print("=== End Locations ===")
end

return KashyyykNavigation
