--!nonstrict

local T=require(script.Parent.Theme)
local State=require(script.Parent.State)
local Games=require(game:GetService("ReplicatedStorage"):WaitForChild("OmniShell"):WaitForChild("Games"))
local Apps={}

function Apps.new(context) return setmetatable({context=context},{__index=Apps}) end

function Apps:menu(body,items)
	local menu=T.frame(body,"MenuBar",T.surface,0,0,100,23)
	menu.Size=UDim2.new(1,0,0,23)
	local x=4
	local popup=nil
	for _,item in items do
		local width=utf8.len(item[1])*6+18
		local menuX=x
		T.flatButton(menu,item[1],x,0,width,23,function()
			if popup then popup:Destroy() popup=nil end
			if type(item[2])=="function" then item[2]() return end
			popup=T.frame(body,"MenuPopup",T.surface,menuX,23,215,#item[2]*25+6)
			popup.ZIndex=100 T.border(popup,Color3.fromRGB(128,128,128))
			for index,entry in item[2] do
				local option=T.flatButton(popup,entry[1],3,3+(index-1)*25,209,25)
				option.TextXAlignment=Enum.TextXAlignment.Left
				if entry[2] then
					option.MouseEnter:Connect(function() option.BackgroundTransparency=0 option.BackgroundColor3=Color3.fromRGB(49,106,197) option.TextColor3=Color3.new(1,1,1) end)
					option.MouseLeave:Connect(function() option.BackgroundTransparency=1 option.TextColor3=T.textColor end)
					option.Activated:Connect(function() popup:Destroy() popup=nil entry[2]() end)
				else option.TextColor3=Color3.fromRGB(128,128,128) end
			end
		end)
		x+=width
	end
	return menu
end

function Apps:notepad(filename)
	local context=self.context
	filename=filename or "Безымянный.txt"
	local window,fresh=context.wm:create("notepad:"..filename,filename.." — Блокнот","327(16x16).png",640,470)
	if not fresh then return window end
	local body=window.body
	local editor=T.input(body,State.current.files[filename] or "",0,25,100,100)
	editor.Size=UDim2.new(1,0,1,-48)
	editor.MultiLine=true
	editor.TextWrapped=true
	editor.TextYAlignment=Enum.TextYAlignment.Top
	editor.FontFace=Font.new(T.assetRoot.."fonts/LucidaConsole.json")
	editor.TextSize=13
	local status=T.text(body,"Строка 1, столбец 1",8,0,400,21)
	status.Position=UDim2.new(0,8,1,-22)
	local function save()
		local dialog,created=context.wm:create("save-notepad","Сохранение","327(16x16).png",440,210)
		if not created then return end
		T.text(dialog.body,"Имя файла:",18,24,100,22)
		local input=T.input(dialog.body,filename,118,24,290,23)
		T.text(dialog.body,"Папка: Мои документы",18,66,380,22)
		T.button(dialog.body,"Сохранить",220,117,90,23,function()
			local name=string.match(input.Text,"^%s*(.-)%s*$")
			if name=="" or string.find(name,'[\\/:*?"<>|]') then context.wm:message("Блокнот","Недопустимое имя файла.") return end
			if not string.match(name,"%.txt$") then name..=".txt" end
			State.current.files[name]=editor.Text
			filename=name window.titleText.Text=name.." — Блокнот" window.taskLabel.Text=name
			dialog.close()
		end)
		T.button(dialog.body,"Отмена",320,117,90,23,dialog.close)
	end
	local previousText=editor.Text
	local history={}
	local restoring=false
	local function selectedText()
		local first,last=editor.SelectionStart,editor.CursorPosition
		if not first or not last or first<1 or last<1 or first==last then return nil end
		return math.min(first,last),math.max(first,last)
	end
	local function copy(cut)
		local first,last=selectedText()
		if not first then return end
		State.clipboard=string.sub(editor.Text,first,last-1)
		if cut then editor.Text=string.sub(editor.Text,1,first-1)..string.sub(editor.Text,last) end
	end
	local function paste()
		local first,last=selectedText()
		local position=if editor.CursorPosition and editor.CursorPosition>0 then editor.CursorPosition else #editor.Text+1
		first=first or position last=last or position
		editor.Text=string.sub(editor.Text,1,first-1)..(State.clipboard or "")..string.sub(editor.Text,last)
	end
	self:menu(body,{
		{"Файл",{{"Создать",function() editor.Text="" filename="Безымянный.txt" window.titleText.Text=filename.." — Блокнот" end},{"Открыть...",function() self:explorer("documents") end},{"Сохранить",save},{"Сохранить как...",save},{"Параметры страницы...",false},{"Печать...",false},{"Выход",window.close}}},
		{"Правка",{{"Отменить",function() local text=table.remove(history) if text then restoring=true editor.Text=text restoring=false previousText=text end end},{"Вырезать",function() copy(true) end},{"Копировать",function() copy(false) end},{"Вставить",paste},{"Выделить все",function() editor:CaptureFocus() editor.CursorPosition=1 editor.SelectionStart=#editor.Text+1 end},{"Время и дата",function() editor.Text..=os.date("%H:%M %d.%m.%Y",os.time()+State.current.preferences.timeOffset) end}}},
		{"Формат",{{"Перенос по словам",function() editor.TextWrapped=not editor.TextWrapped end},{"Шрифт...",function()
			local fontWindow,fresh=context.wm:create("notepad-font","Шрифт","327(16x16).png",420,235)
			if not fresh then return end
			T.text(fontWindow.body,"Шрифт:",18,20,220,20)
			local font="LucidaConsole" local size=editor.TextSize
			T.choice(fontWindow.body,{"LucidaConsole","Tahoma","Trebuchet"},font,18,48,230,function(value) font=value end)
			T.text(fontWindow.body,"Размер:",270,20,100,20)
			T.choice(fontWindow.body,{11,12,13,14,16,18,20,24,28},size,270,48,120,function(value) size=value end)
			T.button(fontWindow.body,"OK",220,145,75,23,function() editor.FontFace=Font.new(T.assetRoot.."fonts/"..font..".json") editor.TextSize=size fontWindow.close() end)
			T.button(fontWindow.body,"Отмена",310,145,80,23,fontWindow.close)
		end}}},
		{"Вид",{{"Строка состояния",function() status.Visible=not status.Visible end}}},
		{"Справка",{{"Вызов справки",function() self:help() end},{"О программе",function() context.wm:message("Блокнот","Microsoft Windows XP\nБлокнот\nВерсия 5.1") end}}},
	})
	editor:GetPropertyChangedSignal("Text"):Connect(function()
		if not restoring then table.insert(history,previousText) if #history>50 then table.remove(history,1) end end
		previousText=editor.Text
		window.titleText.Text="* "..filename.." — Блокнот"
		status.Text="Символов: "..tostring(utf8.len(editor.Text) or #editor.Text)
	end)
	return window
end

function Apps:calculator()
	local context=self.context
	local window,fresh=context.wm:create("calc","Калькулятор","74(16x16).png",285,300)
	if not fresh then return window end
	local display=T.input(window.body,"0",12,30,255,28)
	display.TextXAlignment=Enum.TextXAlignment.Right
	display.TextEditable=false
	self:menu(window.body,{{"Правка",{{"Копировать",function() State.clipboard=display.Text end},{"Вставить",function() local value=tonumber(State.clipboard) if value then display.Text=tostring(value) end end}}},{"Вид",{{"Обычный",false},{"Инженерный",false}}},{"Справка",{{"Вызов справки",function() self:help() end}}}})
	local accumulator=nil
	local operation=nil
	local newNumber=true
	local memory=0
	local function calculate()
		local number=tonumber(display.Text) or 0
		if operation and accumulator then
			if operation=="+" then number=accumulator+number elseif operation=="-" then number=accumulator-number elseif operation=="*" then number=accumulator*number elseif operation=="/" then
				if number==0 then display.Text="Деление на ноль" accumulator=nil operation=nil newNumber=true context:play("Windows XP Error.wav") return end
				number=accumulator/number
			end
		end
		display.Text=string.format("%.12g",number)
		accumulator=number operation=nil newNumber=true
	end
	local keys={"MC","7","8","9","/","MR","4","5","6","*","MS","1","2","3","-","M+","0",".","=","+"}
	for index,key in keys do
		local button=T.button(window.body,key,12+((index-1)%5)*52,100+math.floor((index-1)/5)*34,47,28,function()
			local number=tonumber(display.Text) or 0
			if key=="MC" then memory=0 elseif key=="MR" then display.Text=tostring(memory) newNumber=true elseif key=="MS" then memory=number elseif key=="M+" then memory+=number
			elseif key=="=" then calculate()
			elseif key=="+" or key=="-" or key=="*" or key=="/" then calculate() accumulator=tonumber(display.Text) operation=key newNumber=true
			elseif key=="." then if newNumber then display.Text="0" newNumber=false end if not string.find(display.Text,"%.") then display.Text..="." end
			else if newNumber or display.Text=="0" then display.Text=key else display.Text..=key end newNumber=false end
		end)
		button.TextColor3=if tonumber(key) or key=="." then Color3.fromRGB(0,0,180) else Color3.fromRGB(180,0,0)
	end
	T.button(window.body,"Backspace",12,67,98,25,function() display.Text=string.sub(display.Text,1,-2) if display.Text=="" then display.Text="0" end end)
	T.button(window.body,"CE",116,67,72,25,function() display.Text="0" newNumber=true end)
	T.button(window.body,"C",194,67,72,25,function() display.Text="0" accumulator=nil operation=nil newNumber=true end)
	return window
end

function Apps:explorer(location)
	local context=self.context
	location=location or "computer"
	local titles={computer="Мой компьютер",documents="Мои документы",recycle="Корзина",network="Сетевое окружение",drive="Локальный диск (C:)"}
	local title=titles[location] or location
	local window,fresh=context.wm:create("explorer:"..location,title,"676(16x16).png",720,470)
	if not fresh then return window end
	local body=window.body
	body.BackgroundColor3=Color3.new(1,1,1)
	self:menu(body,{{"Файл",{{"Создать текстовый документ",function() self:notepad() end},{"Закрыть",window.close}}},{"Правка",{{"Вырезать",false},{"Копировать",false},{"Вставить",false},{"Выделить все",false}}},{"Вид",{{"Обновить",function() window.close() self:explorer(location) end}}},{"Избранное",{{"Мои документы",function() self:explorer("documents") end}}},{"Сервис",{{"Панель управления",function() context.settings:panel() end}}},{"Справка",{{"Вызов справки",function() self:help() end}}}})
	local tools=T.frame(body,"Toolbar",T.surface,0,23,714,38)
	tools.Size=UDim2.new(1,0,0,38)
	T.button(tools,"← Назад",6,5,85,28,function() self:explorer("computer") end)
	T.button(tools,"Вверх",100,5,65,28,function() self:explorer("computer") end)
	T.button(tools,"Поиск",179,5,70,28,function() self:search() end)
	T.button(tools,"Папки",260,5,70,28,function() self:explorer("documents") end)
	local address=T.frame(body,"Address",T.surface,0,61,714,28)
	address.Size=UDim2.new(1,0,0,28)
	T.text(address,"Адрес",5,0,45,26)
	local input=T.input(address,title,54,2,570,22)
	input.Size=UDim2.new(1,-135,0,22)
	T.button(address,"Переход",630,2,75,22,function()
		local target=string.lower(input.Text)
		self:explorer(if string.find(target,"c:") then "drive" elseif string.find(target,"док") then "documents" else "computer")
	end).Position=UDim2.new(1,-79,0,2)
	local side=T.frame(body,"Tasks",Color3.fromRGB(116,142,225),0,89,185,100)
	side.Size=UDim2.new(0,185,1,-110)
	T.gradient(side,{Color3.fromRGB(123,157,225),Color3.fromRGB(84,103,205)})
	T.text(side,"Системные задачи",14,16,160,24,12,Color3.new(1,1,1),true)
	local tasks={{"Просмотр сведений о системе",function() self:system() end},{"Панель управления",function() context.settings:panel() end},{"Мои документы",function() self:explorer("documents") end},{"Мой компьютер",function() self:explorer("computer") end}}
	for i,item in tasks do
		local link=T.flatButton(side,item[1],14,50+(i-1)*44,155,38,item[2])
		link.TextWrapped=true link.TextColor3=Color3.new(1,1,1) link.TextXAlignment=Enum.TextXAlignment.Left
	end
	local area=Instance.new("ScrollingFrame")
	area.Name="Items" area.BackgroundTransparency=1 area.BorderSizePixel=0 area.Position=UDim2.fromOffset(195,99) area.Size=UDim2.new(1,-205,1,-130) area.ScrollBarThickness=10 area.CanvasSize=UDim2.fromOffset(0,0) area.AutomaticCanvasSize=Enum.AutomaticSize.Y area.Parent=body
	local items={}
	if location=="computer" then
		items={{"Мои документы","308(32x32).png",function() self:explorer("documents") end},{"Локальный диск (C:)","334(32x32).png",function() self:explorer("drive") end},{"Панель управления","300(32x32).png",function() context.settings:panel() end}}
	elseif location=="drive" then
		items={{"Documents and Settings","folder.png",function() self:explorer("documents") end},{"Игры","folder.png",function() self:games() end}}
	elseif location=="documents" then
		for filename,_ in State.current.files do table.insert(items,{filename,"327(32x32).png",function() self:notepad(filename) end}) end
		table.insert(items,{"Создать текстовый документ","327(32x32).png",function() self:notepad() end})
	end
	for index,item in items do
		local button=T.flatButton(area,"",0,(index-1)*70,450,65)
		T.image(button,item[2],8,10,40,40)
		T.text(button,item[1],62,0,350,65,12)
		local last=0
		button.Activated:Connect(function()
			local now=os.clock()
			if now-last<State.current.preferences.doubleClick then item[3]() else button.BackgroundTransparency=0.8 button.BackgroundColor3=Color3.fromRGB(49,106,197) end
			last=now
		end)
	end
	if #items==0 then T.text(area,if location=="recycle" then "Корзина пуста." else "Нет доступных сетевых подключений.",15,20,420,50) end
	local status=T.text(body,tostring(#items).." объектов",5,0,500,20)
	status.Position=UDim2.new(0,5,1,-21)
	return window
end

function Apps:games()
	local window,fresh=self.context.wm:create("games","Games","folder.png",600,400)
	if not fresh then return window end
	window.body.BackgroundColor3=Color3.new(1,1,1)
	T.text(window.body,"Games",22,20,540,40,22,Color3.fromRGB(0,51,153),true)
	if #Games==0 then
		T.text(window.body,"В этой папке пока нет установленных игр.",22,95,540,50,12)
	else
		for index,entry in Games do T.text(window.body,entry.name,22,90+(index-1)*35,540,30,13) end
	end
	return window
end

function Apps:system()
	local window,fresh=self.context.wm:create("system","Свойства системы","676(16x16).png",470,475)
	if not fresh then return window end
	self.context.wm:tabs(window,{"Общие","Имя компьютера","Оборудование","Дополнительно"},function(page,name)
		if name=="Общие" then
			T.image(page,"windows-off.png",24,38,110,90)
			T.text(page,"Система:\nMicrosoft Windows XP\nProfessional\nService Pack 3",158,30,250,110,12)
			T.text(page,"Пользователь:\n"..State.current.name,158,170,250,65,12)
			T.text(page,"Компьютер:\nOmniShell\nИнтерфейс в Roblox Studio",158,265,250,65,12)
		elseif name=="Имя компьютера" then
			T.text(page,"Полное имя:\nOMNISHELL\n\nРабочая группа:\nWORKGROUP",20,30,380,150)
		else
			T.text(page,"Параметры виртуальной оболочки не изменяют оборудование и настройки компьютера, на котором запущен Studio.",20,30,380,100)
		end
	end)
	T.button(window.body,"OK",365,0,75,23,window.close).Position=UDim2.new(1,-85,1,-32)
	return window
end

function Apps:help()
	local window,fresh=self.context.wm:create("help","Центр справки и поддержки","747(32x32).png",650,430)
	if not fresh then return window end
	window.body.BackgroundColor3=Color3.new(1,1,1)
	T.text(window.body,"Справка и поддержка",24,20,600,40,23,Color3.fromRGB(0,51,153),true)
	T.text(window.body,"Начало работы\n\n• Открывайте значки рабочего стола двойным щелчком.\n• Меню «Пуск» содержит программы и параметры.\n• Панель управления позволяет изменить оформление и учетные записи.\n• Сохраненные в Блокноте файлы находятся в «Моих документах».\n• Для смены пользователя выберите «Выход из системы».\n• Для возврата к выбору платформ выберите «Выключение».\n\nПользователи, документы и параметры сохраняются до остановки текущего запуска Studio.",24,80,595,265,12)
	return window
end

function Apps:run()
	local context=self.context
	local window,fresh=context.wm:create("run","Запуск программы","743(32x32).png",430,205)
	if not fresh then return window end
	T.image(window.body,"743(32x32).png",17,18,32,32)
	T.text(window.body,"Введите имя программы, папки, документа или ресурса Интернета.",65,10,340,48)
	T.text(window.body,"Открыть:",17,75,65,23)
	local input=T.input(window.body,"",85,75,320,23)
	local function execute()
		local command=string.lower(string.match(input.Text,"^%s*(.-)%s*$") or "")
		local commands={
			notepad=function() self:notepad() end,calc=function() self:calculator() end,explorer=function() self:explorer() end,
			control=function() context.settings:panel() end,["desk.cpl"]=function() context.settings:display() end,
			["mmsys.cpl"]=function() context.settings:sound() end,["timedate.cpl"]=function() context.settings:datetime() end,
			["intl.cpl"]=function() context.settings:regional() end,["main.cpl"]=function() context.settings:mouse() end,
			["control userpasswords"]=function() context.settings:users() end,winver=function() self:system() end,
			["shell:games"]=function() self:games() end,
		}
		local callback=commands[command]
		if callback then window.close() callback() else context:play("Windows XP Error.wav") context.wm:message("Запуск программы","Не удается найти «"..input.Text.."». Проверьте, правильно ли указано имя.") end
	end
	T.button(window.body,"OK",158,123,75,23,execute)
	T.button(window.body,"Отмена",240,123,75,23,window.close)
	T.button(window.body,"Обзор...",322,123,85,23,function() self:explorer("documents") end)
	input.FocusLost:Connect(function(enter) if enter then execute() end end)
	return window
end

function Apps:search()
	local window,fresh=self.context.wm:create("search","Результаты поиска","299(32x32).png",600,420)
	if not fresh then return window end
	T.text(window.body,"Что вы хотите найти?",20,20,550,30,18,Color3.fromRGB(0,51,153),true)
	local input=T.input(window.body,"",20,75,420,24)
	local results=T.text(window.body,"",20,130,550,220,12)
	results.TextYAlignment=Enum.TextYAlignment.Top
	T.button(window.body,"Найти",455,75,100,24,function()
		local matches={}
		for filename,_ in State.current.files do if string.find(string.lower(filename),string.lower(input.Text),1,true) then table.insert(matches,filename) end end
		results.Text=if #matches==0 then "Поиск не дал результатов." else table.concat(matches,"\n")
	end)
	return window
end

return Apps
