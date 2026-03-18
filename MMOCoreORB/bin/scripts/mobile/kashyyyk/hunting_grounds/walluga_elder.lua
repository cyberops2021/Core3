walluga_elder = Creature:new {
	objectName = "@monster_name:walluga",
	customName = "a Walluga Elder",
	socialGroup = "walluga",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 70,
	chanceHit = 0.65,
	damageMin = 495,
	damageMax = 700,
	baseXp = 6650,
	baseHAM = 12500,
	baseHAMmax = 15500,
	armor = 1,
	resists = {145, 145, 30, 30, 30, 30, 30, -1, -1},
	meatType = "meat_carnivore",
	meatAmount = 475,
	hideType = "hide_bristley",
	hideAmount = 400,
	boneType = "bone_horn",
	boneAmount = 375,
	milk = 0,
	tamingChance = 0,
	ferocity = 12,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.15,
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
		{"creatureareacombo", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(walluga_elder, "walluga_elder")
