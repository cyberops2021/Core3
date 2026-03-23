-- Grand Cantina Placement Ability Grant
-- Grants "place_grand_cantina" to players who have BOTH:
--   Master Architect (crafting_architect_master)
--   AND either Master Dancer (social_entertainer_dance_master) or Master Musician (social_entertainer_music_master)
-- Checked on login and skill change events.

GrandCantinaAbility = ScreenPlay:new {
	numberOfActs = 1,
}

registerScreenPlay("GrandCantinaAbility", true)

function GrandCantinaAbility:start()
	createObserver(PLAYERLOGGEDIN, "GrandCantinaAbility", "onPlayerLogin")
	createObserver(SKILLADDED, "GrandCantinaAbility", "onSkillChange")
	createObserver(SKILLREMOVED, "GrandCantinaAbility", "onSkillChange")
end

function GrandCantinaAbility:onPlayerLogin(pCreature)
	self:checkAbility(pCreature)
	return 0
end

function GrandCantinaAbility:onSkillChange(pCreature)
	self:checkAbility(pCreature)
	return 0
end

function GrandCantinaAbility:checkAbility(pCreature)
	if pCreature == nil then
		return
	end

	local creature = LuaCreatureObject(pCreature)
	local pGhost = creature:getPlayerObject()

	if pGhost == nil then
		return
	end

	local ghost = LuaPlayerObject(pGhost)

	local hasDancer = creature:hasSkill("social_entertainer_dance_master")
	local hasMusician = creature:hasSkill("social_entertainer_music_master")

	local qualifies = hasDancer or hasMusician
	local hasAbility = ghost:hasAbility("place_grand_cantina")

	if qualifies and not hasAbility then
		ghost:addAbility("place_grand_cantina")
		creature:sendSystemMessage("You have gained the ability to place a Grand Cantina!")
	elseif not qualifies and hasAbility then
		ghost:removeAbility("place_grand_cantina")
		creature:sendSystemMessage("You no longer meet the requirements to place a Grand Cantina.")
	end
end
