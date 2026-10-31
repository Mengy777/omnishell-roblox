--!strict

local TweenService = game:GetService("TweenService")
local UI = {}
UI.colors = {
	background = Color3.fromRGB(10, 14, 23),
	panel = Color3.fromRGB(20, 27, 42),
	text = Color3.fromRGB(239, 243, 255),
	muted = Color3.fromRGB(143, 157, 185),
	accent = Color3.fromRGB(124, 173, 255),
}

function UI.frame(parent: Instance, name: string, color: Color3?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BorderSizePixel = 0
	if color then frame.BackgroundColor3 = color else frame.BackgroundTransparency = 1 end
	frame.Parent = parent
	return frame
end

function UI.round(target: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = target
end

function UI.stroke(target: GuiObject, color: Color3, transparency: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Parent = target
	return stroke
end

function UI.gradient(target: GuiObject, first: Color3, last: Color3, rotation: number)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(first, last)
	gradient.Rotation = rotation
	gradient.Parent = target
end

function UI.text(parent: Instance, value: string, size: number, color: Color3?): TextLabel
	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.Gotham
	text.Text = value
	text.TextSize = size
	text.TextColor3 = color or UI.colors.text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Center
	text.TextWrapped = true
	text.Parent = parent
	return text
end

function UI.button(parent: Instance, name: string, color: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.BorderSizePixel = 0
	button.BackgroundColor3 = color
	button.AutoButtonColor = false
	button.Text = ""
	button.Parent = parent
	UI.round(button, 14)
	local border = UI.stroke(button, Color3.fromRGB(137, 170, 222), 0.86)
	local function focus(active: boolean)
		TweenService:Create(border, TweenInfo.new(0.15), { Transparency = if active then 0.28 else 0.86 }):Play()
	end
	button.MouseEnter:Connect(function() focus(true) end)
	button.MouseLeave:Connect(function() focus(false) end)
	button.SelectionGained:Connect(function() focus(true) end)
	button.SelectionLost:Connect(function() focus(false) end)
	return button
end

return UI
