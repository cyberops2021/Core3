ep3_sathog = Creature:new {
	objectName = "",
	customName = "a sathog",
	socialGroup = "sathog",
	faction = "",
	mobType = MOB_CARNIVORE,
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
	hideAmount = 400,
	boneType = "bone_mammal",
	boneAmount = 375,
	milk = 0,
	tamingChance = 0,
	ferocity = 10,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + HERD + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.0,
	templates = {
		"object/mobile/sathog.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"knockdownattack", ""},
		{"posturedownattack", ""},
		{"creatureareableeding", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(ep3_sathog, "ep3_sathog")
