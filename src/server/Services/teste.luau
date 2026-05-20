local Modux = require(game.ReplicatedStorage.Shared.Modux)

local testeService = Modux.Service("testeService")
testeService:Import("PlayerService")
testeService:Extend("PlayerService")

testeService:OnInit(function(self)

end)

testeService:OnStart(function(self)
    
end)

return testeService