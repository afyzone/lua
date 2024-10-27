-- https://www.roblox.com/games/17486343676

local players = game:GetService('Players')
local replicatedstorage = game:GetService("ReplicatedStorage")
local client = players.LocalPlayer
local backpack = client.Backpack

local flip, flag = tick()

shared.afy = not shared.afy

while shared.afy and task.wait() do
    local char = client.Character
    
    if (char) then
        local root = char:FindFirstChild('HumanoidRootPart')
        local hum = char:FindFirstChildWhichIsA('Humanoid')
        local my_slime = char:FindFirstChild('Slime')

        if (root and my_slime) then
            local get_enemy = function()
                for i,v in (workspace.Enemies.dungeon:GetChildren()) do
                    if (v:GetAttribute('targetPlayer') ~= client.Name) then continue end
    
                    local enemy_root = v:FindFirstChild('Enemy')
                    
                    if (enemy_root) then
                        return enemy_root
                    end
                end
            end

            local enemy_root = get_enemy()
            if (enemy_root) then
                replicatedstorage.EnemyGetHit:FireServer(enemy_root.Parent, 40, false, "")                
            end
        end
    end
end
