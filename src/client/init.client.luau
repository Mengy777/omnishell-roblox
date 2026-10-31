--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")

local shared = ReplicatedStorage:WaitForChild("OmniShell")
local catalog = require(shared:WaitForChild("Platforms"))
local games = require(shared:WaitForChild("Games"))
local UI = require(script:WaitForChild("UI"))
local XP = require(script:WaitForChild("XP"))
type Platform = catalog.Platform
type Category = catalog.Category

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("OmniShell")
if previous then previous:Destroy() end

-- No avatar HUD in the shell. Roblox's system menu remains available.
task.spawn(function()
	for _ = 1, 10 do
		local ok = pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
		if ok then break end
		task.wait(0.2)
	end
end)
local function lockCamera()
	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(0, 100, 0)
	end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(lockCamera)
lockCamera()

local gui = Instance.new("ScreenGui")
gui.Name = "OmniShell"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local root = UI.frame(gui, "FullScreen", UI.colors.background)
root.Size = UDim2.fromScale(1, 1)
UI.gradient(root, Color3.fromRGB(17, 24, 43), Color3.fromRGB(8, 12, 20), 35)

local sidebar = UI.frame(root, "Navigation", Color3.fromRGB(14, 19, 31))
local brand = UI.text(sidebar, "omni", 30)
brand.Font = Enum.Font.GothamBold
brand.Position = UDim2.fromOffset(24, 58)
brand.Size = UDim2.fromOffset(160, 40)
local brandTag = UI.text(sidebar, "S H E L L", 11, UI.colors.accent)
brandTag.Position = UDim2.fromOffset(26, 96)
brandTag.Size = UDim2.fromOffset(150, 22)
local navCaption = UI.text(sidebar, "ПЛАТФОРМЫ", 10, UI.colors.muted)
navCaption.Position = UDim2.fromOffset(24, 156)
navCaption.Size = UDim2.fromOffset(170, 20)

local nav = UI.frame(sidebar, "Categories")
local navButtons: { TextButton } = {}
local navLabels: { TextLabel } = {}
local selectedCategory: Category = catalog.categories[1]
local selectedPlatform: Platform? = nil
local page = "category"

local footer = UI.text(sidebar, "OMNISHELL / STUDIO\nОдна библиотека. Разные миры.", 11, UI.colors.muted)
footer.Position = UDim2.new(0, 24, 1, -80)
footer.Size = UDim2.new(1, -44, 0, 50)

local content = UI.frame(root, "Content")
local breadcrumb = UI.text(content, "ПЛАТФОРМЫ / WINDOWS", 11, UI.colors.muted)
breadcrumb.Size = UDim2.new(1, 0, 0, 24)
local heading = UI.text(content, "Выбери свою среду", 32)
heading.Font = Enum.Font.GothamBold
heading.Position = UDim2.fromOffset(0, 34)
heading.Size = UDim2.new(1, 0, 0, 48)
local subtitle = UI.text(content, "Твои игры — в интерфейсе, который нравится тебе.", 14, UI.colors.muted)
subtitle.Position = UDim2.fromOffset(0, 86)
subtitle.Size = UDim2.new(1, 0, 0, 42)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Page"
scroll.Position = UDim2.fromOffset(0, 146)
scroll.Size = UDim2.new(1, 0, 1, -146)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = UI.colors.accent
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = content
local stack = Instance.new("UIListLayout")
stack.Padding = UDim.new(0, 22)
stack.SortOrder = Enum.SortOrder.LayoutOrder
stack.Parent = scroll
local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingRight = UDim.new(0, 8)
scrollPadding.PaddingBottom = UDim.new(0, 24)
scrollPadding.Parent = scroll

local hero = UI.frame(scroll, "Spotlight", Color3.new(1, 1, 1))
hero.LayoutOrder = 1
hero.Size = UDim2.new(1, 0, 0, 190)
hero.ClipsDescendants = true
UI.round(hero, 20)
UI.gradient(hero, Color3.fromRGB(34, 67, 114), Color3.fromRGB(25, 30, 58), 20)
UI.stroke(hero, Color3.fromRGB(105, 154, 217), 0.7)
local heroTag = UI.text(hero, "ТВОЯ ТОЧКА ВХОДА", 10, Color3.fromRGB(169, 202, 255))
heroTag.Position = UDim2.fromOffset(24, 20)
heroTag.Size = UDim2.new(1, -48, 0, 20)
local heroTitle = UI.text(hero, "Одна коллекция.\nЛюбая атмосфера.", 28)
heroTitle.Font = Enum.Font.GothamBold
heroTitle.Position = UDim2.fromOffset(24, 49)
heroTitle.Size = UDim2.new(0.72, -24, 0, 78)
local heroNote = UI.text(hero, "Оболочка меняется. Твои игры остаются.", 13, Color3.fromRGB(181, 199, 226))
heroNote.Position = UDim2.fromOffset(24, 140)
heroNote.Size = UDim2.new(0.75, -24, 0, 32)
local heroSymbol = UI.text(hero, "⊞", 100, Color3.fromRGB(153, 195, 255))
heroSymbol.Position = UDim2.fromScale(0.77, 0.12)
heroSymbol.Size = UDim2.fromScale(0.2, 0.72)
heroSymbol.TextXAlignment = Enum.TextXAlignment.Center
heroSymbol.TextTransparency = 0.45

local section = UI.text(scroll, "WINDOWS / ВЫБЕРИ ВЕРСИЮ", 11, UI.colors.muted)
section.LayoutOrder = 2
section.Size = UDim2.new(1, 0, 0, 24)
local cards = UI.frame(scroll, "Cards")
cards.LayoutOrder = 3
cards.Size = UDim2.new(1, 0, 0, 0)
local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.fromOffset(16, 16)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = cards
local function resizeCards()
	local columns = math.max(1, math.min(3, math.floor((cards.AbsoluteSize.X + 16) / 256)))
	grid.FillDirectionMaxCells = columns
	grid.CellSize = UDim2.new(1 / columns, -16 * (columns - 1) / columns, 0, 192)
	cards.Size = UDim2.new(1, 0, 0, grid.AbsoluteContentSize.Y)
end
cards:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeCards)
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	cards.Size = UDim2.new(1, 0, 0, grid.AbsoluteContentSize.Y)
end)

local message = UI.frame(scroll, "EmptyState", UI.colors.panel)
message.LayoutOrder = 4
message.Size = UDim2.new(1, 0, 0, 172)
UI.round(message, 16)
UI.stroke(message, Color3.fromRGB(75, 91, 122), 0.6)
local messageTitle = UI.text(message, "", 21)
messageTitle.Font = Enum.Font.GothamBold
messageTitle.Position = UDim2.fromOffset(24, 20)
messageTitle.Size = UDim2.new(1, -48, 0, 50)
local messageBody = UI.text(message, "", 14, UI.colors.muted)
messageBody.Position = UDim2.fromOffset(24, 78)
messageBody.Size = UDim2.new(1, -48, 0, 74)

local action = UI.button(scroll, "LibraryOrBack", Color3.fromRGB(60, 94, 154))
action.LayoutOrder = 5
action.Size = UDim2.new(1, 0, 0, 52)
local actionText = UI.text(action, "", 14)
actionText.Font = Enum.Font.GothamBold
actionText.Position = UDim2.fromOffset(20, 0)
actionText.Size = UDim2.new(1, -40, 1, 0)

local render: () -> ()
local function clearCards()
	GuiService.SelectedObject = nil
	for _, child in cards:GetChildren() do
		if child:IsA("TextButton") then child:Destroy() end
	end
end

local function addPlatform(platform: Platform, index: number)
	local button = UI.button(cards, platform.id, UI.colors.panel)
	button.LayoutOrder = index
	local icon = UI.frame(button, "Icon", platform.accent:Lerp(UI.colors.panel, 0.84))
	icon.Position = UDim2.fromOffset(18, 18)
	icon.Size = UDim2.fromOffset(48, 48)
	UI.round(icon, 12)
	local symbol = UI.text(icon, platform.symbol, 27, platform.accent)
	symbol.Size = UDim2.fromScale(1, 1)
	symbol.TextXAlignment = Enum.TextXAlignment.Center
	local status = UI.text(button, if platform.id == "windows-xp" then "ОТКРЫТЬ" else "В ПЛАНЕ", 9, UI.colors.muted)
	status.Position = UDim2.new(1, -97, 0, 28)
	status.Size = UDim2.fromOffset(80, 20)
	status.TextXAlignment = Enum.TextXAlignment.Right
	local name = UI.text(button, platform.name, 21)
	name.Font = Enum.Font.GothamBold
	name.Position = UDim2.fromOffset(18, 80)
	name.Size = UDim2.new(1, -36, 0, 32)
	local caption = UI.text(button, platform.caption, 12, UI.colors.muted)
	caption.Position = UDim2.fromOffset(18, 118)
	caption.Size = UDim2.new(1, -36, 0, 28)
	local open = UI.text(button, if platform.id == "windows-xp" then "Войти в Windows XP  →" else "Об оболочке  →", 12, platform.accent)
	open.Position = UDim2.fromOffset(18, 156)
	open.Size = UDim2.new(1, -36, 0, 20)
	button.Activated:Connect(function()
		if platform.id == "windows-xp" then
			GuiService.SelectedObject = nil
			root.Visible = false
			XP.mount(gui, function() root.Visible = true end)
			return
		end
		selectedPlatform = platform
		page = "platform"
		render()
		GuiService.SelectedObject = action
	end)
end

render = function()
	clearCards()
	scroll.CanvasPosition = Vector2.zero
	for index, category in catalog.categories do
		navButtons[index].BackgroundColor3 = if category.id == selectedCategory.id then Color3.fromRGB(36, 51, 78) else Color3.fromRGB(18, 25, 39)
		navLabels[index].TextColor3 = if category.id == selectedCategory.id then UI.colors.text else UI.colors.muted
	end
	breadcrumb.Text = "ПЛАТФОРМЫ / " .. string.upper(selectedCategory.name)
	heroSymbol.Text = selectedCategory.symbol
	heroSymbol.TextColor3 = selectedCategory.accent
	cards.Visible = page == "category"
	message.Visible = page ~= "category"
	action.Visible = page ~= "category"
	heroTag.Text = "ТВОЯ ТОЧКА ВХОДА"
	heroTitle.Text = "Одна коллекция.\nЛюбая атмосфера."
	heroNote.Text = "Оболочка меняется. Твои игры остаются."
	if page == "category" then
		heading.Text = "Выбери свою среду"
		subtitle.Text = selectedCategory.description
		section.Text = string.upper(selectedCategory.name) .. " / ОБОЛОЧКИ"
		local count = 0
		for _, platform in catalog.platforms do
			if platform.category == selectedCategory.id then
				count += 1
				addPlatform(platform, count)
			end
		end
		if count == 0 then
			message.Visible = true
			messageTitle.Text = "Место для новых систем"
			messageBody.Text = "Здесь появятся дополнительные оболочки. Выберем следующую систему после первого рабочего интерфейса."
		end
	elseif page == "platform" and selectedPlatform then
		heading.Text = selectedPlatform.name
		subtitle.Text = "Оболочка для общей игровой библиотеки"
		heroTag.Text = "ПРЕДПРОСМОТР / ОБОЛОЧКА В ПЛАНЕ"
		heroTitle.Text = selectedPlatform.name
		heroNote.Text = "Один интерфейс. Доступ ко всей коллекции."
		heroSymbol.Text = selectedPlatform.symbol
		heroSymbol.TextColor3 = selectedPlatform.accent
		section.Text = "ЧТО БУДЕТ ВНУТРИ"
		messageTitle.Text = "Тот же набор игр — в другом стиле"
		messageBody.Text = "Загрузка, главное меню и настройки получат стиль этой системы. Её интерфейс пока не реализован. Игры будут общими для всех оболочек."
		actionText.Text = "Открыть общую библиотеку  →"
	else
		heading.Text = "Твоя библиотека"
		subtitle.Text = if selectedPlatform then "Выбранная оболочка: " .. selectedPlatform.name else "Общая коллекция для всех систем"
		heroTag.Text = "ОБЩАЯ БИБЛИОТЕКА"
		heroTitle.Text = "Игры объединяют."
		heroNote.Text = "Один игровой режим — во всех оболочках."
		section.Text = "КОЛЛЕКЦИЯ / " .. tostring(#games) .. " ИГР"
		messageTitle.Text = "Первая игра ещё впереди"
		messageBody.Text = "Сначала создадим рабочую оболочку и один игровой режим. Здесь будут только игры, которые действительно можно запустить."
		actionText.Text = "← Вернуться к оболочке"
	end
	resizeCards()
end

for index, category in catalog.categories do
	local button = UI.button(nav, category.id, Color3.fromRGB(18, 25, 39))
	local text = UI.text(button, category.symbol .. "   " .. category.name, 14, UI.colors.muted)
	text.Position = UDim2.fromOffset(14, 0)
	text.Size = UDim2.new(1, -28, 1, 0)
	navButtons[index] = button
	navLabels[index] = text
	button.Activated:Connect(function()
		selectedCategory = category
		selectedPlatform = nil
		page = "category"
		render()
	end)
end

action.Activated:Connect(function()
	page = if page == "library" then "platform" else "library"
	render()
	GuiService.SelectedObject = action
end)

local function resize()
	local width = root.AbsoluteSize.X
	local compact = width < 850
	brand.Visible = not compact
	brandTag.Visible = not compact
	navCaption.Visible = not compact
	footer.Visible = not compact
	if compact then
		sidebar.Position = UDim2.fromOffset(0, 0)
		sidebar.Size = UDim2.new(1, 0, 0, 116)
		nav.Position = UDim2.fromOffset(16, 60)
		nav.Size = UDim2.new(1, -32, 0, 44)
		content.Position = UDim2.fromOffset(20, 132)
		content.Size = UDim2.new(1, -40, 1, -148)
	else
		sidebar.Position = UDim2.fromOffset(0, 0)
		sidebar.Size = UDim2.new(0, 224, 1, 0)
		nav.Position = UDim2.fromOffset(16, 190)
		nav.Size = UDim2.new(1, -32, 0, 240)
		content.Position = UDim2.fromOffset(260, 58)
		content.Size = UDim2.new(1, -296, 1, -82)
	end
	for index, button in navButtons do
		button.Position = if compact then UDim2.new((index - 1) / 4, 3, 0, 0) else UDim2.fromOffset(0, (index - 1) * 56)
		button.Size = if compact then UDim2.new(0.25, -6, 1, 0) else UDim2.new(1, 0, 0, 46)
		navLabels[index].Text = if compact then catalog.categories[index].name else catalog.categories[index].symbol .. "   " .. catalog.categories[index].name
		navLabels[index].TextSize = if compact then 12 else 14
		navLabels[index].TextXAlignment = if compact then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left
		navLabels[index].Position = UDim2.fromOffset(if compact then 3 else 14, 0)
		navLabels[index].Size = UDim2.new(1, if compact then -6 else -28, 1, 0)
	end
	heading.TextSize = if width < 550 then 25 else 32
	heroSymbol.Visible = width >= 550
	heroTitle.TextSize = if width < 550 then 23 else 28
	heroTitle.Size = UDim2.new(if width < 550 then 1 else 0.72, -48, 0, 78)
	heroNote.Size = UDim2.new(if width < 550 then 1 else 0.75, -48, 0, 32)
	resizeCards()
end

root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
resize()
render()
