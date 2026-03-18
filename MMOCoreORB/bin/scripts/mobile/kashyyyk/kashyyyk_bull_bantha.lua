kashyyyk_bull_bantha = Creature:new {
	objectName = "@monster_name:kashyyyk_bantha",
	customName = "a Kashyyyk Bull Bantha",
	socialGroup = "etyyybantha",
	faction = "",
	mobType = MOB_HERBIVORE,
	level = 42,
	chanceHit = 0.44,
	damageMin = 350,
	damageMax = 400,
	baseXp = 4000,
	baseHAM = 8500,
	baseHAMmax = 10000,
	armor = 0,
	resists = {130, 10, 145, 10, -1, -1, -1, -1, -1},
	meatType = "meat_herbivore",
	meatAmount = 400,
	hideType = "hide_wooly",
	hideAmount = 325,
	boneType = "bone_mammal",
	boneAmount = 350,
	milk = 0,
	tamingChance = 0,
	ferocity = 0,
	pvpBitmask = ATTACKABLE,
	creatureBitmask = PACK + HERD,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,
	scale = 1.1,
	templates = {
		"object/mobile/kashyyyk_bantha.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"posturedownattack", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(kashyyyk_bull_bantha, "kashyyyk_bull_bantha")
