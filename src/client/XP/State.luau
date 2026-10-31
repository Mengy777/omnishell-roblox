--!strict

export type Preferences = {
	wallpaper: string, background: string, wallpaperMode: string, theme: string,
	fontSize: number, showIcons: boolean, showClock: boolean, quickLaunch: boolean,
	lockTaskbar: boolean, autoHide: boolean, groupTasks: boolean, classicStart: boolean,
	volume: number, muted: boolean, doubleClick: number, screenSaver: string,
	saverMinutes: number, resolution: string, colorDepth: string, timeOffset: number,
	language: string, dateFormat: string,
	showComputer: boolean, showDocuments: boolean, showNetwork: boolean,
}
export type Profile = { id: number, name: string, avatar: string, guest: boolean, preferences: Preferences, files: { [string]: string } }

local State = {}
State.clipboard = ""
State.utcOffset = 0
State.avatars={"airplane.png","astronaut.png","ball.png","beach.png","butterfly.png","car.png","cat.png","chess.png","dirt bike.png","dog.png","drip.png","duck.png","fish.png","frog.png","guest.png","guitar.png","horses.png","kick.png","lift-off.png","palm tree.png","pink flower.png","red flower.png","skater.png","skillz.png","snowflake.png"}
State.wallpapers={"None","Ascent.jpg","Autumn.jpg","Azul.jpg","Bliss.png","Crystal.jpg","Follow.jpg","Friend.jpg","Home.jpg","Moon flower.jpg","Peace.jpg","Power.jpg","Purple flower.jpg","Radiance.jpg","Red moon desert.jpg","Ripple.jpg","Stonehenge.jpg","Tulips.jpg","Vortec space.jpg","Wind.jpg","Windows-XP.jpg"}
local function defaults(): Preferences
	return {
		wallpaper = "Bliss.png", background = "0,78,152", wallpaperMode = "Stretch", theme = "Blue",
		fontSize = 11, showIcons = true, showClock = true, quickLaunch = false,
		lockTaskbar = true, autoHide = false, groupTasks = true, classicStart = false,
		volume = 70, muted = false, doubleClick = 0.45, screenSaver = "None",
		saverMinutes = 10, resolution = "1024 × 768", colorDepth = "32 бита", timeOffset = State.utcOffset,
		language = "Русский", dateFormat = "dd.MM.yyyy",
		showComputer = false, showDocuments = false, showNetwork = false,
	}
end

State.profiles = {} :: { Profile }
State.current = nil :: Profile?
local nextId = 1

function State.create(name: string, avatar: string?, guest: boolean?): (Profile?, string?)
	name = string.match(name, "^%s*(.-)%s*$") or ""
	if name == "" or (utf8.len(name) or 41) > 40 or string.find(name, '[\\/:*?"<>|]') then
		return nil, "Введите допустимое имя пользователя (до 40 символов)."
	end
	for _, profile in State.profiles do
		if string.lower(profile.name) == string.lower(name) then return nil, "Пользователь с таким именем уже существует." end
	end
	if #State.profiles >= 8 then return nil, "Достигнуто максимальное число локальных пользователей: 8." end
	local profile: Profile = { id = nextId, name = name, avatar = avatar or "chess.png", guest = guest or false, preferences = defaults(), files = {} }
	nextId += 1
	table.insert(State.profiles, profile)
	return profile, nil
end

function State.rename(profile: Profile, name: string): (boolean, string?)
	name = string.match(name, "^%s*(.-)%s*$") or ""
	if name == "" or (utf8.len(name) or 41) > 40 or string.find(name, '[\\/:*?"<>|]') then return false, "Недопустимое имя пользователя." end
	for _, other in State.profiles do
		if other ~= profile and string.lower(other.name) == string.lower(name) then return false, "Это имя уже используется." end
	end
	profile.name = name
	return true, nil
end

function State.delete(profile: Profile): boolean
	if profile == State.current or #State.profiles <= 1 then return false end
	local index = table.find(State.profiles, profile)
	if not index then return false end
	table.remove(State.profiles, index)
	return true
end

function State.initialize(owner: string, utcOffset: number?)
	if #State.profiles > 0 then return end
	State.utcOffset = utcOffset or 0
	State.create(owner, "chess.png", false)
	if owner ~= "Гость" then State.create("Гость", "guest.png", true) end
end

return State
