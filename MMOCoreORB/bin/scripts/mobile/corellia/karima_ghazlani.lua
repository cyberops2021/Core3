-- Karima Ghazlani - AI Entertainer/Dancer at Petersburg Cantina
-- Voluptuous human female from Tatooine with Moroccan heritage

print("LOADING: mobile/corellia/karamia_ghazlani.lua")

karima_ghazlani = Creature:new {
        objectName = "",
        customName = "Karima Ghazlani",
        socialGroup = "townsperson",
        mobType = MOB_NPC,
        faction = "",
        level = 10,
        chanceHit = 0.28,
        damageMin = 90,
        damageMax = 110,
        baseXp = 0,
        baseHAM = 810,
        baseHAMmax = 990,
        armor = 0,
        resists = {0,0,0,0,0,0,0,-1,-1},
        meatType = "",
        meatAmount = 0,
        hideType = "",
        hideAmount = 0,
        boneType = "",
        boneAmount = 0,
        milk = 0,
        tamingChance = 0,
        ferocity = 0,
        pvpBitmask = NONE,
        creatureBitmask = NONE,
        optionsBitmask = AIENABLED + CONVERSABLE,
        diet = HERBIVORE,
        templates = {"object/mobile/dressed_diva_human_female_01.iff"},
        lootGroups = {},
        primaryWeapon = "unarmed",
        secondaryWeapon = "none",
        conversationTemplate = "",
        primaryAttacks = {},
        secondaryAttacks = {}
}
CreatureTemplates:addCreatureTemplate(karima_ghazlani, "karima_ghazlani")
