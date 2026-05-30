    local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gridType = require(ReplicatedStorage.Shared.Types.gridType)
local Netwotking = require(ReplicatedStorage.Shared.Components.Netwotking)
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local GridHandler = Modux.Service("GridHandler")

local Grids: {[string]: gridType.Grid} = {}

local function SendGridToCLient(Player: Player, Grid: gridType.Grid)
    Netwotking.GameInit:send({
        PlayerGrid = Grid,
    }, Player)
end

local ChekingGrid = function(Player: Player): (boolean, gridType.Grid | nil)
    return Grids[tostring(Player.UserId)] and true or false, Grids[tostring(Player.UserId)]
end

local function randomizeGrid(): gridType.Grid | boolean
    local grid = {}
    for x = 1, 5 do
        for y = 1, 5 do
            local cellKey = tostring(x) .. "," .. tostring(y)
            grid[cellKey] = {
                position = {x, y},
                occupied = false,
                occupant = nil,
            }
        end
    end
    
    return grid :: gridType.Grid
end

function GridHandler:CreateGrid(Player: Player)
    if Grids[tostring(Player.UserId)] then
        return Grids[tostring(Player.UserId)]
    end

    local grid = randomizeGrid() :: gridType.Grid
    if not grid then return nil end

    Grids[tostring(Player.UserId)] = grid

    return grid
end

function GridHandler:initGridGame(Player: Player)
    if not Player then return end

    if not Players:findFirstChild(Player.Name) then return end

    local PlayerHasGrid: boolean, PlayerGrid: gridType.Grid? = ChekingGrid(Player)
    if not PlayerHasGrid then
        warn("O Player não possui grid")
        PlayerGrid = self:CreateGrid(Player)
    end

    if PlayerGrid then
        SendGridToCLient(Player, PlayerGrid)
    end
end

GridHandler:OnInit(function(self) return end)

GridHandler:OnStart(function(self)    
    for _, player in Players:GetPlayers() do
        task.spawn(function()
            task.wait(1)
            self:CreateGrid(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        self:CreateGrid(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        Grids[tostring(player.UserId)] = nil
    end)
end)

return GridHandler
