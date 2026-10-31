--!nonstrict

local T = {}
T.assetRoot = "rbxasset://omnishell/xp/"
T.surface = Color3.fromRGB(236, 233, 216)
T.blue = Color3.fromRGB(0, 84, 227)
T.textColor = Color3.fromRGB(0, 0, 0)
T.font = Font.new(T.assetRoot .. "fonts/Tahoma.json")
T.bold = Font.new(T.assetRoot .. "fonts/Tahoma.json", Enum.FontWeight.Bold)
T.titleFont = Font.new(T.assetRoot .. "fonts/Trebuchet.json", Enum.FontWeight.Bold)
T.currentTheme = "blue"

function T.frame(parent, name, color, x, y, w, h)
	local item = Instance.new("Frame")
	item.Name = name
	item.BorderSizePixel = 0
	item.BackgroundColor3 = color or T.surface
	if not color then item.BackgroundTransparency = 1 end
	item.Position = UDim2.fromOffset(x or 0, y or 0)
	item.Size = UDim2.fromOffset(w or 100, h or 100)
	item.Parent = parent
	return item
end

function T.text(parent, value, x, y, w, h, size, color, bold)
	local item = Instance.new("TextLabel")
	item.Name = "Label"
	item.BackgroundTransparency = 1
	item.FontFace = if bold then T.bold else T.font
	item.Text = value
	item.TextSize = size or 11
	item.TextColor3 = color or T.textColor
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.TextWrapped = true
	item.Position = UDim2.fromOffset(x or 0, y or 0)
	item.Size = UDim2.fromOffset(w or 100, h or 20)
	item.Parent = parent
	return item
end

function T.image(parent, file, x, y, w, h, folder)
	local item = Instance.new("ImageLabel")
	item.BackgroundTransparency = 1
	item.Image = T.assetRoot .. (folder or "icons/") .. file
	item.Position = UDim2.fromOffset(x or 0, y or 0)
	item.Size = UDim2.fromOffset(w or 32, h or 32)
	item.Parent = parent
	return item
end

function T.skin(parent,file,x,y,w,h,slice)
	local image=T.image(parent,file,x,y,w,h,"luna/"..T.currentTheme.."/")
	image.Name="LunaSkin"
	image:SetAttribute("LunaFile",file)
	if slice then image.ScaleType=Enum.ScaleType.Slice image.SliceCenter=slice end
	return image
end

function T.border(parent, color, thickness)
	local border = Instance.new("UIStroke")
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	border.Color = color or Color3.fromRGB(127, 157, 185)
	border.Thickness = thickness or 1
	border.Parent = parent
	return border
end

function T.round(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 3)
	corner.Parent = parent
end

function T.gradient(parent, colors)
	local keys = {}
	for i, color in colors do table.insert(keys, ColorSequenceKeypoint.new((i-1)/(#colors-1), color)) end
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(keys)
	gradient.Rotation = 90
	gradient.Parent = parent
	return gradient
end

function T.button(parent, text, x, y, w, h, callback)
	local skin=T.skin(parent,"button-1.png",x,y,w or 75,h or 23,Rect.new(4,4,16,19))
	local item = Instance.new("TextButton")
	item.Name = text
	item.FontFace = T.font
	item.Text = text
	item.TextSize = 11
	item.TextColor3 = T.textColor
	item.BorderSizePixel = 0
	item.BackgroundColor3 = Color3.new(1, 1, 1)
	item.BackgroundTransparency = 1
	item.Position = UDim2.fromOffset(x, y)
	item.Size = UDim2.fromOffset(w or 75, h or 23)
	item.Parent = parent
	local function state(index)
		local file=item:GetAttribute("FixedSkin") or ("button-"..index..".png")
		skin.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..file
		skin:SetAttribute("LunaFile",file)
	end
	item.MouseEnter:Connect(function() state(2) end)
	item.MouseLeave:Connect(function() state(1) end)
	item.MouseButton1Down:Connect(function() state(3) end)
	item.MouseButton1Up:Connect(function() state(2) end)
	for _,property in {"Position","Size","Visible","ZIndex"} do
		item:GetPropertyChangedSignal(property):Connect(function() skin[property]=item[property] end)
	end
	item.Destroying:Connect(function() skin:Destroy() end)
	if callback then item.Activated:Connect(callback) end
	return item,skin
end

function T.flatButton(parent, text, x, y, w, h, callback)
	local item = Instance.new("TextButton")
	item.Name = text
	item.Text = text
	item.FontFace = T.font
	item.TextSize = 11
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.TextColor3 = T.textColor
	item.Position = UDim2.fromOffset(x,y)
	item.Size = UDim2.fromOffset(w,h)
	item.Parent = parent
	if callback then item.Activated:Connect(callback) end
	return item
end

function T.input(parent, value, x, y, w, h)
	local item = Instance.new("TextBox")
	item.Name = "Input"
	item.BackgroundColor3 = Color3.new(1,1,1)
	item.BorderSizePixel = 0
	item.FontFace = T.font
	item.TextColor3 = T.textColor
	item.TextSize = 11
	item.Text = value or ""
	item.ClearTextOnFocus = false
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.Position = UDim2.fromOffset(x,y)
	item.Size = UDim2.fromOffset(w,h or 22)
	item.Parent = parent
	T.border(item)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0,4)
	padding.PaddingRight = UDim.new(0,4)
	padding.Parent = item
	return item
end

function T.checkbox(parent, text, value, x, y, w, callback)
	local row = T.flatButton(parent, "", x,y,w or 330,22)
	row.Name = text
	local box = T.skin(row,if value then "CheckBox13-5.png" else "CheckBox13-1.png",0,4,13,13)
	T.text(row,text,21,0,(w or 330)-21,22)
	row.Activated:Connect(function()
		value = not value
		local file=if value then "CheckBox13-5.png" else "CheckBox13-1.png"
		box.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..file box:SetAttribute("LunaFile",file)
		if callback then callback(value) end
	end)
	return row
end

function T.choice(parent, values, current, x,y,w,callback)
	local selected = table.find(values,current) or 1
	local item = T.button(parent, tostring(values[selected]) .. "   ▾",x,y,w or 220,23)
	local menu = nil
	item.Activated:Connect(function()
		if menu then menu:Destroy() menu = nil return end
		menu = T.frame(parent,"Dropdown",Color3.new(1,1,1),x,y+24,w or 220,#values*23)
		menu.ZIndex = 20
		T.border(menu)
		for index,value in values do
			local option = T.flatButton(menu,tostring(value),2,(index-1)*23,(w or 220)-4,23)
			option.TextXAlignment = Enum.TextXAlignment.Left
			option.ZIndex = 21
			option.MouseEnter:Connect(function() option.BackgroundTransparency=0 option.BackgroundColor3=Color3.fromRGB(49,106,197) option.TextColor3=Color3.new(1,1,1) end)
			option.MouseLeave:Connect(function() option.BackgroundTransparency=1 option.TextColor3=T.textColor end)
			option.Activated:Connect(function()
				selected=index
				item.Text=tostring(value).."   ▾"
				menu:Destroy() menu=nil
				if callback then callback(value) end
			end)
		end
	end)
	return item
end

function T.group(parent,title,x,y,w,h)
	local group=T.frame(parent,title,T.surface,x,y,w,h)
	T.border(group,Color3.fromRGB(208,208,191))
	local caption=T.text(group,title,10,-8,w-20,17,11,Color3.fromRGB(0,70,213))
	caption.BackgroundTransparency=0 caption.BackgroundColor3=T.surface
	return group
end

return T
