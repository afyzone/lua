-- https://www.roblox.com/games/104715542330896/BlockSpin

-- For Blockspin Developers
-- If you guys want tips on how to make an anti cheat. DM me @afyzone

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

for i,v in getconnections(Client.Idled) do
	v:Disable()
end

loadstring(game:HttpGet('https://gist.githubusercontent.com/afyzone/f6b069c544830c1f9131ba0e501730cc/raw/'))()
