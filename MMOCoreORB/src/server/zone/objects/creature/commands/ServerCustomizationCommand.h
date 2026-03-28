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

		// Virtual slider expansion — compound sliders that map to multiple real sliders
		if (subCommand == "blend_face_round") {
			// Round face: increase fat/cheeks, decrease skinny/muscle
			targetCreature->setCustomizationVariable("/shared_owner/blend_fat", (int16)Math::clamp((int)(value * 0.6f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_skinny", (int16)Math::clamp(255 - (int)(value * 0.8f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_cheeks_0", (int16)Math::clamp((int)(value * 0.7f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_cheeks_1", (int16)Math::clamp((int)(value * 0.3f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_jaw_0", (int16)Math::clamp((int)(value * 0.4f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_jaw_1", (int16)Math::clamp((int)(value * 0.4f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_muscle", (int16)Math::clamp(255 - (int)(value * 0.5f), 0, 255), true);
			creature->sendSystemMessage("Applied blend_face_round = " + String::valueOf(value) + " (expanded to 7 sliders)");
			return 0;
		} else if (subCommand == "blend_nose_small") {
			// Small delicate nose: reduce all nose sliders proportionally
			targetCreature->setCustomizationVariable("/shared_owner/blend_nosewidth_0", (int16)Math::clamp(255 - (int)(value * 0.8f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_nosewidth_1", (int16)Math::clamp(255 - (int)(value * 0.8f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_nosesize_0", (int16)Math::clamp(255 - (int)(value * 0.7f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_nosesize_1", (int16)Math::clamp(255 - (int)(value * 0.7f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_nosedepth_0", (int16)Math::clamp(255 - (int)(value * 0.6f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_nosedepth_1", (int16)Math::clamp(255 - (int)(value * 0.6f), 0, 255), true);
			creature->sendSystemMessage("Applied blend_nose_small = " + String::valueOf(value) + " (expanded to 6 sliders)");
			return 0;
		} else if (subCommand == "blend_eyes_soft") {
			// Heavy-lidded soft eyes: lower eyeshape, lower eyedirection, moderate size
			targetCreature->setCustomizationVariable("/shared_owner/blend_eyeshape_0", (int16)Math::clamp(255 - (int)(value * 0.7f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_eyeshape_1", (int16)Math::clamp(255 - (int)(value * 0.7f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_eyedirection_0", (int16)Math::clamp(255 - (int)(value * 0.5f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_eyedirection_1", (int16)Math::clamp(255 - (int)(value * 0.5f), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_eyesize_0", (int16)Math::clamp((int)(value * 0.5f + 90), 0, 255), true);
			targetCreature->setCustomizationVariable("/shared_owner/blend_eyesize_1", (int16)Math::clamp((int)(value * 0.5f + 90), 0, 255), true);
			creature->sendSystemMessage("Applied blend_eyes_soft = " + String::valueOf(value) + " (expanded to 6 sliders)");
			return 0;
		}

		// Normal single slider
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
