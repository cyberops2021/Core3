local Logger = require("utils.logger")

-- Grand Cantina Schematic Grant
-- Schematics require: Master Architect
-- Placement ability uses the existing "place_cantina" from Master Dancer/Musician/Chef skill data.
-- Checked on login and skill change events.

GrandCantinaAbility = ScreenPlay:new {
	numberOfActs = 1,
}

GrandCantinaAbility.schematics = {
	"object/draft_schematic/structure/city/grand_cantina_tatooine.iff",
	"object/draft_schematic/structure/city/grand_cantina_corellia.iff",
	"object/draft_schematic/structure/city/grand_cantina_naboo.iff",
}

registerScreenPlay("GrandCantinaAbility", true)

function GrandCantinaAbility:start()
end

function GrandCantinaAbility:onPlayerLogin(pPlayer)
	if pPlayer == nil then
		Logger:log("GrandCantinaAbility: pPlayer is nil", LT_INFO)
		return
	end

	Logger:log("GrandCantinaAbility: onPlayerLogin called", LT_INFO)
	self:checkSchematics(pPlayer)
end

function GrandCantinaAbility:onSkillChange(pCreature)
	self:checkSchematics(pCreature)
	return 0
end

function GrandCantinaAbility:checkSchematics(pCreature)
	if pCreature == nil then
		Logger:log("GrandCantinaAbility: pCreature is nil", LT_ERROR)
		return
	end

	local creature = LuaCreatureObject(pCreature)
	local pGhost = creature:getPlayerObject()

	if pGhost == nil then
		Logger:log("GrandCantinaAbility: pGhost is nil", LT_ERROR)
		return
	end

	local ghost = LuaPlayerObject(pGhost)
	local hasArchitect = creature:hasSkill("crafting_architect_master")

	Logger:log("GrandCantinaAbility: checking " .. creature:getFirstName() .. " hasArchitect=" .. tostring(hasArchitect), LT_INFO)

	for _, schematic in ipairs(self.schematics) do
		local has = ghost:hasSchematic(schematic)

		Logger:log("GrandCantinaAbility: schematic=" .. schematic .. " has=" .. tostring(has), LT_INFO)

		if hasArchitect and not has then
			Logger:log("GrandCantinaAbility: GRANTING " .. schematic, LT_INFO)
			ghost:addRewardedSchematic(schematic, 2, -1, true)
		elseif not hasArchitect and has then
			Logger:log("GrandCantinaAbility: REMOVING " .. schematic, LT_INFO)
			ghost:removeRewardedSchematic(schematic, true)
		end
	end
end
