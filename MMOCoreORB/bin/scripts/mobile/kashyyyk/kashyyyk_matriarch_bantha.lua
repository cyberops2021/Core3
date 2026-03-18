kashyyyk_matriarch_bantha = Creature:new {
	objectName = "@monster_name:kashyyyk_bantha",
	customName = "a Kashyyyk Matriarch Bantha",
	socialGroup = "etyyybantha",
	faction = "",
	mobType = MOB_HERBIVORE,
	level = 45,
	chanceHit = 0.47,
	damageMin = 375,
	damageMax = 450,
	baseXp = 4500,
	baseHAM = 9000,
	baseHAMmax = 11000,
	armor = 0,
	resists = {135, 15, 150, 15, -1, -1, -1, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 450,
	hideType = "hide_wooly",
	hideAmount = 375,
	boneType = "bone_mammal",
	boneAmount = 400,
	milk = 0,
	tamingChance = 0,
	ferocity = 0,
	pvpBitmask = ATTACKABLE,
	creatureBitmask = PACK + HERD + KILLER,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,
	scale = 1.2,
	templates = {
		"object/mobile/kashyyyk_bantha.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"posturedownattack", ""},
		{"knockdownattack", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(kashyyyk_matriarch_bantha, "kashyyyk_matriarch_bantha")
