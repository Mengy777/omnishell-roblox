--!nonstrict

local T=require(script.Parent.Theme)
local State=require(script.Parent.State)
local Settings={}

function Settings.new(context)
	local self={context=context}
	return setmetatable(self,{__index=Settings})
end

function Settings:dialog(id,title,icon,tabs,render,width,height)
	local context=self.context
	local window,fresh=context.wm:create(id,title,icon,width or 470,height or 500)
	if not fresh then return window end
	local draft=table.clone(State.current.preferences)
	context.wm:tabs(window,tabs,function(page,name) render(page,name,draft,window) end)
	local function apply() State.current.preferences=table.clone(draft) context:applyPreferences() end
	local buttons=T.frame(window.body,"DialogButtons",nil,0,0,100,30)
	buttons.Position=UDim2.new(1,-252,1,-33)
	T.button(buttons,"OK",0,0,75,23,function() apply() window.close() end)
	T.button(buttons,"Отмена",81,0,75,23,window.close)
	T.button(buttons,"Применить",162,0,80,23,apply)
	return window
end

function Settings:display()
	local context=self.context
	return self:dialog("display","Свойства: Экран","680(16x16).png",{"Темы","Рабочий стол","Заставка","Оформление","Параметры"},function(page,name,draft)
		if name=="Темы" then
			T.text(page,"Тема определяет фон, звуки, значки и другие элементы рабочего стола.",18,18,346,42)
			T.text(page,"Тема:",18,70,100,18)
			T.choice(page,{"Windows XP","Windows XP — серебристая","Windows XP — оливковая"},if draft.theme=="Silver" then "Windows XP — серебристая" elseif draft.theme=="Olive" then "Windows XP — оливковая" else "Windows XP",18,94,350,function(value)
				draft.theme=if value=="Windows XP — серебристая" then "Silver" elseif value=="Windows XP — оливковая" then "Olive" else "Blue"
			end)
			local preview=T.frame(page,"Preview",Color3.fromRGB(0,78,152),18,143,346,165)
			local image=T.image(preview,"Bliss.png",0,0,346,165,"images/")
			image.ScaleType=Enum.ScaleType.Stretch
			local bar=T.frame(preview,"PreviewTaskbar",T.blue,0,140,346,25)
			T.text(bar,"пуск",8,0,60,25,14,Color3.new(1,1,1),true)
		elseif name=="Рабочий стол" then
			local monitor=T.image(page,"DisplayMonitor.png",100,20,182,164)
			local image=T.image(monitor,draft.wallpaper,12,16,154,115,"images/")
			image.Visible=draft.wallpaper~="None"
			T.text(page,"Фоновый рисунок:",15,186,260,18)
			local list=Instance.new("ScrollingFrame")
			list.Name="Wallpapers" list.BackgroundColor3=Color3.new(1,1,1) list.BorderSizePixel=0 list.Position=UDim2.fromOffset(15,207) list.Size=UDim2.fromOffset(270,110) list.CanvasSize=UDim2.fromOffset(0,#State.wallpapers*17) list.ScrollBarThickness=14 list.Parent=page
			T.border(list)
			local rows={}
			for index,value in State.wallpapers do
				local row=T.flatButton(list,if value=="None" then "(Нет)" else string.gsub(value,"%.[^.]+$",""),2,(index-1)*17,252,17)
				row.Name=value row.TextXAlignment=Enum.TextXAlignment.Left
				rows[value]=row
				local function select()
					draft.wallpaper=value image.Image=T.assetRoot.."images/"..value image.Visible=value~="None"
					for file,button in rows do button.BackgroundTransparency=if file==value then 0 else 1 button.BackgroundColor3=Color3.fromRGB(49,106,197) button.TextColor3=if file==value then Color3.new(1,1,1) else T.textColor end
				end
				row.Activated:Connect(select)
				if value==draft.wallpaper then row.BackgroundTransparency=0 row.BackgroundColor3=Color3.fromRGB(49,106,197) row.TextColor3=Color3.new(1,1,1) end
			end
			T.text(page,"Расположение:",296,240,80,18)
			T.choice(page,{"Stretch","Center","Tile"},draft.wallpaperMode,296,260,73,function(value) draft.wallpaperMode=value end)
			T.text(page,"Цвет:",296,291,73,18)
			T.choice(page,{"0,78,152","0,128,128","0,0,0","58,110,165"},draft.background,296,311,73,function(value) draft.background=value end)
			T.button(page,"Настройка рабочего стола...",15,330,205,23,function() self:desktopIcons() end)
		elseif name=="Заставка" then
			local screen=T.frame(page,"Monitor",Color3.fromRGB(0,0,0),75,20,232,148)
			T.border(screen,Color3.fromRGB(80,80,80),6)
			T.text(page,"Заставка:",18,192,200,18)
			T.choice(page,{"None","Пустой экран","Бегущая строка"},draft.screenSaver,18,216,260,function(value) draft.screenSaver=value end)
			T.button(page,"Просмотр",280,216,85,23,function() context:screenSaver(draft.screenSaver) end)
			T.text(page,"Интервал (минут):",18,270,180,22)
			T.choice(page,{1,2,5,10,15,30,60},draft.saverMinutes,220,270,100,function(value) draft.saverMinutes=value end)
		elseif name=="Оформление" then
			local preview=T.frame(page,"WindowPreview",Color3.fromRGB(58,110,165),18,18,346,140)
			local mini=T.frame(preview,"ExampleWindow",T.surface,28,28,290,95)
			local title=T.frame(mini,"TitleBar",T.blue,0,0,290,25)
			T.text(title,"Активное окно",6,0,270,25,13,Color3.new(1,1,1),true)
			T.button(mini,"OK",106,54,75,23)
			T.text(page,"Окна и кнопки:",18,184,350,18)
			T.choice(page,{"Стиль Windows XP"},"Стиль Windows XP",18,207,346)
			T.text(page,"Цветовая схема:",18,244,350,18)
			T.choice(page,{"Blue","Olive","Silver"},draft.theme,18,267,346,function(value) draft.theme=value end)
			T.text(page,"Размер шрифта:",18,304,350,18)
			T.choice(page,{11,13,15},draft.fontSize,18,321,346,function(value) draft.fontSize=value end)
		else
			T.text(page,"Дисплей:",18,20,346,18)
			T.text(page,"Экран OmniShell",18,45,346,24,12,nil,true)
			local monitor=T.frame(page,"Monitor",Color3.fromRGB(0,0,0),108,88,166,110)
			T.border(monitor,Color3.fromRGB(100,100,100),6)
			T.text(monitor,"1",60,24,40,50,36,Color3.new(1,1,1),true)
			T.text(page,"Разрешение экрана:",18,232,200,20)
			T.choice(page,{"800 × 600","1024 × 768","1280 × 1024","1600 × 1200"},draft.resolution,18,261,170,function(value) draft.resolution=value end)
			T.text(page,"Качество цветопередачи:",204,232,160,20)
			T.choice(page,{"32 бита"},draft.colorDepth,204,261,160)
			T.text(page,"Параметры относятся к рабочему столу выбранного пользователя.",18,301,346,40)
		end
	end,404,455)
end

function Settings:desktopIcons()
	return self:dialog("desktop-icons","Элементы рабочего стола","676(16x16).png",{"Общие"},function(page,_,draft)
		local group=T.group(page,"Значки рабочего стола",15,25,340,180)
		for index,item in {{"Мой компьютер","showComputer"},{"Мои документы","showDocuments"},{"Сетевое окружение","showNetwork"}} do
			T.checkbox(group,item[1],draft[item[2]],15,22+(index-1)*40,310,function(value) draft[item[2]]=value end)
		end
		T.checkbox(page,"Отображать значки рабочего стола",draft.showIcons,15,225,340,function(value) draft.showIcons=value end)
	end,400,365)
end

function Settings:taskbar()
	return self:dialog("taskbar","Свойства панели задач и меню «Пуск»","358(16x16).png",{"Панель задач","Меню «Пуск»"},function(page,name,draft)
		if name=="Панель задач" then
			local group=T.group(page,"Оформление панели задач",14,22,393,190)
			local options={{"Закрепить панель задач","lockTaskbar"},{"Автоматически скрывать панель задач","autoHide"},{"Группировать сходные кнопки панели задач","groupTasks"},{"Отображать панель быстрого запуска","quickLaunch"}}
			for index,option in options do T.checkbox(group,option[1],draft[option[2]],14,20+(index-1)*35,370,function(value) draft[option[2]]=value end) end
			local area=T.group(page,"Область уведомлений",14,240,393,90)
			T.checkbox(area,"Отображать часы",draft.showClock,14,25,360,function(value) draft.showClock=value end)
		else
			T.text(page,"Выберите стиль меню «Пуск» для этого пользователя.",18,20,390,42)
			T.choice(page,{"Меню «Пуск»","Классическое меню «Пуск»"},if draft.classicStart then "Классическое меню «Пуск»" else "Меню «Пуск»",18,92,390,function(value) draft.classicStart=value=="Классическое меню «Пуск»" end)
		end
	end)
end

function Settings:sound()
	local context=self.context
	return self:dialog("sound","Свойства: Звуки и аудиоустройства","120(16x16).png",{"Громкость","Звуки","Аудио","Голос","Оборудование"},function(page,name,draft)
		if name=="Громкость" then
			local group=T.group(page,"Громкость устройства",18,30,390,170)
			T.image(group,"120(16x16).png",18,34,32,32)
			T.text(group,"Громкость:",68,24,260,22)
			T.choice(group,{0,10,20,30,40,50,60,70,80,90,100},draft.volume,68,55,280,function(value) draft.volume=value end)
			T.checkbox(group,"Выключить звук",draft.muted,68,110,280,function(value) draft.muted=value end)
		elseif name=="Звуки" then
			T.text(page,"Звуковая схема:",18,20,390,20)
			T.choice(page,{"Стандартная Windows"},"Стандартная Windows",18,48,390)
			T.text(page,"Программные события:",18,95,390,20)
			local selected="Windows XP Logon Sound.wav"
			T.choice(page,{"Windows XP Logon Sound.wav","Windows XP Logoff Sound.wav","Windows XP Shutdown.wav","Windows XP Critical Stop.wav","Windows XP Error.wav","Windows XP Notify.wav","Windows XP Exclamation.wav"},selected,18,125,390,function(value) selected=value end)
			T.button(page,"▶ Проверить",275,173,130,25,function() context:play(selected,draft.volume,draft.muted) end)
		else
			T.text(page,"Устройство по умолчанию:",18,30,390,22)
			T.choice(page,{"Аудиоустройство Roblox Studio"},"Аудиоустройство Roblox Studio",18,65,390)
			T.text(page,"Параметры звука оболочки применяются на вкладке «Громкость».",18,125,390,60)
		end
	end)
end

function Settings:mouse()
	return self:dialog("mouse","Свойства: Мышь","227(16x16).png",{"Кнопки мыши","Указатели","Параметры указателя","Колесико"},function(page,name,draft)
		if name=="Кнопки мыши" then
			local group=T.group(page,"Скорость выполнения двойного щелчка",18,35,390,130)
			T.text(group,"Медленнее                                      Быстрее",16,20,360,30)
			T.choice(group,{0.2,0.3,0.45,0.6,0.8},draft.doubleClick,18,65,350,function(value) draft.doubleClick=value end)
		elseif name=="Указатели" then
			T.text(page,"Схема:",18,22,390,20)
			T.choice(page,{"Стандартная Windows"},"Стандартная Windows",18,50,390)
			T.checkbox(page,"Включить тень указателя",draft.pointerShadow,18,122,390,function(value) draft.pointerShadow=value end)
		elseif name=="Параметры указателя" then
			T.checkbox(page,"Отображать след указателя мыши",draft.mouseTrails,18,45,390,function(value) draft.mouseTrails=value end)
		else
			T.text(page,"Прокрутка выполняется колесом мыши в окнах с полосой прокрутки.",18,35,390,70)
		end
	end,570,420)
end

function Settings:regional()
	return self:dialog("regional","Язык и региональные стандарты","earth.png",{"Региональные параметры","Языки","Дополнительно"},function(page,name,draft)
		T.text(page,if name=="Языки" then "Язык интерфейса:" else "Стандарты и форматы:",18,30,390,24)
		T.choice(page,{"Русский"},draft.language,18,66,390)
		T.text(page,"Краткий формат даты:",18,120,390,24)
		T.choice(page,{"dd.MM.yyyy","MM/dd/yyyy","yyyy-MM-dd"},draft.dateFormat,18,154,390,function(value) draft.dateFormat=value end)
	end,495,410)
end

function Settings:datetime()
	local context=self.context
	return self:dialog("datetime","Свойства: Дата и время","history.png",{"Дата и время","Часовой пояс"},function(page,name,draft)
		local now=os.date("!*t",os.time()+draft.timeOffset)
		if name=="Дата и время" then
			T.text(page,"Дата:",18,25,180,22)
			local date=T.input(page,string.format("%04d-%02d-%02d",now.year,now.month,now.day),18,57,190,24)
			T.text(page,"Время:",230,25,180,22)
			local time=T.input(page,string.format("%02d:%02d:%02d",now.hour,now.min,now.sec),230,57,175,24)
			T.button(page,"Установить",280,105,125,23,function()
				local y,m,d=string.match(date.Text,"^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
				local h,mi,s=string.match(time.Text,"^(%d%d):(%d%d):(%d%d)$")
				if not y or not h then context.wm:message("Дата и время","Введите дату ГГГГ-ММ-ДД и время ЧЧ:ММ:СС.") return end
				local parts={year=tonumber(y),month=tonumber(m),day=tonumber(d),hour=tonumber(h),min=tonumber(mi),sec=tonumber(s)}
				if parts.month<1 or parts.month>12 or parts.day<1 or parts.day>31 or parts.hour>23 or parts.min>59 or parts.sec>59 then context.wm:message("Дата и время","Введено недопустимое значение.") return end
				draft.timeOffset=DateTime.fromUniversalTime(parts.year,parts.month,parts.day,parts.hour,parts.min,parts.sec).UnixTimestamp-os.time()
			end)
		else
			T.text(page,"Часовой пояс:",18,30,390,22)
			T.choice(page,{"UTC","UTC+02:00","UTC+03:00"},"UTC",18,68,390,function(value) draft.timeOffset=if value=="UTC+02:00" then 7200 elseif value=="UTC+03:00" then 10800 else 0 end)
		end
	end,470,370)
end

function Settings:users()
	local context=self.context
	local window,fresh=context.wm:create("users","Учетные записи пользователей","user.png",620,470)
	if not fresh then return window end
	local body=window.body
	local function clear()
		for _,child in body:GetChildren() do child:Destroy() end
	end
	local showList
	local function editor(profile)
		clear()
		T.text(body,"Что вы хотите изменить в своей учетной записи?",24,20,560,35,18,Color3.fromRGB(0,51,153),true)
		T.image(body,profile.avatar,24,78,64,64,"users/")
		T.text(body,"Имя пользователя:",110,76,380,22)
		local name=T.input(body,profile.name,110,106,340,25)
		T.button(body,"Изменить имя",110,143,145,25,function()
			local ok,message=State.rename(profile,name.Text)
			if not ok then context:play("Windows XP Error.wav") context.wm:message("Учетные записи пользователей",message) else context:applyPreferences() showList() end
		end)
		T.text(body,"Изменить изображение:",24,198,500,22)
		local avatarArea=Instance.new("ScrollingFrame")
		avatarArea.Name="AccountPictures" avatarArea.BackgroundTransparency=1 avatarArea.BorderSizePixel=0 avatarArea.Position=UDim2.fromOffset(24,228) avatarArea.Size=UDim2.fromOffset(565,100) avatarArea.CanvasSize=UDim2.fromOffset(0,math.ceil(#State.avatars/7)*70) avatarArea.ScrollBarThickness=12 avatarArea.Parent=body
		for index,avatar in State.avatars do
			local button=T.button(avatarArea,"",((index-1)%7)*74,math.floor((index-1)/7)*70,62,62,function() profile.avatar=avatar editor(profile) context:applyPreferences() end)
			T.image(button,avatar,5,5,52,52,"users/")
		end
		if profile~=State.current and #State.profiles>1 then
			T.button(body,"Удалить учетную запись",24,330,210,25,function()
				local confirm,fresh=context.wm:create("delete-user","Удаление учетной записи","897(16x16).png",420,185)
				if not fresh then return end
				T.text(confirm.body,"Удалить пользователя «"..profile.name.."» и его файлы из этой сессии?",18,14,380,60)
				T.button(confirm.body,"Удалить",220,98,85,23,function() State.delete(profile) confirm.close() showList() end)
				T.button(confirm.body,"Отмена",310,98,85,23,confirm.close)
			end)
		end
		T.button(body,"Назад",490,375,95,23,showList)
	end
	showList=function()
		clear()
		T.text(body,"Выберите задание...",24,15,560,35,21,Color3.fromRGB(0,51,153),true)
		T.button(body,"Создание учетной записи",24,65,230,28,function()
			clear()
			T.text(body,"Введите имя новой учетной записи",24,25,560,40,19,Color3.fromRGB(0,51,153),true)
			local input=T.input(body,"",24,95,400,26)
			T.button(body,"Создать учетную запись",24,145,230,26,function()
				local profile,message=State.create(input.Text)
				if profile then showList() else context.wm:message("Учетные записи пользователей",message) end
			end)
			T.button(body,"Назад",460,375,100,23,showList)
		end)
		T.text(body,"...или выберите учетную запись для изменения",24,110,560,35,16,Color3.fromRGB(0,51,153),true)
		local scroll=Instance.new("ScrollingFrame")
		scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0 scroll.Position=UDim2.fromOffset(24,160) scroll.Size=UDim2.fromOffset(560,235) scroll.CanvasSize=UDim2.fromOffset(0,math.ceil(#State.profiles/2)*76) scroll.ScrollBarThickness=10 scroll.Parent=body
		for index,profile in State.profiles do
			local button=T.flatButton(scroll,"",((index-1)%2)*275,math.floor((index-1)/2)*76,265,70,function() editor(profile) end)
			T.image(button,profile.avatar,4,8,48,48,"users/")
			T.text(button,profile.name,66,10,185,28,15,Color3.fromRGB(0,51,153),true)
			T.text(button,if profile.guest then "Гостевая учетная запись" else "Администратор компьютера",66,39,185,20)
		end
	end
	showList()
	return window
end

function Settings:panel()
	local context=self.context
	local window,fresh=context.wm:create("control","Панель управления","300(16x16).png",680,500)
	if not fresh then return window end
	local body=window.body
	body.BackgroundColor3=Color3.new(1,1,1)
	local side=T.frame(body,"Tasks",Color3.fromRGB(100,132,220),0,0,170,430)
	side.Size=UDim2.new(0,170,1,0)
	T.gradient(side,{Color3.fromRGB(123,157,225),Color3.fromRGB(84,103,205)})
	T.text(side,"Панель управления",14,18,145,46,16,Color3.new(1,1,1),true)
	T.text(side,"См. также",14,92,145,22,12,Color3.new(1,1,1),true)
	T.flatButton(side,"Мой компьютер",14,125,140,26,function() context.apps:explorer("computer") end).TextColor3=Color3.new(1,1,1)
	T.text(body,"Выберите категорию",192,15,450,35,20,Color3.fromRGB(0,51,153),true)
	local items={
		{"Оформление и темы","680(32x32).png",function() self:display() end},
		{"Звуки, речь и аудиоустройства","120(16x16).png",function() self:sound() end},
		{"Учетные записи пользователей","user.png",function() self:users() end},
		{"Дата, время, язык и региональные стандарты","earth.png",function() self:datetime() end},
		{"Мышь","227(32x32).png",function() self:mouse() end},
		{"Панель задач и меню «Пуск»","358(32x32).png",function() self:taskbar() end},
		{"Язык и региональные стандарты","earth.png",function() self:regional() end},
		{"Система","676(32x32).png",function() context.apps:system() end},
	}
	for index,item in items do
		local button=T.flatButton(body,"",192,65+(index-1)*46,450,44,item[3])
		T.image(button,item[2],0,6,32,32)
		T.text(button,item[1],45,0,395,44,13,Color3.fromRGB(0,51,153))
	end
	return window
end

return Settings
