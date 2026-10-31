--!strict

export type Category = { id: string, name: string, symbol: string, description: string, accent: Color3 }
export type Platform = { id: string, name: string, category: string, caption: string, symbol: string, accent: Color3 }

local categories: { Category } = {
	{ id = "windows", name = "Windows", symbol = "⊞", description = "Знакомые рабочие столы. Разные эпохи.", accent = Color3.fromRGB(94, 168, 255) },
	{ id = "consoles", name = "Консоли", symbol = "◇", description = "Большой экран. Твоя игровая коллекция.", accent = Color3.fromRGB(165, 143, 255) },
	{ id = "macos", name = "macOS", symbol = "M", description = "Другая атмосфера той же библиотеки.", accent = Color3.fromRGB(255, 175, 145) },
	{ id = "other", name = "Другое", symbol = "+", description = "Ещё больше способов войти в игру.", accent = Color3.fromRGB(101, 219, 182) },
}

local platforms: { Platform } = {
	{ id = "windows-xp", name = "Windows XP", category = "windows", caption = "Классика рабочего стола", symbol = "⊞", accent = Color3.fromRGB(102, 191, 132) },
	{ id = "windows-7", name = "Windows 7", category = "windows", caption = "Эпоха Aero", symbol = "⊞", accent = Color3.fromRGB(87, 204, 221) },
	{ id = "windows-10", name = "Windows 10", category = "windows", caption = "Привычный ритм", symbol = "⊞", accent = Color3.fromRGB(78, 155, 255) },
	{ id = "windows-11", name = "Windows 11", category = "windows", caption = "Современный рабочий стол", symbol = "⊞", accent = Color3.fromRGB(144, 148, 255) },
	{ id = "ps4", name = "PlayStation 4", category = "consoles", caption = "Синяя классика", symbol = "PS", accent = Color3.fromRGB(94, 145, 255) },
	{ id = "ps5", name = "PlayStation 5", category = "consoles", caption = "Новое поколение интерфейса", symbol = "PS", accent = Color3.fromRGB(197, 207, 244) },
	{ id = "xbox", name = "Xbox", category = "consoles", caption = "Твоя игровая панель", symbol = "X", accent = Color3.fromRGB(116, 217, 127) },
	{ id = "macos", name = "macOS", category = "macos", caption = "Версию оболочки выберем позже", symbol = "M", accent = Color3.fromRGB(255, 175, 145) },
}

return { categories = categories, platforms = platforms }
