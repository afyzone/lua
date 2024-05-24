-- https://www.roblox.com/games/12578805328/
local players = game:GetService('Players')
local replicatedstorage = game:GetService("ReplicatedStorage")

local client, my_island = players.LocalPlayer
shared.afy = not shared.afy

local get_island = function()
    for i,v in pairs(workspace.Scripts.Islands:GetChildren()) do
        if not (v:FindFirstChild('Owner') and v.Owner.Value == client.Name) then continue end
        
        return v
    end
end

while (shared.afy and task.wait()) do
    my_island = my_island or get_island()
    local current_planet = my_island.Planet:FindFirstChildWhichIsA('Model')
    
    if (current_planet) then
        replicatedstorage.Packages.Knit.Services.IslandService.RE.Damage:FireServer(current_planet.Name)
    end

    
    for i,v in pairs(my_island.Debris.Orbs.Storage:GetChildren()) do
        replicatedstorage.Packages.Knit.Services.OrbService.RE.collectOrbs:FireServer(v.Name)
    end
end
