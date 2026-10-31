--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local platforms = require(ReplicatedStorage:WaitForChild("OmniShell"):WaitForChild("Platforms"))
type Platform = platforms.Platform

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("OmniShell")
if previous then
	previous:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "OmniShell"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(13, 17, 27)
background.BorderSizePixel = 0
background.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.9, 0.9)
panel.BackgroundTransparency = 1
panel.Parent = background

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(920, 760)
sizeLimit.Parent = panel

local function label(parent: Instance, value: string, position: UDim2, size: UDim2, textSize: number): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Position = position
	item.Size = size
	item.Font = Enum.Font.Gotham
	item.Text = value
	item.TextSize = textSize
	item.TextColor3 = Color3.fromRGB(231, 236, 249)
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.TextWrapped = true
	item.Parent = parent
	return item
end

local title = label(panel, "OmniShell", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 48), 32)
title.Font = Enum.Font.GothamBold
label(panel, "Выбери систему · первый прототип", UDim2.fromOffset(0, 52), UDim2.new(1, 0, 0, 44), 16)

local list = Instance.new("ScrollingFrame")
list.Name = "PlatformList"
list.Position = UDim2.fromOffset(0, 112)
list.Size = UDim2.new(1, 0, 1, -112)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.fromOffset(0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local detail = Instance.new("Frame")
detail.Name = "PlatformPreview"
detail.Position = list.Position
detail.Size = list.Size
detail.BackgroundTransparency = 1
detail.Visible = false
detail.Parent = panel

local detailTitle = label(detail, "", UDim2.fromScale(0, 0), UDim2.new(1, 0, 0.18, 0), 26)
detailTitle.Font = Enum.Font.GothamBold
label(
	detail,
	"Платформа выбрана.\n\nЗдесь появятся загрузка и интерфейс системы.\nСейчас работает выбор платформы и возврат в меню.",
	UDim2.fromScale(0, 0.2),
	UDim2.new(1, 0, 0.55, 0),
	17
)

local back = Instance.new("TextButton")
back.Name = "Back"
back.Position = UDim2.new(0, 0, 1, -54)
back.Size = UDim2.new(1, 0, 0, 48)
back.BackgroundColor3 = Color3.fromRGB(43, 55, 80)
back.BorderSizePixel = 0
back.Font = Enum.Font.GothamBold
back.Text = "← Выбрать другую систему"
back.TextSize = 16
back.TextColor3 = Color3.fromRGB(255, 255, 255)
back.Parent = detail
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 10)
backCorner.Parent = back

local selectedButton: TextButton? = nil

local function selectPlatform(platform: Platform, button: TextButton)
	selectedButton = button
	detailTitle.Text = platform.name
	detailTitle.TextColor3 = platform.accent
	list.Visible = false
	detail.Visible = true
	GuiService.SelectedObject = back
end

back.Activated:Connect(function()
	detail.Visible = false
	list.Visible = true
	GuiService.SelectedObject = selectedButton
end)

for index, platform in platforms do
	local button = Instance.new("TextButton")
	button.Name = platform.id
	button.LayoutOrder = index
	button.Size = UDim2.new(1, -12, 0, 82)
	button.BackgroundColor3 = Color3.fromRGB(25, 33, 49)
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = list

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local name = label(button, platform.name, UDim2.fromOffset(18, 10), UDim2.new(1, -36, 0, 30), 21)
	name.TextColor3 = platform.accent
	name.Font = Enum.Font.GothamBold
	label(button, platform.family .. " · интерфейс запланирован", UDim2.fromOffset(18, 44), UDim2.new(1, -36, 0, 24), 13)

	button.Activated:Connect(function()
		selectPlatform(platform, button)
	end)
end
