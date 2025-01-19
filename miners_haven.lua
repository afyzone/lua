shared.afy = not shared.afy
print(shared.afy)

local players = game:GetService('Players')
local client = players.LocalPlayer
local in_progress = {}

local get_char, get_root, get_hum; do
    get_char = function(player)
        return player.Character
    end

    get_root = function(character)
        return character and character:FindFirstChild('HumanoidRootPart')
    end

    get_hum = function()
        return character and character:FindFirstChildWhichIsA('Humanoid')
    end
end

local my_tycoon = (function()
    for i,v in (workspace.Tycoons:GetChildren()) do
        if (v.Owner.Value ~= client.Name) then continue end

        return v
    end
end)()

while (shared.afy and task.wait()) do
    local char = get_char(client)
    local root = get_root(char)

    local dropped_parts = workspace.DroppedParts:FindFirstChild(my_tycoon.Name)
    
    if not (char and root) then return end

    if (dropped_parts) then
        local upgrades, sell = {}; do
            for i,v in (my_tycoon:GetChildren()) do
                if (v:FindFirstChild('Model') and v.Model:FindFirstChild('Lava')) then
                    sell = v.Model.Lava
                end
                
                if not (v:FindFirstChildWhichIsA('Model') and v:FindFirstChildWhichIsA('Model'):FindFirstChild('Upgrade')) then continue end
    
                table.insert(upgrades, v:FindFirstChildWhichIsA('Model'):FindFirstChild('Upgrade'))
            end
        end

        for i,part in (dropped_parts:GetChildren()) do
            if not (part:IsDescendantOf(workspace) or in_progress[part]) then continue end
            in_progress[part] = true

            task.spawn(function() 
                local og_cframe = part.CFrame
                for i = 1, 30 do
                    for i,upgrade in (upgrades) do
                        firetouchinterest(part, upgrade, 0)
                        firetouchinterest(part, upgrade, 1)
                        task.wait()
                    end
                end
            
                firetouchinterest(part, sell, 0)
                firetouchinterest(part, sell, 1)

                in_progress[part] = nil
            end)
        end
    end
end
