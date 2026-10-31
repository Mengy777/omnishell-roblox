-- A controlled execution harness. It does not render or emulate the Roblox engine.
local sources=__SOURCES__
local apiProperties=__API_PROPERTIES__
local function signal()
	local listeners={}
	local function connect(_,callback)
		local entry={active=true,callback=callback}
		table.insert(listeners,entry)
		return {Disconnect=function() entry.active=false end}
	end
	return {Connect=connect,Once=connect,Fire=function(_,...)
		for _,entry in table.clone(listeners) do if entry.active then entry.callback(...) end end
	end}
end
local methods={}
function methods:GetChildren() return table.clone(self._children) end
function methods:FindFirstChild(name) for _,child in self._children do if child.Name==name then return child end end return nil end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name),"Missing child: "..name) end
function methods:FindFirstChildOfClass(name) for _,child in self._children do if child.ClassName==name then return child end end end
function methods:GetDescendants()
	local result={}
	for _,child in self._children do table.insert(result,child) for _,nested in child:GetDescendants() do table.insert(result,nested) end end
	return result
end
function methods:IsA(name)
	if name==self.ClassName then return true end
	if name=="GuiButton" then return self.ClassName=="TextButton" or self.ClassName=="ImageButton" end
	if name=="GuiObject" then return table.find({"Frame","ScrollingFrame","TextButton","TextBox","TextLabel","ImageLabel","ImageButton"},self.ClassName)~=nil end
	return false
end
function methods:IsDescendantOf(parent) local current=self.Parent while current do if current==parent then return true end current=current.Parent end return false end
function methods:GetAttribute(name) return self._attributes[name] end
function methods:SetAttribute(name,value) self._attributes[name]=value end
function methods:Destroy()
	if self._destroyed then return end
	self._destroyed=true self.Destroying:Fire()
	for _,child in self:GetChildren() do child:Destroy() end
	self.Parent=nil
end
function methods:GetPropertyChangedSignal(name) self._signals[name]=self._signals[name] or signal() return self._signals[name] end
function methods:Play() self._played=true end
local events={Activated=true,MouseEnter=true,MouseLeave=true,SelectionGained=true,SelectionLost=true,
	MouseButton1Down=true,MouseButton1Up=true,InputBegan=true,InputEnded=true,InputChanged=true,FocusLost=true,Destroying=true,Heartbeat=true,Ended=true}
local function instance(className)
	local object={_children={},_signals={},_attributes={},_props={ClassName=className,Name=className,Visible=true,
		AbsoluteSize={X=1200,Y=800},AbsolutePosition={X=0,Y=0},AbsoluteContentSize={X=800,Y=400},Text=""}}
	return setmetatable(object,{
		__index=function(self,key)
			if methods[key] then return methods[key] end
			if events[key] then self._signals[key]=self._signals[key] or signal() return self._signals[key] end
			if self._props[key]~=nil then return self._props[key] end
			return methods.FindFirstChild(self,key)
		end,
		__newindex=function(self,key,value)
			if apiProperties[className] and string.sub(key,1,1)~="_" and type(value)~="function" then
				assert(apiProperties[className][key],"Unknown engine property "..className.."."..key)
			end
			local previous=self._props[key]
			if previous==value then return end
			if key=="Parent" then
				if previous then local index=table.find(previous._children,self) if index then table.remove(previous._children,index) end end
				if value then table.insert(value._children,self) end
			end
			self._props[key]=value
			if self._signals[key] then self._signals[key]:Fire() end
		end,
	})
end
local function dimensions(x,y,w,h)
	return {X={Scale=x or 0,Offset=y or 0},Y={Scale=w or 0,Offset=h or 0}}
end
local function offset(x,y) return dimensions(0,x,0,y) end
local function scale(x,y) return dimensions(x,0,y,0) end
local function color(...) return {values={...},Lerp=function(self) return self end} end
local function enumNode() return setmetatable({},{__index=function(self,key) local result=enumNode() rawset(self,key,result) return result end}) end
local playerGui=instance("PlayerGui")
local player=instance("Player") player.DisplayName="Owner" playerGui.Parent=player
local oldCharacter=instance("Model") player.Character=oldCharacter
local players={LocalPlayer=player,CharacterAutoLoads=true,PlayerAdded=signal(),GetPlayers=function() return {player} end}
local shared=instance("Folder") shared.Name="OmniShell"
local storage=instance("ReplicatedStorage") shared.Parent=storage
local nodes={}
for _,name in {"Platforms","Games"} do nodes[name]=instance("ModuleScript") nodes[name].Name=name nodes[name].Parent=shared end
local client=instance("LocalScript")
for _,name in {"UI","XP"} do nodes[name]=instance("ModuleScript") nodes[name].Name=name nodes[name].Parent=client end
for _,name in {"Theme","State","WindowManager","Settings","Apps"} do nodes[name]=instance("ModuleScript") nodes[name].Name=name nodes[name].Parent=nodes.XP end
local world=instance("Workspace") world.CurrentCamera=instance("Camera")
local input=instance("UserInputService") input.IsKeyDown=function() return false end input.GetMouseLocation=function() return {X=0,Y=0} end
local runService=instance("RunService")
local services={Players=players,ReplicatedStorage=storage,GuiService={},UserInputService=input,RunService=runService,
	SoundService=instance("SoundService"),Debris={AddItem=function() end},StarterGui={SetCoreGuiEnabled=function() end},
	TweenService={Create=function() return {Play=function() end} end}}
local results={}
local env=setmetatable({
	game={GetService=function(_,name) return assert(services[name],name) end},workspace=world,
	Instance={new=instance},Color3={new=color,fromRGB=color},ColorSequence={new=dimensions},ColorSequenceKeypoint={new=dimensions},
	UDim2={new=dimensions,fromOffset=offset,fromScale=scale},UDim={new=dimensions},
	Vector2={new=function(x,y) return {X=x,Y=y} end,zero={X=0,Y=0}},CFrame={new=dimensions},Rect={new=dimensions},
	Font={new=dimensions},TweenInfo={new=dimensions},Enum=enumNode(),
	task={spawn=function(callback) callback() end,wait=function() end,delay=function(_,callback) callback() end},
	require=function(module) return assert(results[module.Name],"Unloaded module: "..module.Name) end,
},{__index=getfenv()})
local function load(name,node)
	local chunk=assert(loadstring(sources[name],name))
	setfenv(chunk,setmetatable({script=node},{__index=env}))
	return chunk()
end
for _,name in {"Platforms","Games","UI","State","Theme","WindowManager","Settings","Apps","XP"} do results[name]=load(name,nodes[name]) end
local State=results.State
State.initialize("Owner")
assert(#State.profiles==2,"Default profiles")
local owner=State.profiles[1]
local guest=State.profiles[2]
local created=assert(State.create("  Test  ")) assert(created.name=="Test")
assert(not State.create("Test"),"Duplicate profile must be rejected")
assert(not State.create("bad/name"),"Invalid profile name must be rejected")
assert(not State.create(string.rep("A",41)),"Name length")
assert(State.rename(created,"Renamed"))
assert(not State.rename(created,"Owner"),"Cannot rename over another profile")
State.current=owner assert(not State.delete(owner),"Cannot remove active profile")
assert(State.delete(created),"Remove inactive profile")
owner.preferences.volume=20 assert(guest.preferences.volume==70,"Per-user settings isolation")
owner.preferences.volume=70 State.current=nil
print("PASS: account validation, rename/delete, per-profile settings isolation")
load("Server",client)
assert(not players.CharacterAutoLoads and player.Character==nil and oldCharacter._destroyed,"No falling avatar")
local incoming={Character=instance("Model")} players.PlayerAdded:Fire(incoming) assert(incoming.Character==nil)
local session
local mount=results.XP.mount
results.XP.mount=function(...) session=mount(...) return session end
load("Client",client)
local gui=playerGui:WaitForChild("OmniShell")
local root=gui:WaitForChild("FullScreen")
local nav=root.Navigation.Categories
local cards=root.Content.Page.Cards
cards:WaitForChild("windows-xp").Activated:Fire()
assert(session and session.welcomeFrame and not root.Visible,"XP welcome replaces launcher")
session.welcomeFrame.Center.Profiles:WaitForChild("Profile:"..owner.id).Activated:Fire()
assert(State.current==owner and session.desktop.Visible and not session.welcomeFrame,"Profile login")
session:startMenu() assert(session.menu,"Start menu") session:closeMenus()
local settingsCount=0
for _,method in {"display","desktopIcons","taskbar","sound","mouse","regional","datetime"} do
	local window=session.settings[method](session.settings)
	local tabs=window.body:WaitForChild("Tabs")
	for _,button in tabs:GetChildren() do if button:IsA("TextButton") then button.Activated:Fire() settingsCount+=1 end end
	window.close()
end
session.settings:panel().close()
local accounts=session.settings:users()
assert(accounts.body:FindFirstChild("ScrollingFrame"),"Account list") accounts.close()
local display=session.settings:display()
display.body.Tabs:WaitForChild("Рабочий стол").Activated:Fire()
local function findButton(parent,text)
	for _,child in parent:GetDescendants() do if child:IsA("TextButton") and child.Text==text then return child end end
	error("Missing button: "..text)
end
display.body.Page.Wallpapers:WaitForChild("Autumn.jpg").Activated:Fire()
findButton(display.body,"Применить").Activated:Fire()
assert(owner.preferences.wallpaper=="Autumn.jpg" and guest.preferences.wallpaper=="Bliss.png","Apply settings only to current profile")
assert(session.desktop.Wallpaper.Image=="rbxasset://omnishell/xp/images/Autumn.jpg","Wallpaper content URI")
display.close()
print("PASS: profile login, Start menu, "..settingsCount.." settings tabs, wallpaper Apply, account list")
local note=session.apps:notepad()
note.body.Input.Text="Saved test text"
findButton(note.body,"Файл").Activated:Fire()
findButton(note.body,"Сохранить").Activated:Fire()
local save=session.wm.windows["save-notepad"]
save.body.Input.Text="test.txt"
findButton(save.body,"Сохранить").Activated:Fire()
assert(owner.files["test.txt"]=="Saved test text","Save text file in profile")
note.close()
session.apps:notepad("test.txt").close()
local calc=session.apps:calculator()
findButton(calc.body,"2").Activated:Fire() findButton(calc.body,"+").Activated:Fire()
findButton(calc.body,"3").Activated:Fire() findButton(calc.body,"=").Activated:Fire()
assert(calc.body.Input.Text=="5","Calculator arithmetic") calc.close()
for _,location in {"computer","documents","drive","recycle","network"} do session.apps:explorer(location).close() end
session.apps:games().close() session.apps:help().close() session.apps:search().close()
local system=session.apps:system()
for _,tab in system.body.Tabs:GetChildren() do if tab:IsA("TextButton") then tab.Activated:Fire() end end
system.close()
local run=session.apps:run() run.body.Input.Text="calc" findButton(run.body,"OK").Activated:Fire()
assert(session.wm.windows.calc,"Run launches known app") session.wm.windows.calc.close()
session:screenSaver("Пустой экран") assert(session.screen) session.screen:Destroy() session.screen=nil
session:welcome() assert(not State.current and session.welcomeFrame,"Logoff returns to welcome")
session:login(guest) assert(guest.preferences.wallpaper=="Bliss.png","Guest gets own desktop")
session:welcome() session:login(owner) assert(owner.files["test.txt"]=="Saved test text","Profile files survive switching")
session:destroy() assert(not session.alive and not gui:FindFirstChild("WindowsXP"),"XP cleanup")
print("PASS: Notepad save/reopen, calculator, 5 Explorer locations, Run, games/help/search/system, logoff/switch, cleanup")
print("PASS: startup removes existing/future avatars; XP resources use local content URIs")
