/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

#ifndef SERVERCUSTOMIZATIONCOMMAND_H_
#define SERVERCUSTOMIZATIONCOMMAND_H_

#include "templates/customization/AssetCustomizationManagerTemplate.h"
#include "templates/customization/BasicRangedIntCustomizationVariable.h"
#include "templates/customization/CustomizationVariable.h"
#include "server/zone/managers/player/PlayerManager.h"

class ServerCustomizationCommand {
public:
	static int executeCommand(CreatureObject* creature, uint64 target, const String& arguments) {
		ManagedReference<PlayerManager*> playerManager = creature->getZoneServer()->getPlayerManager();

		StringTokenizer tokenizer(arguments);

		if (!tokenizer.hasMoreTokens()) {
			sendSyntax(creature);
			return 0;
		}

		String targetName;
		tokenizer.getStringToken(targetName);

		ManagedReference<CreatureObject*> targetCreature = playerManager->getPlayer(targetName);

		if (targetCreature == nullptr || !targetCreature->isPlayerCreature()) {
			creature->sendSystemMessage("Player '" + targetName + "' not found or not online.");
			return 0;
		}

		if (!tokenizer.hasMoreTokens()) {
			sendSyntax(creature);
			return 0;
		}

		String subCommand;
		tokenizer.getStringToken(subCommand);

		if (subCommand == "list") {
			listVariables(creature, targetCreature);
			return 0;
		}

		// subCommand is the variable name
		if (!tokenizer.hasMoreTokens()) {
			sendSyntax(creature);
			return 0;
		}

		int value = tokenizer.getIntToken();

		Locker targetLocker(targetCreature, creature);
		targetCreature->setCustomizationVariable(subCommand, (int16)value, true);

		creature->sendSystemMessage("Set " + targetName + " " + subCommand + " = " + String::valueOf(value));
		return 0;
	}

	static void listVariables(CreatureObject* admin, CreatureObject* target) {
		SharedObjectTemplate* tmpl = target->getObjectTemplate();
		if (tmpl == nullptr) return;

		String appearanceFilename = tmpl->getAppearanceFilename();

		VectorMap<String, Reference<CustomizationVariable*>> variableLimits;
		AssetCustomizationManagerTemplate::instance()->getCustomizationVariables(
			appearanceFilename.hashCode(), variableLimits, false);

		StringBuffer msg;
		msg << "Variables for " << target->getFirstName() << ":\\n";

		for (int i = 0; i < variableLimits.size(); ++i) {
			String varName = variableLimits.elementAt(i).getKey();
			CustomizationVariable* var = variableLimits.elementAt(i).getValue();

			BasicRangedIntCustomizationVariable* ranged = dynamic_cast<BasicRangedIntCustomizationVariable*>(var);

			if (ranged != nullptr) {
				msg << varName << " [" << ranged->getMinValueInclusive() << "-" << (ranged->getMaxValueExclusive() - 1) << "]\\n";
			} else {
				msg << varName << " [palette]\\n";
			}
		}

		admin->sendSystemMessage(msg.toString());
	}

	static void sendSyntax(CreatureObject* creature) {
		creature->sendSystemMessage("/server customization <player> <variable> <value>");
		creature->sendSystemMessage("/server customization <player> list");
		creature->sendSystemMessage("Example: /server customization Douglas /private/index_style_eyebrow 5");
	}
};

#endif //SERVERCUSTOMIZATIONCOMMAND_H_
