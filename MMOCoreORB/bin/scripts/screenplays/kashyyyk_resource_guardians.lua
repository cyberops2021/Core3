local Logger = require("utils.logger")

-- Kashyyyk Resource Guardians
-- Spawns aggressive mobs when players sample high-concentration resources on kashyyyk_main.
-- Density tiers: 51-75% chance spawns, 76-90% guaranteed elites, 91%+ boss with adds.

KashyyykResourceGuardians = ScreenPlay:new {
	numberOfActs = 1,
}

registerScreenPlay("KashyyykResourceGuardians", true)

-- Mob templates by tier
KashyyykResourceGuardians.tier1Mobs = {
	"ep3_blackscale_assault_m_01",
	"ep3_blackscale_assault_m_02",
	"ep3_blackscale_assault_m_03",
}

KashyyykResourceGuardians.tier2Mobs = {
	"ep3_blackscale_enforcer_m_01",
	"ep3_blackscale_enforcer_m_02",
	"ep3_blackscale_enforcer_m_03",
}

KashyyykResourceGuardians.tier3Mobs = {
	"ep3_blackscale_captain_beshk",
}

function KashyyykResourceGuardians:start()
end

function KashyyykResourceGuardians:onPlayerLogin(pPlayer)
	if pPlayer == nil then
		return
	end

	createObserver(SAMPLE, "KashyyykResourceGuardians", "onSample", pPlayer)
end

function KashyyykResourceGuardians:onSample(pPlayer, pResource, density)
	if pPlayer == nil then
		return 0
	end

	local creature = LuaCreatureObject(pPlayer)
	local zone = creature:getZoneName()

	-- Only trigger on kashyyyk_main
	if zone ~= "kashyyyk_main" then
		return 0
	end

	local x = creature:getPositionX()
	local y = creature:getPositionY()
	local z = creature:getPositionZ()

	-- density is 0-100 (passed as density * 100 from C++)
	if density <= 50 then
		return 0
	end

	if density <= 75 then
		-- 40% chance of CL50-60 mob spawn
		if getRandomNumber(100) <= 40 then
			self:spawnGuardians(pPlayer, x, y, z, 1)
		end
	elseif density <= 90 then
		-- Guaranteed CL70-80 elite spawn
		self:spawnGuardians(pPlayer, x, y, z, 2)
	else
		-- Boss tier CL85+ with adds
		self:spawnGuardians(pPlayer, x, y, z, 3)
	end

	return 0
end

function KashyyykResourceGuardians:spawnGuardians(pPlayer, x, y, z, tier)
	local creature = LuaCreatureObject(pPlayer)
	local pZone = creature:getZone()

	if pZone == nil then
		return
	end

	local mobList
	local count

	if tier == 1 then
		mobList = self.tier1Mobs
		count = getRandomNumber(1, 2)
		creature:sendSystemMessage("You hear rustling in the undergrowth...")
	elseif tier == 2 then
		mobList = self.tier2Mobs
		count = getRandomNumber(2, 3)
		creature:sendSystemMessage("\\#FF4444Hostile creatures are drawn to the resource concentration!")
	else
		mobList = self.tier3Mobs
		count = 1
		creature:sendSystemMessage("\\#FF0000A powerful predator emerges from the shadows!")
		-- Also spawn 2 adds from tier 2
		for i = 1, 2 do
			local addTemplate = self.tier2Mobs[getRandomNumber(1, #self.tier2Mobs)]
			local addX = x + getRandomNumber(-30, 30)
			local addY = y + getRandomNumber(-30, 30)
			spawnMobile("kashyyyk_main", addTemplate, 0, addX, z, addY, getRandomNumber(0, 360), 0)
		end
	end

	for i = 1, count do
		local template = mobList[getRandomNumber(1, #mobList)]
		local spawnX = x + getRandomNumber(-40, 40)
		local spawnY = y + getRandomNumber(-40, 40)
		spawnMobile("kashyyyk_main", template, 0, spawnX, z, spawnY, getRandomNumber(0, 360), 0)
	end
end
