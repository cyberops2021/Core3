katarn = Creature:new {
	objectName = "@monster_name:katarn",
	customName = "",
	socialGroup = "katarn",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 35,
	chanceHit = 0.42,
	damageMin = 320,
	damageMax = 370,
	baseXp = 3460,
	baseHAM = 9500,
	baseHAMmax = 11500,
	armor = 0,
	resists = {140, 140, 25, -1, -1, 25, 25, -1, -1},
	meatType = "meat_carnivore",
	meatAmount = 400,
	hideType = "hide_leathery",
	hideAmount = 350,
	boneType = "bone_mammal",
	boneAmount = 300,
	milk = 0,
	tamingChance = 0.15,
	ferocity = 6,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER + STALKER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.0,
	templates = {
		"object/mobile/katarn.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"knockdownattack", ""},
		{"creatureareacombo", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(katarn, "katarn")
