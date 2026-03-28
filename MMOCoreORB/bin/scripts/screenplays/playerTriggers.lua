local Logger = require("utils.logger")

PlayerTriggers = { }

function PlayerTriggers:playerLoggedIn(pPlayer)
	Logger:log("PlayerTriggers: playerLoggedIn called", LT_INFO)
	if (pPlayer == nil) then
		Logger:log("PlayerTriggers: pPlayer is nil!", LT_ERROR)
		return
	end
	Logger:log("PlayerTriggers: calling ServerEventAutomation", LT_INFO)
	ServerEventAutomation:playerLoggedIn(pPlayer)
	Logger:log("PlayerTriggers: calling BestineElection", LT_INFO)
	BestineElection:playerLoggedIn(pPlayer)
	Logger:log("PlayerTriggers: calling GrandCantinaAbility", LT_INFO)
	GrandCantinaAbility:onPlayerLogin(pPlayer)
	KashyyykResourceGuardians:onPlayerLogin(pPlayer)
	Logger:log("PlayerTriggers: done", LT_INFO)
end

function PlayerTriggers:playerLoggedOut(pPlayer)
	if (pPlayer == nil) then
		return
	end
	ServerEventAutomation:playerLoggedOut(pPlayer)
end
