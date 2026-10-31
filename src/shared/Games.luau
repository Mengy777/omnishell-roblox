--!strict

-- One catalog for every shell. Only list playable games that exist in the project.
export type Game = { id: string, name: string }
local games: { Game } = {}
return games
