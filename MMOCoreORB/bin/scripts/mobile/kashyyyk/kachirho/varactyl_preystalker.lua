varactyl_preystalker = Creature:new {
	objectName = "@monster_name:varactyl",
	customName = "a Varactyl Preystalker",
	socialGroup = "varactyl",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 40,
	chanceHit = 0.42,
	damageMin = 345,
	damageMax = 400,
	baseXp = 3850,
	baseHAM = 7800,
	baseHAMmax = 9200,
	armor = 0,
	resists = {130, 130, 15, 15, 15, -1, -1, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 380,
	hideType = "hide_scaley",
	hideAmount = 310,
	boneType = "bone_avian",
	boneAmount = 230,
	milk = 0,
	tamingChance = 0,
	ferocity = 7,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + STALKER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.0,
	templates = {
		"object/mobile/varactyl.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"posturedownattack", ""},
		{"stunattack", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(varactyl_preystalker, "varactyl_preystalker")
