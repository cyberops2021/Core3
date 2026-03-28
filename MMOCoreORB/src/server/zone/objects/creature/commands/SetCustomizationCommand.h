/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

#ifndef SETCUSTOMIZATIONCOMMAND_H_
#define SETCUSTOMIZATIONCOMMAND_H_

#include "templates/customization/AssetCustomizationManagerTemplate.h"
#include "templates/customization/BasicRangedIntCustomizationVariable.h"
#include "templates/customization/CustomizationVariable.h"

class SetCustomizationCommand : public QueueCommand {
public:

	SetCustomizationCommand(const String& name, ZoneProcessServer* server)
		: QueueCommand(name, server) {
	}

	int doQueueCommand(CreatureObject* creature, const uint64& target, const UnicodeString& arguments) const {

		if (!checkStateMask(creature))
			return INVALIDSTATE;

		if (!checkInvalidLocomotions(creature))
			return INVALIDLOCOMOTION;

		// Parse arguments: <player> <variable> <value>
		// OR: <player> list  (to show all available variables)
		UnicodeTokenizer tokenizer(arguments);

		if (!tokenizer.hasMoreTokens()) {
			sendSyntax(creature);
			return GENERALERROR;
		}

		String targetName;
		tokenizer.getStringToken(targetName);

		PlayerManager* playerManager = server->getZoneServer()->getPlayerManager();
		ManagedReference<CreatureObject*> targetCreature = playerManager->getPlayer(targetName);

		if (targetCreature == nullptr || !targetCreature->isPlayerCreature()) {
			creature->sendSystemMessage("Player '" + targetName + "' not found or not online.");
			return INVALIDTARGET;
		}

		if (!tokenizer.hasMoreTokens()) {
			sendSyntax(creature);
			return GENERALERROR;
		}

		String variableName;
		tokenizer.getStringToken(variableName);

		// "list" subcommand — show all available customization variables for the target
		if (variableName == "list") {
			listVariables(creature, targetCreature);
			return SUCCESS;
		}

		if (!tokenizer.hasMoreTokens()) {
			sendSyntax(creature);
			return GENERALERROR;
		}

		int value = tokenizer.getIntToken();

		// Apply the customization
		Locker targetLocker(targetCreature, creature);

		targetCreature->setCustomizationVariable(variableName, (int16)value, true);

		StringBuffer msg;
		msg << "Set " << targetName << " " << variableName << " = " << value;
		creature->sendSystemMessage(msg.toString());

		return SUCCESS;
	}

	void listVariables(CreatureObject* admin, CreatureObject* target) const {
		// Get appearance filename to resolve available variables
		SharedObjectTemplate* tmpl = target->getObjectTemplate();
		if (tmpl == nullptr) return;

		String appearanceFilename = tmpl->getAppearanceFilename();

		VectorMap<String, Reference<CustomizationVariable*>> variableLimits;
		AssetCustomizationManagerTemplate::instance()->getCustomizationVariables(
			appearanceFilename.hashCode(), variableLimits, false);

		StringBuffer msg;
		msg << "Customization variables for " << target->getFirstName() << " (" << appearanceFilename << "):\\n";

		for (int i = 0; i < variableLimits.size(); ++i) {
			String varName = variableLimits.elementAt(i).getKey();
			CustomizationVariable* var = variableLimits.elementAt(i).getValue();

			BasicRangedIntCustomizationVariable* ranged = dynamic_cast<BasicRangedIntCustomizationVariable*>(var);

			if (ranged != nullptr) {
				msg << varName << " [" << ranged->getMinValueInclusive() << "-" << (ranged->getMaxValueExclusive() - 1) << "]";
			} else {
				msg << varName << " [palette]";
			}

			msg << "\\n";
		}

		admin->sendSystemMessage(msg.toString());
	}

	void sendSyntax(CreatureObject* creature) const {
		creature->sendSystemMessage("SYNTAX: /setCustomization <player> <variable> <value>");
		creature->sendSystemMessage("SYNTAX: /setCustomization <player> list");
		creature->sendSystemMessage("EXAMPLE: /setCustomization Douglas /private/index_nose_width 200");
	}
};

#endif //SETCUSTOMIZATIONCOMMAND_H_
