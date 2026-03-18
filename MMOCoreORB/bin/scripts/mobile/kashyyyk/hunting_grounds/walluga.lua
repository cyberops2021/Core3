walluga = Creature:new {
	objectName = "@monster_name:walluga",
	customName = "",
	socialGroup = "walluga",
	faction = "",
	mobType = MOB_HERBIVORE,
	level = 70,
	chanceHit = 0.7,
	damageMin = 495,
	damageMax = 700,
	baseXp = 6655,
	baseHAM = 12000,
	baseHAMmax = 15000,
	armor = 2,
	resists = {25, 45, -1, 45, 45, 100, 45, -1, -1},
	meatType = "meat_carnivore",
	meatAmount = 450,
	hideType = "hide_bristley",
	hideAmount = 375,
	boneType = "bone_horn",
	boneAmount = 350,
	milk = 0,
	tamingChance = 0,
	ferocity = 5,
	pvpBitmask = ATTACKABLE,
	creatureBitmask = PACK + HERD,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,
	scale = 1,
	templates = {
		"object/mobile/walluga.iff"
	},
	lootGroups = {},
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"knockdownattack", ""},
		{"stunattack", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(walluga, "walluga")
