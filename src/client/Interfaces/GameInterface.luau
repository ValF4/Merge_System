local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local function GameInterface()
	return React.createElement("Frame", {
		Size = UDim2.fromScale(0.3, 0.85),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderSizePixel = 0,
	}, React.createElement("UICorner"), {
		CornerRadius = UDim.new(0.05, 0),
	}, React.createElement("TextLabel", {
		Text = "Game Interface",
		Size = UDim2.fromScale(1, 0.1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
	}))
end

return GameInterface