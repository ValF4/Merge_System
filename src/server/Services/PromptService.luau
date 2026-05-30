-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

-- Modulees
local _Netwotking = require(ReplicatedStorage.Shared.Components.Netwotking)
local Modux = require(game.ReplicatedStorage.Shared.Modux)

-- Modux
local PromptService = Modux.Service("PromptService")
PromptService:Import("GridHandler")

-- Lists
local PrompConnections: {RBXScriptConnection} = {}

-- Local Functions
local function createPromptConnection(prompt: ProximityPrompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    
    local connection = prompt.Triggered:Connect(function(player)
        PromptService.GridHandler:initGridGame(player)
    end)

    table.insert(PrompConnections, connection)
end

local function createPompt()
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Merge"
    prompt.ObjectText = "Merge"
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 10
    return prompt
end

local function LoadPrompts()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "MergePart" then
            local prompt = createPompt()
            prompt.Parent = part
            createPromptConnection(prompt)
        end
    end
end

function PromptService:OnInit(callback)
    return nil
end

PromptService:OnStart(function(self)
    LoadPrompts()
    return nil
end)


return PromptService