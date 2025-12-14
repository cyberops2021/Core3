local ObjectManager = require("managers.object.object_manager")

-- Shuttle contact locations by faction for waypoint tracking
local shuttleContacts = {
	neutral = { planet = "tatooine", x = -6178.8, y = -6381.5, name = "Klaatu" },
	imperial = { planet = "naboo", x = 2447.5, y = -3898.0, name = "DS-297" },
	rebel = { planet = "corellia", x = -6518.5, y = 6044.1, name = "Lt. Lance" }
}

-- Intel locations for all 9 quest givers (from original SOE data)
local intelLocations = {
	-- NEUTRAL QUESTS
	ticketGiverYondalla = {  -- Rescue
		{ planet = "talus", x = -4820, y = -4743, name = "Kahmurra Bio Facility" },
		{ planet = "corellia", x = 1353, y = -329, name = "Lord Nyax Hideout" },
		{ planet = "endor", x = 2134, y = 3686, name = "Korga Cave" }
	},
	ticketGiverBruce = {  -- Destroy
		{ planet = "naboo", x = 2455, y = -3869, name = "Mauler Stronghold" },
		{ planet = "corellia", x = 5765, y = 1585, name = "Rogue CorSec Base" },
		{ planet = "dathomir", x = -3782, y = -84, name = "Nightsister Slave Camp" }
	},
	ticketGiverBronell = {  -- Assassin
		{ planet = "talus", x = -2475, y = -3886, name = "Binayre Pirate Bunker" },
		{ planet = "naboo", x = -1507, y = -1729, name = "Pirate Bunker" },
		{ planet = "lok", x = -3824, y = -464, name = "Canyon Corsair Stronghold" }
	},
	-- IMPERIAL QUESTS
	ticketGiverSabol = {  -- Assassin
		{ planet = "corellia", x = -2557, y = 3005, name = "Afarathu Cave" },
		{ planet = "dantooine", x = -6676, y = 5557, name = "Abandoned Rebel Base" },
		{ planet = "dathomir", x = 5693, y = 1934, name = "Downed Ship" }
	},
	ticketGiverDarkstone = {  -- Rescue
		{ planet = "yavin4", x = -291, y = 4856, name = "Woolamander Palace" },
		{ planet = "corellia", x = 5765, y = 1585, name = "Rogue CorSec Base" },
		{ planet = "lok", x = 3350, y = -4690, name = "Droid Engineer Cave" }
	},
	ticketGiverVelso = {  -- Destroy
		{ planet = "naboo", x = -5936, y = -6270, name = "Weapons Depot" },
		{ planet = "talus", x = -2235, y = 2303, name = "Detainment Center" },
		{ planet = "rori", x = -1635, y = -3721, name = "Rebel Outpost" }
	},
	-- REBEL QUESTS
	ticketGiverPashna = {  -- Assassin
		{ planet = "dantooine", x = -4195, y = -2376, name = "Mokk Stronghold" },
		{ planet = "yavin4", x = -6485, y = -447, name = "Geonosian Lab" },
		{ planet = "tatooine", x = -3939, y = 6323, name = "Fort Tusken" }
	},
	ticketGiverTallon = {  -- Rescue
		{ planet = "naboo", x = 4660, y = -4682, name = "Imperial vs. Gungan Battle" },
		{ planet = "dathomir", x = -6309, y = 753, name = "Dathomir Prison" },
		{ planet = "yavin4", x = 5070, y = 5537, name = "Massassi Temple" }
	},
	ticketGiverCrowley = {  -- Destroy
		{ planet = "corellia", x = -4654, y = -2644, name = "Hidden Bunker" },
		{ planet = "dathomir", x = -6309, y = 753, name = "Dathomir Prison" },
		{ planet = "rori", x = 5451, y = 5025, name = "Cobral Hideout" }
	}
}

CorvetteTicketGiverConvoHandler = conv_handler:new {
	ticketGiver = nil
}

function CorvetteTicketGiverConvoHandler:setTicketGiver(giver)
	self.ticketGiver = giver
end

-- Add a quest waypoint for the corvette mission
function CorvetteTicketGiverConvoHandler:addQuestWaypoint(pPlayer, waypointName, planet, x, y)
	local pGhost = CreatureObject(pPlayer):getPlayerObject()
	if pGhost == nil then
		return nil
	end

	-- Remove any existing corvette quest waypoint first
	self:removeQuestWaypoint(pPlayer)

	-- Add new waypoint using standard purple quest waypoint
	local waypointID = PlayerObject(pGhost):addWaypoint(planet, waypointName, "", x, 0, y, WAYPOINT_PURPLE, true, true, 0, 0)

	if waypointID ~= nil and waypointID ~= 0 then
		-- Store the waypoint ID for later removal
		local playerID = SceneObject(pPlayer):getObjectID()
		setQuestStatus(playerID .. ":corvetteQuestWaypointID", waypointID)
	end

	return waypointID
end

-- Remove the corvette quest waypoint
function CorvetteTicketGiverConvoHandler:removeQuestWaypoint(pPlayer)
	local pGhost = CreatureObject(pPlayer):getPlayerObject()
	if pGhost == nil then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()
	local waypointID = getQuestStatus(playerID .. ":corvetteQuestWaypointID")

	if waypointID ~= nil and waypointID ~= "" then
		PlayerObject(pGhost):removeWaypoint(tonumber(waypointID), true)
		removeQuestStatus(playerID .. ":corvetteQuestWaypointID")
	end
end

-- Add waypoint to shuttle contact when player has ticket
function CorvetteTicketGiverConvoHandler:addShuttleContactWaypoint(pPlayer)
	local faction = self.ticketGiver.ticketInfo.faction or "neutral"
	local contact = shuttleContacts[faction]
	if contact ~= nil then
		self:addQuestWaypoint(pPlayer, "Corvette Boarding: " .. contact.name, contact.planet, contact.x, contact.y)
	end
end

-- Add waypoint to intel location based on location number (1, 2, or 3)
function CorvetteTicketGiverConvoHandler:addIntelLocationWaypoint(pPlayer, locationNumber)
	local giverName = self.ticketGiver.giverName
	local locations = intelLocations[giverName]
	
	if locations == nil then
		return
	end
	
	local loc = locations[locationNumber]
	if loc ~= nil then
		self:addQuestWaypoint(pPlayer, "Intel: " .. loc.name, loc.planet, loc.x, loc.y)
	end
end

function CorvetteTicketGiverConvoHandler:runScreenHandlers(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	local screenID = screen:getScreenID()
	local convoTemplate = LuaConversationTemplate(pConvoTemplate)
	local playerID = SceneObject(pPlayer):getObjectID()

	if (screenID == "go_get_intel") then
		setQuestStatus(playerID .. ":activeCorvetteQuest", self.ticketGiver.giverName)
		setQuestStatus(playerID .. ":activeCorvetteQuestType", self.ticketGiver.ticketInfo.missionType)
		setQuestStatus(playerID .. ":activeCorvetteStep", "1")
		self.ticketGiver:randomizeIntelLocs(pPlayer)
		-- Add waypoint to first intel location by default
		self:addIntelLocationWaypoint(pPlayer, 1)
	elseif (screenID == "back_already") then
		pConvoScreen = self:handleScreenBackAlready(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif (screenID == "has_intel") or  screenID == "other_documents" then
		pConvoScreen = self:handleScreenHasIntel(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif (screenID == "hear_locations_quit") or (screenID == "decline_quest_reset") or (screenID == "back_already_reset") then
		removeQuestStatus(playerID .. ":activeCorvetteQuest")
		removeQuestStatus(playerID .. ":activeCorvetteStep")
		removeQuestStatus(playerID .. ":corvetteIntelAcquired")
		removeQuestStatus(playerID .. ":corvetteIntelLocs")
		removeQuestStatus(playerID .. ":activeCorvetteQuestType")
		removeQuestStatus(playerID .. ":heardLocation1")
		removeQuestStatus(playerID .. ":heardLocation2")
		removeQuestStatus(playerID .. ":heardLocation3")
		self.ticketGiver:removeDocuments(pPlayer)
		-- Remove quest waypoint when quest is abandoned
		self:removeQuestWaypoint(pPlayer)
	elseif (screenID == "which_planet") or (screenID == "quest_start") then
		removeQuestStatus(playerID .. ":heardLocation1")
		removeQuestStatus(playerID .. ":heardLocation2")
		removeQuestStatus(playerID .. ":heardLocation3")
		pConvoScreen = self:handleScreenHeardLocations(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif (screenID == "first_location") then
		setQuestStatus(playerID .. ":heardLocation1",1)
		pConvoScreen = self:handleScreenHeardLocations(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
		-- Add waypoint to first intel location
		self:addIntelLocationWaypoint(pPlayer, 1)
	elseif (screenID == "second_location") then
		setQuestStatus(playerID .. ":heardLocation2",1)
		pConvoScreen = self:handleScreenHeardLocations(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
		-- Add waypoint to second intel location
		self:addIntelLocationWaypoint(pPlayer, 2)
	elseif (screenID == "third_location") then
		setQuestStatus(playerID .. ":heardLocation3",1)
		pConvoScreen = self:handleScreenHeardLocations(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
		-- Add waypoint to third intel location
		self:addIntelLocationWaypoint(pPlayer, 3)
	elseif (screenID == "bad_intel_1") then
		self.ticketGiver:removeIntel(pPlayer, 1)
		self.ticketGiver:giveCompensation(pPlayer)
		pConvoScreen = self:handleScreenHasIntel(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif  (screenID == "bad_intel_2") then
		self.ticketGiver:removeIntel(pPlayer, 2)
		self.ticketGiver:giveCompensation(pPlayer)
		pConvoScreen = self:handleScreenHasIntel(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif  (screenID == "good_intel") then
		removeQuestStatus(playerID .. ":corvetteIntelAcquired")
		removeQuestStatus(playerID .. ":corvetteIntelLocs")
		removeQuestStatus(playerID .. ":heardLocation1")
		removeQuestStatus(playerID .. ":heardLocation2")
		removeQuestStatus(playerID .. ":heardLocation3")
		setQuestStatus(playerID .. ":activeCorvetteStep", "2")
		self.ticketGiver:removeIntel(pPlayer, 3)
		self.ticketGiver:giveTicket(pPlayer)
		pConvoScreen = self:handleScreenGoodIntel(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
		-- Now add waypoint to shuttle contact since player has ticket
		self:addShuttleContactWaypoint(pPlayer)
	elseif (screenID == "still_here") then
		pConvoScreen = self:handleScreenStillHere(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif (screenID == "earned_reward") then
		pConvoScreen = self:handleScreenReward(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	elseif (screenID == "give_reward") then
		removeQuestStatus(playerID .. ":activeCorvetteQuest")
		removeQuestStatus(playerID .. ":activeCorvetteStep")
		removeQuestStatus(playerID .. ":activeCorvetteQuestType")
		self.ticketGiver:removeDocuments(pPlayer)
		self.ticketGiver:giveReward(pPlayer)
		-- Remove quest waypoint when quest is complete
		self:removeQuestWaypoint(pPlayer)
	end
	return pConvoScreen
end

function CorvetteTicketGiverConvoHandler:getInitialScreen(pPlayer, pNpc, pConvoTemplate)
	local convoTemplate = LuaConversationTemplate(pConvoTemplate)
	local playerID = SceneObject(pPlayer):getObjectID()
	local activeQuest = getQuestStatus(playerID .. ":activeCorvetteQuest")
	local activeStep = tonumber(getQuestStatus(playerID .. ":activeCorvetteStep"))
	local missionType = self.ticketGiver.ticketInfo.faction .. "_" .. self.ticketGiver.ticketInfo.missionType

	if (readData(playerID .. ":corvetteComplete:" .. missionType) == 1) then
		deleteData(playerID .. ":corvetteComplete:" .. missionType)
		return convoTemplate:getScreen("reward")
	elseif (self.ticketGiver.faction ~= 0 and not ThemeParkLogic:isInFaction(self.ticketGiver.faction, pPlayer)) then
		return convoTemplate:getScreen("no_faction")
	elseif (activeQuest ~= nil and activeQuest ~= self.ticketGiver.giverName) then
		return convoTemplate:getScreen("already_busy")
	elseif (activeQuest == nil) then
		return convoTemplate:getScreen("convo_start")
	elseif (activeStep == 1) then
		return convoTemplate:getScreen("back_already")
	elseif (activeStep == 2) then
		return convoTemplate:getScreen("still_here")
	elseif (activeStep == 3) then
		return convoTemplate:getScreen("reward")
	end
end

function CorvetteTicketGiverConvoHandler:hasIntel(pPlayer)
	local pInventory = CreatureObject(pPlayer):getSlottedObject("inventory")

	if pInventory == nil then
		return false
	end

	local templates = self.ticketGiver.intelMap.itemTemplates
	local pIntel1 = getContainerObjectByTemplate(pInventory, templates[1], true)
	local pIntel2 = getContainerObjectByTemplate(pInventory, templates[2], true)
	local pIntel3 = getContainerObjectByTemplate(pInventory, templates[3], true)

	return pIntel1 ~= nil and pIntel2 ~= nil and pIntel3 ~= nil
end

function CorvetteTicketGiverConvoHandler:handleScreenReward(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	pConvoScreen = screen:cloneScreen()
	local clonedScreen = LuaConversationScreen(pConvoScreen)

	local pInventory = CreatureObject(pPlayer):getSlottedObject("inventory")
	if (pInventory == nil) then
		return pConvoScreen
	end

	if SceneObject(pInventory):isContainerFullRecursive() then
		local text = clonedScreen:getOptionText(0)
		clonedScreen:removeAllOptions()
		clonedScreen:addOption(text, "cant_give_reward")
	end

	return pConvoScreen
end

function CorvetteTicketGiverConvoHandler:handleScreenHeardLocations(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	pConvoScreen = screen:cloneScreen()
	local clonedScreen = LuaConversationScreen(pConvoScreen)

	local playerID = SceneObject(pPlayer):getObjectID()

	local heard1 = tonumber(getQuestStatus(playerID .. ":heardLocation1"))
	local heard2 = tonumber(getQuestStatus(playerID .. ":heardLocation2"))
	local heard3 = tonumber(getQuestStatus(playerID .. ":heardLocation3"))

	clonedScreen:removeAllOptions()

	if (heard1 == nil) then
		clonedScreen:addOption(self.ticketGiver.first_location, "first_location")
	end

	if (heard2 == nil) then
		clonedScreen:addOption(self.ticketGiver.second_location, "second_location")
	end

	if (heard3 == nil) then
		clonedScreen:addOption(self.ticketGiver.third_location, "third_location")
	end

	clonedScreen:addOption(self.ticketGiver.go_get_intel, "go_get_intel")
	clonedScreen:addOption(self.ticketGiver.hear_locations_quit, "hear_locations_quit")

	return pConvoScreen
end

function CorvetteTicketGiverConvoHandler:handleScreenBackAlready(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	pConvoScreen = screen:cloneScreen()
	local clonedScreen = LuaConversationScreen(pConvoScreen)

	local pInventory = CreatureObject(pPlayer):getSlottedObject("inventory")

	if (pInventory == nil) then
		return pConvoScreen
	end

	clonedScreen:removeAllOptions()

	if self.ticketGiver:hasDocuments(pPlayer) then
		clonedScreen:addOption(self.ticketGiver.has_intel, "has_intel")
	end

	clonedScreen:addOption(self.ticketGiver.which_planet, "which_planet")
	clonedScreen:addOption(self.ticketGiver.back_already_reset, "back_already_reset")

	return pConvoScreen
end

function CorvetteTicketGiverConvoHandler:handleScreenHasIntel(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	pConvoScreen = screen:cloneScreen()
	local clonedScreen = LuaConversationScreen(pConvoScreen)

	local pInventory = CreatureObject(pPlayer):getSlottedObject("inventory")

	if (pInventory == nil) then
		return pConvoScreen
	end

	local templates = self.ticketGiver.intelMap.itemTemplates
	local pIntel1 = getContainerObjectByTemplate(pInventory, templates[1], true)
	local pIntel2 = getContainerObjectByTemplate(pInventory, templates[2], true)
	local pIntel3 = getContainerObjectByTemplate(pInventory, templates[3], true)

	clonedScreen:removeAllOptions()

	if (pIntel1 ~= nil) then
		clonedScreen:addOption(self.ticketGiver.bad_intel_1, "bad_intel_1")
	end

	if (pIntel2 ~= nil) then
		clonedScreen:addOption(self.ticketGiver.bad_intel_2, "bad_intel_2")
	end

	if (pIntel3 ~= nil) then
		clonedScreen:addOption(self.ticketGiver.good_intel, "good_intel")
	end

	if self.ticketGiver:hasTicket(pPlayer) then
		clonedScreen:addOption(self.ticketGiver.go_to_corvette, "go_to_corvette")
	else
		local screenID = screen:getScreenID()
		if (screenID == "bad_intel_1" or screenID == "bad_intel_2") then
			clonedScreen:addOption(self.ticketGiver.check_other_places, "check_other_places")
		end
	end

	return pConvoScreen
end

function CorvetteTicketGiverConvoHandler:handleScreenStillHere(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	pConvoScreen = screen:cloneScreen()
	local clonedScreen = LuaConversationScreen(pConvoScreen)

	clonedScreen:removeAllOptions()

	clonedScreen:addOption(self.ticketGiver.launch_location, "launch_location")
	clonedScreen:addOption(self.ticketGiver.still_here_decline, "still_here_decline")

	if self.ticketGiver:hasDocuments(pPlayer) then
		clonedScreen:addOption(self.ticketGiver.other_documents, "other_documents")
	end

	return pConvoScreen
end

function CorvetteTicketGiverConvoHandler:handleScreenGoodIntel(pConvoTemplate, pPlayer, pNpc, selectedOption, pConvoScreen)
	local screen = LuaConversationScreen(pConvoScreen)
	pConvoScreen = screen:cloneScreen()
	local clonedScreen = LuaConversationScreen(pConvoScreen)

	clonedScreen:removeAllOptions()

	if self.ticketGiver:hasTicket(pPlayer) then
		clonedScreen:addOption(self.ticketGiver.go_to_corvette, "go_to_corvette")

		if self.ticketGiver:hasDocuments(pPlayer) then
			clonedScreen:addOption(self.ticketGiver.other_documents, "other_documents")
		end
	end

	return pConvoScreen
end
