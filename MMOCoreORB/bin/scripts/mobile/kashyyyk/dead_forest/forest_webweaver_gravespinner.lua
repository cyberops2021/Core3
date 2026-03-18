forest_webweaver_gravespinner = Creature:new {
	objectName = "@monster_name:webweaver",
	customName = "",
	socialGroup = "webweaver",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 60,
	chanceHit = 0.65,
	damageMin = 470,
	damageMax = 650,
	baseXp = 5800,
	baseHAM = 12000,
	baseHAMmax = 15000,
	armor = 1,
	resists = {-1, 50, -1, 5, 5, 75, 5, -1, -1},
	meatType = "meat_insect",
	meatAmount = 275,
	hideType = "",
	hideAmount = 0,
	boneType = "",
	boneAmount = 0,
	milk = 0,
	tamingChance = 0,
	ferocity = 4,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.3,
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
CreatureTemplates:addCreatureTemplate(forest_webweaver_gravespinner, "forest_webweaver_gravespinner")
