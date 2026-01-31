--[[
    Nyxara Syn AI Conversation System
    
    An AI-powered NPC bartender with emergent personality.
    Uses SPATIALCHAT observer - players just talk near her and she responds.
    
    Installation:
    1. Place in screenplays folder
    2. Add to screenplays.lua: includeFile("nyxara_conversation.lua")
    3. Update petersburg_cantina.lua to call NyxaraConversation:initNpc(pNpc) after spawn
]]

local ObjectManager = require("managers.object.object_manager")
local http = require("socket.http")
local ltn12 = require("ltn12")

-- =============================================================================
-- CONFIGURATION
-- =============================================================================

NyxaraConversation = ScreenPlay:new {
    screenplayName = "NyxaraConversation",
    
    -- API endpoint
    API_BASE = "http://192.168.0.113:5000/api/npc",
    
    -- NPC identifier for the API
    NPC_ID = "nyxara_syn",
    
    -- Cooldown between responses (milliseconds)
    RESPONSE_COOLDOWN = 3000,
    
    -- Animation mappings (API response -> SWG animation)
    animationMap = {
        -- Basic
        ["none"] = nil,
        ["smile"] = "nod_head_once",
        ["grin"] = "nod_head_multiple",
        ["laugh"] = "belly_laugh",
        ["giggle"] = "laugh_titter",
        ["chuckle"] = "laugh_cackle",
        
        -- Greetings
        ["wave"] = "wave1",
        ["wave2"] = "wave2",
        ["greet"] = "greet",
        ["bow"] = "bow",
        ["curtsey"] = "bow",
        
        -- Flirty/Seductive
        ["wink"] = "nod_head_once",
        ["blow_kiss"] = "worship",
        ["flirt"] = "beckon",
        ["tease"] = "wave_finger_warning",
        ["coy"] = "shrug_shoulders",
        ["beckon"] = "beckon",
        ["lick_lips"] = "slow_down",
        ["come_hither"] = "beckon",
        ["sultry_look"] = "nod_head_once",
        ["play_with_hair"] = "rub_chin_thoughtful",
        ["lean_close"] = "slow_down",
        ["touch_arm"] = "manipulate_medium",
        ["pose"] = "pose_proudly",
        ["strut"] = "pose_proudly",
        
        -- Dismissive/Negative
        ["shrug"] = "shrug_shoulders",
        ["shake_head"] = "shake_head_no",
        ["sigh"] = "sigh_deeply",
        ["eye_roll"] = "shake_head_disgust",
        ["dismiss"] = "dismiss",
        ["angry"] = "angry",
        
        -- Thinking/Uncertain
        ["think"] = "rub_chin_thoughtful",
        ["ponder"] = "rub_chin_thoughtful",
        ["confused"] = "shrug_hands",
        ["nervous"] = "nervous",
        
        -- Affirmative
        ["nod"] = "nod_head_once",
        ["agree"] = "nod_head_multiple",
        ["applause"] = "applause_excited",
        ["cheer"] = "cheer",
        ["celebrate"] = "celebrate",
        
        -- Service/Work
        ["pour_drink"] = "manipulate_medium",
        ["serve"] = "manipulate_high",
        ["clean"] = "manipulate_medium",
        ["lean"] = "slow_down",
        
        -- Expressive
        ["stretch"] = "stretch",
        ["yawn"] = "yawn",
        ["point"] = "point_away",
        ["point_at"] = "point_accusingly",
        ["whisper"] = "whisper",
        
        -- Dancing/Sensual
        ["dance"] = "bounce",
        ["sway"] = "bounce",
        ["sexy_stretch"] = "stretch",
    },
    
    -- Mood mappings (API response -> SWG mood string)
    moodMap = {
        ["flirty"] = "coy",
        ["sultry"] = "seductive",
        ["happy"] = "cheerful",
        ["annoyed"] = "grumpy",
        ["playful"] = "mischievous",
        ["cold"] = "indifferent",
        ["warm"] = "friendly",
    }
}

registerScreenPlay("NyxaraConversation", false)

-- =============================================================================
-- HTTP HELPERS
-- =============================================================================

-- Make a POST request with JSON body
function NyxaraConversation:httpPost(url, jsonBody)
    local response = {}
    local body, status, headers = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #jsonBody
        },
        source = ltn12.source.string(jsonBody),
        sink = ltn12.sink.table(response)
    }
    
    if status == 200 then
        return table.concat(response), nil
    else
        return nil, "HTTP Error: " .. tostring(status)
    end
end

-- Simple JSON encode (for our limited use case)
function NyxaraConversation:jsonEncode(tbl)
    local result = "{"
    local first = true
    for k, v in pairs(tbl) do
        if not first then result = result .. "," end
        first = false
        
        result = result .. '"' .. tostring(k) .. '":'
        
        if type(v) == "string" then
            -- Escape special characters
            v = v:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')
            result = result .. '"' .. v .. '"'
        elseif type(v) == "number" then
            result = result .. tostring(v)
        elseif type(v) == "boolean" then
            result = result .. (v and "true" or "false")
        else
            result = result .. '"' .. tostring(v) .. '"'
        end
    end
    return result .. "}"
end

-- Simple JSON decode (for our limited use case)
function NyxaraConversation:jsonDecode(str)
    local result = {}
    
    -- Extract string values
    for key, value in str:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
        result[key] = value
    end
    
    -- Extract boolean values
    for key, value in str:gmatch('"([^"]+)"%s*:%s*(true)') do
        result[key] = true
    end
    for key, value in str:gmatch('"([^"]+)"%s*:%s*(false)') do
        result[key] = false
    end
    
    return result
end

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

-- Call this after spawning Nyxara to set up the chat observer
function NyxaraConversation:initNpc(pNpc)
    if pNpc == nil then
        print("NyxaraConversation:initNpc - pNpc is nil!")
        return
    end
    
    local npcId = SceneObject(pNpc):getObjectID()
    print("NyxaraConversation: Initializing chat listener for NPC ID " .. npcId)
    
    -- Store NPC ID for reference
    writeData("nyxara:npc_id", npcId)
    
    -- Create the spatial chat observer
    createObserver(SPATIALCHAT, "NyxaraConversation", "onSpatialChat", pNpc)
    createObserver(AIMESSAGE, "NyxaraConversation", "onSocialCommand", pNpc)
    
    print("NyxaraConversation: Chat observer created successfully")
    
    -- Start idle behavior loop
    self:startIdleLoop(pNpc)
end


-- =============================================================================
-- SOCIAL COMMAND HANDLING
-- =============================================================================

-- Emote ID to name mapping (from reaction_manager.lua observation)
local EMOTE_NAMES = {
    [180] = "kiss",
    [167] = "hug",
    [102] = "embrace",
    [142] = "nuzzle",
    [203] = "squeeze",
    [195] = "snog",
    [217] = "tickle",
    [151] = "pat",
    [229] = "lick",
    [153] = "pet",
    [155] = "pinch",
    [63] = "drool",
    [191] = "lick",
    [290] = "slap",
    [101] = "grope",  -- may not exist, placeholder
    [200] = "spank",  -- may not exist, placeholder
    [85] = "flirt",   -- may not exist, placeholder
    [236] = "wink",
    [38] = "cuddle",
    [27] = "caress",
    [218] = "tickle",
}

-- Emote tiers for relationship gating
local EMOTE_TIERS = {
    -- Tier 1: Always OK
    kiss = 1, hug = 1, embrace = 1, wink = 1, pat = 1, cuddle = 1,
    -- Tier 2: Stage 2+ required
    lick = 2, pet = 2, pinch = 2, nuzzle = 2, squeeze = 2, tickle = 2, caress = 2,
    -- Tier 3: Stage 3+ required
    grope = 3, spank = 3, slobber = 3,
    -- Negative
    slap = -1,
}

-- Relationship points for emotes
local EMOTE_RP = {
    -- Positive (at appropriate stage)
    kiss = 3, hug = 2, embrace = 2, wink = 1, cuddle = 2, caress = 2,
    lick = 2, pet = 2, pinch = 1, nuzzle = 2, squeeze = 2, tickle = 2,
    grope = 3, spank = 2,
    -- Negative
    slap = -10, slobber = -2,
}


function NyxaraConversation:onSocialCommand(pNpc, pPlayer, emoteId)
    if pNpc == nil or pPlayer == nil then
        return 0
    end
    
    local emoteName = EMOTE_NAMES[emoteId] or "unknown"
    local playerName = CreatureObject(pPlayer):getFirstName()
    local playerID = SceneObject(pPlayer):getObjectID()
    
    print("NyxaraConversation: Received social command '" .. emoteName .. "' (ID: " .. emoteId .. ") from " .. playerName)
    
    -- Get player's relationship level
    local relationship = readData("nyxara:relationship:" .. playerID) or 0
    local stage = math.floor(relationship / 20) + 1
    if stage > 5 then stage = 5 end
    
    -- Get emote tier requirement
    local requiredTier = EMOTE_TIERS[emoteName] or 1
    local rpChange = EMOTE_RP[emoteName] or 0
    
    -- Handle negative emotes (slap)
    if requiredTier == -1 then
        self:handleNegativeEmote(pNpc, pPlayer, emoteName, rpChange)
        return 0
    end
    
    -- Check if player meets tier requirement
    local requiredStage = requiredTier
    if stage < requiredStage then
        self:handlePrematureEmote(pNpc, pPlayer, emoteName, requiredStage, stage)
        return 0
    end
    
    -- Emote is appropriate - give RP and respond positively
    self:handlePositiveEmote(pNpc, pPlayer, emoteName, rpChange, stage)
    
    return 0
end

function NyxaraConversation:handleNegativeEmote(pNpc, pPlayer, emoteName, rpChange)
    local playerID = SceneObject(pPlayer):getObjectID()
    local playerName = CreatureObject(pPlayer):getFirstName()
    
    -- Apply RP penalty
    local currentRP = readData("nyxara:relationship:" .. playerID) or 0
    local newRP = math.max(-50, currentRP + rpChange)
    writeData("nyxara:relationship:" .. playerID, newRP)
    
    -- Angry response via API
    local requestBody = self:jsonEncode({
        npc_id = self.NPC_ID,
        player_name = playerName,
        message = "[PLAYER ACTION: " .. emoteName .. " - HOSTILE]",
        social_action = emoteName,
        is_positive = "false",
        intensity = 3
    })
    
    local response, err = self:httpPost(self.API_BASE .. "/chat", requestBody)
    if response then
        local data = self:jsonDecode(response)
        if data and data.dialogue then
            CreatureObject(pNpc):setMoodString("angry")
            CreatureObject(pNpc):doAnimation("shake_head_disgust")
            spatialChat(pNpc, data.dialogue)
        end
    end
end

function NyxaraConversation:handlePrematureEmote(pNpc, pPlayer, emoteName, requiredStage, currentStage)
    local playerID = SceneObject(pPlayer):getObjectID()
    local playerName = CreatureObject(pPlayer):getFirstName()
    
    -- Apply RP penalty based on how premature
    local penalty = (requiredStage - currentStage) * -5
    local currentRP = readData("nyxara:relationship:" .. playerID) or 0
    local newRP = math.max(-50, currentRP + penalty)
    writeData("nyxara:relationship:" .. playerID, newRP)
    
    -- Rejection response via API
    local requestBody = self:jsonEncode({
        npc_id = self.NPC_ID,
        player_name = playerName,
        message = "[PLAYER ACTION: " .. emoteName .. " - TOO FORWARD, relationship stage " .. currentStage .. " but needs " .. requiredStage .. "]",
        social_action = emoteName,
        is_positive = "false",
        intensity = 2,
        rejection_reason = "premature"
    })
    
    local response, err = self:httpPost(self.API_BASE .. "/chat", requestBody)
    if response then
        local data = self:jsonDecode(response)
        if data and data.dialogue then
            CreatureObject(pNpc):setMoodString("annoyed")
            CreatureObject(pNpc):doAnimation("wave_finger_warning")
            spatialChat(pNpc, data.dialogue)
        end
    end
end

function NyxaraConversation:handlePositiveEmote(pNpc, pPlayer, emoteName, rpChange, stage)
    local playerID = SceneObject(pPlayer):getObjectID()
    local playerName = CreatureObject(pPlayer):getFirstName()
    
    -- Apply RP bonus
    local currentRP = readData("nyxara:relationship:" .. playerID) or 0
    local newRP = math.min(100, currentRP + rpChange)
    writeData("nyxara:relationship:" .. playerID, newRP)
    
    print("NyxaraConversation: " .. playerName .. " RP: " .. currentRP .. " -> " .. newRP)
    
    -- Positive response via API
    local requestBody = self:jsonEncode({
        npc_id = self.NPC_ID,
        player_name = playerName,
        message = "[PLAYER ACTION: " .. emoteName .. " - WELCOME, relationship stage " .. stage .. "]",
        social_action = emoteName,
        is_positive = "true",
        intensity = stage,
        current_relationship = newRP
    })
    
    local response, err = self:httpPost(self.API_BASE .. "/chat", requestBody)
    if response then
        local data = self:jsonDecode(response)
        if data and data.dialogue then
            local mood = data.mood or "flirtatious"
            if self.moodMap[mood] then
                mood = self.moodMap[mood]
            end
            CreatureObject(pNpc):setMoodString(mood)
            
            local animation = data.animation or "none"
            local swgAnim = self.animationMap[animation]
            if swgAnim then
                CreatureObject(pNpc):doAnimation(swgAnim)
            end
            
            spatialChat(pNpc, data.dialogue)
        end
    end
    
    -- Check if we should apply a buff
    if stage >= 2 and (emoteName == "kiss" or emoteName == "embrace" or emoteName == "cuddle") then
        self:considerBuff(pNpc, pPlayer, stage)
    end
end

function NyxaraConversation:considerBuff(pNpc, pPlayer, stage)
    local playerID = SceneObject(pPlayer):getObjectID()
    
    -- Check cooldown (1 hour between buffs)
    local lastBuff = readData("nyxara:last_buff:" .. playerID) or 0
    local now = os.time()
    
    if now - lastBuff < 3600 then
        print("NyxaraConversation: Buff on cooldown for player " .. playerID)
        return
    end
    
    -- Apply buff based on stage
    self:applyBuff(pNpc, pPlayer, stage)
    writeData("nyxara:last_buff:" .. playerID, now)
end

function NyxaraConversation:applyBuff(pNpc, pPlayer, stage)
    local playerName = CreatureObject(pPlayer):getFirstName()
    local playerID = SceneObject(pPlayer):getObjectID()
    
    -- Calculate buff amounts
    local baseAmount = stage * 50  -- 100/150/200/250 for stages 2-5
    local duration = stage * 600   -- 20/30/40/50 minutes
    
    -- Personality bonus (set in subclass or config)
    local focusBonus = baseAmount
    local willBonus = baseAmount
    -- Nyxara: Better Focus buffs
    focusBonus = math.floor(baseAmount * 1.25)
    
    -- Get current max HAM
    local currentMind = CreatureObject(pPlayer):getMaxHAM(6)
    local currentFocus = CreatureObject(pPlayer):getMaxHAM(7)
    local currentWill = CreatureObject(pPlayer):getMaxHAM(8)
    
    -- Store original values for removal
    writeData("nyxara:buff_mind:" .. playerID, baseAmount)
    writeData("nyxara:buff_focus:" .. playerID, focusBonus)
    writeData("nyxara:buff_will:" .. playerID, willBonus)
    
    -- Apply buffs
    CreatureObject(pPlayer):setMaxHAM(6, currentMind + baseAmount)
    CreatureObject(pPlayer):setMaxHAM(7, currentFocus + focusBonus)
    CreatureObject(pPlayer):setMaxHAM(8, currentWill + willBonus)
    
    -- Heal to new max
    
    -- Notify player
    local buffNames = {"", "Pleasant Company", "Flattered", "Aroused", "Satisfied", "Euphoric"}
    CreatureObject(pPlayer):sendSystemMessage("You feel " .. buffNames[stage] .. ". Mind +" .. baseAmount .. ", Focus +" .. focusBonus .. ", Willpower +" .. willBonus)
    
    -- Schedule removal
    createEvent(duration * 1000, "NyxaraConversation", "removeBuff", pPlayer, tostring(playerID))
    
    print("NyxaraConversation: Applied stage " .. stage .. " buff to " .. playerName .. " for " .. duration .. " seconds")
end

function NyxaraConversation:removeBuff(pPlayer, playerIDStr)
    if pPlayer == nil then
        return
    end
    
    local playerID = tonumber(playerIDStr) or SceneObject(pPlayer):getObjectID()
    
    local mindBuff = readData("nyxara:buff_mind:" .. playerID) or 0
    local focusBuff = readData("nyxara:buff_focus:" .. playerID) or 0
    local willBuff = readData("nyxara:buff_will:" .. playerID) or 0
    
    if mindBuff > 0 then
        local currentMind = CreatureObject(pPlayer):getMaxHAM(6)
        local currentFocus = CreatureObject(pPlayer):getMaxHAM(7)
        local currentWill = CreatureObject(pPlayer):getMaxHAM(8)
        
        CreatureObject(pPlayer):setMaxHAM(6, math.max(1, currentMind - mindBuff))
        CreatureObject(pPlayer):setMaxHAM(7, math.max(1, currentFocus - focusBuff))
        CreatureObject(pPlayer):setMaxHAM(8, math.max(1, currentWill - willBuff))
        
        deleteData("nyxara:buff_mind:" .. playerID)
        deleteData("nyxara:buff_focus:" .. playerID)
        deleteData("nyxara:buff_will:" .. playerID)
        
        CreatureObject(pPlayer):sendSystemMessage("The warmth of your encounter fades...")
        print("NyxaraConversation: Removed buff from player " .. playerID)
    end
end



-- =============================================================================
-- MOVEMENT MECHANICS - BACK ROOM
-- =============================================================================

-- Location constants
NyxaraConversation.HOME_CELL = 3
NyxaraConversation.HOME_X = -0.61
NyxaraConversation.HOME_Y = 0.4
NyxaraConversation.HOME_Z = 0.74

NyxaraConversation.BACKROOM_WAYPOINTS = {
    {cell = 3, x = 4.96, y = -0.33, z = 0.74},   -- Doorway (cell 3)
    {cell = 4, x = 4.82, y = 4.25, z = 0.74},    -- Back room entrance (cell 4)
    {cell = 4, x = -2.51, y = 4.35, z = 0.74}    -- Couch (cell 4) - FINAL
}

function NyxaraConversation:leadToBackRoom(pNpc, pPlayer)
    if pNpc == nil or pPlayer == nil then
        return
    end
    
    local playerID = SceneObject(pPlayer):getObjectID()
    local relationship = readData("nyxara:relationship:" .. playerID) or 0
    local stage = math.floor(relationship / 20) + 1
    
    -- Require Stage 4+ (61+ RP)
    if stage < 4 then
        spatialChat(pNpc, "*her lekku curl slightly as she smiles* I like you, sugar. I do. But some things... they need time to feel right. You understand?")
        return
    end
    
    -- Check if already in back room
    if readData("nyxara:in_backroom") == 1 then
        spatialChat(pNpc, "*blushes* I'm... busy right now. Give me a few minutes?")
        return
    end
    
    writeData("nyxara:in_backroom", 1)
    writeData("nyxara:backroom_player", playerID)
    
    spatialChat(pNpc, "*her voice drops softer* It's loud out here. Too many watching. *touches your hand briefly* There's a quiet room... if you want to just... talk. Without all this.")
    
    -- Start movement sequence
    self:moveToWaypoint(pNpc, pPlayer, 1)
end

function NyxaraConversation:moveToWaypoint(pNpc, pPlayer, waypointIndex)
    if pNpc == nil then
        return
    end
    
    local waypoint = self.BACKROOM_WAYPOINTS[waypointIndex]
    if waypoint == nil then
        -- Arrived at destination
        self:arrivedAtBackRoom(pNpc, pPlayer)
        return
    end
    
    -- Get the building and cell
    local pBuilding = SceneObject(pNpc):getRootParent()
    if pBuilding == nil then
        print("NyxaraConversation: No building found")
        return
    end
    
    local pCell = BuildingObject(pBuilding):getCell(waypoint.cell)
    if pCell == nil then
        print("NyxaraConversation: No cell found for cell " .. waypoint.cell)
        return
    end
    
    local cellID = SceneObject(pCell):getObjectID()
    
    -- Remove static flag and enable movement
    AiAgent(pNpc):removeObjectFlag(AI_STATIC)
    AiAgent(pNpc):setMovementState(AI_PATROLLING)
    
    -- Set next position (x, z, y, cellID)
    AiAgent(pNpc):setNextPosition(waypoint.x, waypoint.z, waypoint.y, cellID)
    
    print("NyxaraConversation: Moving to waypoint " .. waypointIndex .. " at " .. waypoint.x .. ", " .. waypoint.y)
    
    -- Schedule next waypoint check
    local npcId = SceneObject(pNpc):getObjectID()
    writeData("nyxara:current_waypoint", waypointIndex + 1)
    
    createEvent(3000, "NyxaraConversation", "continueMovement", pNpc, tostring(npcId))
end

function NyxaraConversation:continueMovement(pNpc, npcIdStr)
    if pNpc == nil then
        local npcId = tonumber(npcIdStr)
        if npcId then
            pNpc = getSceneObject(npcId)
        end
        if pNpc == nil then
            return
        end
    end
    
    local waypointIndex = readData("nyxara:current_waypoint") or 1
    local playerID = readData("nyxara:backroom_player")
    local pPlayer = nil
    if playerID then
        pPlayer = getSceneObject(playerID)
    end
    
    self:moveToWaypoint(pNpc, pPlayer, waypointIndex)
end

function NyxaraConversation:arrivedAtBackRoom(pNpc, pPlayer)
    if pNpc == nil then
        return
    end
    
    CreatureObject(pNpc):setMoodString("seductive")
    spatialChat(pNpc, "*closes the door gently, her back against it for a moment* I don't bring people here. *meets your eyes* But you... you actually listen. That's rare.")
    
    -- Schedule return after private time (10 minutes)
    local npcId = SceneObject(pNpc):getObjectID()
    createEvent(600000, "NyxaraConversation", "returnFromBackRoom", pNpc, tostring(npcId))
    
    print("NyxaraConversation: Arrived at back room")
end


function NyxaraConversation:setStaticFlag(pNpc, args)
    if pNpc == nil then
        return
    end
    AiAgent(pNpc):addObjectFlag(AI_STATIC)
    AiAgent(pNpc):setMovementState(AI_OBLIVIOUS)
    -- Face south (180 degrees / pi radians)
    SceneObject(pNpc):updateDirection(3.14159)
    print("NyxaraConversation: Re-added AI_STATIC flag, facing south")
end

function NyxaraConversation:returnFromBackRoom(pNpc, npcIdStr)
    if pNpc == nil then
        local npcId = tonumber(npcIdStr)
        if npcId then
            pNpc = getSceneObject(npcId)
        end
        if pNpc == nil then
            return
        end
    end
    
    -- Get the building and home cell
    local pBuilding = SceneObject(pNpc):getRootParent()
    if pBuilding == nil then
        return
    end
    
    local pCell = BuildingObject(pBuilding):getCell(self.HOME_CELL)
    if pCell == nil then
        return
    end
    
    -- Move back to starting position using proper pathfinding
    local cellID = SceneObject(pCell):getObjectID()
    AiAgent(pNpc):setNextPosition(self.HOME_X, self.HOME_Z, self.HOME_Y, cellID)
    
    -- Re-add static flag after a delay
    createEvent(5000, "NyxaraConversation", "setStaticFlag", pNpc, "")
    
    writeData("nyxara:in_backroom", 0)
    deleteData("nyxara:backroom_player")
    deleteData("nyxara:current_waypoint")
    
    CreatureObject(pNpc):setMoodString("flirty")
    spatialChat(pNpc, "*slips back behind the bar, something softer in her eyes now* ...Thank you. For not making it weird.")
    
    print("NyxaraConversation: Returned from back room")
end


-- =============================================================================
-- CHAT OBSERVER
-- =============================================================================

-- =============================================================================
-- IDLE BEHAVIOR
-- =============================================================================

function NyxaraConversation:startIdleLoop(pNpc)
    if pNpc == nil then
        return
    end
    
    local npcId = SceneObject(pNpc):getObjectID()
    writeData("nyxara:idle_npc_id", npcId)
    
    -- Start the idle check loop (every 30 seconds)
    createEvent(300000, "NyxaraConversation", "idleCheck", pNpc, "")
    print("NyxaraConversation: Idle behavior loop started")
end

function NyxaraConversation:idleCheck(pNpc)
    if pNpc == nil then
        -- Try to recover NPC reference
        local npcId = readData("nyxara:idle_npc_id")
        if npcId ~= 0 then
            pNpc = getSceneObject(npcId)
        end
        if pNpc == nil then
            print("NyxaraConversation: Lost NPC reference, stopping idle loop")
            return
        end
    end

    -- Schedule next check
    createEvent(300000, "NyxaraConversation", "idleCheck", pNpc, "")

    -- Find nearby players by checking the building cells
    local nearbyPlayers = {}
    
    local pBuilding = SceneObject(pNpc):getRootParent()
    if pBuilding == nil or not SceneObject(pBuilding):isBuildingObject() then
        return
    end
    
    -- Check all cells in the building for players
    for i = 1, BuildingObject(pBuilding):getTotalCellNumber(), 1 do
        local pCell = BuildingObject(pBuilding):getCell(i)
        if pCell ~= nil then
            for j = 1, SceneObject(pCell):getContainerObjectsSize(), 1 do
                local pObject = SceneObject(pCell):getContainerObject(j - 1)
                if pObject ~= nil and SceneObject(pObject):isPlayerCreature() then
                    local name = CreatureObject(pObject):getFirstName()
                    table.insert(nearbyPlayers, name)
                end
            end
        end
    end

    if #nearbyPlayers == 0 then
        return
    end

    -- Call idle API
    local requestBody = '{"npc_id":"' .. self.NPC_ID .. '","nearby_players":['
    for i, name in ipairs(nearbyPlayers) do
        if i > 1 then requestBody = requestBody .. ',' end
        requestBody = requestBody .. '"' .. name .. '"'
    end
    requestBody = requestBody .. ']}'

    local response, err = self:httpPost(self.API_BASE .. "/idle/" .. self.NPC_ID, requestBody)

    if response then
        local data = self:jsonDecode(response)

        -- Check if should_act is true (need to handle string "true" vs boolean)
        local shouldAct = data.should_act
        if shouldAct == "true" then shouldAct = true end

        if shouldAct and data.dialogue then
            -- Apply mood
            local mood = data.mood or "neutral"
            if self.moodMap[mood] then
                mood = self.moodMap[mood]
            end
            CreatureObject(pNpc):setMoodString(mood)

            -- Play animation
            local animation = data.animation or "none"
            local swgAnim = self.animationMap[animation]
            if swgAnim then
                CreatureObject(pNpc):doAnimation(swgAnim)
            end

            -- Speak
            local dialogue = data.dialogue
            dialogue = dialogue:gsub('\\n', '\n'):gsub('\\"', '"')
            spatialChat(pNpc, dialogue)

            print("NyxaraConversation: Idle action - " .. dialogue)
        end
    end
end

function NyxaraConversation:onSpatialChat(pNpc, pChatMessage, playerID)
    if pNpc == nil or pChatMessage == nil then
        return 0
    end
    
    -- Get the player
    local pPlayer = getSceneObject(playerID)
    if pPlayer == nil or not SceneObject(pPlayer):isPlayerCreature() then
        return 0
    end
    
    -- Get NPC ID for cooldown tracking
    local npcId = SceneObject(pNpc):getObjectID()
    
    -- Check cooldown
    local currentTime = getTimestampMilli()
    local lastResponse = readData("nyxara:last_response:" .. playerID)
    if lastResponse ~= nil and lastResponse > 0 then
        if currentTime < lastResponse + self.RESPONSE_COOLDOWN then
            return 0
        end
    end
    
    -- Get the chat message
    local message = getChatMessage(pChatMessage)
    if message == nil or message == "" then
        return 0
    end
    
    -- Ignore very short messages (probably not directed at her)
    if string.len(message) < 2 then
        return 0
    end
    -- Ignore macro scripts (messages starting with sentinel character)
    if string.sub(message, 1, 1) == "~" or string.sub(message, 1, 1) == "#" then
        return 0
    end

    
    print("NyxaraConversation: Heard from player " .. playerID .. ": " .. message)

    -- Check if message mentions a specific NPC
    local lowerMsgCheck = string.lower(message)
    local mentionsMeChat = string.find(lowerMsgCheck, "nyxara") ~= nil
    local mentionsRivalChat = string.find(lowerMsgCheck, "karima") ~= nil
    
    -- If rival explicitly mentioned and not me, let them handle it
    if mentionsRivalChat and not mentionsMeChat then
        print("NyxaraConversation: Message directed at rival, ignoring")
        return 0
    end
    
    -- If neither name mentioned, only respond if I'm the closest
    if not mentionsMeChat and not mentionsRivalChat then
        local myDist = SceneObject(pNpc):getDistanceTo(pPlayer)
        local karimaId = readData("karima:npc_id")
        if karimaId and karimaId > 0 then
            local pKarima = getSceneObject(karimaId)
            if pKarima then
                local rivalDist = SceneObject(pKarima):getDistanceTo(pPlayer)
                if rivalDist < myDist then
                    print("NyxaraConversation: Rival is closer, ignoring generic chat")
                    return 0
                end
            end
        end
    end


    -- Check for back room trigger phrases (euphemistic, realistic)
    local backroomTriggers = {
        "somewhere private", "somewhere quiet", "private", "quiet room",
        "vip", "back room", "backroom", "upstairs",
        "get out of here", "your place", "alone",
        "special attention", "take care of me",
        "show me", "follow you", "lead the way"
    }
    for _, trigger in ipairs(backroomTriggers) do
        if string.find(lowerMsgCheck, trigger) then
            self:leadToBackRoom(pNpc, pPlayer)
            return 0
        end
    end

    -- Detect tips in message
    local tipAmount = nil
    local tipTarget = nil
    
    -- Pattern: "tip 100 to karima" or "tip karima 100" or just mentions of tipping
    local lowerMsg = string.lower(message)
    
    -- Check if tip is meant for us (mentioned by name) or rival
    local mentionsMe = string.find(lowerMsg, "nyxara") ~= nil
    local mentionsRival = string.find(lowerMsg, "karima") ~= nil
    
    -- If rival is explicitly named, apply jealousy penalty
    if mentionsRival and not mentionsMe then
        -- Check if it's a tip (we're jealous!)
        local amount = string.match(lowerMsg, "(%d+)%s*credits") or string.match(lowerMsg, "tip%s*(%d+)")
        if amount then
            local currentRP = readData("nyxara:relationship:" .. playerID) or 0
            local newRP = math.max(-50, currentRP - 3)  -- Jealousy penalty
            writeData("nyxara:relationship:" .. playerID, newRP)
            print("NyxaraConversation: Player tipped rival! Jealousy RP: " .. currentRP .. " -> " .. newRP)
        end
        return 0  -- Don't process further, let rival handle the tip
    end
    
    -- Check for tip command results that appear in spatial (e.g., "You tip Karima Ghazlani 100 credits")
    -- Or player saying things like "tip 100" or "here's 100 credits"
    local amount = string.match(lowerMsg, "(%d+)%s*credits") or string.match(lowerMsg, "tip%s*(%d+)") or string.match(lowerMsg, "(%d+)%s*tip")
    if amount then
        tipAmount = tonumber(amount)
    end
    

    -- If tip detected but no name mentioned, check if we are the closest
    if tipAmount and not mentionsMe then
        local myDist = SceneObject(pNpc):getDistanceTo(pPlayer)
        local karimaId = readData("karima:npc_id")
        if karimaId and karimaId > 0 then
            local pKarima = getSceneObject(karimaId)
            if pKarima then
                local rivalDist = SceneObject(pKarima):getDistanceTo(pPlayer)
                if rivalDist < myDist then
                    -- Rival is closer and getting the tip - jealousy!
                    local currentRP = readData("nyxara:relationship:" .. playerID) or 0
                    local newRP = math.max(-50, currentRP - 3)
                    writeData("nyxara:relationship:" .. playerID, newRP)
                    print("NyxaraConversation: Rival got tip (closer)! Jealousy RP: " .. currentRP .. " -> " .. newRP)
                    return 0
                end
            end
        end
    end

    -- Award RP based on tip amount
    if tipAmount and tipAmount > 0 then
        local rpGain = 0
        if tipAmount >= 1000 then
            rpGain = 10
        elseif tipAmount >= 500 then
            rpGain = 5
        elseif tipAmount >= 100 then
            rpGain = 2
        elseif tipAmount >= 10 then
            rpGain = 1
        end
        
        if rpGain > 0 then
            local currentRP = readData("nyxara:relationship:" .. playerID) or 0
            local newRP = math.min(100, currentRP + rpGain)
            writeData("nyxara:relationship:" .. playerID, newRP)
            
            -- Track lifetime tips
            local lifetimeTips = readData("nyxara:lifetime_tips:" .. playerID) or 0
            writeData("nyxara:lifetime_tips:" .. playerID, lifetimeTips + tipAmount)
            
            print("NyxaraConversation: Player " .. playerID .. " tipped " .. tipAmount .. " credits, RP: " .. currentRP .. " -> " .. newRP)
        end
    end


    
    -- Update cooldown
    writeData("nyxara:last_response:" .. playerID, currentTime)
    
    -- Get player name
    local playerName = CreatureObject(pPlayer):getFirstName()

    -- Cached quick responses (skip API for simple greetings)
    local quickResponses = {
        ["hi"] = {
            "*looks up with a warm smile* Hey there, sugar. What can I get you?",
            "*leans on the bar* Hi yourself. You look like you've got a story to tell.",
            "*twirls a glass absently* Hey. Rough day, or are you just here to see me?"
        },
        ["hello"] = {
            "*smiles genuinely* Hello, handsome. Welcome to my little corner of the galaxy.",
            "*sets down a glass* Hello there. New in town, or just new to me?",
            "*waves* Hello! Pull up a seat, make yourself comfortable."
        },
        ["hey"] = {
            "*grins* Hey yourself. What's your poison tonight?",
            "*looks up* Hey there. Something I can help you with?",
            "*winks* Hey, sugar. Thought you'd never show up."
        },
        ["sup"] = {
            "*chuckles* Not much, just mixing drinks and listening to stories. You got one?",
            "*shrugs with a smile* Same old, same old. But you being here makes it more interesting.",
            "*tilts head* Oh, you know. The usual chaos. What about you?"
        },
        ["bye"] = {
            "*waves* See you around, sugar. Don't do anything I wouldn't do.",
            "*smiles* Bye now. Door's always open for you.",
            "*nods* Take care of yourself out there. Galaxy's a rough place."
        },
        ["goodbye"] = {
            "*touches the bar where you were sitting* Goodbye, hon. Come back soon.",
            "*smiles warmly* Goodbye. It was nice having the company.",
            "*waves* Safe travels. Remember, first drink's on me next time."
        }
    }
    
    local lowerMsgTrim = string.lower(message):gsub("^%s*", ""):gsub("%s*$", "")
    if quickResponses[lowerMsgTrim] then
        local responses = quickResponses[lowerMsgTrim]
        local response = responses[math.random(#responses)]
        CreatureObject(pNpc):setMoodString("friendly")
        spatialChat(pNpc, response)
        print("NyxaraConversation: Quick response for '" .. lowerMsgTrim .. "'")
        return 0
    end

    
    -- Call the AI API
    local requestBody = self:jsonEncode({
        npc_id = self.NPC_ID,
        player_name = playerName,
        message = message
    })
    
    local response, err = self:httpPost(self.API_BASE .. "/chat", requestBody)
    
    if response then
        local data = self:jsonDecode(response)
        
        if data.dialogue then
            -- Apply mood
            local mood = data.mood or "neutral"
            if self.moodMap[mood] then
                mood = self.moodMap[mood]
            end
            CreatureObject(pNpc):setMoodString(mood)
            
            -- Play animation
            local animation = data.animation or "none"
            local swgAnim = self.animationMap[animation]
            if swgAnim then
                CreatureObject(pNpc):doAnimation(swgAnim)
            end
            
            -- Speak (with slight delay for natural feel)
            local dialogue = data.dialogue
            
            -- Unescape any escaped characters from JSON
            dialogue = dialogue:gsub('\\n', '\n'):gsub('\\"', '"')
            
            spatialChat(pNpc, dialogue)
            
            print("NyxaraConversation: Responded with: " .. dialogue)
        else
            print("NyxaraConversation: No dialogue in response")
        end
    else
        -- Connection error - have her react in character
        spatialChat(pNpc, "*rubs her lekku* Sorry, I'm a bit distracted right now...")
        print("NyxaraConversation: API error: " .. tostring(err))
    end
    
    return 0
end
