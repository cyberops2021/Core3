uller_stoneclaw = Creature:new {
	objectName = "@monster_name:uller",
	customName = "an Uller Stoneclaw",
	socialGroup = "uller",
	faction = "",
	mobType = MOB_HERBIVORE,
	level = 60,
	chanceHit = 0.55,
	damageMin = 445,
	damageMax = 600,
	baseXp = 5700,
	baseHAM = 11000,
	baseHAMmax = 13000,
	armor = 1,
	resists = {140, 140, 25, 25, 25, 25, 25, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 375,
	hideType = "hide_leathery",
	hideAmount = 350,
	boneType = "bone_mammal",
	boneAmount = 325,
	milk = 0,
	tamingChance = 0,
	ferocity = 0,
	pvpBitmask = ATTACKABLE,
	creatureBitmask = PACK + HERD,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,
	scale = 1.1,
	templates = {
		"object/mobile/uller.iff"
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
CreatureTemplates:addCreatureTemplate(uller_stoneclaw, "uller_stoneclaw")
