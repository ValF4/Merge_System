local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local Modux = require(SharedFolder.Modux)
local Netwotking = require(SharedFolder.Components.Netwotking)
local gridType = require(SharedFolder.Types.gridType)

local GridController = Modux.Controller("gridController")

local function printGrid(grid: gridType.Grid)
    local maxX = 0
    local maxY = 0

    for _, cell in grid do
        local position = cell.position
        local x = position[1]
        local y = position[2]

        if x > maxX then
            maxX = x
        end

        if y > maxY then
            maxY = y
        end
    end

    local lines = table.create(maxY + 1)
    lines[1] = `Grid {maxX}x{maxY}`
    for y = 1, maxY do
        local row = table.create(maxX)

        for x = 1, maxX do
            row[x] = "[]"
        end

        lines[y + 1] = table.concat(row, " ")
    end

    print(table.concat(lines, "\n"))
end

GridController:OnInit(function(self)
    print("GridController initialized")
    Netwotking.GameInit:on(function(data)
        local grid = data.PlayerGrid or data.grid
        if grid then
            printGrid(grid)
            self.CurrentGrid = grid
        end
    end)
end)

GridController:OnStart(function(self)
    
end)

return GridController
