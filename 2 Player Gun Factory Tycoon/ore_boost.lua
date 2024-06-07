-- https://www.roblox.com/games/161766693/

local our_color = workspace.DropStorage:FindFirstChildWhichIsA('Model').Name
shared.afy = not shared.afy

while (shared.afy and task.wait()) do
    local ct = os.clock()

    while (os.clock() - ct < 10 and task.wait()) do 
        for i,v in (workspace.DropStorage:FindFirstChildWhichIsA('Model'):GetChildren()) do
            for i,v2 in (workspace.Tycoons[our_color].PurchasedObjects:GetChildren()) do
                if not (v2:FindFirstChild('Upgrade') and v2.Upgrade:FindFirstChildWhichIsA('TouchTransmitter')) then continue end

                v.CFrame = v2.Upgrade.CFrame
                firetouchinterest(v, v2.Upgrade, 0)
            end
        end
    end

    for i,v in (workspace.DropStorage:FindFirstChildWhichIsA('Model'):GetChildren()) do
        v.CFrame = workspace.Tycoons[our_color].Essentials.TeamColor.CFrame
        firetouchinterest(v, workspace.Tycoons[our_color].Essentials.TeamColor, 0)
    end
end
