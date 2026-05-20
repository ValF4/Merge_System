local Modux = require(game.ReplicatedStorage.Shared.Modux)

local CombatService = Modux.Service("CombatService")
CombatService:Import("PlayerService"):Extend("PlayerService") -- it also supports chain
CombatService:Extend("PlayerService")

CombatService:OnPlayerAdded(function(Player: Player)
    
end)

CombatService:OnInit(function(self) end)

CombatService:OnStart(function(self) end)

return CombatService
