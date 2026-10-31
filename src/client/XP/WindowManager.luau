--!nonstrict

local UIS = game:GetService("UserInputService")
local T = require(script.Parent.Theme)
local WM = {}
WM.__index=WM

function WM.new(desktop,taskList)
	local self=setmetatable({desktop=desktop,taskList=taskList,windows={},order=10,connections={},drag=nil,resize=nil},WM)
	table.insert(self.connections,UIS.InputChanged:Connect(function(input)
		if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
		local scale=desktop:GetAttribute("UIScale") or 1
		if self.drag then
			local d=self.drag
			local delta=(input.Position-d.start)/scale
			local x=math.clamp(d.x+delta.X,0,math.max(0,desktop.AbsoluteSize.X/scale-80))
			local y=math.clamp(d.y+delta.Y,0,math.max(0,desktop.AbsoluteSize.Y/scale-60))
			d.window.frame.Position=UDim2.fromOffset(x,y)
		elseif self.resize then
			local d=self.resize
			local delta=(input.Position-d.start)/scale
			d.window.frame.Size=UDim2.fromOffset(math.max(340,d.w+delta.X),math.max(240,d.h+delta.Y))
		end
	end))
	table.insert(self.connections,UIS.InputEnded:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then self.drag=nil self.resize=nil end
	end))
	return self
end

function WM:focus(window)
	self.order+=1
	window.frame.ZIndex=self.order
	window.frame.Visible=true
	for _,other in self.windows do
		other.task.BackgroundColor3=if other==window then Color3.fromRGB(30,82,183) else Color3.fromRGB(60,129,243)
		local taskFile=if other==window then "TaskBandButton-5.png" else "TaskBandButton-1.png"
		other.taskSkin.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..taskFile
		other.taskSkin:SetAttribute("LunaFile",taskFile)
		other.title.BackgroundColor3=if other==window then Color3.new(1,1,1) else Color3.fromRGB(160,178,210)
		local file=if other==window then "FrameCaption-1.png" else "FrameCaption-2.png"
		other.captionSkin.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..file
		other.captionSkin:SetAttribute("LunaFile",file)
	end
end

function WM:create(id,title,icon,width,height)
	if self.windows[id] then self:focus(self.windows[id]) return self.windows[id],false end
	local frame=T.frame(self.desktop,id,T.blue,150+(self.order%5)*22,60+(self.order%5)*18,width or 600,height or 430)
	T.round(frame,6)
	T.border(frame,Color3.fromRGB(0,31,134))
	frame.Active=true
	local header=T.frame(frame,"TitleBar",Color3.new(1,1,1),0,0,100,30)
	header.Size=UDim2.new(1,0,0,30)
	T.round(header,6)
	local captionSkin=T.skin(header,"FrameCaption-1.png",0,0,width or 600,30,Rect.new(8,8,58,25))
	captionSkin.Size=UDim2.new(1,0,1,0)
	if icon then T.image(header,icon,6,7,16,16) end
	local titleText=T.text(header,title,27,1,(width or 600)-110,27,13,Color3.new(1,1,1),true)
	titleText.FontFace=T.titleFont
	titleText.Size=UDim2.new(1,-110,0,28)
	titleText.TextStrokeColor3=Color3.fromRGB(15,16,137)
	titleText.TextStrokeTransparency=0.55
	local body=T.frame(frame,"Body",T.surface,3,30,100,100)
	body.Size=UDim2.new(1,-6,1,-33)
	body.ClipsDescendants=true
	local task=T.flatButton(self.taskList,"",0,3,145,24)
	task.Name="Task:"..id
	local taskSkin=T.skin(task,"TaskBandButton-1.png",0,0,145,24,Rect.new(5,4,21,24))
	local taskLabel=T.text(task,title,6,0,132,24,11,Color3.new(1,1,1))
	taskLabel.TextWrapped=false taskLabel.TextTruncate=Enum.TextTruncate.AtEnd
	local window={id=id,frame=frame,body=body,title=header,captionSkin=captionSkin,titleText=titleText,task=task,taskSkin=taskSkin,taskLabel=taskLabel,maximized=false}
	self.windows[id]=window
	local function close()
		self.windows[id]=nil
		if self.drag and self.drag.window==window then self.drag=nil end
		if self.resize and self.resize.window==window then self.resize=nil end
		frame:Destroy() task:Destroy()
	end
	window.close=close
	local controls={{"_",-73,function() frame.Visible=false if self.onSound then self.onSound("Windows XP Minimize.wav") end end},{"□",-49,function()
		if window.maximized then
			frame.Position=window.savedPosition frame.Size=window.savedSize
		else
			window.savedPosition=frame.Position window.savedSize=frame.Size
			frame.Position=UDim2.fromOffset(0,0) frame.Size=UDim2.new(1,0,1,-30)
		end
		window.maximized=not window.maximized
		if window.maximizeGlyph then
			local file=if window.maximized then "RestoreGlyph-1.png" else "MaximizeGlyph-1.png"
			window.maximizeGlyph.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..file window.maximizeGlyph:SetAttribute("LunaFile",file)
		end
	end},{"×",-25,close}}
	for index,control in controls do
		local button,skin=T.button(header,"",0,4,21,21,control[3])
		button.Position=UDim2.new(1,control[2],0,4)
		button.Name=if index==1 then "Minimize" elseif index==2 then "Maximize" else "Close"
		local file=if index==3 then "CloseButton-1.png" else "CaptionButton-1.png"
		button:SetAttribute("FixedSkin",file)
		skin.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..file skin:SetAttribute("LunaFile",file)
		skin.ScaleType=Enum.ScaleType.Stretch
		local glyph=if index==1 then "MinimizeGlyph-1.png" elseif index==2 then "MaximizeGlyph-1.png" else "CloseGlyph-1.png"
		local glyphImage=T.skin(button,glyph,4,4,13,13)
		if index==2 then window.maximizeGlyph=glyphImage end
	end
	header.InputBegan:Connect(function(input)
		if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
		self:focus(window)
		if not window.maximized then self.drag={window=window,start=input.Position,x=frame.Position.X.Offset,y=frame.Position.Y.Offset} end
	end)
	frame.InputBegan:Connect(function() self:focus(window) end)
	task.Activated:Connect(function()
		if frame.Visible and frame.ZIndex==self.order then frame.Visible=false if self.onSound then self.onSound("Windows XP Minimize.wav") end
		else self:focus(window) if self.onSound then self.onSound("Windows XP Restore.wav") end end
	end)
	local handle=T.flatButton(frame,"◢",0,0,15,15)
	handle.Position=UDim2.new(1,-15,1,-15)
	handle.TextColor3=Color3.fromRGB(100,100,90)
	handle.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 and not window.maximized then
			self.resize={window=window,start=input.Position,w=frame.Size.X.Offset,h=frame.Size.Y.Offset}
		end
	end)
	self:focus(window)
	return window,true
end

function WM:tabs(window,names,render,selected)
	local body=window.body
	local tabs=T.frame(body,"Tabs",nil,8,10,100,24)
	tabs.Size=UDim2.new(1,-16,0,24)
	local page=T.frame(body,"Page",T.surface,8,34,100,100)
	page.Size=UDim2.new(1,-16,1,-78)
	T.border(page,Color3.fromRGB(145,155,156))
	local x=0
	local buttons={}
	local function show(name)
		for _,child in page:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
		for tabName,button in buttons do button.BackgroundColor3=if tabName==name then Color3.fromRGB(255,255,255) else T.surface end
		window.activeTab=name
		render(page,name)
	end
	for _,name in names do
		local width=math.max(54,utf8.len(name)*6+18)
		local button=T.button(tabs,name,x,0,width,24,function() show(name) end)
		buttons[name]=button
		x+=width
	end
	show(selected or names[1])
	return show
end

function WM:message(title,text)
	local window,fresh=self:create("message",title,"897(16x16).png",410,180)
	if not fresh then window.close() return self:message(title,text) end
	T.image(window.body,"897(16x16).png",20,24,32,32)
	T.text(window.body,text,68,16,310,74,11)
	T.button(window.body,"OK",310,102,75,23,window.close)
	return window
end

function WM:clear()
	local windows=table.clone(self.windows)
	for _,window in windows do window.close() end
end

function WM:destroy()
	self:clear()
	for _,connection in self.connections do connection:Disconnect() end
end

return WM
