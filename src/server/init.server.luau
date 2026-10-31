--!strict

local Players = game:GetService("Players")

-- No avatar is needed in the shell. Spawning over the empty place caused
-- an endless fall/death/respawn cycle. Games must explicitly spawn at a safe location.
Players.CharacterAutoLoads = false

local function enterShell(player: Player)
	if player.Character then
		player.Character:Destroy()
		player.Character = nil
	end
end

Players.PlayerAdded:Connect(enterShell)
for _, player in Players:GetPlayers() do
	enterShell(player)
end
