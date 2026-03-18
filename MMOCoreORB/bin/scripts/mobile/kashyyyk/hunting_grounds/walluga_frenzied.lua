walluga_frenzied = Creature:new {
	objectName = "@monster_name:walluga",
	customName = "a Frenzied Walluga",
	socialGroup = "walluga",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 70,
	chanceHit = 0.70,
	damageMin = 520,
	damageMax = 750,
	baseXp = 6700,
	baseHAM = 11500,
	baseHAMmax = 14000,
	armor = 1,
	resists = {140, 140, 25, 25, 25, 25, 25, -1, -1},
	meatType = "meat_carnivore",
	meatAmount = 450,
	hideType = "hide_bristley",
	hideAmount = 385,
	boneType = "bone_horn",
	boneAmount = 360,
	milk = 0,
	tamingChance = 0,
	ferocity = 15,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER + STALKER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.05,
	templates = {
		"object/mobile/walluga.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"posturedownattack", ""},
		{"knockdownattack", ""},
		{"creatureareableeding", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(walluga_frenzied, "walluga_frenzied")
