walluga_stoneleg = Creature:new {
	objectName = "@monster_name:walluga",
	customName = "a Walluga Stoneleg",
	socialGroup = "walluga",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 70,
	chanceHit = 0.65,
	damageMin = 480,
	damageMax = 680,
	baseXp = 6600,
	baseHAM = 13000,
	baseHAMmax = 16000,
	armor = 2,
	resists = {155, 155, 40, 40, 40, 40, 40, -1, -1},
	meatType = "meat_carnivore",
	meatAmount = 500,
	hideType = "hide_bristley",
	hideAmount = 425,
	boneType = "bone_horn",
	boneAmount = 400,
	milk = 0,
	tamingChance = 0,
	ferocity = 10,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.2,
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
CreatureTemplates:addCreatureTemplate(walluga_stoneleg, "walluga_stoneleg")
