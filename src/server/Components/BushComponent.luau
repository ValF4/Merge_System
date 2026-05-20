local Modux = require(game.ReplicatedStorage.Shared.Modux)
local BushComponent = Modux.Component("BushComponent")
BushComponent:Extend("PlayerZoneComponent"):Tag("Bush"):ClassName("Part"):Import("EncounterService")

BushComponent:OnStart(function(self)
	self:ObserverPlayersInPart({
		MinHeight = 8,
	})

	self:OnEnter(function(Player: Player, Zone)
		self.EncounterService:AddPlayer(Player, Zone)
	end)

	self:OnExit(function(Player: Player, Zone)
		self.EncounterService:RemovePlayer(Player, Zone)
	end)
end)

return BushComponent
