bolotaur = Creature:new {
	objectName = "@monster_name:bolotaur",
	customName = "",
	socialGroup = "bolotaur",
	faction = "",
	mobType = MOB_CARNIVORE,
	level = 30,
	chanceHit = 0.39,
	damageMin = 290,
	damageMax = 330,
	baseXp = 3005,
	baseHAM = 8500,
	baseHAMmax = 10500,
	armor = 0,
	resists = {130, 130, 15, -1, -1, 15, 15, -1, -1},
	meatType = "meat_carnivore",
	meatAmount = 350,
	hideType = "hide_scaley",
	hideAmount = 300,
	boneType = "bone_mammal",
	boneAmount = 275,
	milk = 0,
	tamingChance = 0.25,
	ferocity = 4,
	pvpBitmask = AGGRESSIVE + ATTACKABLE + ENEMY,
	creatureBitmask = PACK + KILLER,
	optionsBitmask = AIENABLED,
	diet = CARNIVORE,
	scale = 1.0,
	templates = {
		"object/mobile/bolotaur.iff"
	},
	lootGroups = {},
	conversationTemplate = "",
	primaryWeapon = "unarmed",
	secondaryWeapon = "none",
	primaryAttacks = {
		{"knockdownattack", ""},
		{"creatureareacombo", ""}
	},
	secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(bolotaur, "bolotaur")
