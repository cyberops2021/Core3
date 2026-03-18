varactyl_stalker = Creature:new {
	objectName = "@monster_name:varactyl",
	customName = "a Varactyl Stalker",
	socialGroup = "varactyl",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 40,
	chanceHit = 0.42,
	damageMin = 340,
	damageMax = 390,
	baseXp = 3800,
	baseHAM = 7500,
	baseHAMmax = 9000,
	armor = 0,
	resists = {130, 130, 15, 15, 15, -1, -1, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 375,
	hideType = "hide_scaley",
	hideAmount = 300,
	boneType = "bone_avian",
	boneAmount = 225,
	milk = 0,
	tamingChance = 0,
	ferocity = 6,
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
CreatureTemplates:addCreatureTemplate(varactyl_stalker, "varactyl_stalker")
