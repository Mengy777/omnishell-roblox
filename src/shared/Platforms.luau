--!strict

export type Platform = {
	id: string,
	name: string,
	family: string,
	accent: Color3,
}

local platforms: { Platform } = {
	{ id = "windows-xp", name = "Windows XP", family = "Windows", accent = Color3.fromRGB(69, 134, 240) },
	{ id = "windows-7", name = "Windows 7", family = "Windows", accent = Color3.fromRGB(48, 169, 181) },
	{ id = "windows-10", name = "Windows 10", family = "Windows", accent = Color3.fromRGB(0, 120, 215) },
	{ id = "windows-11", name = "Windows 11", family = "Windows", accent = Color3.fromRGB(99, 143, 255) },
	{ id = "ps4", name = "PlayStation 4", family = "PlayStation", accent = Color3.fromRGB(78, 117, 244) },
	{ id = "ps5", name = "PlayStation 5", family = "PlayStation", accent = Color3.fromRGB(153, 174, 255) },
	{ id = "xbox", name = "Xbox", family = "Xbox", accent = Color3.fromRGB(93, 189, 76) },
}

return platforms
