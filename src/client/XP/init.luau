--!nonstrict

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")
local Debris=game:GetService("Debris")
local T=require(script.Theme)
local State=require(script.State)
local WM=require(script.WindowManager)
local Settings=require(script.Settings)
local Apps=require(script.Apps)
local XP={}

function XP.mount(gui,onExit)
	local utcOffset=0
	pcall(function()
		local now=DateTime.now()
		local localTime=now:ToLocalTime()
		utcOffset=DateTime.fromUniversalTime(localTime.Year,localTime.Month,localTime.Day,localTime.Hour,localTime.Minute,localTime.Second).UnixTimestamp-now.UnixTimestamp
	end)
	State.initialize(Players.LocalPlayer.DisplayName,utcOffset)
	State.current=nil
	local self={alive=true,connections={},lastInput=os.clock(),screen=nil,profileButtons={}}
	local physical=T.frame(gui,"WindowsXP",Color3.fromRGB(0,0,0),0,0,100,100)
	physical.Size=UDim2.fromScale(1,1)
	physical.ZIndex=100
	local canvas=T.frame(physical,"Canvas",Color3.fromRGB(0,78,152),0,0,1024,768)
	local uiScale=Instance.new("UIScale")
	uiScale.Parent=canvas
	self.root=physical self.canvas=canvas
	local originalMouseIcon=UIS.MouseIconEnabled
	UIS.MouseIconEnabled=false
	local pointerShadow=T.image(physical,"arrow.png",1,1,32,32,"cursors/")
	pointerShadow.Name="PointerShadow" pointerShadow.ZIndex=5000 pointerShadow.ImageColor3=Color3.new(0,0,0) pointerShadow.ImageTransparency=0.55
	local pointer=T.image(physical,"arrow.png",0,0,32,32,"cursors/")
	pointer.Name="Pointer" pointer.ZIndex=5001
	local initialPointer=UIS:GetMouseLocation()
	pointer.Position=UDim2.fromOffset(initialPointer.X-physical.AbsolutePosition.X,initialPointer.Y-physical.AbsolutePosition.Y)
	pointerShadow.Position=UDim2.fromOffset(initialPointer.X-physical.AbsolutePosition.X+1,initialPointer.Y-physical.AbsolutePosition.Y+1)
	local pointerHistory={}
	local desktop=T.frame(canvas,"Desktop",Color3.fromRGB(0,78,152),0,0,1024,768)
	desktop.Size=UDim2.fromScale(1,1)
	desktop.Active=true
	desktop.Visible=false
	self.desktop=desktop
	local wallpaper=T.image(desktop,"Bliss.png",0,0,1024,768,"images/")
	wallpaper.Name="Wallpaper"
	wallpaper.Size=UDim2.new(1,0,1,-30)
	local icons=T.frame(desktop,"DesktopIcons",nil,0,0,100,100)
	icons.Size=UDim2.new(1,0,1,-30)
	self.icons=icons
	local taskbar=T.frame(desktop,"Taskbar",Color3.new(1,1,1),0,0,1024,30)
	taskbar.Position=UDim2.new(0,0,1,-30)
	taskbar.Size=UDim2.new(1,0,0,30)
	taskbar.ZIndex=1000
	T.gradient(taskbar,{Color3.fromRGB(49,104,213),Color3.fromRGB(73,147,245),Color3.fromRGB(36,94,220),Color3.fromRGB(36,94,220)})
	local taskbarSkin=T.skin(taskbar,"TaskbarBackground.png",0,0,100,30,Rect.new(2,2,48,26))
	taskbarSkin.Size=UDim2.fromScale(1,1)
	local startSkin=T.skin(taskbar,"StartButton.png",0,0,100,30,Rect.new(4,4,91,29))
	startSkin.ImageRectSize=Vector2.new(99,33)
	startSkin.ImageRectOffset=Vector2.new(0,0)
	local start=T.flatButton(taskbar,"",0,0,100,30)
	start.Name="Start"
	start.MouseEnter:Connect(function() startSkin.ImageRectOffset=Vector2.new(0,33) end)
	start.MouseLeave:Connect(function() startSkin.ImageRectOffset=Vector2.new(0,0) end)
	start.MouseButton1Down:Connect(function() startSkin.ImageRectOffset=Vector2.new(0,66) end)
	start.MouseButton1Up:Connect(function() startSkin.ImageRectOffset=Vector2.new(0,33) end)
	T.image(start,"windows.png",7,5,29,20)
	local startText=T.text(start,"пуск",38,-1,60,30,20,Color3.new(1,1,1),true)
	startText.FontFace=T.titleFont
	startText.TextStrokeTransparency=0.5
	startText.TextStrokeColor3=Color3.fromRGB(30,73,22)
	local quick=T.frame(taskbar,"QuickLaunch",nil,108,0,54,30)
	T.flatButton(quick,"▣",0,3,25,24,function() for _,window in self.wm.windows do window.frame.Visible=false end end)
	T.flatButton(quick,"e",27,3,24,24,function() self.apps:explorer() end)
	self.quick=quick
	local tasks=T.frame(taskbar,"Tasks",nil,110,0,600,30)
	tasks.Size=UDim2.new(1,-240,1,0)
	tasks.ClipsDescendants=true
	local taskLayout=Instance.new("UIListLayout")
	taskLayout.FillDirection=Enum.FillDirection.Horizontal taskLayout.Padding=UDim.new(0,3) taskLayout.VerticalAlignment=Enum.VerticalAlignment.Center taskLayout.SortOrder=Enum.SortOrder.LayoutOrder taskLayout.Parent=tasks
	self.taskList=tasks
	local tray=T.frame(taskbar,"Tray",Color3.new(1,1,1),0,0,120,30)
	tray.Position=UDim2.new(1,-120,0,0)
	T.gradient(tray,{Color3.fromRGB(12,89,185),Color3.fromRGB(24,181,242),Color3.fromRGB(13,141,234),Color3.fromRGB(19,126,215)})
	local traySkin=T.skin(tray,"TaskbarTray.png",0,0,120,30,Rect.new(15,3,95,25))
	traySkin.Size=UDim2.fromScale(1,1)
	T.border(tray,Color3.fromRGB(16,66,175))
	local volume=T.flatButton(tray,"",8,5,22,22,function() self.settings:sound() end)
	T.image(volume,"120(16x16).png",2,3,16,16)
	T.text(tray,"RU",36,0,24,30,10,Color3.new(1,1,1))
	local clock=T.flatButton(tray,"",65,0,52,30,function() self.settings:datetime() end)
	clock.TextColor3=Color3.new(1,1,1)
	self.clock=clock
	local dateTip=T.frame(desktop,"ClockTooltip",Color3.fromRGB(255,255,225),0,0,190,27)
	dateTip.Position=UDim2.new(1,-200,1,-63) dateTip.ZIndex=2000 dateTip.Visible=false
	T.border(dateTip,Color3.new(0,0,0))
	local dateText=T.text(dateTip,"",5,0,180,27,11)
	clock.MouseEnter:Connect(function()
		if not State.current then return end
		local prefs=State.current.preferences
		local format=if prefs.dateFormat=="MM/dd/yyyy" then "!%m/%d/%Y" elseif prefs.dateFormat=="yyyy-MM-dd" then "!%Y-%m-%d" else "!%d.%m.%Y"
		dateText.Text=os.date(format,os.time()+prefs.timeOffset) dateTip.Visible=true
	end)
	clock.MouseLeave:Connect(function() dateTip.Visible=false end)
	self.wm=WM.new(desktop,tasks)
	self.settings=Settings.new(self)
	self.apps=Apps.new(self)
	self.menu=nil self.contextMenu=nil
	local function track(connection) table.insert(self.connections,connection) return connection end
	function self:play(file,volumeOverride,muteOverride)
		local prefs=if State.current then State.current.preferences else nil
		local muted=if muteOverride~=nil then muteOverride else prefs and prefs.muted
		if muted then return end
		local sound=Instance.new("Sound")
		sound.Name="XP:"..file
		sound.SoundId=T.assetRoot.."sounds/"..file
		sound.Volume=(volumeOverride or (prefs and prefs.volume) or 70)/100
		sound.Parent=SoundService
		sound:Play()
		Debris:AddItem(sound,30)
	end

	function self:closeMenus()
		if self.menu then self.menu:Destroy() self.menu=nil end
		if self.contextMenu then self.contextMenu:Destroy() self.contextMenu=nil end
	end
	self.wm.onSound=function(file) self:play(file) end

	function self:applyPreferences()
		if not State.current then return end
		local prefs=State.current.preferences
		T.currentTheme=string.lower(prefs.theme)
		for _,item in physical:GetDescendants() do
			local file=item:GetAttribute("LunaFile")
			if file and item:IsA("ImageLabel") then item.Image=T.assetRoot.."luna/"..T.currentTheme.."/"..file end
		end
		local rgb=string.split(prefs.background,",")
		desktop.BackgroundColor3=Color3.fromRGB(tonumber(rgb[1]) or 0,tonumber(rgb[2]) or 78,tonumber(rgb[3]) or 152)
		wallpaper.Image=T.assetRoot.."images/"..prefs.wallpaper
		wallpaper.Visible=prefs.wallpaper~="None"
		wallpaper.Size=UDim2.new(1,0,1,-30)
		wallpaper.Position=UDim2.fromOffset(0,0)
		wallpaper.ScaleType=if prefs.wallpaperMode=="Tile" then Enum.ScaleType.Tile elseif prefs.wallpaperMode=="Center" then Enum.ScaleType.Fit else Enum.ScaleType.Stretch
		wallpaper.TileSize=UDim2.fromOffset(800,600)
		icons.Visible=prefs.showIcons
		pointerShadow.Visible=prefs.pointerShadow
		clock.Visible=prefs.showClock
		quick.Visible=prefs.quickLaunch
		tasks.Position=UDim2.fromOffset(if prefs.quickLaunch then 168 else 110,0)
		tasks.Size=UDim2.new(1,if prefs.quickLaunch then -298 else -240,1,0)
		T.blue=if prefs.theme=="Olive" then Color3.fromRGB(112,132,62) elseif prefs.theme=="Silver" then Color3.fromRGB(155,154,178) else Color3.fromRGB(0,84,227)
		local tint=if prefs.theme=="Olive" then Color3.fromRGB(202,217,144) elseif prefs.theme=="Silver" then Color3.fromRGB(225,224,239) else Color3.new(1,1,1)
		taskbar.BackgroundColor3=tint
		for _,window in self.wm.windows do window.frame.BackgroundColor3=T.blue window.title.BackgroundColor3=tint end
		local visibleIcon=0
		for _,button in icons:GetChildren() do
			local preference=button:GetAttribute("VisibilityPreference")
			if preference then button.Visible=prefs[preference] end
			if button:IsA("GuiButton") and button.Visible then button.Position=UDim2.fromOffset(8,12+visibleIcon*91) visibleIcon+=1 end
			local text=button:FindFirstChild("IconLabel")
			if text then text.TextSize=prefs.fontSize end
		end
		if self.resizeCanvas then self.resizeCanvas() end
	end

	function self:screenSaver(kind)
		if self.screen then self.screen:Destroy() self.screen=nil end
		if not kind or kind=="None" then return end
		self:closeMenus()
		local screen=T.frame(canvas,"ScreenSaver",Color3.new(0,0,0),0,0,100,100)
		screen.Size=UDim2.fromScale(1,1) screen.ZIndex=4000 screen.Active=true
		self.screen=screen
		if kind=="Бегущая строка" then
			local text=T.text(screen,"Microsoft Windows XP",0,0,500,60,32,Color3.fromRGB(192,192,192),true)
			text.Name="Marquee"
		end
	end

	function self:powerDialog(logoff)
		self:closeMenus()
		local overlay=T.frame(canvas,"PowerDialog",Color3.fromRGB(40,40,40),0,0,100,100)
		overlay.BackgroundTransparency=0.45 overlay.Size=UDim2.fromScale(1,1) overlay.ZIndex=3000 overlay.Active=true
		local dialog=T.frame(overlay,"Dialog",Color3.fromRGB(83,110,204),0,0,350,210)
		dialog.AnchorPoint=Vector2.new(0.5,0.5) dialog.Position=UDim2.fromScale(0.5,0.5)
		local header=T.frame(dialog,"Header",Color3.fromRGB(0,48,154),0,0,350,43)
		T.text(header,if logoff then "Выход из Windows" else "Выключить компьютер",15,0,280,43,20,Color3.new(1,1,1),true)
		T.image(header,"windows.png",300,11,39,22)
		local options=if logoff then {{"Смена пользователя","Switch User.png",function() overlay:Destroy() self:welcome() end},{"Выход","310(32x32).png",function() overlay:Destroy() self:welcome() end}} else {{"Ждущий режим","546(32x32).png",function() overlay:Destroy() self:screenSaver("Пустой экран") end},{"Выключение","310(32x32).png",function()
			self:play("Windows XP Shutdown.wav")
			overlay:Destroy()
			local waitScreen=T.frame(canvas,"Shutdown",Color3.fromRGB(0,48,154),0,0,100,100)
			waitScreen.Size=UDim2.fromScale(1,1) waitScreen.ZIndex=3000
			local message=T.text(waitScreen,"Завершение работы...",0,0,450,70,24,Color3.new(1,1,1))
			message.AnchorPoint=Vector2.new(0.5,0.5) message.Position=UDim2.fromScale(0.5,0.5)
			task.delay(2,function() if self.alive then self:destroy() onExit() end end)
		end},{"Перезагрузка","windows-off.png",function() overlay:Destroy() self:welcome() end}}
		for index,option in options do
			local x=if logoff then 45+(index-1)*145 else 13+(index-1)*111
			local button=T.flatButton(dialog,"",x,62,105,87,option[3])
			T.image(button,option[2],35,0,35,35)
			local caption=T.text(button,option[1],0,44,105,40,12,Color3.new(1,1,1),true)
			caption.TextXAlignment=Enum.TextXAlignment.Center
		end
		local bottom=T.frame(dialog,"Footer",Color3.fromRGB(0,48,154),0,165,350,45)
		T.button(bottom,"Отмена",260,11,75,23,function() overlay:Destroy() end)
	end

	function self:startMenu()
		if self.menu then self:closeMenus() return end
		self:closeMenus()
		self:play("Windows XP Menu Command.wav")
		local classic=State.current.preferences.classicStart
		local menu=T.frame(desktop,"StartMenu",Color3.fromRGB(255,255,255),0,0,if classic then 245 else 410,if classic then 415 else 480)
		menu.Position=UDim2.new(0,0,1,if classic then -445 else -510)
		menu.ZIndex=2000 self.menu=menu
		T.round(menu,5) T.border(menu,Color3.fromRGB(24,75,172),2)
		local header=T.frame(menu,"User",Color3.new(1,1,1),0,0,410,62)
		header.Size=UDim2.new(1,0,0,62)
		T.gradient(header,{Color3.fromRGB(24,104,206),Color3.fromRGB(77,150,236),Color3.fromRGB(16,91,197)})
		local headerSkin=T.skin(header,"StartUserPanel.png",0,0,410,62,Rect.new(8,8,112,55))
		headerSkin.Size=UDim2.fromScale(1,1)
		T.image(header,State.current.avatar,10,8,46,46,"users/")
		T.text(header,State.current.name,68,8,280,46,18,Color3.new(1,1,1),true)
		local divider=T.frame(menu,"OrangeRule",Color3.fromRGB(227,150,64),0,62,410,2)
		divider.Size=UDim2.new(1,0,0,2)
		local right=if classic then nil else T.frame(menu,"Places",Color3.fromRGB(211,229,250),207,64,203,368)
		local function row(parent,text,icon,x,y,w,callback,bold)
			local button=T.flatButton(parent,"",x,y,w,35,function() self:closeMenus() callback() end)
			T.image(button,icon,5,3,28,28)
			local caption=T.text(button,text,40,0,w-45,35,11,nil,bold)
			button.MouseEnter:Connect(function() button.BackgroundTransparency=0 button.BackgroundColor3=Color3.fromRGB(49,106,197) caption.TextColor3=Color3.new(1,1,1) end)
			button.MouseLeave:Connect(function() button.BackgroundTransparency=1 caption.TextColor3=T.textColor end)
		end
		local programs={
			{"Мой компьютер","676(32x32).png",function() self.apps:explorer() end},
			{"Блокнот","327(32x32).png",function() self.apps:notepad() end},
			{"Калькулятор","74(16x16).png",function() self.apps:calculator() end},
			{"Игры","folder.png",function() self.apps:games() end},
			{"Панель управления","300(32x32).png",function() self.settings:panel() end},
			{"Учетные записи","User Accounts.png",function() self.settings:users() end},
			{"Справка и поддержка","747(32x32).png",function() self.apps:help() end},
		}
		for index,item in programs do row(menu,item[1],item[2],5,72+(index-1)*41,if classic then 235 else 195,item[3],index==1) end
		if right then
			local places={{"Мои документы","308(32x32).png",function() self.apps:explorer("documents") end},{"Мой компьютер","676(32x32).png",function() self.apps:explorer() end},{"Панель управления","300(32x32).png",function() self.settings:panel() end},{"Учетные записи","User Accounts.png",function() self.settings:users() end},{"Свойства экрана","Display Properties.png",function() self.settings:display() end},{"Поиск","299(32x32).png",function() self.apps:search() end},{"Выполнить...","743(32x32).png",function() self.apps:run() end}}
			for index,item in places do row(right,item[1],item[2],4,8+(index-1)*45,195,item[3],index<=2) end
			T.flatButton(menu,"Все программы   ▶",10,385,186,33,function()
				local submenu=T.frame(menu,"Programs",Color3.new(1,1,1),200,180,220,210)
				submenu.ZIndex=20 T.border(submenu,T.blue)
				local all={{"Блокнот","327(32x32).png",function() self.apps:notepad() end},{"Калькулятор","74(16x16).png",function() self.apps:calculator() end},{"Проводник","folder.png",function() self.apps:explorer() end},{"Игры","folder.png",function() self.apps:games() end},{"Панель управления","300(32x32).png",function() self.settings:panel() end}}
				for index,item in all do row(submenu,item[1],item[2],4,4+(index-1)*40,210,item[3]) end
			end)
		end
		local footer=T.frame(menu,"Logoff",Color3.new(1,1,1),0,0,410,48)
		footer.Position=UDim2.new(0,0,1,-48) footer.Size=UDim2.new(1,0,0,48)
		T.gradient(footer,{Color3.fromRGB(70,143,231),Color3.fromRGB(13,89,193)})
		local footerSkin=T.skin(footer,"StartPanelLogoffBackground.png",0,0,410,48,Rect.new(4,4,93,35))
		footerSkin.Size=UDim2.fromScale(1,1)
		row(footer,"Выход","Switch User.png",if classic then 3 else 100,7,145,function() self:powerDialog(true) end)
		row(footer,"Выключение","310(32x32).png",if classic then 110 else 247,7,155,function() self:powerDialog(false) end)
	end

	function self:login(profile)
		State.current=profile
		if self.welcomeFrame then self.welcomeFrame:Destroy() self.welcomeFrame=nil end
		desktop.Visible=true
		self:applyPreferences()
		self:play("Windows XP Logon Sound.wav")
		self.lastInput=os.clock()
	end

	function self:welcome()
		if State.current then self:play("Windows XP Logoff Sound.wav") end
		self:closeMenus() self.wm:clear()
		State.current=nil desktop.Visible=false
		if self.welcomeFrame then self.welcomeFrame:Destroy() end
		local welcome=T.frame(canvas,"Welcome",Color3.fromRGB(90,126,220),0,0,100,100)
		welcome.Size=UDim2.fromScale(1,1) welcome.ZIndex=2500
		self.welcomeFrame=welcome
		local top=T.frame(welcome,"Top",Color3.fromRGB(0,48,154),0,0,100,100)
		top.Size=UDim2.new(1,0,0.16,0)
		local bottom=T.frame(welcome,"Bottom",Color3.fromRGB(0,48,154),0,0,100,100)
		bottom.Position=UDim2.fromScale(0,0.84) bottom.Size=UDim2.fromScale(1,0.16)
		local center=T.frame(welcome,"Center",nil,0,0,920,500)
		center.AnchorPoint=Vector2.new(0.5,0.5) center.Position=UDim2.fromScale(0.5,0.5)
		local line=T.frame(center,"Divider",Color3.new(1,1,1),458,20,1,440)
		line.BackgroundTransparency=0.65
		T.image(center,"xplogo.png",150,130,246,146)
		local hint=T.text(center,"Чтобы начать работу,\nщелкните свое имя пользователя",74,285,330,60,19,Color3.new(1,1,1))
		hint.TextXAlignment=Enum.TextXAlignment.Right
		local users=Instance.new("ScrollingFrame")
		users.Name="Profiles" users.BackgroundTransparency=1 users.BorderSizePixel=0 users.Position=UDim2.fromOffset(495,40) users.Size=UDim2.fromOffset(400,420) users.CanvasSize=UDim2.fromOffset(0,#State.profiles*84) users.ScrollBarThickness=3 users.Parent=center
		for index,profile in State.profiles do
			local button=T.flatButton(users,"",0,(index-1)*84,380,78,function() self:login(profile) end)
			button.Name="Profile:"..tostring(profile.id)
			local tile=T.frame(button,"Tile",Color3.fromRGB(225,224,197),3,6,60,60)
			T.round(tile,5) T.border(tile,Color3.fromRGB(255,244,162),2)
			T.image(tile,profile.avatar,3,3,54,54,"users/")
			T.text(button,profile.name,80,9,290,34,22,Color3.new(1,1,1))
			button.MouseEnter:Connect(function() button.BackgroundTransparency=0.75 button.BackgroundColor3=Color3.fromRGB(25,69,174) end)
			button.MouseLeave:Connect(function() button.BackgroundTransparency=1 end)
		end
		local exit=T.flatButton(bottom,"Выключить компьютер",34,23,270,50,function() self:play("Windows XP Shutdown.wav") self:destroy() onExit() end)
		exit.TextColor3=Color3.new(1,1,1) exit.TextSize=15
		T.image(exit,"310(32x32).png",0,10,32,32)
		T.text(bottom,"После входа можно добавить или изменить учетные записи\nв панели управления.",0,16,450,66,12,Color3.new(1,1,1)).Position=UDim2.new(1,-480,0,16)
	end

	local desktopItems={
		{"Мой компьютер","676(32x32).png",function() self.apps:explorer() end},
		{"Мои документы","308(32x32).png",function() self.apps:explorer("documents") end},
		{"Сетевое окружение","309(32x32).png",function() self.apps:explorer("network") end},
		{"Корзина","Recycle Bin (empty).png",function() self.apps:explorer("recycle") end},
	}
	for index,item in desktopItems do
		local button=T.flatButton(icons,"",8,12+(index-1)*91,90,82)
		button.Name="Desktop:"..item[1]
		if index<=3 then button:SetAttribute("VisibilityPreference",({"showComputer","showDocuments","showNetwork"})[index]) end
		T.image(button,item[2],29,4,32,32)
		local label=T.text(button,item[1],0,40,90,38,11,Color3.new(1,1,1))
		label.Name="IconLabel" label.TextXAlignment=Enum.TextXAlignment.Center label.TextStrokeColor3=Color3.new(0,0,0) label.TextStrokeTransparency=0.4
		local last=0
		button.Activated:Connect(function()
			self:closeMenus()
			for _,other in icons:GetChildren() do if other:IsA("GuiButton") then other.BackgroundTransparency=1 end end
			button.BackgroundTransparency=0.65 button.BackgroundColor3=Color3.fromRGB(49,106,197)
			local now=os.clock()
			if State.current and now-last<State.current.preferences.doubleClick then item[3]() end
			last=now
		end)
	end
	start.Activated:Connect(function() self:startMenu() end)
	desktop.InputBegan:Connect(function(input)
		if not State.current then return end
		local location=UIS:GetMouseLocation()
		for _,hit in gui.Parent:GetGuiObjectsAtPosition(location.X,location.Y) do
			if hit==start or hit:IsDescendantOf(start) then return end
			if self.menu and (hit==self.menu or hit:IsDescendantOf(self.menu)) then return end
			if self.contextMenu and (hit==self.contextMenu or hit:IsDescendantOf(self.contextMenu)) then return end
			for _,window in self.wm.windows do if window.frame.Visible and (hit==window.frame or hit:IsDescendantOf(window.frame)) then return end end
		end
		if input.UserInputType==Enum.UserInputType.MouseButton1 then self:closeMenus()
		elseif input.UserInputType==Enum.UserInputType.MouseButton2 then
			self:closeMenus()
			local pos=(UIS:GetMouseLocation()-physical.AbsolutePosition)/uiScale.Scale
			local x=math.clamp(pos.X,0,canvas.AbsoluteSize.X/uiScale.Scale-220)
			local y=math.clamp(pos.Y,0,canvas.AbsoluteSize.Y/uiScale.Scale-180)
			local menu=T.frame(desktop,"ContextMenu",T.surface,x,y,220,145)
			menu.ZIndex=2500 self.contextMenu=menu T.border(menu,Color3.fromRGB(128,128,128))
			local actions={{"Обновить",function() self:applyPreferences() end},{"Создать текстовый документ",function() self.apps:notepad() end},{"Свойства",function() self.settings:display() end}}
			for index,action in actions do T.flatButton(menu,action[1],4,4+(index-1)*42,212,38,function() self:closeMenus() action[2]() end) end
		end
	end)
	taskbar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton2 then self.settings:taskbar() end end)
	taskbar.MouseEnter:Connect(function() taskbar.Position=UDim2.new(0,0,1,-30) end)
	taskbar.MouseLeave:Connect(function() if State.current and State.current.preferences.autoHide and not self.menu then taskbar.Position=UDim2.new(0,0,1,-3) end end)

	local function resizeCanvas()
		local width=physical.AbsoluteSize.X local height=physical.AbsoluteSize.Y
		if width<=0 or height<=0 then return end
		local targetWidth,targetHeight=1024,768
		if State.current then
			local x,y=string.match(State.current.preferences.resolution,"(%d+)%s*×%s*(%d+)")
			targetWidth=tonumber(x) or 1024 targetHeight=tonumber(y) or 768
		end
		local scale=math.min(1,width/targetWidth,height/targetHeight)
		uiScale.Scale=scale
		canvas.Size=UDim2.fromOffset(width/scale,height/scale)
		desktop:SetAttribute("UIScale",scale)
	end
	self.resizeCanvas=resizeCanvas
	track(physical:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeCanvas))
	track(UIS.InputBegan:Connect(function(input,processed)
		self.lastInput=os.clock()
		if self.screen then self.screen:Destroy() self.screen=nil return end
		if processed or not State.current then return end
		if input.KeyCode==Enum.KeyCode.Escape then self:closeMenus()
		elseif input.KeyCode==Enum.KeyCode.F1 then self.apps:help()
		elseif input.KeyCode==Enum.KeyCode.F4 and (UIS:IsKeyDown(Enum.KeyCode.LeftAlt) or UIS:IsKeyDown(Enum.KeyCode.RightAlt)) then
			for _,window in self.wm.windows do if window.frame.ZIndex==self.wm.order and window.frame.Visible then window.close() break end end
		end
	end))
	track(UIS.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			self.lastInput=os.clock()
			if self.screen then self.screen:Destroy() self.screen=nil end
			local point=UIS:GetMouseLocation()
			local x,y=point.X-physical.AbsolutePosition.X,point.Y-physical.AbsolutePosition.Y
			pointer.Position=UDim2.fromOffset(x,y)
			pointerShadow.Position=UDim2.fromOffset(x+1,y+1)
			if State.current and State.current.preferences.mouseTrails then
				local trail=T.image(physical,"arrow.png",x,y,32,32,"cursors/")
				trail.ZIndex=4999 trail.ImageTransparency=0.65
				table.insert(pointerHistory,trail)
				if #pointerHistory>6 then table.remove(pointerHistory,1):Destroy() end
				Debris:AddItem(trail,0.2)
			end
		end
	end))
	local elapsed=0
	track(RunService.Heartbeat:Connect(function(delta)
		elapsed+=delta
		if elapsed<1 then return end
		elapsed=0
		if not State.current then return end
		local prefs=State.current.preferences
		clock.Text=os.date("!%H:%M",os.time()+prefs.timeOffset)
		if not self.screen and prefs.screenSaver~="None" and os.clock()-self.lastInput>prefs.saverMinutes*60 then self:screenSaver(prefs.screenSaver) end
		if self.screen then
			local marquee=self.screen:FindFirstChild("Marquee")
			if marquee then marquee.Position=UDim2.new(0.5,math.sin(os.clock()/7)*250-250,0.5,math.cos(os.clock()/9)*200) end
		end
	end))
	function self:destroy()
		if not self.alive then return end
		self.alive=false
		UIS.MouseIconEnabled=originalMouseIcon
		for _,connection in self.connections do connection:Disconnect() end
		self.wm:destroy()
		physical:Destroy()
	end
	resizeCanvas()
	self:welcome()
	return self
end

return XP
