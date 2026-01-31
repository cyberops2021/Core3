CorelliaPetersburgScreenPlay = ScreenPlay:new {
	numberOfActs = 1,

	screenplayName = "CorelliaPetersburgScreenPlay",

	planet = "corellia"
}

registerScreenPlay("CorelliaPetersburgScreenPlay", true)

function CorelliaPetersburgScreenPlay:start()
	if (isZoneEnabled(self.planet)) then
		self:spawnSceneObjects()
	end
end


function CorelliaPetersburgScreenPlay:spawnSceneObjects()
   -- Holo Newsnet Terminal at Petersburg
   spawnSceneObject(self.planet, "object/tangible/terminal/terminal_newsnet.iff", -406, 28, -1619, 0, math.rad(90))
   
   -- Crashed transport debris
   spawnSceneObject(self.planet, "object/static/structure/general/transport_debris_01.iff", -431.18, 34.53, -1520.12, 0, math.rad(90))
   spawnSceneObject(self.planet, "object/static/structure/general/transport_debris_02.iff", -420.49, 39.43, -1514.28, 0, math.rad(90))
   
   -- Smoke effects
   spawnSceneObject(self.planet, "object/static/particle/pt_burning_smokeandembers_large.iff", -431.18, 34.53, -1520.12, 0, 0)
   spawnSceneObject(self.planet, "object/static/particle/pt_burning_smokeandembers_large.iff", -420.49, 39.43, -1514.28, 0, 0)
   
   -- Fire sound
   spawnSceneObject(self.planet, "object/soundobject/soundobject_fire_roaring.iff", -425, 37, -1517, 0, 0)
end

