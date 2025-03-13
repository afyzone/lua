-- https://www.roblox.com/games/161766693/

local GetMyTycoon = function()
    local TycoonDropper = workspace.DropStorage:FindFirstChildWhichIsA('Model')
    local MyTycoon = TycoonDropper and workspace.Tycoons:FindFirstChild(TycoonColor.Name)

    return MyTycoon, TycoonDropper
end

local Tycoon, Dropper = GetMyTycoon()

Dropper.ChildAdded:Connect(function(drop)
    local DroppedTime = tick()

    while (tick() - DroppedTime < 10) do
        for i,v in (Tycoon.PurchasedObjects:GetChildren()) do
            local Upgrade = v:FindFirstChild('Upgrade')
            local UpgradeTouch = Upgrade and Upgrade:FindFirstChildWhichIsA('TouchTransmitter')

            if (not UpgradeTouch) then continue end

            drop.CFrame = Upgrade.CFrame
            firetouchinterest(drop, Upgrade, 0)
        end

        task.wait()
    end

    local Seller = Tycoon.Essentials.TeamColor
    drop.CFrame = Seller.CFrame
    firetouchinterest(drop, Seller, 0)
end)
