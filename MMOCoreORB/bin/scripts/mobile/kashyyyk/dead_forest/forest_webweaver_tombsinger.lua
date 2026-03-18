forest_webweaver_tombsinger = Creature:new {
	objectName = "@monster_name:webweaver",
	customName = "",
	socialGroup = "webweaver",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 65,
	chanceHit = 0.7,
	damageMin = 500,
	damageMax = 700,
	baseXp = 6200,
	baseHAM = 13000,
	baseHAMmax = 16000,
	armor = 1,
	resists = {-1, 55, -1, 10, 10, 80, 10, -1, -1},
	meatType = "meat_insect",
	meatAmount = 300,
	hideType = "",
	hideAmount = 0,
	boneType = "",
	boneAmount = 0,
	milk = 0,
	tamingChance = 0,
	ferocity = 5,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.35,
	templates = {
		"object/mobile/som/webweaver.iff"
	},
	lootGroups = {},
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"posturedownattack", ""},
		{"creatureareableeding", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(forest_webweaver_tombsinger, "forest_webweaver_tombsinger")
