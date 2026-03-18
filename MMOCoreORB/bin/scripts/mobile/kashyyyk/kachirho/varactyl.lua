varactyl = Creature:new {
	objectName = "@monster_name:varactyl",
	customName = "",
	socialGroup = "varactyl",
	faction = "",
	mobType = MOB_HERBIVORE,
	level = 26,
	chanceHit = 0.35,
	damageMin = 240,
	damageMax = 290,
	baseXp = 2637,
	baseHAM = 7200,
	baseHAMmax = 8800,
	armor = 0,
	resists = {120, 5, 5, -1, -1, -1, 5, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 350,
	hideType = "hide_scaley",
	hideAmount = 275,
	boneType = "bone_avian",
	boneAmount = 200,
	milk = 0,
	tamingChance = 0.25,
	ferocity = 0,
	pvpBitmask = ATTACKABLE,
	creatureBitmask = PACK + HERD,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,
	scale = 1.0,
	templates = {
		"object/mobile/varactyl.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"stunattack", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(varactyl, "varactyl")
