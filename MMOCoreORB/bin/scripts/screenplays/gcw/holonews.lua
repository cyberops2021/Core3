local ObjectManager = require("managers.object.object_manager")
local http = require("socket.http")

--[[
    HoloNews System for Ahazi Server
    Based on Empire in Flames original concept
    
    Connects to local Flask API at 192.168.0.113:5000 for dynamic,
    AI-generated news content that updates hourly.
    
    Installation:
    1. Place this file at: MMOCoreORB/bin/scripts/screenplays/holonews.lua
    2. Place terminal_newsnet.lua at: MMOCoreORB/bin/scripts/object/tangible/terminal/
    3. Add to screenplays.lua: includeFile("screenplays/holonews.lua")
    4. Restart server
]]

HolonewsMenuComponent = { }

-- Configuration: Point to your Flask server
local API_BASE = "http://192.168.0.113:5000/api/holonews"

-- Helper function to fetch content from API
local function fetchNews(endpoint)
    local url = API_BASE .. "/" .. endpoint
    local body, status, headers = http.request(url)
    
    if status == 200 and body then
        return body
    else
        return "HoloNet connection unavailable.\n\nPlease try again later.\n\nError: " .. tostring(status)
    end
end

-- Radial menu on the Newsnet Object
-- Menu ID 20 is the default "use" action
function HolonewsMenuComponent:fillObjectMenuResponse(pSceneObject, pMenuResponse, pPlayer)
    local menuResponse = LuaObjectMenuResponse(pMenuResponse)

    -- Main menu items
    menuResponse:addRadialMenuItem(20, 3, "Galactic Headlines")
    menuResponse:addRadialMenuItem(40, 3, "Local News")
    menuResponse:addRadialMenuItem(60, 3, "Trade & Commerce")
    menuResponse:addRadialMenuItem(80, 3, "Entertainment")
    menuResponse:addRadialMenuItem(100, 3, "Bounty Board")
    
    -- Server info submenu
    menuResponse:addRadialMenuItem(120, 1, "Server Info")
    menuResponse:addRadialMenuItemToRadialID(120, 121, 3, "Upcoming Events")
    menuResponse:addRadialMenuItemToRadialID(120, 122, 3, "Patch Notes")
    
    -- Original GCW Headlines (preserved from SWGEmu)
    menuResponse:addRadialMenuItem(140, 1, "War Status")
    menuResponse:addRadialMenuItemToRadialID(140, 141, 3, "GCW Headlines")
end


-- Handle menu selection
function HolonewsMenuComponent:handleObjectMenuSelect(pObject, pPlayer, selectedID)
    if (pPlayer == nil or pObject == nil) then
        return 0
    end

    local pGhost = CreatureObject(pPlayer):getPlayerObject()
    local suiManager = LuaSuiManager()
    
    -- Helper to show news
    local function showNews(title, content)
        if (pGhost ~= nil) then
            PlayerObject(pGhost):closeSuiWindowType(NEWSNET_INFO)
        end
        suiManager:sendMessageBox(pObject, pPlayer, title, content, "@ok", "HolonewsMenuComponent", "notifyOkPressed", NEWSNET_INFO)
    end

    -- Galactic Headlines
    if (selectedID == 20) then
        local body = fetchNews("headlines")
        showNews("Galactic Headlines", body)
        return 0
    end

    -- Local News
    if (selectedID == 40) then
        local body = fetchNews("local")
        showNews("Local News - Corellia", body)
        return 0
    end

    -- Trade & Commerce
    if (selectedID == 60) then
        local body = fetchNews("trade")
        showNews("Trade & Commerce", body)
        return 0
    end

    -- Entertainment
    if (selectedID == 80) then
        local body = fetchNews("entertainment")
        showNews("Entertainment", body)
        return 0
    end

    -- Bounty Board
    if (selectedID == 100) then
        local body = fetchNews("bounty")
        showNews("Bounty Board", body)
        return 0
    end

    -- Upcoming Events
    if (selectedID == 121 or selectedID == 120) then
        local body = fetchNews("events")
        showNews("Upcoming Events", body)
        return 0
    end

    -- Patch Notes
    if (selectedID == 122) then
        local body = fetchNews("patch")
        showNews("Patch Notes", body)
        return 0
    end

    -- Original GCW Headlines (preserved from base SWGEmu)
    if (selectedID == 141 or selectedID == 140) then
        local planet = SceneObject(pObject):getZoneName()

        if (planet == "") then
            return 0
        end

        local controllingFaction = getControllingFaction(planet)

        if (planet ~= "naboo" and planet ~= "corellia") then
            planet = "general"
        end

        local headline

        if (controllingFaction == FACTIONREBEL) then
            headline = "headline_" .. planet .. "_rebel_winning_" .. getRandomNumber(1,4)
        elseif (controllingFaction == FACTIONIMPERIAL) then
            headline = "headline_" .. planet .. "_rebel_losing_" .. getRandomNumber(1,4)
        else
            headline = "headline_" .. planet .. "_equal"
        end

        if (pGhost ~= nil) then
            PlayerObject(pGhost):closeSuiWindowType(NEWSNET_INFO)
        end

        suiManager:sendMessageBox(pObject, pPlayer, "@gcw:" .. planet .. "_newsnet_name", "@gcw:" .. headline, "@ok", "NewsnetMenuComponent", "notifyOkPressed", NEWSNET_INFO)
        return 0
    end

    return 0
end


-- Callback for OK button press (required but empty)
function HolonewsMenuComponent:notifyOkPressed()
end
