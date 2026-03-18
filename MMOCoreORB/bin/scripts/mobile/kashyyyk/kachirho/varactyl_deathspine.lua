varactyl_deathspine = Creature:new {
	objectName = "@monster_name:varactyl",
	customName = "a Varactyl Deathspine",
	socialGroup = "varactyl",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 50,
	chanceHit = 0.50,
	damageMin = 400,
	damageMax = 500,
	baseXp = 4800,
	baseHAM = 9500,
	baseHAMmax = 11500,
	armor = 1,
	resists = {140, 140, 25, 25, 25, -1, -1, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 425,
	hideType = "hide_scaley",
	hideAmount = 350,
	boneType = "bone_avian",
	boneAmount = 275,
	milk = 0,
	tamingChance = 0,
	ferocity = 9,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + STALKER + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.1,
	templates = {
		"object/mobile/varactyl.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"posturedownattack", ""},
		{"stunattack", ""},
		{"knockdownattack", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(varactyl_deathspine, "varactyl_deathspine")
