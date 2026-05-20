local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EncounterSettings = require(ReplicatedStorage.Shared.Settings.EncounterSettings)
local AnimalDatabase = require(ReplicatedStorage.Shared.Utils.AnimalDatabase)
local EncounterDatabase = require(ReplicatedStorage.Shared.Utils.EncounterDatabase)
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local EncounterService = Modux.Service("EncounterService")
EncounterService:Import("PlayerService"):Import("ProfileService"):Import("CombatService")
EncounterService.InZone = {} :: { [Player]: { [Instance]: boolean } }

EncounterService.SelectOpponent = function(self, Player)
	local currentZone = self.ProfileService:GetData(Player).CurrentZone
	local targetList = AnimalDatabase.GetByElement(EncounterDatabase[currentZone])
	print(targetList)
end

EncounterService.RollChance = function(self, Player)
	local playerChance = EncounterSettings.EncounterChance
	local profile = self.ProfileService:GetData(Player)

	if profile.HasIncense then
		playerChance *= EncounterSettings.EssenceMultiplier
	end

	local result = math.random(1, 100)
	if result <= playerChance then
		self:SelectOpponent(Player)
		warn(`[{Player} got in a Combat!]`)
	end
end

EncounterService.AddPlayer = function(self, Player: Player, Zone: Instance)
	self.InZone[Player] = self.InZone[Player] or {}
	self.InZone[Player][Zone] = true
end

EncounterService.RemovePlayer = function(self, Player: Player, Zone: Instance)
	local zones = self.InZone[Player]
	if not zones then
		return
	end

	zones[Zone] = nil

	if next(zones) == nil then
		self.InZone[Player] = nil
	end
end

EncounterService.StartThread = function(self)
	task.spawn(function()
		while task.wait(0.25) do
			for player in self.InZone do
				EncounterService:RollChance(player)
			end
		end
	end)
end

EncounterService:OnStart(function(self)
	self:StartThread()
end)

return EncounterService
