forest_webweaver_bloodseeker = Creature:new {
	objectName = "@monster_name:webweaver",
	customName = "",
	socialGroup = "webweaver",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 55,
	chanceHit = 0.6,
	damageMin = 445,
	damageMax = 600,
	baseXp = 5373,
	baseHAM = 11000,
	baseHAMmax = 14000,
	armor = 0,
	resists = {-1, 45, -1, 0, 0, 70, 0, -1, -1},
	meatType = "meat_insect",
	meatAmount = 250,
	hideType = "",
	hideAmount = 0,
	boneType = "",
	boneAmount = 0,
	milk = 0,
	tamingChance = 0,
	ferocity = 3,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.25,
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
CreatureTemplates:addCreatureTemplate(forest_webweaver_bloodseeker, "forest_webweaver_bloodseeker")
